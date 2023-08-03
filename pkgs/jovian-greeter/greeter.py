# A minimal greetd greeter that runs a user's preferred session
# in $HOME/.local/state/steamos-session-select

import json
import logging
import os
import re
import socket
import struct
import subprocess
import sys
from pathlib import Path
from typing import Any, Optional, Iterable, Mapping, List

DEFAULT_SESSION = 'steam-wayland'
HELPER_PREFIX = Path('/run/current-system/sw/lib/jovian-greeter')

class Session:
    TYPE = 'tty'

    def __init__(self, name: str, path: Path):
        self.name = name
        with open(path, 'r') as f:
            self.content = f.read()

    def get_command(self) -> Optional[List[str]]:
        if command := self._get_property('Exec'):
            return command.split(' ')

        return None

    def get_environment(self) -> List[str]:
        envs = [
            f'XDG_SESSION_TYPE={self.TYPE}',
            f'XDG_SESSION_DESKTOP={self.name}',
        ]

        if desktop_names := self._get_property('DesktopNames'):
            envs.append(f'XDG_CURRENT_DESKTOP={desktop_names}')

        return envs

    def _get_property(self, property: str) -> Optional[str]:
        if matches := re.search(f'^{property}=(.*)$', self.content, re.MULTILINE):
            return matches.group(1)

        return None

class WaylandSession(Session):
    TYPE = 'wayland'

class XSession(Session):
    TYPE = 'X11'

    def get_command(self) -> Optional[List[str]]:
        if command := super().get_command():
            return [ 'startx', '/usr/bin/env' ] + command

        return None

class GreetdClient:
    def __init__(self, path: Path):
        self.client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.client.connect(str(path))

    def create_session(self, username: str):
        self._send({
            'type': 'create_session',
            'username': username,
        })
        response = self._recv()

        if response['type'] == 'success':
            return

        if response['type'] == 'auth_message':
            raise RuntimeError('Interactive authentication is not supported')

        if response['type'] == 'error':
            raise RuntimeError('Authentication failed', response)

        raise RuntimeError('Bad response', response)

    def start_session(self, command: List[str], environment: List[str]):
        # greetd before 0.9.0 doesn't support env
        command_with_env = [ 'systemd-cat', '--identifier=jovian-session', '--', '/usr/bin/env' ] + environment + command

        self._send({
            'type': 'start_session',
            'cmd': command_with_env,
            'env': environment,
        })
        response = self._recv()

        if response['type'] == 'success':
            return

        if response['type'] == 'error':
            raise RuntimeError('Failed to start session', response)

        raise RuntimeError('Bad response', response)

    def _send(self, data: dict):
        payload = bytes(json.dumps(data), encoding='utf-8')
        self.client.sendall(struct.pack('=I', len(payload)))
        self.client.sendall(payload)

    def _recv(self) -> Mapping[str, Any]:
        length = self.client.recv(4, socket.MSG_WAITALL)
        (length,) = struct.unpack('=I', length)
        payload = self.client.recv(length, socket.MSG_WAITALL)
        return json.loads(payload)

class Context:
    def __init__(self, user: str, home: Path):
        self.user = user
        self.home = home
        self.xdg_data_dirs = os.environ.get('XDG_DATA_DIRS', '').split(':')

    def next_session(self) -> Optional[Session]:
        sessions = [ DEFAULT_SESSION ]

        if next_session := self._consume_session():
            sessions = [ next_session ] + sessions

        return self._find_sessions(sessions)

    def _consume_session(self) -> Optional[str]:
        helper = HELPER_PREFIX.joinpath('consume-session')
        if helper.exists():
            logging.debug('Using pkexec helper')
            res = subprocess.run(
                ['/run/wrappers/bin/pkexec', helper, self.user],
                stdin=subprocess.DEVNULL,
                capture_output=True,
                check=True,
                env={'SHELL': '/bin/sh'}
            )
            next_session = res.stdout.decode('utf-8').strip()

            if not next_session:
                return None

            return next_session

        next_session_file = self.home.joinpath(".local/state/steamos-session-select")
        if not next_session_file.exists():
            return None

        with open(next_session_file, 'r') as f:
            next_session = f.read().strip()

        next_session_file.unlink()

        if not next_session:
            return None

        return next_session

    def _find_sessions(self, sessions: Iterable[str]) -> Optional[Session]:
        for data_dir in self.xdg_data_dirs + [ '/usr/share' ]:
            data_dir = Path(data_dir)
            for session in sessions:
                desktop_file = f'{session}.desktop'
                wayland_session = data_dir.joinpath('wayland-sessions').joinpath(desktop_file)
                x_session = data_dir.joinpath('xsessions').joinpath(desktop_file)

                if wayland_session.exists():
                    return WaylandSession(session, wayland_session)

                if x_session.exists():
                    return XSession(session, x_session)

        return None

if __name__ == '__main__':
    if len(sys.argv) != 2:
        logging.error("Usage: jovian-greeter <user>")
        sys.exit(1)

    user = sys.argv[1]
    home = os.path.expanduser(f'~{user}/')
    socket_path = os.environ.get('GREETD_SOCK')

    if not home:
        logging.error(f'Home directory for {user} not found')
        sys.exit(1)

    if not socket_path:
        logging.error("GREETD_SOCK must be set")
        sys.exit(1)

    ctx = Context(user, Path(home))

    client = GreetdClient(Path(socket_path))
    client.create_session(user)

    session = ctx.next_session()
    if not session:
        logging.error('No sessions found')
        sys.exit(1)

    logging.debug(f'Found {session.TYPE} session')
    command = session.get_command()
    environment = session.get_environment()

    if not command:
        logging.error(".desktop file doesn't contain Exec=")
        sys.exit(1)

    client.start_session(command, environment)

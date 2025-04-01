#!/usr/bin/env python3
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
from types import TracebackType
from typing import cast, override

from systemd.journal import JournalHandler

DEFAULT_SESSION = 'gamescope-wayland'

class Session:
    TYPE: str = 'tty'

    def __init__(self, name: str, path: Path):
        self.name: str = name
        with open(path, 'r') as f:
            self.content: str = f.read()

    def get_command(self) -> list[str] | None:
        if command := self._get_property('Exec'):
            return command.split(' ')

        return None

    def get_environment(self) -> list[str]:
        envs = [
            f'XDG_SESSION_TYPE={self.TYPE}',
            f'XDG_SESSION_DESKTOP={self.name}',
        ]

        if desktop_names := self._get_property('DesktopNames'):
            envs.append(f'XDG_CURRENT_DESKTOP={desktop_names}')

        return envs

    def _get_property(self, property: str) -> str | None:
        if matches := re.search(f'^{property}=(.*)$', self.content, re.MULTILINE):
            return matches.group(1)

        return None

class WaylandSession(Session):
    TYPE: str = 'wayland'

class XSession(Session):
    TYPE: str = 'x11'

    @override
    def get_command(self) -> list[str] | None:
        if command := super().get_command():
            return [ 'startx', '/usr/bin/env' ] + command

        return None

class GreetdClient:
    def __init__(self, path: Path):
        self.client: socket.socket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
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

    def start_session(self, session: Session):
        try:
            _ = subprocess.check_call(["plymouth", "quit", "--retain-splash", "--wait"])
        except Exception as ex:
            logging.debug("Failed to stop Plymouth", exc_info=ex)

        session_command = session.get_command()
        if not session_command:
            raise RuntimeError('Session does not have a command')

        command = [ 'systemd-cat', '--identifier=jovian-session', '--' ] + session_command
        environment = session.get_environment()

        logging.info("Starting session '%s'", session.name)
        logging.info("Command: %s", command)
        logging.info("Environment: %s", environment)
        self._send({
            'type': 'start_session',
            'cmd': command,
            'env': environment,
        })
        response = self._recv()

        if response['type'] == 'success':
            return

        if response['type'] == 'error':
            raise RuntimeError('Failed to start session', response)

        raise RuntimeError('Bad response', response)

    def _send(self, data: dict[str, str | list[str]]):
        payload = bytes(json.dumps(data), encoding='utf-8')
        self.client.sendall(struct.pack('=I', len(payload)))
        self.client.sendall(payload)

    def _recv(self) -> dict[str, str]:
        length_bytes = self.client.recv(4, socket.MSG_WAITALL)
        length: tuple[int] = struct.unpack('=I', length_bytes)
        payload = self.client.recv(length[0], socket.MSG_WAITALL)
        return cast(dict[str, str], json.loads(payload))

class Context:
    def __init__(self, user: str):
        self.user: str = user
        self.xdg_data_dirs: list[str] = os.environ.get('XDG_DATA_DIRS', '').split(':')

    def next_session(self) -> Session | None:
        sessions = [ DEFAULT_SESSION ]

        if next_session := self._consume_session():
            sessions = [ next_session ] + sessions

        return self._find_sessions(sessions)

    def _consume_session(self) -> str | None:
        res = subprocess.run(
            ['/run/wrappers/bin/jovian-consume-session'],
            stdin=subprocess.DEVNULL,
            capture_output=True,
            check=True,
            env={},
        )
        next_session = res.stdout.decode('utf-8').strip()

        if not next_session:
            return None

        return next_session

    def _find_sessions(self, sessions: list[str]) -> Session | None:
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

def handle_exception(exc_type: type[Exception], exc_value: Exception, exc_traceback: TracebackType):
    if issubclass(exc_type, KeyboardInterrupt):
        sys.__excepthook__(exc_type, exc_value, exc_traceback)
        return

    logging.error("Uncaught exception", exc_info=(exc_type, exc_value, exc_traceback))
    sys.exit(1)

sys.excepthook = handle_exception

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    logging.root.handlers = [
        JournalHandler(SYSLOG_IDENTIFIER="jovian-greeter")
    ]

    if len(sys.argv) != 2:
        logging.error("Usage: jovian-greeter <user>")
        sys.exit(1)

    user = sys.argv[1]
    socket_path = os.environ.get('GREETD_SOCK')

    if not socket_path:
        logging.error("GREETD_SOCK must be set")
        sys.exit(1)

    ctx = Context(user)

    client = GreetdClient(Path(socket_path))
    client.create_session(user)

    session = ctx.next_session()
    if not session:
        logging.error('No sessions found')
        sys.exit(1)

    logging.info(f'Found {session.TYPE} session')
    command = session.get_command()
    environment = session.get_environment()

    if not command:
        logging.error(".desktop file doesn't contain Exec=")
        sys.exit(1)

    client.start_session(session)

#!/usr/bin/env python
import collections
import io
import pathlib
import re
import subprocess
import tarfile

from colorama import Fore as F, Style as S
import httpx
import pyalpm
import toml


def parse_desc(desc: str):
    result = collections.defaultdict(list)
    current_tag = None
    for line in desc.splitlines():
        line = line.strip()
        if not line:
            continue
        if line.startswith("%") and line.endswith("%"):
            current_tag = line[1:-1]
        else:
            result[current_tag].append(line)
    return result


def fetch_valve_repo(name: str):
    url = f"https://steamdeck-packages.steamos.cloud/archlinux-mirror/{name}/os/x86_64/{name}.db.tar.xz"
    repo = httpx.get(url).read()

    with tarfile.open(fileobj=io.BytesIO(repo), mode="r:xz") as tf:
        for file in tf.getmembers():
            if file.name.endswith("/desc"):
                fd = tf.extractfile(file)
                assert fd
                desc = fd.read().decode()
                yield parse_desc(desc)


def max_version(this, that):
    if this is None:
        return that

    if that is None:
        return this

    if pyalpm.vercmp(this, that) < 0:
        return that
    else:
        return this


def get_latest_versions(repos: list[str]):
    result = {}
    for repo in repos:
        for pkg in fetch_valve_repo(repo):
            pkgbase = pkg['BASE'][0]
            pkgver = pkg['VERSION'][0]

            # FIXME: ugly hack
            if pkgbase == "linux-firmware-neptune":
                pkgver = pkgver.removeprefix("jupiter.")

            result[pkgbase] = max_version(result.get(pkgbase), pkgver)
    return result


def get_local_version(package: str):
    return subprocess.check_output(
        [
            "nix", "eval", 
            f".#{package}", 
            "--apply",
            'p: if p ? pkgrel then "${p.version}-${toString p.pkgrel}" else p.version',
            "--raw",
            "--option", "warn-dirty", "false"
        ],
        stderr=subprocess.DEVNULL
    ).decode()


def fixup_v_version(local: str, remote: str) -> tuple[str, str]:
    return local, remote.removeprefix('v')


def fixup_mesa_version(local: str, remote: str) -> tuple[str, str]:
    remote = re.sub(r'([\d.]+)_devel\.[\d]+\.steamos_([\d.]+)-(\d+)', r'\1.steamos-\2-\3', remote)
    return local, remote


def fixup_wireplumber_version(local: str, remote: str) -> tuple[str, str]:
    return local, remote.replace('.dev', '-dev')


HERE = pathlib.Path(__file__).parent
FIXUPS = {
    "v": fixup_v_version,
    "mesa": fixup_mesa_version,
}


def main():
    package_map = toml.load(HERE / 'mappings.toml')['packages']
    latest = get_latest_versions(['jupiter-main', 'holo-main'])

    for package in package_map:
        if package not in latest:
            print(f'{F.RED}-{F.RESET} {package}')

    for package, remote_version in sorted(latest.items()):
        if package.startswith("lib32-"):
            continue

        action = package_map.get(package, {})

        if action.get('ignore'):
            continue
        elif fixed_version := action.get('check'):
            if fixed_version != remote_version:
                print(f'{F.GREEN}!{F.RESET} {package} {S.BRIGHT}{fixed_version}{S.RESET_ALL} -> {S.BRIGHT}{remote_version}{S.RESET_ALL}')
        elif local_packages := action.get('map'):
            if local_packages is True:
                local_packages = [package]
            elif isinstance(local_packages, str):
                local_packages = [local_packages]

            pkgrel = action.get('pkgrel')
            fixup = action.get('fixup')

            for local_package in local_packages:
                local_version = get_local_version(local_package)
                if pkgrel:
                    local_version += f'-{pkgrel}'
                if fixup:
                    local_version, remote_version = FIXUPS[fixup](local_version, remote_version)

                cmp = pyalpm.vercmp(local_version, remote_version)
                if cmp < 0:
                    print(f'{F.GREEN}!{F.RESET} {local_package} {S.BRIGHT}{local_version}{S.RESET_ALL} -> {S.BRIGHT}{remote_version}{S.RESET_ALL}')
                if cmp > 0:
                    print(f'{F.BLUE}?{F.RESET} {local_package} {S.BRIGHT}{local_version}{S.RESET_ALL} -> {S.BRIGHT}{remote_version}{S.RESET_ALL}')
        else:
            print(f'{F.YELLOW}+{F.RESET} {package} {S.BRIGHT}{latest[package]}{S.RESET_ALL}')
            continue


# Run this script to generate a list of package version differences between
# our expressions and the upstream jupiter-main/holo-main repos.
#
# The output will start with "-" for removed packages, "+" for new packages,
# "!" for updates and "?" for downgrades or other version mismatches.
if __name__ == '__main__':
    main()

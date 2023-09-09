import subprocess
import string
import random
import argparse
import requests
import asyncio
import telnetlib3
from typing import *
from rich import print as rprint
from pathlib import Path


def quit(*args, **kwargs):
    exit(0)


def insert_build_id(files: List[Path]) -> Dict[Path, str]:
    replacements = {}
    key = "BUILDID"
    id = "".join([random.choice(string.ascii_lowercase) for _ in range(5)])
    for file in files:
        with open(file) as f:
            orig_content = f.read()
        if key not in orig_content:
            continue
        replacements[file] = orig_content
        new_content = orig_content.replace(
            key,
            id,
        )
        with open(file, "w") as f:
            f.write(new_content)

    return replacements


def undo_replacements(replacements: Dict[Path, str]) -> None:
    for path, orig_content in replacements.items():
        with open(path, "w") as f:
            f.write(orig_content)


def deploy_zip(dir: str):
    print("Zipping from", dir)
    zip = Path("hello-world.zip").resolve()
    zip.unlink(missing_ok=True)
    root = Path(dir)

    # Ensure the build always has some new content
    replacements = insert_build_id(root.glob("components/**/*.xml"))

    # Zip the files
    subprocess.run(
        ["zip", "-r", str(zip), "components", "images", "source", "manifest"],
        stdout=subprocess.PIPE,
        cwd=args.dir,
    )

    undo_replacements(replacements)

    requests.post(f"http://{args.tv_ip}:8060/keypress/home")

    cmd = f'curl --user {args.username}:{args.password} --digest -s -S -F "mysubmit=Install" -F "archive=@{zip}" -F "passwd=" http://{args.tv_ip}/plugin_install'

    print("Submitting to TV")
    proc = subprocess.run(
        cmd, check=True, shell=True, stdout=subprocess.PIPE, encoding="utf-8"
    )
    html = proc.stdout.strip()

    if "Application Received: Identical to previous version -- not replacing" in html:
        print("Bundle is the same, TV refused to replace it")


class Printer:
    def __init__(self):
        self.saw_start_str = False
        self.start_str = "Running dev"

    def show_line(self, line: str):
        if self.saw_start_str:
            if "Compiling dev" in line:
                rprint(f"[red]{line}[/]", flush=True)
            elif "Running dev" in line:
                rprint(f"[red]{line}[/]", flush=True)
            else:
                rprint(line, flush=True)
        else:
            if self.start_str in line:
                self.saw_start_str = True
                self.show_line(line)


async def main(args):
    async def read_until_end(reader: telnetlib3.stream_reader.TelnetReader):
        while True:
            try:
                await asyncio.wait_for(reader.read(1024), timeout=0.2)
            except asyncio.TimeoutError:
                return

    async def shell(reader: telnetlib3.stream_reader.TelnetReader, writer):
        await read_until_end(reader)
        deploy_zip(dir=args.dir)
        printer = Printer()
        while True:
            output = await reader.readline()
            printer.show_line(output.strip())

    reader, writer = await telnetlib3.open_connection(args.tv_ip, 8085, shell=shell)
    try:
        await writer.protocol.waiter_closed
    except asyncio.CancelledError:
        pass


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Upload the application to a Roku device on the LAN")
    parser.add_argument("--tv-ip", required=True, help="IP address of the Roku device")
    parser.add_argument("--username", required=True, help="Roku device username")
    parser.add_argument("--password", required=True, help="Roku device password")
    parser.add_argument("--dir", default=".", help="Directory to upload")
    args = parser.parse_args()

    try:
        asyncio.run(main(args))
    except KeyboardInterrupt:
        pass

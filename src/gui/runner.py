#!/usr/bin/env python3
"""Asynchronous command runner for executing setup.sh operations from GUI."""

import os
from pathlib import Path
import select
import signal
import subprocess
import threading
from typing import Callable, Optional

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent


class CommandRunner:
    def __init__(self):
        self._process: Optional[subprocess.Popen] = None
        self._thread: Optional[threading.Thread] = None
        self._is_cancelled: bool = False
        self._lock = threading.Lock()

    @property
    def is_running(self) -> bool:
        with self._lock:
            return self._process is not None and self._process.poll() is None

    def cancel(self) -> None:
        """Cancel the currently running process."""
        with self._lock:
            self._is_cancelled = True
            if self._process is not None and self._process.poll() is None:
                try:
                    # Kill process group if started in a new session
                    os.killpg(os.getpgid(self._process.pid), signal.SIGTERM)
                except Exception:
                    try:
                        self._process.terminate()
                    except Exception:
                        pass

    def run(
        self,
        args: list[str],
        dry_run: bool = False,
        verbose: bool = False,
        auto_yes: bool = True,
        on_output: Optional[Callable[[str], None]] = None,
        on_finish: Optional[Callable[[int], None]] = None,
    ) -> bool:
        """Start running setup.sh with args asynchronously in a worker thread."""
        if self.is_running:
            return False

        self._is_cancelled = False
        setup_script = PROJECT_ROOT / "setup.sh"

        cmd_flags = ["--cli"]  # Force terminal execution in child process
        if dry_run:
            cmd_flags.append("--dry-run")
        if verbose:
            cmd_flags.append("-v")
        if auto_yes:
            cmd_flags.append("-y")

        full_script_args = cmd_flags + args

        # Determine privilege escalation
        is_root = (os.geteuid() == 0)
        final_cmd: list[str] = []

        if is_root or dry_run:
            final_cmd = ["bash", str(setup_script)] + full_script_args
        else:
            # Need privilege elevation
            has_pkexec = (subprocess.run(["which", "pkexec"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0)
            if has_pkexec:
                display = os.environ.get("DISPLAY", ":0")
                xauth = os.environ.get("XAUTHORITY", str(Path.home() / ".Xauthority"))
                final_cmd = [
                    "pkexec",
                    "env",
                    f"DISPLAY={display}",
                    f"XAUTHORITY={xauth}",
                    "bash",
                    str(setup_script),
                ] + full_script_args
            else:
                final_cmd = ["sudo", "-E", "bash", str(setup_script)] + full_script_args

        def worker():
            env = os.environ.copy()
            if dry_run:
                env["DRY_RUN"] = "true"
            if verbose:
                env["VERBOSE_MODE"] = "true"
            env["PYTHONUNBUFFERED"] = "1"

            if on_output:
                cmd_display = " ".join(final_cmd)
                on_output(f"\x1b[1;35m>>> Starting:\x1b[0m {cmd_display}\n")

            return_code = 1
            try:
                with self._lock:
                    self._process = subprocess.Popen(
                        final_cmd,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.STDOUT,
                        text=True,
                        bufsize=1,
                        preexec_fn=os.setsid,
                        env=env,
                    )

                if self._process.stdout:
                    for line in iter(self._process.stdout.readline, ""):
                        if on_output:
                            on_output(line)
                        if self._is_cancelled:
                            break

                self._process.wait()
                return_code = self._process.returncode

                if self._is_cancelled:
                    if on_output:
                        on_output("\n\x1b[1;31m[CANCELLED] Operation stopped by user.\x1b[0m\n")
                    return_code = 130
                else:
                    if on_output:
                        if return_code == 0:
                            on_output(f"\n\x1b[1;32m[COMPLETED] Operation finished successfully.\x1b[0m\n")
                        else:
                            on_output(f"\n\x1b[1;31m[FAILED] Process exited with code {return_code}.\x1b[0m\n")

            except Exception as e:
                if on_output:
                    on_output(f"\n\x1b[1;31m[ERROR] Failed to run command: {e}\x1b[0m\n")
                return_code = 1
            finally:
                with self._lock:
                    self._process = None
                if on_finish:
                    on_finish(return_code)

        self._thread = threading.Thread(target=worker, daemon=True)
        self._thread.start()
        return True

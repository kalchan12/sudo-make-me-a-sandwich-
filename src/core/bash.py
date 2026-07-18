import subprocess
import os
from .logging import DRY_RUN, VERBOSE_MODE

API_SCRIPT = ""


def setup(script_dir: str) -> None:
    global API_SCRIPT
    API_SCRIPT = os.path.join(script_dir, "core", "python_api.sh")


def call(func: str, *args: str) -> tuple[int, str, str]:
    env = os.environ.copy()
    env["YES_MODE"] = "true"  # Python handles confirmation, bash just executes
    cmd = ["bash", API_SCRIPT, func] + list(args)
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=600, env=env)
    return result.returncode, result.stdout, result.stderr


def run(cmd: str) -> tuple[int, str, str]:
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=600, shell=True)
    return result.returncode, result.stdout, result.stderr

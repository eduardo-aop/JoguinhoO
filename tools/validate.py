#!/usr/bin/env python3
"""Run the Godot regression suite, preserving logs and rejecting script errors."""
import argparse
import datetime
import json
from pathlib import Path
import re
import subprocess
import sys

TESTS = ("brawler", "suite", "polish", "control", "tactical_camera", "input_and_stress", "attack_timing",
         "effects", "tactics", "telemetry", "dash_timing", "hitbox")


def classify_errors(output):
    unexpected, environment = [], []
    lines = output.splitlines()
    for index, line in enumerate(lines):
        if not (line.startswith(("ERROR:", "SCRIPT ERROR:")) or "instances leaked at exit" in line):
            continue
        expected = line.startswith("ERROR: Failed to open 'user://logs/") or line == "ERROR: Failed to open log file for writing: user://logs/godot.log"
        if line == 'ERROR: Condition "ret != noErr" is true. Returning: ""':
            expected = index + 1 < len(lines) and "get_system_ca_certificates" in lines[index + 1]
        (environment if expected else unexpected).append(line)
    return unexpected, environment


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot", help="Godot executable path")
    parser.add_argument("--output", required=True, type=Path, help="Directory for logs and report")
    parser.add_argument("--timeout", type=int, default=300, help="Seconds allowed per test")
    args = parser.parse_args()
    project = Path(__file__).resolve().parents[1]
    args.output.mkdir(parents=True, exist_ok=True)
    report = {"generated_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
              "project": str(project), "tests": [], "checks": 0, "passed": True}
    for name in TESTS:
        command = [args.godot, "--headless", "--path", str(project),
                   "--fixed-fps", "60", "--script", f"tests/{name}.gd"]
        try:
            result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                    timeout=args.timeout, text=True, check=False)
            output, code = result.stdout, result.returncode
        except subprocess.TimeoutExpired as error:
            raw = error.stdout or b""
            output = raw.decode(errors="replace") if isinstance(raw, bytes) else raw
            output += "\nVALIDATOR_TIMEOUT\n"
            code = -1
        except OSError as error:
            output, code = str(error), -1
        (args.output / f"{name}.log").write_text(output)
        summary = re.search(r"\w+_COMPLETE checks=(\d+) failures=(\d+)", output)
        script_errors = bool(re.search(r"SCRIPT ERROR:|Parse Error:|Failed to load script", output))
        unexpected_errors, environment_warnings = classify_errors(output)
        checks, failures = map(int, summary.groups()) if summary else (0, 0)
        passed = code == 0 and summary is not None and checks > 0 and failures == 0 and not script_errors and not unexpected_errors
        report["tests"].append({"name": name, "checks": checks, "failures": failures,
                                "exit_code": code, "script_errors": script_errors,
                                "unexpected_errors": unexpected_errors,
                                "environment_warnings": environment_warnings, "passed": passed})
        report["checks"] += checks
        report["passed"] = report["passed"] and passed
        print(f"{'PASS' if passed else 'FAIL'} {name}: {checks} checks", flush=True)
    (args.output / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())

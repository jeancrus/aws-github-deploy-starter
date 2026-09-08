#!/usr/bin/env python3
"""Fetch SSM parameters into a private Compose override (outside the git checkout).

Copy into your backend as scripts/production/sync_config.py and adapt:
  - SSM_PREFIX
  - SECRETS (must be SecureString in SSM)
  - compose_config() service/env mapping for your stack

JSON avoids dotenv/shell quoting; $$ prevents Compose expanding dollars in secrets.
Never log parameter values.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import tempfile
from pathlib import Path

DEFAULTS = Path(__file__).with_name("defaults.json")
SSM_PREFIX = "/<PROJECT>/production/"
SECRETS = {
    "POSTGRES_PASSWORD",
    # "JWT_ACCESS_SECRET",
    # "JWT_REFRESH_SECRET",
}


def compose_config(parameters: list[dict]) -> dict:
    defaults = json.loads(DEFAULTS.read_text(encoding="utf-8"))
    values = {**defaults, **dict.fromkeys(SECRETS, "")}
    seen: set[str] = set()
    for item in parameters:
        name = item["Name"]
        if not name.startswith(SSM_PREFIX):
            raise ValueError(f"Unexpected SSM name: {name}")
        key = name.removeprefix(SSM_PREFIX)
        if key not in values or key in seen:
            raise ValueError(f"Unknown or duplicate SSM key: {key}")
        if key in SECRETS and item.get("Type") != "SecureString":
            raise ValueError(f"{key} must be SecureString")
        value = item["Value"]
        if not value or "SUBSTITUA_" in value or any(c in value for c in "\r\n\x00"):
            raise ValueError(f"Invalid value for {key}")
        seen.add(key)
        values[key] = value

    for key in SECRETS:
        if not values.get(key):
            raise ValueError(f"Missing {key}")

    # Example mapping: adjust services to match docker-compose.prod.yml
    postgres_keys = ("POSTGRES_DB", "POSTGRES_USER", "POSTGRES_PASSWORD")
    postgres = {key: values.pop(key) for key in postgres_keys if key in values}
    api_env = {key: value.replace("$", "$$") for key, value in values.items()}
    services: dict = {"api": {"environment": api_env}}
    if postgres:
        services["postgres"] = {
            "environment": {key: value.replace("$", "$$") for key, value in postgres.items()}
        }
    return {"services": services}


def write_atomic(path: Path, config: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(dir=path.parent, prefix=".config-")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as output:
            json.dump(config, output)
            output.flush()
            os.fsync(output.fileno())
        os.replace(temporary, path)
        os.chmod(path, 0o600)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def fetch_parameters(region: str) -> list[dict]:
    raw = subprocess.check_output(
        [
            "aws",
            "ssm",
            "get-parameters-by-path",
            "--path",
            SSM_PREFIX.rstrip("/"),
            "--recursive",
            "--with-decryption",
            "--region",
            region,
            "--output",
            "json",
        ],
        text=True,
    )
    return json.loads(raw)["Parameters"]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--region", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    config = compose_config(fetch_parameters(args.region))
    write_atomic(Path(args.output), config)
    # Log only counts — never values
    print(f"Wrote Compose override with {len(config.get('services', {}))} services.")


if __name__ == "__main__":
    main()

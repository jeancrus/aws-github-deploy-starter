#!/usr/bin/env python3
"""Validate PRODUCTION_CONFIG_JSON / PRODUCTION_SECRETS_JSON without printing values."""

from __future__ import annotations

import json
import os
import sys


def main() -> int:
    secrets_raw = os.environ.get("TF_VAR_secrets", "")
    config_raw = os.environ.get("TF_VAR_configuration", "{}")
    if not secrets_raw.strip():
        print("TF_VAR_secrets is empty", file=sys.stderr)
        return 1
    try:
        secrets = json.loads(secrets_raw)
        config = json.loads(config_raw)
    except json.JSONDecodeError as exc:
        print(f"Invalid JSON: {exc}", file=sys.stderr)
        return 1
    if not isinstance(secrets, dict) or not isinstance(config, dict):
        print("Expected JSON objects", file=sys.stderr)
        return 1
    for key, value in {**config, **secrets}.items():
        if isinstance(value, str) and "SUBSTITUA_" in value:
            print(f"Placeholder left in {key}", file=sys.stderr)
            return 1
    print(f"Inputs OK ({len(config)} config keys, {len(secrets)} secret keys).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

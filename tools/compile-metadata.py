#!/usr/bin/env python3
"""
JIT Metadata Compiler for AI-Assisted Infrastructure Operations Platform.
Dynamically introspects docker-compose stacks and generates a unified,
machine-readable service-catalog.json without manual YAML documentation drift.
"""

import json
import os
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("❌ PyYAML is required. Run: pip install pyyaml", file=sys.stderr)
    sys.exit(1)


def parse_compose_file(compose_path: Path) -> dict:
    try:
        with open(compose_path, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
    except Exception as e:
        print(f"⚠️ Warning: Failed to parse {compose_path}: {e}", file=sys.stderr)
        return {}

    if not isinstance(data, dict):
        return {}

    services = data.get("services", {})
    parsed_services = {}

    for s_name, s_conf in services.items():
        if not isinstance(s_conf, dict):
            continue

        parsed_services[s_name] = {
            "image": s_conf.get("image", "custom-build"),
            "restart": s_conf.get("restart", "no"),
            "ports": s_conf.get("ports", []),
            "networks": list(s_conf.get("networks", []))
            if isinstance(s_conf.get("networks"), (list, dict))
            else [],
            "volumes_count": len(s_conf.get("volumes", [])),
            "environment_keys": [
                k.split("=")[0]
                for k in s_conf.get("environment", [])
                if isinstance(k, str)
            ]
            if isinstance(s_conf.get("environment"), list)
            else list(s_conf.get("environment", {}).keys()),
        }

    return parsed_services


def main():
    repo_root = Path(__file__).resolve().parent.parent
    docker_dir = repo_root / "Docker"
    output_dir = repo_root / "metadata"
    output_file = output_dir / "service-catalog.json"

    if not docker_dir.exists():
        print(f"❌ Error: Docker directory not found at {docker_dir}", file=sys.stderr)
        sys.exit(1)

    catalog = {
        "version": "1.0.0",
        "description": "Dynamic JIT Service Catalog compiled from active compose blueprints",
        "total_stacks": 0,
        "total_services": 0,
        "stacks": {},
    }

    for stack_path in sorted(docker_dir.iterdir()):
        if not stack_path.is_dir():
            continue

        compose_file = None
        for candidate in ["docker-compose.yml", "docker-compose.yaml", "compose.yml"]:
            p = stack_path / candidate
            if p.exists():
                compose_file = p
                break

        if not compose_file:
            continue

        stack_name = stack_path.name
        services = parse_compose_file(compose_file)

        catalog["stacks"][stack_name] = {
            "path": str(compose_file.relative_to(repo_root)),
            "services": services,
        }
        catalog["total_stacks"] += 1
        catalog["total_services"] += len(services)

    output_dir.mkdir(parents=True, exist_ok=True)
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(catalog, f, indent=2)

    print(
        f"✅ Successfully compiled {catalog['total_services']} services across {catalog['total_stacks']} stacks into {output_file.relative_to(repo_root)}"
    )


if __name__ == "__main__":
    main()

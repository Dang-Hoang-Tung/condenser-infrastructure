#!/usr/bin/env python3

import json
import subprocess
import argparse
import os
import sys
from dataclasses import dataclass

# Terraform output variables - keep in sync!
TERRAFORM_DIRECTORY = "infrastructure"
TERRAFORM_ANSIBLE_KEY = "ansible_inventory"

@dataclass
class AnsibleHost(dict):
    """
    An Ansible host expected from Terraform output
    """
    name: str
    group: str
    ip: str

def get_terraform_ansible_output() -> list[AnsibleHost]:
    working_dir = os.getcwd()
    current_script_dir = os.path.dirname(os.path.abspath(__file__))

    try:
        os.chdir(f"{current_script_dir}/../{TERRAFORM_DIRECTORY}")
        result = subprocess.run(['terraform', 'output', '--json', TERRAFORM_ANSIBLE_KEY], capture_output=True, encoding='UTF-8')
        terraform_output = json.loads(result.stdout)
        ansible_hosts: list[AnsibleHost] = []
        for item in terraform_output:
            name, group, ips = item['name'], item['group'], item['ips']
            if len(ips) == 1:
                ansible_hosts.append(AnsibleHost(name, group, ips[0]))
            else:
                ansible_hosts.extend([AnsibleHost(name, group, ip) for ip in ips])
        return ansible_hosts
    except subprocess.CalledProcessError as e:
        print(f"Error executing Terraform: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        sys.exit(1)
    finally:
        os.chdir(working_dir)

def generate_inventory():
    tf_ansible_output = get_terraform_ansible_output()

    _jd = {
        # Metadata
        "_meta": { "hostvars": {} },
        "all": { "children": [] },
        "ungrouped": { "hosts": [] },
    }

    for item in tf_ansible_output:
        # Map host name to IP address in hostvars object
        _jd.hostvars[item.name] = { "ansible_host": item.ip }
        # Add host to group
        if item.group not in _jd:
            _jd[item.group] = { "hosts": [] }
            _jd.all.children.append(item.group)
        _jd[item.group].hosts.append(item.name)

    jd = json.dumps(_jd, indent=4)
    return jd

if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description = "Generate a cluster inventory from Terraform.",
        prog = __file__
    )

    mo = ap.add_mutually_exclusive_group()
    mo.add_argument("--list",action="store", nargs="*", default="dummy", help="Show JSON of all managed hosts")
    mo.add_argument("--host",action="store", help="Display vars related to the host")
    mo.add_argument("--test",action="store_true", help="Run test and print")

    args = ap.parse_args()

    if args.host:
        print(json.dumps({}))
    elif len(args.list) >= 0:
        jd = generate_inventory()
        print(jd)
    else:
        raise ValueError("Expecting either --host $HOSTNAME or --list")

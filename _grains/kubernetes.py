import salt.modules.cmdmod
import re
from salt.exceptions import CommandExecutionError


def main():
    grains = {}
    try:
        raw_k8s_ver = salt.modules.cmdmod._run_quiet('hyperkube --version')
        ver = re.search('(v[0-9.-]+)', raw_k8s_ver)
        if ver:
            grains['kubernetes_version'] = ver.group(1)
    except CommandExecutionError:
        pass
    return grains

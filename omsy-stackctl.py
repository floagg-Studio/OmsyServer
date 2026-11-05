#!/usr/bin/env python3
import json, os, re, shlex, signal, subprocess, sys, time

ROOT = os.environ.get("ROOT_PATH", os.path.dirname(os.path.abspath(__file__)))
BIN = os.path.join(ROOT, "sys/bin")

# Dossier des logs (repli sur /tmp si impossible à créer)
LOG_DIR = os.path.join(ROOT, "share/log")
try:
    os.makedirs(LOG_DIR, exist_ok=True)
except OSError:
    LOG_DIR = "/tmp"

START_CHECK_DELAY = 4  # secondes d'attente avant de vérifier que le service tourne


def resolve(arg):
    return os.path.expandvars(arg.replace("${root_path}", ROOT))


def build(cmd):
    """Retourne (commande, shell) prête pour subprocess."""
    shell = any("$(" in a for a in cmd)
    if shell:
        cmd = " ".join(a if "$(" in a else shlex.quote(a) for a in cmd)
    return cmd, shell


def show(cmd, shell):
    print("  $", cmd if shell else " ".join(shlex.quote(a) for a in cmd))


def run(cmd, wait=True):
    """Exécute une commande et attend sa fin (utilisé pour l'arrêt)."""
    cmd, shell = build(cmd)
    show(cmd, shell)
    r = subprocess.run(cmd, shell=shell, stdin=subprocess.DEVNULL,
                       capture_output=True, text=True, cwd=BIN)
    prog = os.path.basename(cmd.split()[0] if shell else cmd[0])
    # pkill/pgrep renvoient 1 quand rien ne correspond : pas une erreur
    if r.returncode != 0 and not (prog in ("pkill", "pgrep") and r.returncode == 1):
        print(f"  ! code {r.returncode} : {(r.stderr or r.stdout).strip()}")
        return False
    return True


def launch(cmd, log_path):
    """Lance une commande en arrière-plan, sortie redirigée vers un log."""
    cmd, shell = build(cmd)
    show(cmd, shell)
    log = open(log_path, "ab")
    log.write(f"\n=== {time.strftime('%Y-%m-%d %H:%M:%S')} ===\n".encode())
    log.write(f"ROOT={ROOT}\nCMD={cmd}\n\n".encode())
    log.flush()
    return subprocess.Popen(cmd, shell=shell, stdin=subprocess.DEVNULL,
                            stdout=log, stderr=log,
                            start_new_session=True, cwd=BIN)


def find_pids(binpath):
    r = subprocess.run(["pgrep", "-f", f"^{re.escape(binpath)}( |$)"],
                       capture_output=True, text=True)
    return [int(p) for p in r.stdout.split()]


def wait_gone(binpath, timeout):
    end = time.time() + timeout
    while time.time() < end:
        if not find_pids(binpath):
            return True
        time.sleep(0.3)
    return not find_pids(binpath)


def tail(path, n=15):
    try:
        with open(path, "r", errors="replace") as f:
            return "".join(f.readlines()[-n:]).rstrip()
    except OSError:
        return ""


def start(slug, info):
    label = info.get("label", slug)
    if not info.get("start"):
        return print(f"{label} : pas de commande de démarrage")

    cmd = [resolve(a) for a in info["start"]]
    binpath = cmd[0]

    if not os.path.exists(binpath):
        return print(f"{label} : ÉCHEC, exécutable introuvable : {binpath}\n"
                     f"  (ROOT = {ROOT})")

    if find_pids(binpath):
        return print(f"{label} : déjà en cours d'exécution")

    log_path = os.path.join(LOG_DIR, f"omsy-{slug}.log")
    proc = launch(cmd, log_path)

    # Vérification : le processus doit encore être vivant après un court délai
    time.sleep(START_CHECK_DELAY)
    code = proc.poll()

    if code is None:
        print(f"{label} : lancé (pid {proc.pid})")
    elif code == 0 and find_pids(binpath):
        print(f"{label} : lancé")  # lanceur qui s'est détaché proprement
    else:
        print(f"{label} : ÉCHEC (le processus s'est arrêté, code {code})")
        out = tail(log_path)
        if out:
            print("  --- dernières lignes du log ---")
            print("  " + out.replace("\n", "\n  "))
        print(f"  Log complet : {log_path}")


def stop(slug, info):
    label = info.get("label", slug)
    if not info.get("stop"):
        return print(f"{label} : pas de commande d'arrêt")
    for cmd in info["stop"]:
        run([resolve(a) for a in cmd], wait=True)

    # Filet de sécurité : si le programme tourne encore, SIGTERM (arrêt propre)
    binpath = resolve(info["start"][0]) if info.get("start") else None
    if binpath:
        if not wait_gone(binpath, 3):
            for pid in find_pids(binpath):
                print(f"  → encore actif (pid {pid}), envoi de SIGTERM")
                try:
                    os.kill(pid, signal.SIGTERM)
                except ProcessLookupError:
                    pass
            if not wait_gone(binpath, 15):
                return print(f"{label} : toujours actif après 15 s")
    print(f"{label} : arrêté")


if __name__ == "__main__":
    if len(sys.argv) < 4 or sys.argv[2] not in ("start", "stop"):
        sys.exit("Usage : omsy-stackctl.py appstore.json start|stop service1 [service2 ...]")
    print(f"ROOT = {ROOT}")
    with open(sys.argv[1]) as f:
        services = json.load(f)
    action = start if sys.argv[2] == "start" else stop
    for slug in sys.argv[3:]:
        if slug in services:
            action(slug, services[slug])
        else:
            print(f"{slug} : inconnu")
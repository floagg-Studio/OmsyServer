#!/usr/bin/env python3
import json, os, re, shlex, signal, subprocess, sys, time

ROOT = os.environ.get("ROOT_PATH", os.path.dirname(os.path.abspath(__file__)))
BIN = os.path.join(ROOT, "sys/bin")

def resolve(arg):
	return os.path.expandvars(arg.replace("${root_path}", ROOT))

def run(cmd, wait=False):
	shell = any("$(" in a for a in cmd)
	if shell:
		cmd = " ".join(a if "$(" in a else shlex.quote(a) for a in cmd)
	print("  $", cmd if shell else " ".join(shlex.quote(a) for a in cmd))

	if wait:
		r = subprocess.run(cmd, shell=shell, stdin=subprocess.DEVNULL,
			capture_output=True, text=True, cwd=BIN)
		prog = os.path.basename(cmd.split()[0] if shell else cmd[0])
		# pkill/pgrep renvoient 1 quand rien ne correspond : pas une erreur
		if r.returncode != 0 and not (prog in ("pkill", "pgrep") and r.returncode == 1):
			print(f"  ! code {r.returncode} : {(r.stderr or r.stdout).strip()}")
			return False
		return True

	subprocess.Popen(cmd, shell=shell, stdin=subprocess.DEVNULL,
		stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
		start_new_session=True, cwd=BIN)
	return True

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

def start(slug, info):
	if not info.get("start"):
		return print(f"{info['label']} : pas de commande de démarrage")
	run([resolve(a) for a in info["start"]])
	print(f"{info['label']} : lancé")
	
def stop(slug, info):
	if not info.get("stop"):
		return print(f"{info['label']} : pas de commande d'arrêt")
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
				return print(f"{info['label']} : toujours actif après 15 s")
	print(f"{info['label']} : arrêté")

if __name__ == "__main__":
	if len(sys.argv) < 4 or sys.argv[2] not in ("start", "stop"):
		sys.exit("Usage : service.py services.json start|stop service1 [service2 ...]")
	with open(sys.argv[1]) as f:
		services = json.load(f)
	action = start if sys.argv[2] == "start" else stop
	for slug in sys.argv[3:]:
		if slug in services:
			action(slug, services[slug])
		else:
			print(f"{slug} : inconnu")
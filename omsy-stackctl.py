#!/usr/bin/env python3
import json, os, subprocess, sys

ROOT = os.environ.get("ROOT_PATH", os.path.dirname(os.path.abspath(__file__)))
BIN = os.path.join(ROOT, "sys/bin")

def resolve(arg):
	return os.path.expandvars(arg.replace("${root_path}", ROOT))

def run(cmd, wait=False):
	# Les commandes du JSON contenant $(...) ont besoin d'un shell
	shell = any("$(" in a for a in cmd)
	cmd = " ".join(cmd) if shell else cmd
	print(cmd)
	p = subprocess.Popen(cmd, shell=shell, stdin=subprocess.DEVNULL,
		stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
		start_new_session=True, cwd=BIN)
	if wait:
		p.wait()

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
	print(f"{info['label']} : arrêt demandé")

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
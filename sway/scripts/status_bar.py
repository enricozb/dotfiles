#!/usr/bin/python

import signal
import time

from subprocess import run, CalledProcessError, PIPE
from threading import Lock


def cmd(cmd, shell=False, none_on_err=True):
    proc = run(cmd, shell=shell, stdout=PIPE, stderr=PIPE, encoding="utf-8")
    if not none_on_err or proc.returncode == 0:
        return proc.stdout.strip()


def handle_usr_signal(signum, frame):
    """ Reprints on user signal """
    print_status()


def volume():
    return cmd(["pamixer", "--get-volume-human"], none_on_err=False)


def playerctl():
    try:
        playerctl_status = cmd(["playerctl", "-a", "status"])
    except CalledProcessError:
        playerctl_status = "Stopped"

    if playerctl_status is None:
        return None

    if "Playing" in playerctl_status:
        playerctl_status = "Playing"
        artist = cmd(["playerctl", "metadata", "artist"])
        title = cmd(["playerctl", "metadata", "title"])
        return f"[{artist}]: {title}"

    if playerctl_status != "Stopped":
        return "Paused"

    return playerctl_status


def date():
    return cmd(["date", "+%A  %Y-%m-%d %l:%M:%S %p"])


def battery():
    for prefix in ["charge", "energy"]:
        status = cmd(["cat", "/sys/class/power_supply/BAT0/status"])
        now = cmd(["cat", f"/sys/class/power_supply/BAT0/energy_now"])
        full = cmd(["cat", f"/sys/class/power_supply/BAT0/energy_full"])
        if None in (now, full):
            return

    if status == "Charging":
        return f"{100 * int(now) / int(full):0.1f}% [chrg]"
    else:
        return f"{100 * int(now) / int(full):0.1f}%"


last_print_time = 0
def print_status():
    global last_print_time
    start_time = time.time()
    items = [playerctl(), volume(), battery(), date()]
    items = [item for item in items if item is not None]
    if last_print_time < start_time:
        last_print_time = start_time
        print(" · ".join(items) + " ", flush=True)


def main():
    signal.signal(signal.SIGUSR1, handle_usr_signal)
    while True:
        print_status()
        time.sleep(1)


if __name__ == "__main__":
    main()

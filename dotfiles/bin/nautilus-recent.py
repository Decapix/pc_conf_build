#!/usr/bin/env python3
"""Keep the last N folders visited in Nautilus as sidebar bookmarks.

Nautilus publishes the location of every open window on D-Bus
(org.freedesktop.FileManager1.OpenWindowsWithLocations). We listen for
changes, keep an MRU list, and rewrite the GTK bookmarks file: the user's own
bookmarks stay untouched, ours are appended with a "🕘 " label prefix.
"""
import os
import sys
from urllib.parse import unquote, urlparse

from gi.repository import Gio, GLib

MAX_RECENT = int(os.environ.get("NAUTILUS_RECENT_MAX", "5"))
PREFIX = "🕘 "
BOOKMARKS = os.path.expanduser("~/.config/gtk-3.0/bookmarks")
STATE_DIR = os.path.join(GLib.get_user_state_dir(), "nautilus-recent")
STATE = os.path.join(STATE_DIR, "recent")  # one URI per line, newest first
HOME_URI = Gio.File.new_for_path(os.path.expanduser("~")).get_uri()

windows = {}  # window object path -> set of URIs shown in it
recent = []


def path_of(uri):
    return unquote(urlparse(uri).path)


def load_state():
    try:
        with open(STATE) as f:
            return [l.strip() for l in f if l.strip()][:MAX_RECENT]
    except FileNotFoundError:
        return []


def save_state():
    os.makedirs(STATE_DIR, exist_ok=True)
    with open(STATE, "w") as f:
        f.write("".join(u + "\n" for u in recent))


def is_ours(line):
    parts = line.split(" ", 1)
    return len(parts) == 2 and parts[1].startswith(PREFIX)


def write_bookmarks():
    try:
        with open(BOOKMARKS) as f:
            lines = f.read().splitlines()
    except FileNotFoundError:
        lines = []
    user = [l for l in lines if l.strip() and not is_ours(l)]
    user_uris = {l.split(" ", 1)[0].rstrip("/") for l in user}
    ours = [
        f"{u} {PREFIX}{os.path.basename(path_of(u).rstrip('/')) or '/'}"
        for u in recent
        if u.rstrip("/") not in user_uris and os.path.isdir(path_of(u))
    ]
    new = user + ours
    if new == lines:
        return
    os.makedirs(os.path.dirname(BOOKMARKS), exist_ok=True)
    tmp = BOOKMARKS + ".tmp"
    with open(tmp, "w") as f:
        f.write("".join(l + "\n" for l in new))
    os.replace(tmp, BOOKMARKS)


def visit(uri):
    global recent
    if not uri.startswith("file://") or uri.rstrip("/") == HOME_URI.rstrip("/"):
        return
    recent = [uri] + [u for u in recent if u != uri]
    recent = recent[:MAX_RECENT]
    save_state()
    write_bookmarks()


def on_windows(value):
    global windows
    current = {w: set(locs) for w, locs in value.items()}
    for w, locs in current.items():
        for uri in locs - windows.get(w, set()):
            visit(uri)
    windows = current


def on_signal(conn, sender, path, iface, signal, params):
    _, changed, _ = params.unpack()
    if "OpenWindowsWithLocations" in changed:
        on_windows(changed["OpenWindowsWithLocations"])


def main():
    global recent
    recent = load_state()
    write_bookmarks()
    bus = Gio.bus_get_sync(Gio.BusType.SESSION)
    bus.signal_subscribe(
        "org.freedesktop.FileManager1",
        "org.freedesktop.DBus.Properties",
        "PropertiesChanged",
        "/org/freedesktop/FileManager1",
        None,
        Gio.DBusSignalFlags.NONE,
        on_signal,
    )
    # Seed with windows already open so they don't count as fresh visits.
    try:
        res = bus.call_sync(
            "org.freedesktop.FileManager1", "/org/freedesktop/FileManager1",
            "org.freedesktop.DBus.Properties", "Get",
            GLib.Variant("(ss)", ("org.freedesktop.FileManager1", "OpenWindowsWithLocations")),
            None, Gio.DBusCallFlags.NO_AUTO_START, -1, None,
        )
        windows.update({w: set(l) for w, l in res.unpack()[0].items()})
    except GLib.Error:
        pass  # Nautilus not running yet
    GLib.MainLoop().run()


if __name__ == "__main__":
    sys.exit(main())

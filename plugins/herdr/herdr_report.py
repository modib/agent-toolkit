#!/usr/bin/env python3
"""
Herdr agent state reporter for goose.
Reports goose agent state to herdr via Unix socket API.

HERDR_INTEGRATION_ID=goose
HERDR_INTEGRATION_VERSION=1
"""

import os
import sys
import json
import socket
import time
import random
import fcntl
import struct

SOURCE = "herdr:goose"
_report_seq = int(time.time() * 1000)

def _next_seq():
    global _report_seq
    _report_seq += 1
    return _report_seq

def _get_socket_path():
    path = os.environ.get("HERDR_SOCKET_PATH")
    if path:
        return path
    
    xdg_runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    default_paths = [
        os.path.join(xdg_runtime, "herdr", "default.sock"),
        os.path.expanduser("~/.config/herdr/herdr.sock"),
    ]
    for p in default_paths:
        if os.path.exists(p):
            return p
    return None

def _get_pane_id():
    pane_id = os.environ.get("HERDR_PANE_ID")
    if pane_id:
        return pane_id
    
    try:
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        socket_path = _get_socket_path()
        if not socket_path:
            return None
        
        creds = struct.pack('iII', os.getpid(), os.getuid(), os.getgid())
        s.setsockopt(socket.SOL_SOCKET, socket.SO_PASSCRED, 1)
        s.connect(socket_path)
        
        request_id = f"{SOURCE}:{time.time()}:{random.randint(0, 999999):06d}"
        req = {
            "id": request_id,
            "method": "server.whoami",
            "params": {}
        }
        s.sendall((json.dumps(req) + "\n").encode())
        s.settimeout(0.5)
        data = b""
        while True:
            chunk = s.recv(4096)
            if not chunk:
                break
            data += chunk
            if b"\n" in data:
                break
        s.close()
        
        if data:
            resp = json.loads(data.split(b"\n")[0].decode())
            result = resp.get("result", {})
            if isinstance(result, dict) and "pane_id" in result:
                return result["pane_id"]
    except Exception:
        pass
    return None

def is_herdr_env():
    if os.environ.get("HERDR_ENV") == "1":
        return True
    if os.environ.get("HERDR_SOCKET_PATH") and os.environ.get("HERDR_PANE_ID"):
        return True
    return False

def report_state(state):
    if state not in ("working", "blocked", "idle", "done", "release"):
        raise ValueError(f"Invalid state: {state}")
    
    pane_id = _get_pane_id()
    socket_path = _get_socket_path()
    
    if not pane_id or not socket_path:
        return False
    
    request_id = f"{SOURCE}:{time.time()}:{random.randint(0, 999999):06d}"
    
    if state == "release":
        method = "pane.release_agent"
        params = {
            "pane_id": pane_id,
            "source": SOURCE,
            "agent": "goose",
            "seq": _next_seq(),
        }
    else:
        method = "pane.report_agent"
        params = {
            "pane_id": pane_id,
            "source": SOURCE,
            "agent": "goose",
            "state": state,
            "seq": _next_seq(),
        }
    
    request = {
        "id": request_id,
        "method": method,
        "params": params,
    }
    
    try:
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.settimeout(0.5)
        s.connect(socket_path)
        s.sendall((json.dumps(request) + "\n").encode())
        
        try:
            data = s.recv(4096)
        except socket.timeout:
            pass
        s.close()
        return True
    except Exception:
        return False

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <working|blocked|idle|done|release|check>")
        sys.exit(1)
    
    cmd = sys.argv[1]
    
    if cmd == "check":
        if is_herdr_env():
            print("Running inside herdr")
            socket_path = _get_socket_path()
            pane_id = _get_pane_id()
            print(f"  Socket: {socket_path}")
            print(f"  Pane ID: {pane_id}")
            sys.exit(0)
        else:
            print("Not running inside herdr")
            sys.exit(1)
    
    if not is_herdr_env():
        sys.exit(0)
    
    if report_state(cmd):
        print(f"Reported state: {cmd}")
    else:
        print(f"Failed to report state: {cmd}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Generate the In a Pickle design-wireframe scenes (nested-square style).

One or two phone frames per scene, drawn as nested coloured squares with black
borders, default excalidraw styles. Labels are 1-2 short lines bound to their
blocks so the geometry/legibility gate can measure them.

Outputs docs/design/*.excalidraw
"""

from pathlib import Path

DARK = "#1e1e1e"
GREY = "#e9ecef"
GREEN = "#b2f2bb"
BLUE = "#a5d8ff"
YELLOW = "#ffec99"
RED = "#ffc9c9"

_now = 1757600000000
_seed = [0]
_nonce = [0]


def stats():
    _seed[0] += 1
    _nonce[0] += 1
    return _seed[0] * 1000 + 1, _nonce[0] + 1


def base(kind, x, y, w, h):
    seed, nonce = stats()
    return {
        "id": None, "type": kind, "x": x, "y": y, "width": w, "height": h,
        "index": f"a{_nonce[0]:04x}",
        "angle": 0, "strokeColor": DARK, "backgroundColor": "transparent",
        "fillStyle": "solid", "strokeWidth": 2, "strokeStyle": "solid",
        "roughness": 1, "opacity": 100, "groupIds": [], "frameId": None,
        "roundness": None, "seed": seed, "version": 1, "versionNonce": nonce,
        "isDeleted": False, "boundElements": [], "updated": _now,
        "link": None, "locked": False,
    }


FILLS = {
    "grey": GREY, "green": GREEN, "blue": BLUE, "yellow": YELLOW,
    "red": RED, "white": "transparent",
}


class Scene:
    def __init__(self):
        self.elements = []

    def box(self, eid, x, y, w, h, fill="grey", rx=10):
        el = base("rectangle", x, y, w, h)
        el["id"] = eid
        el["backgroundColor"] = FILLS[fill]
        el["roundness"] = {"type": 3, "radius": rx if rx else None}
        self.elements.append(el)
        return el

    def ellipse(self, eid, x, y, w, h, fill="grey"):
        el = base("ellipse", x, y, w, h)
        el["id"] = eid
        el["backgroundColor"] = FILLS[fill]
        self.elements.append(el)
        return el

    def title(self, eid, text, x, y, size=26):
        el = base("text", x, y, max(40, len(text) * 12), size + 7)
        el["id"] = eid
        el.update({"text": text, "fontSize": size, "fontFamily": 5,
                   "textAlign": "left", "verticalAlign": "top",
                   "containerId": None, "originalText": text,
                   "autoResize": True, "lineHeight": 1.25})
        self.elements.append(el)
        return el

    def label(self, eid, container_id, cx, cy, text, size=19, align="center"):
        lines = text.splitlines() or [""]
        w = max(24, max(len(line) for line in lines) * size * 0.52)
        h = size * 1.25 * len(lines)
        x = cx - w / 2 if align == "center" else cx
        el = base("text", x, cy - h / 2, w, h)
        el["id"] = eid
        el.update({"text": text, "fontSize": size, "fontFamily": 5,
                   "textAlign": "center" if align == "center" else "left",
                   "verticalAlign": "middle", "containerId": container_id,
                   "originalText": text, "autoResize": True, "lineHeight": 1.25})
        owner = self._find(container_id)
        owner["boundElements"].append({"type": "text", "id": eid})
        self.elements.append(el)
        return el

    def block(self, eid, x, y, w, h, lines, fill="grey", size=19,
              align="center", name=None, ellipse=False):
        if ellipse:
            self.ellipse(eid, x, y, w, h, fill)
        else:
            self.box(eid, x, y, w, h, fill)
        if isinstance(lines, str):
            lines = [lines]
        text = "\n".join(lines)
        if align == "left":
            self.label(f"{eid}--text", eid, x + 14, y + h / 2,
                       text, size, "left")
        else:
            self.label(f"{eid}--text", eid, x + w / 2, y + h / 2,
                       text, size, "center")
        return eid

    def arrow(self, eid, start_id, end_id, label=None, gap=10.0):
        source = self._find(start_id)
        target = self._find(end_id)
        scx = source["x"] + source["width"] / 2
        scy = source["y"] + source["height"] / 2
        tcx = target["x"] + target["width"] / 2
        tcy = target["y"] + target["height"] / 2
        vx, vy = tcx - scx, tcy - scy
        length = (vx * vx + vy * vy) ** 0.5
        if length == 0:
            raise ValueError(f"{eid}: cannot connect concentric shapes")
        ux, uy = vx / length, vy / length

        def port(box, cx, cy, dx, dy):
            half_w, half_h = box["width"] / 2, box["height"] / 2
            factor = 1 / max(abs(dx) / half_w, abs(dy) / half_h)
            return cx + factor * dx, cy + factor * dy

        sbx, sby = port(source, scx, scy, vx, vy)
        tbx, tby = port(target, tcx, tcy, -vx, -vy)
        sx, sy = sbx + ux * gap, sby + uy * gap
        tx, ty = tbx - ux * gap, tby - uy * gap
        el = base("arrow", sx, sy, abs(tx - sx), abs(ty - sy))
        el["id"] = eid
        el["roundness"] = {"type": 2}
        el["points"] = [[0, 0], [tx - sx, ty - sy]]
        el["lastCommittedPoint"] = None
        el["startBinding"] = {"elementId": start_id, "focus": 0, "gap": gap}
        el["endBinding"] = {"elementId": end_id, "focus": 0, "gap": gap}
        el["startArrowhead"] = None
        el["endArrowhead"] = "arrow"
        for sid in (start_id, end_id):
            self._find(sid)["boundElements"].append({"type": "arrow", "id": eid})
        self.elements.append(el)
        if label:
            self.label(f"{eid}--label", eid, sx + (tx - sx) / 2,
                       sy + (ty - sy) / 2 - 12, label, 16)
        return eid

    def _find(self, eid):
        for el in self.elements:
            if el["id"] == eid:
                return el
        raise KeyError(eid)

    def dump(self, path):
        scene = {
            "type": "excalidraw", "version": 2,
            "source": "https://excalidraw.com",
            "elements": self.elements,
            "appState": {"gridSize": 20, "gridStep": 5,
                         "gridModeEnabled": False,
                         "viewBackgroundColor": "#ffffff"},
            "files": {},
        }
        Path(path).write_text(json_dump(scene))


import json


def json_dump(obj):
    return json.dumps(obj, indent=2)


PHONE_W, PHONE_H = 320, 620
PAD = 16


def new_phone(sc, eid, x, y, title_lines, header_h=64, w=PHONE_W, h=PHONE_H):
    sc.box(f"{eid}-frame", x, y, w, h, "white", rx=26)
    sc.block(f"{eid}-header", x + PAD, y + 14, w - 2 * PAD, header_h,
             title_lines, "blue", size=20)
    return PhoneCursor(sc, eid, x, y, w, h, header_h)


class PhoneCursor:
    def __init__(self, sc, eid, x, y, w, h, header_h):
        self.sc = sc
        self.eid = eid
        self.x = x
        self.y = y
        self.w = w
        self.h = h
        self.cursor = y + 14 + header_h + 12

    def add(self, name, lines, h, fill="grey", size=19, align="center"):
        pw = self.w - 2 * PAD
        self.sc.block(f"{self.eid}-{name}", self.x + PAD, self.cursor,
                      pw, h, lines, fill, size=size, align=align)
        self.cursor += h + 10
        return self

    def rest(self, extra=14):
        self.cursor += extra
        if self.cursor > self.y + self.h - 8:
            raise ValueError(f"{self.eid}: content taller than frame "
                             f"({self.cursor} > {self.y + self.h})")
        return self


def tiles(sc, eid, x, y, w, rows, label_h, cols=2):
    """rows: list of (tile_id, lines, fill). Returns end y."""
    gap = 10
    tw = (w - (cols - 1) * gap) / cols
    cy = y
    placed = []
    for idx, (tid, lines, fill) in enumerate(rows):
        col = idx % cols
        row = idx // cols
        tx = x + col * (tw + gap)
        ty = y + row * (label_h + gap)
        sc.block(f"{eid}-{tid}", tx, ty, tw, label_h, lines, fill, size=17)
        placed.append((f"{eid}-{tid}", tx, ty, tw, label_h))
    bottom = max((ty + label_h for (_id, _x, ty, _w, _h) in placed), default=y)
    return bottom, placed


# ---------------------------------------------------------------- scenes

def s_verify_location():
    sc = Scene()
    sc.title("title", "Register — verify where you live", 60, 30)
    p = new_phone(sc, "v", 60, 70, ["Where do you live?"], header_h=60)
    p.add("map", ["Map — the pin is your spot", "drop it on your house"], 104, "grey")
    p.add("addr", ["Address", "Jane Road 10, Pringle Bay"], 64, "grey")
    p.add("opt-home", ["I'm at home now", "let GPS check that here"], 56, "blue", size=16)
    p.add("opt-night", ["Not home? Come back later", "we check only when you choose"], 56, "blue", size=16)
    p.add("opt-cpt", ["Optional · a street captain", "visits to confirm the spot"], 56, "blue", size=16)
    p.add("cta", ["That's my spot"], 52, "green", size=18)
    p.add("quiet", ["Unverified accounts stay quiet", "until your spot is confirmed"], 48, "yellow", size=15)
    p.rest(10)
    sc.dump("docs/design/design-01-verify-location.excalidraw")


def s_capabilities():
    sc = Scene()
    sc.title("title", "Capabilities — what you'll help with", 60, 30)
    p = new_phone(sc, "c", 60, 70, ["What can you help with?"], header_h=64)
    (why, _) = tiles(sc, "c", p.x + PAD, p.cursor, p.w - 2 * PAD, [
        ("dogs", ["Dogs"], "grey"),
        ("cats", ["Cats"], "grey"),
        ("kids", ["Kids"], "grey"),
        ("drive", ["Driving"], "grey"),
        ("errands", ["Errands"], "grey"),
        ("tech", ["Tech"], "grey"),
        ("firstaid", ["First", "responders"], "grey"),
        ("choice", ["Anything —", "ask me"], "grey"),
    ], 62)
    p.cursor = why + 12
    p.add("note", ["Tap all that fit you", "you can change this later"], 56, "grey", size=16)
    p.add("next", ["Continue"], 60, "green", size=20)
    p.rest(8)
    sc.dump("docs/design/design-02-capabilities.excalidraw")


def s_home():
    sc = Scene()
    sc.title("title", "Home — with your call radius", 60, 30)
    p = new_phone(sc, "h", 60, 70, ["In a Pickle", "Good day, Sue"], 66)
    p.add("need", ["I need help"], 96, "green", size=22)
    p.add("can", ["I can help"], 96, "blue", size=22)
    p.add("loc", ["Where help finds you", "Home · Jane Road 10", "or follow me live"], 88, "yellow", size=16)
    p.add("strip", ["Happy to help when called: on"], 56, "grey", size=16)
    p.add("profile", ["My profile"], 56, "white", size=16)
    p.rest(6)
    sc.dump("docs/design/design-03-home.excalidraw")


def s_declare():
    sc = Scene()
    sc.title("title", "Declare a pickle — type, then ask", 60, 30)
    pa = new_phone(sc, "a", 60, 70, ["What kind of pickle?"], header_h=56)
    (hb, _) = tiles(sc, "a", pa.x + PAD, pa.cursor, pa.w - 2 * PAD, [
        ("lift", ["A lift"], "grey"),
        ("shopping", ["Shopping"], "grey"),
        ("kids", ["Kids care"], "grey"),
        ("pet", ["Pet care"], "grey"),
        ("borrow", ["Borrow", "something"], "grey"),
        ("tech", ["Tech help"], "grey"),
    ], 60, cols=2)
    pa.cursor = hb + 12
    pa.add("other", ["Anything else — ask anyway"], 64, "grey", size=17)
    pa.add("next", ["Write the ask"], 56, "green", size=18)
    pa.rest(6)
    pb = new_phone(sc, "b", 440, 70, ["Say it in one line"], header_h=56)
    pb.add("ask", ["Your ask", "Lift to the clinic", "Tuesday · 10:00"], 104, "grey", size=17)
    pb.add("who", ["Who gets called", "5 closest helpers first", "widening until answered"], 100, "grey", size=16)
    pb.add("send", ["Send the pickle"], 60, "green", size=19)
    pb.add("hint", ["Keep it short", "neighbours read fast"], 60, "grey", size=15)
    pb.rest(6)
    sc.dump("docs/design/design-04-declare-pickle.excalidraw")


def s_rings():
    sc = Scene()
    sc.title("title", "Ring matching — the call widens until answered", 60, 26)
    sc.block("pickle", 60, 70, 420, 66, ["Sue needs · Lift to the clinic", "Jane Road 10 · Tuesday 10:00"], "grey", size=18)
    sc.block("r1", 60, 176, 420, 72, ["Ring 1 · the 5 closest helpers"], "green", size=19)
    sc.block("r2", 60, 296, 420, 72, ["Ring 2 · the next 5"], "blue", size=19)
    sc.block("r3", 60, 416, 420, 72, ["Ring 3 · the next 5"], "blue", size=19)
    sc.arrow("a1", "pickle", "r1", "notify")
    sc.arrow("a2", "r1", "r2", "no answer in 5 min")
    sc.arrow("a3", "r2", "r3", "still open")
    sc.block("note", 60, 528, 420, 62, ["First to accept stops the rings", "badges clear for the other helpers"], "yellow", size=15)
    sc.block("called", 560, 176, 300, 150, ["You were called", "Lift to clinic · 10:00", "~500 m away"], "yellow", size=17)
    sc.block("accept", 560, 352, 300, 64, ["I can help"], "green", size=19)
    sc.block("later", 560, 428, 300, 56, ["Maybe later"], "white", size=16)
    sc.arrow("a4", "r1", "called", label="to 1 of 5")
    sc.dump("docs/design/design-05-ring-matching.excalidraw")


def s_accept():
    sc = Scene()
    sc.title("title", "Accept — the call clears everywhere else", 60, 30)
    pa = new_phone(sc, "a", 60, 70, ["You're called", "Lift to clinic · 10:00"], 66)
    pa.add("who", ["Sue", "about 500 m away", "exact address still hidden"], 86, "grey", size=16)
    pa.add("time", ["Needed at", "Tuesday 10:00"], 76, "grey", size=17)
    pa.add("yes", ["I can help"], 84, "green", size=21)
    pa.add("no", ["Maybe later"], 60, "white", size=16)
    pa.rest(6)
    pb = new_phone(sc, "b", 440, 70, ["You said yes"], 56)
    pb.add("match", ["You said yes — badge cleared", "waiting for Sue's OK", "address comes when she confirms"], 120, "green", size=15)
    pb.add("clear", ["Other helpers' badges cleared", "no noise for them"], 70, "yellow", size=15)
    pb.add("empty", ["No open pickles near you"], 60, "grey", size=16)
    pb.add("again", ["I can help again"], 54, "white", size=15)
    pb.rest(10)
    sc.dump("docs/design/design-06-accept-cleared.excalidraw")


def s_trust_gate():
    sc = Scene()
    sc.title("title", "Onboarding — explain the trust gate first", 60, 30)
    p = new_phone(sc, "t", 60, 70, ["A trusted circle", "of neighbours"], 72)
    p.add("why", ["Why we check", "every member confirms", "one home in the village"], 104,
          "grey", size=16)
    p.add("private", ["What stays private", "your exact address appears", "only after you approve a helper"],
          108, "blue", size=15)
    p.add("quiet", ["Unverified accounts stay quiet", "no calls · other addresses · chat"],
          70, "yellow", size=15)
    p.add("next", ["Set up my account"], 62, "green", size=19)
    p.rest(8)
    sc.dump("docs/design/design-07-trust-gate.excalidraw")


def s_verify_at_home():
    sc = Scene()
    sc.title("title", "Address verification — pin, check once, confirm", 60, 30)
    pa = new_phone(sc, "a", 60, 70, ["Pin your home"], 56)
    pa.add("map", ["Map", "pin on your house", "not a public map"], 150, "grey", size=17)
    pa.add("name", ["Sue"], 54, "white", size=17)
    pa.add("address", ["10 Jane Road", "Pringle Bay"], 70, "white", size=17)
    pa.add("next", ["That's my home"], 60, "green", size=18)
    pa.rest(6)
    pb = new_phone(sc, "b", 440, 70, ["Confirm you live here"], 56)
    pb.add("once", ["Use location once", "while you are at home", "we do not track where you go"],
           104, "blue", size=15)
    pb.add("result", ["Home confirmed", "phone is 11 m from the pin"],
           90, "green", size=17)
    pb.add("fallback", ["Location not working?", "ask a street captain"],
           74, "grey", size=16)
    pb.add("next", ["Continue"], 60, "green", size=18)
    pb.rest(6)
    sc.dump("docs/design/design-08-verify-at-home.excalidraw")


def s_two_account_approval():
    sc = Scene()
    sc.title("title", "Two accounts — accept, clear, requester approves", 60, 30)
    pa = new_phone(sc, "a", 60, 70, ["Marius · helper"], 56)
    pa.add("called", ["Sue needs a lift", "clinic · 10:00", "about 500 m away"],
           100, "yellow", size=17)
    pa.add("yes", ["I can help Sue"], 72, "green", size=20)
    pa.add("wait", ["Waiting for Sue's OK", "exact address stays hidden"],
           82, "grey", size=16)
    pa.add("clear", ["Other helpers' calls clear", "nothing stays in their inbox"],
           78, "blue", size=15)
    pa.rest(6)
    pb = new_phone(sc, "b", 440, 70, ["Sue · requester"], 56)
    pb.add("offer", ["Marius can help", "verified neighbour", "about 500 m away"],
           104, "green", size=17)
    pb.add("privacy", ["Approving shares", "your exact address", "and opens directions"],
           94, "yellow", size=16)
    pb.add("approve", ["Approve Marius"], 68, "green", size=19)
    pb.add("other", ["Ask someone else"], 56, "white", size=16)
    pb.rest(8)
    sc.dump("docs/design/design-09-two-account-approval.excalidraw")


def s_active_help_map():
    sc = Scene()
    sc.title("title", "Active help — route for helper, reassurance for requester", 60, 30)
    pa = new_phone(sc, "a", 60, 70, ["On the way to Sue"], 56)
    pa.add("map", ["Route map", "Marius → Sue's pin", "6 minutes"], 180, "blue", size=18)
    pa.add("address", ["Sue · 10 Jane Road", "Lift to clinic · 10:00"],
           76, "grey", size=16)
    pa.add("chat", ["Chat with Sue"], 64, "green", size=18)
    pa.add("directions", ["Open directions"], 56, "white", size=16)
    pa.rest(6)
    pb = new_phone(sc, "b", 440, 70, ["Your pickle"], 56)
    pb.add("status", ["Marius is on the way", "about 6 minutes"],
           88, "green", size=18)
    pb.add("map", ["Live route", "helper moving to your pin"], 180, "blue", size=17)
    pb.add("chat", ["Chat with Marius"], 64, "green", size=18)
    pb.add("safe", ["Address visible only", "inside this match"], 64, "yellow", size=15)
    pb.rest(6)
    sc.dump("docs/design/design-10-active-help-map.excalidraw")


def s_match_chat():
    sc = Scene()
    sc.title("title", "Matched chat — enough coordination, no phone number needed", 60, 30)
    p = new_phone(sc, "c", 60, 70, ["Sue", "matched neighbour"], 66)
    p.add("private", ["Exact address stays", "inside this match"],
          62, "yellow", size=15)
    p.add("m1", ["Marius", "I'm leaving now", "there in six minutes"],
          92, "green", size=16, align="left")
    p.add("m2", ["Sue", "Thank you", "I'll wait by the front gate"],
          92, "white", size=16, align="left")
    p.add("quick", ["Quick reply · I'm here"], 54, "blue", size=15)
    p.add("compose", ["Write a message"], 58, "white", size=16, align="left")
    p.rest(6)
    sc.dump("docs/design/design-11-match-chat.excalidraw")


if __name__ == "__main__":
    s_verify_location()
    s_capabilities()
    s_home()
    s_declare()
    s_rings()
    s_accept()
    s_trust_gate()
    s_verify_at_home()
    s_two_account_approval()
    s_active_help_map()
    s_match_chat()

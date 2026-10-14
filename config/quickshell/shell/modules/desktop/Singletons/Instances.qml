pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Extra desktop widgets beyond the one-per-type built-ins: any number of any
// type, each with its own placement. Kept in its own file,
// ~/.config/ryoku/widget-instances.json, because the Hub rewrites widgets.json
// with only the keys it knows. An entry is { type, wAnchor, wX, wY, wScale,
// wOpacity, wLocked }: the same key suffixes WidgetSlot reads from Config,
// under the fixed prefix "w". A type's look (clock face, calendar style) still
// comes from that type's widgets.json settings, shared by all its instances.
Singleton {
    id: root

    property var items: ({})
    // drives the desktop Repeater, so it changes only on add / remove: a drag
    // or a lock must never rebuild the tiles (and drop a half-typed note).
    property var ids: []
    signal patched(string id)

    readonly property var types: [
        { "id": "notes", "label": "Notes" },
        { "id": "gcal", "label": "Google Calendar" },
        { "id": "gtasks", "label": "Google Tasks" },
        { "id": "clock", "label": "Clock" },
        { "id": "calendar", "label": "Calendar" },
        { "id": "music", "label": "Music" },
        { "id": "aio", "label": "All-in-one" },
        { "id": "stats", "label": "System stats" },
        { "id": "weather", "label": "Weather" }
    ]
    function label(type) {
        const t = root.types.find(e => e.id === type);
        return t ? t.label : "Widget";
    }
    function get(id) { return root.items[id] || ({}); }

    function _commit(next) {
        root.items = next;
        file.setText(JSON.stringify(next, null, 2));
    }
    function add(type, x, y) {
        const next = Object.assign({}, root.items);
        next[type + "-" + Date.now().toString(36)] = {
            "type": type, "wAnchor": "free", "wX": Math.round(x), "wY": Math.round(y),
            "wScale": 1, "wOpacity": 1, "wLocked": false
        };
        root._commit(next);
        root.ids = Object.keys(next);
    }
    function patch(id, values) {
        if (!root.items[id])
            return;
        const next = Object.assign({}, root.items);
        next[id] = Object.assign({}, next[id], values);
        root._commit(next);
        root.patched(id);
    }
    function remove(id) {
        const next = Object.assign({}, root.items);
        delete next[id];
        root._commit(next);
        root.ids = Object.keys(next);
    }

    FileView {
        id: file
        path: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/ryoku/widget-instances.json"
        blockLoading: true
        printErrors: false
        atomicWrites: true
    }

    Component.onCompleted: {
        try {
            const v = JSON.parse(file.text() || "{}");
            if (v && typeof v === "object" && !Array.isArray(v))
                root.items = v;
        } catch (e) {
        }
        root.ids = Object.keys(root.items);
    }
}

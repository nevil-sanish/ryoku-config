import QtQuick
import Quickshell
import Quickshell.Io

// One polled ryoku-google command (events | tasks) as a list of rows. The
// script does the OAuth refresh and the API calls; this only schedules it and
// parses the single JSON object it prints.
Item {
    id: feed

    property string command: "events"
    property bool active: true
    property int interval: 600000
    property var items: []
    property string error: ""      // "" | "auth" (not signed in) | a message
    property bool loaded: false
    property bool hold: false      // true while the user types: a refresh must not rebuild the rows
    property string _last: ""

    readonly property string script: Quickshell.shellPath("modules/desktop/google/ryoku-google")

    function refresh() {
        if (feed.active && !feed.hold && !fetch.running)
            fetch.running = true;
    }
    // a write (done / add), then a refresh so the list shows Google's truth.
    function act(args) {
        feed._last = "";
        action.command = ["python3", feed.script].concat(args);
        action.running = true;
    }

    onActiveChanged: feed.refresh()
    Component.onCompleted: feed.refresh()

    Process {
        id: fetch
        command: ["python3", feed.script, feed.command]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const r = JSON.parse(text);
                    feed.error = r.ok ? "" : (r.error || "error");
                    // only a real change replaces the rows, so a poll that finds
                    // nothing new never resets a scrolled list.
                    if (r.ok && text !== feed._last) {
                        feed._last = text;
                        feed.items = r.items;
                    }
                } catch (e) {
                    feed.error = "error";
                }
                feed.loaded = true;
            }
        }
    }
    Process {
        id: action
        onExited: feed.refresh()
    }
    Timer {
        interval: feed.interval
        running: feed.active
        repeat: true
        onTriggered: feed.refresh()
    }
}

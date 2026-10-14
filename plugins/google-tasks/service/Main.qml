pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

// Google Tasks service: keeps the default list's open tasks, adds and completes
// them through bin/gapi. The widget only reads `items` / `error` and calls add()
// and complete().
Item {
    id: svc

    property var pluginApi
    readonly property string scopes: "https://www.googleapis.com/auth/tasks"
    readonly property string base: "https://tasks.googleapis.com/tasks/v1/lists/@default/tasks"

    property var items: []
    property string error: ""

    function api(method, url, body, cb) {
        if (!pluginApi) return;
        var cmd = [pluginApi.pluginDir + "/bin/gapi", pluginApi.stateDir, scopes, method, url];
        if (body) cmd.push(JSON.stringify(body));
        job.createObject(svc, { command: cmd, cb: cb || function () {} });
    }

    function refresh() {
        api("GET", base + "?showCompleted=false&maxResults=50", null, function (r) {
            svc.items = r.items || [];
        });
    }

    function add(title) {
        title = String(title || "").trim();
        if (title.length > 0) api("POST", base, { title: title }, refresh);
    }

    function complete(id) {
        // drop it locally right away; the refresh confirms
        svc.items = svc.items.filter(function (t) { return t.id !== id; });
        api("PATCH", base + "/" + encodeURIComponent(id), { status: "completed" }, refresh);
    }

    onPluginApiChanged: refresh()

    Component {
        id: job
        Process {
            id: p
            property var cb
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    var r;
                    try { r = JSON.parse(text); } catch (e) { r = { error: "bad response from gapi" }; }
                    svc.error = r.error || "";
                    if (!r.error) p.cb(r);
                    p.destroy();
                }
            }
        }
    }

    Timer {
        interval: 5 * 60 * 1000
        running: true
        repeat: true
        onTriggered: svc.refresh()
    }
}

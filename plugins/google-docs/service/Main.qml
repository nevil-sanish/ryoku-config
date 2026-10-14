pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

// Google Docs service: your most recently edited Docs (via Drive metadata, read
// only), shaped as { title, sub, link } rows for the widget.
Item {
    id: svc

    property var pluginApi
    readonly property string scopes: "https://www.googleapis.com/auth/drive.metadata.readonly"
    readonly property int maxDocs: pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.maxDocs ? pluginApi.pluginSettings.maxDocs : 6

    property var items: []
    property string error: ""

    function refresh() {
        if (!pluginApi) return;
        var url = "https://www.googleapis.com/drive/v3/files?orderBy=modifiedTime%20desc&pageSize=" + maxDocs
            + "&fields=files(name,webViewLink,modifiedTime)&q="
            + encodeURIComponent("mimeType='application/vnd.google-apps.document' and trashed=false");
        job.createObject(svc, { command: [pluginApi.pluginDir + "/bin/gapi", pluginApi.stateDir, scopes, "GET", url] });
    }

    onPluginApiChanged: refresh()

    Component {
        id: job
        Process {
            id: p
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    var r;
                    try { r = JSON.parse(text); } catch (e) { r = { error: "bad response from gapi" }; }
                    svc.error = r.error || "";
                    if (!r.error) svc.items = (r.files || []).map(function (f) {
                        return { title: f.name, sub: "edited " + Qt.formatDateTime(new Date(f.modifiedTime), "d MMM · hh:mm"), link: f.webViewLink };
                    });
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

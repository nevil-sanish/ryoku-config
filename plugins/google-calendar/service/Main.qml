pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

// Google Calendar service: the next upcoming events on the primary calendar,
// shaped as { title, sub, link } rows for the widget.
Item {
    id: svc

    property var pluginApi
    readonly property string scopes: "https://www.googleapis.com/auth/calendar.readonly"
    readonly property int maxEvents: pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.maxEvents ? pluginApi.pluginSettings.maxEvents : 6

    property var items: []
    property string error: ""

    function when(ev) {
        if (ev.start.dateTime) return Qt.formatDateTime(new Date(ev.start.dateTime), "ddd d MMM · hh:mm");
        return Qt.formatDate(new Date(ev.start.date + "T00:00:00"), "ddd d MMM") + " · all day";
    }

    function refresh() {
        if (!pluginApi) return;
        var url = "https://www.googleapis.com/calendar/v3/calendars/primary/events?singleEvents=true&orderBy=startTime"
            + "&maxResults=" + maxEvents + "&timeMin=" + encodeURIComponent(new Date().toISOString());
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
                    if (!r.error) svc.items = (r.items || []).map(function (ev) {
                        return { title: ev.summary || "(no title)", sub: svc.when(ev), link: ev.htmlLink };
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

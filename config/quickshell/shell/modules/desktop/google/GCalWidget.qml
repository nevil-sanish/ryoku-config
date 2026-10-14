pragma ComponentBehavior: Bound
import QtQuick
import ".."
import "../Singletons"

// The Google Calendar week on a frosted plate, top to bottom: yesterday, today
// and the next five days, from every calendar ticked in Google Calendar plus
// dated tasks. Only days that hold something get a heading. A click opens the
// event in the browser. Grows to fit, then scrolls past maxBody.
Item {
    id: root

    property real s: 1
    property bool active: true
    property Item wallpaperSource: null
    property rect wallpaperRect: Qt.rect(0, 0, 0, 0)

    readonly property real pad: Math.round(16 * root.s)
    readonly property real maxBody: Math.round(420 * root.s)

    implicitWidth: Math.round(280 * root.s)
    implicitHeight: head.implicitHeight + Math.round(8 * root.s)
        + Math.min(col.implicitHeight, root.maxBody) + 2 * root.pad

    readonly property string status: !feed.loaded ? "Loading…"
        : feed.error === "auth" ? "Not signed in.\nRun: ryoku-google login <client.json>"
        : feed.error !== "" ? feed.error
        : feed.items.length === 0 ? "Nothing this week" : ""

    function dayOffset(d) {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        return Math.round((new Date(d.getFullYear(), d.getMonth(), d.getDate()) - today) / 86400000);
    }
    // events flattened to draw rows: a { day } heading whenever the date turns,
    // then { time, title }. Something already running when the window opens
    // files under yesterday, the window's first day.
    readonly property var rows: {
        const out = [];
        let last = -99;
        for (const e of feed.items) {
            const d = new Date(e.allDay ? e.start + "T00:00:00" : e.start);
            const n = Math.max(-1, root.dayOffset(d));
            if (n !== last) {
                out.push({
                    "day": n === -1 ? "Yesterday" : n === 0 ? "Today" : n === 1 ? "Tomorrow"
                        : Qt.formatDate(d, "dddd d MMM"),
                    "offset": n
                });
                last = n;
            }
            out.push({
                "day": "",
                "offset": n,
                "time": e.allDay ? "" : Qt.formatTime(d, Config.clock24h ? "HH:mm" : "h:mm ap"),
                "title": e.title,
                "color": e.color,
                "link": e.link
            });
        }
        return out;
    }

    GoogleFeed {
        id: feed
        command: "events"
        active: root.active
        interval: 600000
    }

    WidgetGlass {
        anchors.fill: parent
        s: root.s
        sourceItem: root.wallpaperSource
        sourceRect: root.wallpaperRect
    }

    Text {
        id: head
        x: root.pad
        y: root.pad
        text: "THIS WEEK"
        color: Theme.faint
        font.family: Theme.font
        font.pixelSize: Math.round(10 * root.s)
        font.weight: Font.DemiBold
        font.letterSpacing: 1.6 * root.s
    }

    Flickable {
        id: flick
        x: root.pad
        y: head.y + head.implicitHeight + Math.round(8 * root.s)
        width: root.width - 2 * root.pad
        height: Math.min(col.implicitHeight, root.maxBody)
        contentHeight: col.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        // wheel and touchpad scroll; a mouse drag stays a widget drag.
        interactive: contentHeight > height

        Column {
            id: col
            width: flick.width
            spacing: Math.round(5 * root.s)

            Text {
                visible: root.status !== ""
                width: parent.width
                text: root.status
                color: Theme.inkDim
                wrapMode: Text.Wrap
                font.family: Theme.font
                font.pixelSize: Math.round(13 * root.s)
            }
            Repeater {
                model: root.status === "" ? root.rows : []
                Item {
                    id: row
                    required property var modelData
                    readonly property bool isDay: row.modelData.day !== ""
                    width: col.width
                    implicitHeight: row.isDay ? dayText.implicitHeight + Math.round(6 * root.s) : title.implicitHeight
                    opacity: row.modelData.offset < 0 ? 0.55 : 1

                    Text {
                        id: dayText
                        visible: row.isDay
                        anchors.bottom: parent.bottom
                        text: row.modelData.day
                        color: row.modelData.offset === 0 ? Theme.accent : Theme.inkDim
                        font.family: Theme.font
                        font.pixelSize: Math.round(12 * root.s)
                        font.weight: Font.DemiBold
                    }
                    Rectangle {
                        id: dot
                        visible: !row.isDay
                        width: Math.round(7 * root.s)
                        height: width
                        radius: width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        color: row.modelData.color || Theme.inkDim
                    }
                    Text {
                        id: title
                        visible: !row.isDay
                        anchors.left: dot.right
                        anchors.leftMargin: Math.round(9 * root.s)
                        anchors.right: time.left
                        anchors.rightMargin: Math.round(8 * root.s)
                        text: row.modelData.title || ""
                        color: Theme.ink
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Math.round(14 * root.s)
                        font.weight: Font.Medium
                        font.underline: open.containsMouse
                    }
                    Text {
                        id: time
                        visible: !row.isDay
                        anchors.right: parent.right
                        anchors.baseline: title.baseline
                        text: row.modelData.time || ""
                        color: Theme.inkDim
                        font.family: Theme.font
                        font.pixelSize: Math.round(12 * root.s)
                    }
                    MouseArea {
                        id: open
                        anchors.fill: parent
                        enabled: !row.isDay && !!row.modelData.link
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally(row.modelData.link)
                    }
                }
            }
        }
    }
}

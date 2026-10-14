pragma ComponentBehavior: Bound
import QtQuick
import ".."
import "../Singletons"

// Google Tasks as a board on a frosted plate: one column per task list, three
// in view, the rest a sideways scroll away; each column scrolls its own tasks
// inside a fixed, compact height. Tap a ring to complete, tap a title to open
// Google Tasks in the browser, type under a column to add to that list.
// `editing` is true while an add field holds focus, so the desktop layer grabs
// the keyboard only then; Enter, Escape or the pointer leaving hands it back.
Item {
    id: root

    property real s: 1
    property bool active: true
    property Item wallpaperSource: null
    property rect wallpaperRect: Qt.rect(0, 0, 0, 0)

    property Item focused: null
    readonly property bool editing: root.focused !== null

    readonly property real pad: Math.round(16 * root.s)
    readonly property real gap: Math.round(14 * root.s)
    readonly property real colW: Math.round(200 * root.s)
    readonly property real bodyH: Math.round(210 * root.s)
    readonly property int shown: Math.max(1, Math.min(3, feed.items.length))

    implicitWidth: root.shown * root.colW + (root.shown - 1) * root.gap + 2 * root.pad
    implicitHeight: head.implicitHeight + Math.round(10 * root.s) + board.height + 2 * root.pad

    readonly property string status: !feed.loaded ? "Loading…"
        : feed.error === "auth" ? "Not signed in.\nRun: ryoku-google login <client.json>"
        : feed.error !== "" ? feed.error
        : feed.items.length === 0 ? "No task lists" : ""

    function complete(listId, task) {
        // drop it (and its subtasks, the rows indented under it) now; the
        // refresh after the write confirms it.
        feed.items = feed.items.map(l => {
            if (l.id !== listId)
                return l;
            const at = l.tasks.findIndex(t => t.id === task.id);
            let end = at + 1;
            while (task.indent === 0 && end < l.tasks.length && l.tasks[end].indent > 0)
                end++;
            return { "id": l.id, "title": l.title, "tasks": l.tasks.slice(0, at).concat(l.tasks.slice(end)) };
        });
        feed.act(["done", listId, task.id]);
    }

    GoogleFeed {
        id: feed
        command: "tasks"
        active: root.active
        interval: 300000
        hold: root.editing
    }

    HoverHandler {
        onHoveredChanged: if (!hovered && root.focused) root.focused.focus = false
    }

    WidgetGlass {
        anchors.fill: parent
        hovered: root.editing
        s: root.s
        sourceItem: root.wallpaperSource
        sourceRect: root.wallpaperRect
    }

    Text {
        id: head
        x: root.pad
        y: root.pad
        text: "TASKS" + (feed.items.length > 3 ? "  ·  " + feed.items.length + " lists, scroll →" : "")
        color: Theme.faint
        font.family: Theme.font
        font.pixelSize: Math.round(10 * root.s)
        font.weight: Font.DemiBold
        font.letterSpacing: 1.6 * root.s
    }
    Text {
        visible: root.status !== ""
        x: root.pad
        y: board.y
        width: root.width - 2 * root.pad
        text: root.status
        color: Theme.inkDim
        wrapMode: Text.Wrap
        font.family: Theme.font
        font.pixelSize: Math.round(13 * root.s)
    }

    ListView {
        id: board
        x: root.pad
        y: head.y + head.implicitHeight + Math.round(10 * root.s)
        width: root.width - 2 * root.pad
        height: root.status !== "" ? Math.round(40 * root.s)
            : Math.round(22 * root.s) + root.bodyH + Math.round(26 * root.s)
        orientation: ListView.Horizontal
        spacing: root.gap
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        snapMode: ListView.SnapToItem
        model: root.status === "" ? feed.items : []

        // Shift + wheel scrolls the board sideways (a touchpad swipe or a drag
        // does too); the plain wheel belongs to the column under the pointer.
        WheelHandler {
            acceptedModifiers: Qt.ShiftModifier
            onWheel: (event) => {
                const max = Math.max(0, board.contentWidth - board.width);
                board.contentX = Math.max(0, Math.min(max, board.contentX - event.angleDelta.y));
            }
        }

        delegate: Item {
            id: column
            required property var modelData
            width: root.colW
            height: board.height

            Text {
                id: listTitle
                width: parent.width
                height: Math.round(22 * root.s)
                text: column.modelData.title + "  " + column.modelData.tasks.length
                color: Theme.accent
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Math.round(13 * root.s)
                font.weight: Font.DemiBold
            }

            ListView {
                id: tasks
                anchors.top: listTitle.bottom
                width: parent.width
                height: root.bodyH
                clip: true
                spacing: Math.round(7 * root.s)
                boundsBehavior: Flickable.StopAtBounds
                model: column.modelData.tasks

                delegate: Item {
                    id: row
                    required property var modelData
                    readonly property real inset: row.modelData.indent * Math.round(16 * root.s)
                    width: tasks.width
                    implicitHeight: Math.max(ring.height, title.implicitHeight)
                    height: implicitHeight

                    Rectangle {
                        id: ring
                        x: row.inset
                        y: Math.round(2 * root.s)
                        width: Math.round(14 * root.s)
                        height: width
                        radius: width / 2
                        color: tick.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35) : "transparent"
                        border.width: Math.max(1, Math.round(1.5 * root.s))
                        border.color: tick.containsMouse ? Theme.accent : Theme.inkDim
                        MouseArea {
                            id: tick
                            anchors.fill: parent
                            anchors.margins: -Math.round(4 * root.s)
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.complete(column.modelData.id, row.modelData)
                        }
                    }
                    Text {
                        id: title
                        anchors.left: ring.right
                        anchors.leftMargin: Math.round(8 * root.s)
                        anchors.right: parent.right
                        text: row.modelData.title
                        color: row.modelData.indent > 0 ? Theme.inkDim : Theme.ink
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Math.round(13 * root.s)
                        font.weight: Font.Medium
                        font.underline: open.containsMouse
                        MouseArea {
                            id: open
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.openUrlExternally("https://tasks.google.com/")
                        }
                    }
                }
            }

            TextInput {
                id: input
                anchors.bottom: parent.bottom
                width: parent.width
                clip: true
                color: Theme.ink
                selectionColor: Theme.accent
                selectByMouse: true
                font.family: Theme.font
                font.pixelSize: Math.round(13 * root.s)
                onActiveFocusChanged: {
                    if (input.activeFocus)
                        root.focused = input;
                    else if (root.focused === input)
                        root.focused = null;
                }
                Component.onDestruction: if (root.focused === input) root.focused = null
                Keys.onEscapePressed: (event) => { input.focus = false; event.accepted = true; }
                onAccepted: {
                    const t = input.text.trim();
                    input.text = "";
                    input.focus = false;
                    if (t.length > 0)
                        feed.act(["add", t, column.modelData.id]);
                }
                Text {
                    visible: input.text.length === 0 && !input.activeFocus
                    text: "+ Add a task"
                    color: Theme.faint
                    font: input.font
                }
            }
        }
    }
}

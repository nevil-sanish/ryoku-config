import QtQuick
import Ryoku.PluginKit.Singletons

// Google Calendar card: upcoming events; click one to open it in the browser.
Rectangle {
    id: root

    property var pluginApi
    property var screen
    property bool active: false
    property string density: "full"
    property real s: 1
    property real widthBudget: 0

    readonly property var svc: pluginApi ? pluginApi.mainInstance : null

    implicitWidth: 300 * s
    implicitHeight: col.implicitHeight + 24 * s
    radius: 12 * s
    color: Theme.cardTop
    border.width: 1
    border.color: Theme.border

    Column {
        id: col
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 * root.s }
        spacing: 8 * root.s

        Item {
            width: parent.width
            height: title.implicitHeight
            Text {
                id: title
                text: "GOOGLE CALENDAR"
                color: Theme.dim
                font.family: Theme.font
                font.pixelSize: 10 * root.s
                font.weight: Font.DemiBold
                font.letterSpacing: 1.4 * root.s
            }
            Row {
                anchors.right: parent.right
                spacing: 10 * root.s
                Text {
                    text: "+"
                    color: Theme.dim
                    font.pixelSize: 14 * root.s
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Qt.openUrlExternally("https://calendar.google.com/calendar/r/eventedit") }
                }
                Text {
                    text: "↻"
                    color: Theme.dim
                    font.pixelSize: 13 * root.s
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (root.svc) root.svc.refresh() }
                }
            }
        }

        Repeater {
            model: root.svc ? root.svc.items : []
            delegate: Item {
                width: col.width
                height: row.implicitHeight
                Column {
                    id: row
                    width: parent.width
                    Text {
                        width: parent.width
                        text: modelData.title
                        color: Theme.bright
                        font.family: Theme.font
                        font.pixelSize: 13 * root.s
                        elide: Text.ElideRight
                    }
                    Text {
                        text: modelData.sub
                        color: Theme.accent
                        font.family: Theme.font
                        font.pixelSize: 10.5 * root.s
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Qt.openUrlExternally(modelData.link)
                }
            }
        }

        Text {
            visible: root.svc && (root.svc.error.length > 0 || root.svc.items.length === 0)
            width: parent.width
            wrapMode: Text.Wrap
            text: !root.svc ? "" : root.svc.error.length > 0 ? root.svc.error : "Nothing coming up."
            color: Theme.dim
            font.family: Theme.font
            font.pixelSize: 11 * root.s
        }
    }
}

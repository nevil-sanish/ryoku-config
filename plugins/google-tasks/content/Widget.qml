import QtQuick
import Ryoku.PluginKit.Singletons

// Google Tasks card: open tasks, click the circle to complete, type + Enter to add.
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
                text: "GOOGLE TASKS"
                color: Theme.dim
                font.family: Theme.font
                font.pixelSize: 10 * root.s
                font.weight: Font.DemiBold
                font.letterSpacing: 1.4 * root.s
            }
            Text {
                anchors.right: parent.right
                text: "↻"
                color: Theme.dim
                font.pixelSize: 13 * root.s
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (root.svc) root.svc.refresh() }
            }
        }

        Repeater {
            model: root.svc ? root.svc.items : []
            delegate: Row {
                width: col.width
                spacing: 8 * root.s
                Text {
                    text: "○"
                    color: Theme.accent
                    font.pixelSize: 14 * root.s
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.svc.complete(modelData.id) }
                }
                Text {
                    width: parent.width - 24 * root.s
                    text: modelData.title
                    color: Theme.bright
                    font.family: Theme.font
                    font.pixelSize: 13 * root.s
                    elide: Text.ElideRight
                }
            }
        }

        Text {
            visible: root.svc && (root.svc.error.length > 0 || root.svc.items.length === 0)
            width: parent.width
            wrapMode: Text.Wrap
            text: !root.svc ? "" : root.svc.error.length > 0 ? root.svc.error : "All done."
            color: Theme.dim
            font.family: Theme.font
            font.pixelSize: 11 * root.s
        }

        Rectangle {
            width: parent.width
            height: 28 * root.s
            radius: 6 * root.s
            color: Theme.tileBg
            TextInput {
                id: input
                anchors { fill: parent; leftMargin: 8 * root.s; rightMargin: 8 * root.s }
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.bright
                font.family: Theme.font
                font.pixelSize: 12 * root.s
                clip: true
                onAccepted: { root.svc.add(text); text = ""; }
                Text {
                    visible: !input.text && !input.activeFocus
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Add a task…"
                    color: Theme.faint
                    font: input.font
                }
            }
        }
    }
}

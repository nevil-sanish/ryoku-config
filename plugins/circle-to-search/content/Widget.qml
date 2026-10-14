import QtQuick
import Ryoku.PluginKit.Singletons

// Circle to Search button: click, drag a box, results open in Google Lens.
Rectangle {
    id: root

    property var pluginApi
    property var screen
    property bool active: false
    property string density: "full"
    property real s: 1
    property real widthBudget: 0

    readonly property var svc: pluginApi ? pluginApi.mainInstance : null

    implicitWidth: label.implicitWidth + 32 * s
    implicitHeight: 40 * s
    radius: height / 2
    color: area.containsMouse ? Theme.tileBg : Theme.cardTop
    border.width: 1
    border.color: Theme.border

    Text {
        id: label
        anchors.centerIn: parent
        text: root.svc && root.svc.busy ? "◎  Select an area…" : "◎  Circle to Search"
        color: Theme.bright
        font.family: Theme.font
        font.pixelSize: 13 * root.s
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: if (root.svc) root.svc.search()
    }
}

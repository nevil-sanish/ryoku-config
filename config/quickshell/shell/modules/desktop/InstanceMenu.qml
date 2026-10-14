pragma ComponentBehavior: Bound
import QtQuick
import "Singletons"

// Right-click chrome for the extra widgets (Singletons/Instances.qml), on the
// shared DesktopMenu: with no instance it is the Add list of every type; with
// one it is that tile's menu.
Item {
    id: menu

    anchors.fill: parent

    property string iid: ""
    readonly property bool adding: menu.iid === ""
    readonly property var entry: Instances.get(menu.iid)

    function openFor(id, x, y) { menu.iid = id; shell.px = x; shell.py = y; shell.open = true; }
    function openAdd(x, y) { menu.openFor("", x, y); }

    DesktopMenu {
        id: shell
        title: menu.adding ? "Add widget" : Instances.label(menu.entry.type)

        Repeater {
            model: menu.adding ? Instances.types : []
            MenuRow {
                required property var modelData
                label: modelData.label
                onTriggered: Instances.add(modelData.id, shell.px, shell.py)
            }
        }
        MenuRow {
            visible: !menu.adding
            label: "Add another"
            onTriggered: Instances.add(menu.entry.type, shell.px + 32, shell.py + 32)
        }
        MenuRow {
            visible: !menu.adding
            label: menu.entry.wLocked ? "Unlock" : "Lock"
            onTriggered: Instances.patch(menu.iid, { "wLocked": !menu.entry.wLocked })
        }
        MenuRow {
            visible: !menu.adding
            label: "Remove"
            onTriggered: Instances.remove(menu.iid)
        }
    }
}

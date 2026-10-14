pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

// Circle to Search service: runs bin/circle-search (select region -> Google Lens).
Item {
    id: svc

    property var pluginApi
    readonly property bool busy: proc.running

    function search() {
        if (!pluginApi || proc.running) return;
        proc.command = [pluginApi.pluginDir + "/bin/circle-search"];
        proc.running = true;
    }

    Process { id: proc }
}

import QtQuick
import "Singletons"

// One extra widget's placement, shaped like the slice of Config a WidgetSlot
// uses (keys under the prefix "w", plus set / setLive / setFree), so the slot
// drags, resizes and locks an instance exactly as it does a built-in.
QtObject {
    id: st

    required property string iid

    property string wAnchor: "free"
    property real wX: 80
    property real wY: 80
    property real wScale: 1
    property real wOpacity: 1
    property bool wLocked: false
    property string wColor: ""
    property string wColor2: ""
    property bool wGradient: false

    function adopt() {
        const e = Instances.get(st.iid);
        for (const k in e)
            if (k.charAt(0) === "w" && st[k] !== undefined && st[k] !== e[k])
                st[k] = e[k];
    }
    function setLive(key, value) { st[key] = value; }
    function set(key, value) {
        st[key] = value;
        const v = {};
        v[key] = value;
        Instances.patch(st.iid, v);
    }
    function setFree(prefix, x, y) {
        // a resize ends here too, after setLive scrubbed wScale: persist it with
        // the position, as Config's whole-file write does.
        Instances.patch(st.iid, { "wAnchor": "free", "wX": x, "wY": y, "wScale": st.wScale });
    }

    Component.onCompleted: st.adopt()

    property Connections watch: Connections {
        target: Instances
        function onPatched(id) {
            if (id === st.iid)
                st.adopt();
        }
    }
}

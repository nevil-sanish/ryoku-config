pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "../Singletons"
import Ryoku.Ui.Singletons

// A scratch pad that rides the wallpaper: a wrapping TextEdit over a faint
// plate, ink resolved against the tone under the widget the way the clock faces
// pick theirs. The note body is content, not configuration, so it is not a
// widgets.json key -- it persists to ~/.local/state/ryoku/desktop-notes.txt
// through an atomic FileView, debounced so a burst of typing writes the file a
// few times, never once per keystroke.
//
// `editing` is true exactly while the pad holds focus; the desktop layer reads
// it to grab the keyboard while typing and hand it straight back the moment the
// pad blurs (Escape or a click off it). A wallpaper widget that kept an
// exclusive keyboard grab would strand every window, so the pad's interactive
// area is only the text: a press on the plate margin falls through to the
// slot's drag grip, and losing focus is never sticky.
Item {
    id: root

    property real underL: Scheme.wallLstar   // wallpaper tone under the slot, pushed by WidgetSlot
    // WidgetSlot pins a hex here to paint this widget's ink; "" follows the wallpaper.
    property string inkColorA: ""
    property real s: 1                        // scale (Config.notesScale)
    property bool active: true                // visible/enabled
    property int wLogical: 260                // Config.notesWidth, native px before scale
    property int hLogical: 180                // Config.notesHeight
    property string noteId: ""                // "" = the main pad; an extra pad keeps its own file
    property Item wallpaperSource: null       // the host's wallpaper mirror, for the frosted plate
    property rect wallpaperRect: Qt.rect(0, 0, 0, 0)

    implicitWidth: root.wLogical * root.s
    // hLogical is the pad's minimum: it grows downward to fit the whole note.
    implicitHeight: Math.max(root.hLogical * root.s,
        pad.implicitHeight + 2 * Math.round(16 * root.s))

    readonly property bool editing: pad.activeFocus

    // The body sits on the frosted plate (a Theme.surface wash), so its ink is the
    // palette's on-surface ink, the way the glass calendar picks its own; a pinned
    // colour paints the note body, never the plate behind it.
    readonly property color ink:     root.inkColorA !== "" ? root.inkColorA : Theme.ink
    readonly property color inkSoft: Qt.rgba(root.ink.r, root.ink.g, root.ink.b, 0.45)

    // `loaded` gates writes until the disk copy is in, so the initial load can
    // never echo back out as a write; `loading` suppresses the onTextChanged the
    // load itself fires.
    property bool loaded: false
    property bool loading: false

    // Take the disk copy unless the user is mid-edit -- reloads (our own atomic
    // write, or another monitor's) must not clobber the caret's line.
    function adopt() {
        if (pad.activeFocus)
            return;
        root.loading = true;
        const t = notesFile.text();
        if (pad.text !== t)
            pad.text = t;
        root.loading = false;
        root.loaded = true;
    }
    // Land any pending debounced write now, so a blur, a hide or a shell reload
    // can never drop the last few characters.
    function flush() {
        if (root.loaded && debounce.running) {
            debounce.stop();
            notesFile.setText(pad.text);
        }
    }

    onActiveChanged: if (!root.active) root.flush()
    onEditingChanged: if (!root.editing) { root.flush(); root.sync(); }
    Component.onCompleted: root.adopt()
    Component.onDestruction: root.flush()

    // frosted plate: the wallpaper patch under the pad, blurred and washed. It
    // takes no mouse, so a press on its margin falls through to the slot grip
    // below the content and drags.
    WidgetGlass {
        anchors.fill: parent
        hovered: pad.activeFocus
        s: root.s
        sourceItem: root.wallpaperSource
        sourceRect: root.wallpaperRect
    }

    // A non-interactive viewport: it clips and follows the caret without ever
    // grabbing a drag, so mouse text-selection stays with the TextEdit and the
    // plate margin stays a drag handle.
    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: Math.round(16 * root.s)
        clip: true
        interactive: false
        contentWidth: width
        contentHeight: pad.height

        TextEdit {
            id: pad
            width: flick.width
            height: Math.max(implicitHeight, flick.height)
            enabled: root.active
            color: root.ink
            selectionColor: Theme.accentOn2(root.underL, root.inkColorA)
            selectedTextColor: root.ink
            selectByMouse: true
            wrapMode: TextEdit.Wrap
            font.family: Theme.font
            font.pixelSize: Math.round(15 * root.s)
            font.weight: Font.Medium

            onTextChanged: if (root.loaded && !root.loading && root.active) debounce.restart()
            onCursorRectangleChanged: {
                if (cursorRectangle.y < flick.contentY)
                    flick.contentY = cursorRectangle.y;
                else if (cursorRectangle.y + cursorRectangle.height > flick.contentY + flick.height)
                    flick.contentY = cursorRectangle.y + cursorRectangle.height - flick.height;
            }
            Keys.onEscapePressed: (event) => { pad.focus = false; event.accepted = true; }

            Text {
                anchors.fill: parent
                visible: pad.text.length === 0
                text: I18n.tr("Jot a note\u2026")
                color: root.inkSoft
                font: pad.font
                wrapMode: Text.Wrap
            }
        }
    }

    // Two-way sync with a Google Doc (ryoku-google note-sync): the script edits
    // the same file this pad watches, so a change made in the Doc arrives through
    // the FileView like any other reload. Never while typing; once on blur.
    function sync() {
        if (root.active && root.loaded && !root.editing && !syncProc.running)
            syncProc.running = true;
    }
    Process {
        id: syncProc
        command: ["python3", Quickshell.shellPath("modules/desktop/google/ryoku-google"),
            "note-sync", root.noteId !== "" ? root.noteId : "main"]
    }
    Timer {
        interval: 60000
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: root.sync()
    }

    Timer {
        id: debounce
        interval: 400
        onTriggered: if (root.loaded) notesFile.setText(pad.text)
    }

    FileView {
        id: notesFile
        path: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/ryoku/desktop-notes" + (root.noteId !== "" ? "-" + root.noteId : "") + ".txt"
        blockLoading: true
        watchChanges: true
        printErrors: false
        // temp + rename: a SIGTERM mid-write (a shell refresh) can't leave a
        // half-written pad, and two monitors' pads can't tear each other's file.
        atomicWrites: true
        onFileChanged: reload()
        onLoaded: root.adopt()
        // no file yet: an empty pad is the initial state, and the first keystroke
        // is now free to create it.
        onLoadFailed: root.loaded = true
    }
}

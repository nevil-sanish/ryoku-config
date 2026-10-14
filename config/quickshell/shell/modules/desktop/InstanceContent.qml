pragma ComponentBehavior: Bound
import QtQuick
import "Singletons"
import "clock"
import "calendar"
import "music"
import "aio"
import "stats"
import "weather"
import "notes"
import "google"

// The face of one extra widget (see Singletons/Instances.qml): picks the
// component for its type and relays what a WidgetSlot expects of its child --
// the implicit size, `editing`, and the pushed `underL` / `inkColorA`.
Item {
    id: root

    property string type: ""
    property string iid: ""
    property real s: 1
    property bool active: true
    property real underL: Scheme.wallLstar
    property string inkColorA: ""
    property Item wallpaperSource: null
    property rect wallpaperRect: Qt.rect(0, 0, 0, 0)

    readonly property bool editing: !!(face.item && face.item.editing)

    implicitWidth: face.item ? face.item.implicitWidth : 0
    implicitHeight: face.item ? face.item.implicitHeight : 0

    Loader {
        id: face
        sourceComponent: {
            switch (root.type) {
            case "notes": return notesC;
            case "gcal": return gcalC;
            case "gtasks": return gtasksC;
            case "clock": return clockC;
            case "calendar": return calendarC;
            case "music": return musicC;
            case "aio": return aioC;
            case "stats": return statsC;
            case "weather": return weatherC;
            }
            return null;
        }
    }

    Component {
        id: notesC
        NotesWidget {
            noteId: root.iid
            s: root.s
            active: root.active
            wLogical: Config.notesWidth
            hLogical: Config.notesHeight
            underL: root.underL
            inkColorA: root.inkColorA
            wallpaperSource: root.wallpaperSource
            wallpaperRect: root.wallpaperRect
        }
    }
    Component {
        id: gcalC
        GCalWidget {
            s: root.s
            active: root.active
            wallpaperSource: root.wallpaperSource
            wallpaperRect: root.wallpaperRect
        }
    }
    Component {
        id: gtasksC
        GTasksWidget {
            s: root.s
            active: root.active
            wallpaperSource: root.wallpaperSource
            wallpaperRect: root.wallpaperRect
        }
    }
    // the clock sizes itself from Config.clockScale, so every clock shares the
    // main clock's size.
    Component {
        id: clockC
        Clock {
            underL: root.underL
            inkColorA: root.inkColorA
        }
    }
    Component {
        id: calendarC
        CalendarWidget {
            style: Config.calendarStyle
            weeks: Config.calendarWeeks
            showWeekNumbers: Config.calendarWeekNumbers
            holidayRegion: Config.calendarHolidayRegion
            active: root.active
            s: root.s
            underL: root.underL
            inkColorA: root.inkColorA
            wallpaperSource: root.wallpaperSource
            wallpaperRect: root.wallpaperRect
        }
    }
    Component {
        id: musicC
        MusicWidget {
            style: Config.musicStyle
            showLyrics: Config.musicLyrics
            viz: Config.musicViz
            active: root.active
            musicApp: Config.musicApp
            shape: Config.musicShape
            videoMode: Config.musicVideo
            videoFile: Config.musicVideoFile
            s: root.s
            underL: root.underL
            inkColorA: root.inkColorA
            wallpaperSource: root.wallpaperSource
            wallpaperRect: root.wallpaperRect
        }
    }
    Component {
        id: aioC
        AioWidget {
            style: Config.aioStyle
            s: root.s
            active: root.active
            underL: root.underL
            inkColorA: root.inkColorA
        }
    }
    Component {
        id: statsC
        StatsWidget {
            s: root.s
            active: root.active
            underL: root.underL
            inkColorA: root.inkColorA
        }
    }
    Component {
        id: weatherC
        WeatherWidget {
            design: Config.weatherDesign
            s: root.s
            active: root.active
            underL: root.underL
            inkColorA: root.inkColorA
        }
    }
}

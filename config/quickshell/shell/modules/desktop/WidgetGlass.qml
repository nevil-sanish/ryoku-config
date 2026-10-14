import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import "Singletons"

// Frosted plate for a desktop widget that draws its own card: the exact patch of
// wallpaper behind the widget, blurred and dimmed inside the rounded shape, with
// a grey wash and a film grain over it. The wallpaper lives in its own Wayland surface, which
// Qt cannot sample, so the host mirrors it into the scene and hands that Item in
// as `sourceItem` with the widget's rect (see Desktop.qml).
ClippingRectangle {
    id: root

    property bool hovered: false
    property real s: 1
    property Item sourceItem: null
    property rect sourceRect: Qt.rect(0, 0, 0, 0)

    readonly property real bleed: 36 * root.s
    readonly property real cropX: Math.max(0, root.sourceRect.x - root.bleed)
    readonly property real cropY: Math.max(0, root.sourceRect.y - root.bleed)
    readonly property real cropRight: root.sourceItem
        ? Math.min(root.sourceItem.width, root.sourceRect.x + root.width + root.bleed) : 0
    readonly property real cropBottom: root.sourceItem
        ? Math.min(root.sourceItem.height, root.sourceRect.y + root.height + root.bleed) : 0

    // unscaled, so a small widget and a large one share the same corner.
    radius: Theme.radiusWidget
    color: "transparent"
    contentUnderBorder: true
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, root.hovered ? 0.42 : 0.26)

    Behavior on border.color { ColorAnimation { duration: Theme.quick } }

    ShaderEffectSource {
        id: backdropCrop
        x: root.cropX - root.sourceRect.x
        y: root.cropY - root.sourceRect.y
        width: Math.max(1, root.cropRight - root.cropX)
        height: Math.max(1, root.cropBottom - root.cropY)
        sourceItem: root.sourceItem
        sourceRect: Qt.rect(root.cropX, root.cropY, width, height)
        live: root.visible
        hideSource: true
        recursive: false
        smooth: true
        visible: false
    }

    MultiEffect {
        x: backdropCrop.x
        y: backdropCrop.y
        width: backdropCrop.width
        height: backdropCrop.height
        source: backdropCrop
        autoPaddingEnabled: false
        blurEnabled: !Performance.blurDisabled
        blur: 1
        blurMax: 64
        blurMultiplier: 1.7
        saturation: -0.15
        contrast: 0.08
        brightness: -0.04
    }

    // the pane: almost clear, with a soft light falling from the top edge the way
    // it does across a sheet of glass. The bright rim is the border above.
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.rgba(1, 1, 1, root.hovered ? 0.2 : 0.15) }
            GradientStop { position: 0.4; color: Qt.rgba(0.85, 0.85, 0.88, 0.06) }
            GradientStop { position: 1; color: Qt.rgba(0.85, 0.85, 0.88, 0.03) }
        }
    }
    // film grain over the wash, under the content.
    Image {
        anchors.fill: parent
        source: "grain.png"
        fillMode: Image.Tile
        opacity: 0.6
        smooth: false
    }
}

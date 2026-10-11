import QtQuick 2.11

// Built-in on-screen keyboard, loaded by Main.qml (no extra packages needed)
Item {
    id: kbRoot

    property bool shown: false
    property var target: null        // field that receives the keys
    property bool shift: false
    property int page: 0             // 0 = letters, 1 = symbols, 2 = more symbols
    property var symLabels: ["?123", "#+=", "ABC"]

    property var layers: [
        [ "1234567890".split(""), "qwertyuiop".split(""), "asdfghjkl".split(""), "zxcvbnm".split("") ],
        [ "1234567890".split(""), "!@#$%^&*()".split(""), "-_=+[]{}".split(""), ";:'\",./".split("") ],
        [ "1234567890".split(""), "~`<>?|\\".split(""), [], [] ]
    ]

    function typeChar(c) {
        if (!target) return
        target.insert(target.cursorPosition, c)
        if (shift) shift = false
    }

    function backspace() {
        if (!target) return
        var p = target.cursorPosition
        if (p > 0) target.remove(p - 1, p)
    }

    Rectangle {
        id: panel

        property real gap: 8
        property real unit: (width - 40 - 9 * gap) / 10

        width: Math.min(kbRoot.width * 0.55, 1100)
        height: col.implicitHeight + 40
        x: (kbRoot.width - width) / 2
        y: kbRoot.shown ? kbRoot.height - height - 20 : kbRoot.height
        visible: y < kbRoot.height

        color: "#000000"
        border.color: "#FFFFFF"
        border.width: 2

        Behavior on y {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        // Swallow clicks between keys
        MouseArea { anchors.fill: parent }

        Column {
            id: col
            anchors.centerIn: parent
            spacing: panel.gap

            // Number row and first two letter rows
            Repeater {
                model: 3
                Row {
                    id: rowItem
                    property int ri: index
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: panel.gap
                    visible: kbRoot.layers[kbRoot.page][ri].length > 0

                    Repeater {
                        model: kbRoot.layers[kbRoot.page][rowItem.ri]
                        OskKey {
                            width: panel.unit
                            label: (kbRoot.shift && kbRoot.page === 0) ? modelData.toUpperCase() : modelData
                            onActivated: kbRoot.typeChar(label)
                        }
                    }
                }
            }

            // Shift, bottom letter row, delete
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: panel.gap

                OskKey {
                    width: 1.5 * panel.unit + 0.5 * panel.gap
                    label: "SHIFT"
                    highlighted: kbRoot.shift
                    opacity: kbRoot.page === 0 ? 1 : 0
                    enabled: kbRoot.page === 0
                    onActivated: kbRoot.shift = !kbRoot.shift
                }

                Item {
                    width: 7 * panel.unit + 6 * panel.gap
                    height: panel.unit > 0 ? 60 : 0
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: panel.gap
                        Repeater {
                            model: kbRoot.layers[kbRoot.page][3]
                            OskKey {
                                width: panel.unit
                                label: (kbRoot.shift && kbRoot.page === 0) ? modelData.toUpperCase() : modelData
                                onActivated: kbRoot.typeChar(label)
                            }
                        }
                    }
                }

                OskKey {
                    width: 1.5 * panel.unit + 0.5 * panel.gap
                    label: "DEL"
                    onActivated: kbRoot.backspace()
                }
            }

            // Page switch, space, enter
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: panel.gap

                OskKey {
                    width: 2 * panel.unit
                    label: kbRoot.symLabels[kbRoot.page]
                    onActivated: kbRoot.page = (kbRoot.page + 1) % 3
                }
                OskKey {
                    width: 6 * panel.unit + 7 * panel.gap
                    label: "SPACE"
                    onActivated: kbRoot.typeChar(" ")
                }
                OskKey {
                    width: 2 * panel.unit
                    label: "ENTER"
                    highlighted: true
                    onActivated: { if (kbRoot.target) kbRoot.target.accepted() }
                }
            }
        }
    }
}

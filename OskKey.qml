import QtQuick 2.11

// On-screen keyboard key
Rectangle {
    id: key

    property string label: ""
    property bool highlighted: false
    property string fontFamily: "Arsenal"
    signal activated()

    height: 60
    color: area.pressed ? "#D92323" : (area.containsMouse ? "#222222" : "#000000")
    border.color: highlighted ? "#D92323" : "#FFFFFF"
    border.width: 2

    Text {
        anchors.centerIn: parent
        text: key.label
        color: "#FFFFFF"
        font.family: key.fontFamily
        font.pixelSize: key.label.length > 2 ? 20 : 26
        font.bold: true
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: key.activated()
    }
}

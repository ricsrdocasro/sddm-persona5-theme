import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.11

Pane {
    id: root
    height: config.ScreenHeight || Screen.height
    width: config.ScreenWidth || Screen.width
    padding: 0 

    FontLoader {
        id: p5Hatty
        source: "p5hatty.ttf"
    }
    property string headerFont: "p5hatty" 
    property string bodyFont: "Arsenal"
    property real scaleFactor: Math.min(root.width / 1920, root.height / 1080)

    Image {
        id: bg
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop 
        asynchronous: true
    }
    MouseArea { 
        anchors.fill: parent
        onClicked: parent.forceActiveFocus() 
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            shakeAnim.start()
            daggerImg.visible = false
            pass.text = "" 
            pass.placeholderText = "WRONG!" 
        }
    }

    SequentialAnimation {
        id: shakeAnim
        NumberAnimation {
            target: uiGroup
            property: "anchors.rightMargin"
            to: root.width*0.10 + 20
            duration: 50
        }
        NumberAnimation {
            target: uiGroup
            property: "anchors.rightMargin"
            to: root.width*0.10 - 20
            duration: 50
        }
        NumberAnimation {
            target: uiGroup
            property: "anchors.rightMargin"
            to: root.width*0.10 + 20
            duration: 50
        }
        NumberAnimation {
            target: uiGroup
            property: "anchors.rightMargin"
            to: root.width*0.10
            duration: 50
        }
    }

    // --- KINETIC PIERCING ANIMATION ---
    SequentialAnimation {
        id: daggerAttack
        ScriptAction {
            script: daggerImg.visible = true
        }
        
        ParallelAnimation {
            NumberAnimation { 
                target: daggerImg
                property: "x"
                from: 320 
                to: 100 
                duration: 100
                easing.type: Easing.OutExpo 
            }
            NumberAnimation { 
                target: daggerImg
                property: "y"
                from: 150
                to: -15 
                duration: 100
                easing.type: Easing.OutExpo 
            }
            NumberAnimation { 
                target: daggerImg
                property: "scale"
                from: 2.0
                to: 0.6 
                duration: 100
                easing.type: Easing.OutExpo 
            }
        }

        // The "Wobble" after impact
        SequentialAnimation {
            NumberAnimation {
                target: daggerImg
                property: "rotation"
                from: 45
                to: 40
                duration: 40
            }
            NumberAnimation {
                target: daggerImg
                property: "rotation"
                from: 40
                to: 50
                duration: 40
            }
            NumberAnimation {
                target: daggerImg
                property: "rotation"
                from: 50
                to: 45
                duration: 40
            }
        }
        
        PauseAnimation {
            duration: 400
        }
        // FIX: Login using index instead of key model
        ScriptAction {
            script: sddm.login(user.text, pass.text, session.currentIndex)
        }
    }

    Item {
        id: clockWidget
        width: 300
        height: 120
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 30
        anchors.bottomMargin: 20
        
        Component.onCompleted: clockAnim.start()
        NumberAnimation {
            id: clockAnim
            target: clockWidget
            property: "opacity"
            from: 0
            to: 1
            duration: 1000
        }

        ColumnLayout {
            anchors.right: parent.right
            spacing: 0
            
            Image {
                id: daySprite
                property var days: ["sunday.png", "monday.png", "tuesday.png", "wednesday.png", "thursday.png", "friday.png", "saturday.png"]
                source: days[new Date().getDay()]
                fillMode: Image.PreserveAspectFit
                Layout.preferredHeight: 60
                Layout.preferredWidth: 180
                Layout.alignment: Qt.AlignRight
                smooth: true
                transform: Rotation {
                    angle: -3
                }
            }

            RowLayout {
                spacing: 10
                Layout.alignment: Qt.AlignRight
                Image { 
                    source: "playtime.png"
                    fillMode: Image.PreserveAspectFit
                    Layout.preferredHeight: 25
                    Layout.preferredWidth: 100
                    transform: Rotation {
                        angle: -2
                    } 
                }
                Text {
                    id: timeLabel
                    text: Qt.formatTime(new Date(), "hh:mm")
                    color: "#FFFFFF"
                    font.family: root.headerFont
                    font.pixelSize: 36
                    style: Text.Outline
                    styleColor: "black"
                    transform: Rotation {
                        angle: -3
                    }
                }
            }
        }
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                timeLabel.text = Qt.formatTime(new Date(), "hh:mm")
                daySprite.source = daySprite.days[new Date().getDay()]
            }
        }
    }

    Item {
        id: uiGroup
        width: 600
        height: 650 
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: root.width * 0.10
        anchors.verticalCenterOffset: -40 
        scale: root.scaleFactor

        Component.onCompleted: enterAnim.start()
        ParallelAnimation {
            id: enterAnim
            NumberAnimation { 
                target: uiGroup
                property: "x"
                from: root.width
                to: root.width - uiGroup.width - (root.width * 0.10)
                duration: 600
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
            NumberAnimation {
                target: uiGroup
                property: "opacity"
                from: 0
                to: 1
                duration: 300
            }
        }

        Image {
            id: headerImg
            source: "header.png"
            width: 450
            height: 180
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            fillMode: Image.PreserveAspectFit
            transform: Rotation {
                angle: -5
            } 
        }

        ColumnLayout {
            anchors.top: headerImg.bottom
            anchors.topMargin: -20 
            anchors.horizontalCenter: parent.horizontalCenter
            width: 450
            spacing: 25 
            
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 90 
                Image { 
                    anchors.fill: parent
                    source: "input_bg.png"
                    fillMode: Image.Stretch
                    mirror: true 
                }
                TextField {
                    id: user
                    anchors.centerIn: parent
                    width: parent.width * 0.8 
                    anchors.verticalCenterOffset: 8 
                    placeholderText: "Phantom ID"
                    color: "#FFFFFF"
                    placeholderTextColor: "#DDDDDD" 
                    font.family: root.bodyFont
                    font.pixelSize: 28
                    font.bold: true
                    font.italic: true
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter 
                    
                    background: Item {
                        // Empty
                    } 
                    
                    Component.onCompleted: {
                        if(config.ForceLastUser) user.text = sddm.lastUser
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                Image { 
                    anchors.fill: parent
                    source: "input_bg.png"
                    fillMode: Image.Stretch
                    transform: Rotation {
                        angle: 2
                    } 
                }
                TextField {
                    id: pass
                    anchors.centerIn: parent
                    width: parent.width * 0.8
                    anchors.verticalCenterOffset: 12 
                    placeholderText: "Alias"
                    echoMode: TextInput.Password
                    color: "#FFFFFF"
                    placeholderTextColor: "#DDDDDD"
                    font.family: root.bodyFont
                    font.pixelSize: 24
                    font.bold: true
                    font.italic: true
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    background: Item {
                        // Empty
                    }
                    onAccepted: daggerAttack.start() 
                }
            }

            // BUTTON AREA
            Item {
                id: btnContainer
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                Layout.topMargin: 20 

                // 1. THE MAGIC CLIPPER
                Item {
                    id: daggerClipper
                    z: 10

                    x: 220 
                    y: 20
                    rotation: -30
                    width: 500 
                    height: 200
                    clip: true 
                    
                    Image {
                        id: daggerImg
                        source: "dagger.png"
                        visible: false

                        width: 300
                        height: 100
                        fillMode: Image.PreserveAspectFit 
                        rotation: 45 

                        layer.enabled: true
                        layer.effect: DropShadow {
                            horizontalOffset: 8
                            verticalOffset: 8
                            radius: 8.0
                            samples: 16
                            color: "#80000000"
                            transparentBorder: true
                        }
                    }
                }

                // 2. THE TEXT BUTTON
                Button {
                    id: loginButton
                    anchors.fill: parent
                    onClicked: {
                        daggerAttack.start()
                    }

                    background: Item {
                        Image {
                            id: btnImg
                            source: "login_btn.png"
                            anchors.centerIn: parent
                            width: 400
                            height: 80
                            fillMode: Image.PreserveAspectFit
                            scale: loginButton.hovered ? 1.05 : 1.0
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 100
                                }
                            }
                        }

                        ColorOverlay {
                            anchors.fill: btnImg
                            source: btnImg
                            color: "#D92323" 
                            opacity: loginButton.hovered ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 200
                                }
                            }
                        }
                    }
                    contentItem: Item {}
                }
            }
        }
        
        RowLayout {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 100
            spacing: 20
            
            Button { 
                id: reb
                text: "REBOOT"
                onClicked: sddm.reboot()
                background: Item {} 
                contentItem: Text { 
                    text: parent.text
                    color: "white"
                    font.family: root.headerFont
                    font.pixelSize: 24 
                }
            }
            Text { 
                text: "/"
                color: "#D92323"
                font.bold: true
                font.pixelSize: 20 
            }
            Button { 
                id: shut
                text: "SHUTDOWN"
                onClicked: sddm.shutdown()
                background: Item {} 
                contentItem: Text { 
                    text: parent.text
                    color: "white"
                    font.family: root.headerFont
                    font.pixelSize: 24 
                }
            }
        }

        Item {
            id: phantomLogo
            width: 150
            height: 130
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -60
            anchors.right: parent.right
            anchors.rightMargin: 230
            
            transform: Rotation {
                angle: -10
            }
            z: 10
            
            Image { 
                id: hatBase
                source: "hat.png"
                width: 120
                height: 100
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                smooth: true 
            }
            Image {
                id: flameSprite
                width: 80
                height: 80
                x: 56
                y: 33 
                source: "fire1.png"
                fillMode: Image.PreserveAspectFit
                
                Rectangle { 
                    anchors.fill: parent
                    color: "transparent"
                    visible: parent.status == Image.Error 
                }
            }
            property int frame: 1
            Timer {
                interval: 80
                running: true
                repeat: true
                onTriggered: { 
                    parent.frame = (parent.frame % 10) + 1
                    flameSprite.source = "fire" + parent.frame + ".png" 
                }
            }
        }
    }

    Item {
        id: sessionCard
        width: 300
        height: 50
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 40
        
        Component.onCompleted: sessAnim.start()
        NumberAnimation {
            id: sessAnim
            target: sessionCard
            property: "x"
            from: -300
            to: 40
            duration: 800
            easing.type: Easing.OutBack
        }
        Rectangle { 
            anchors.fill: parent
            color: "#000000"
            border.color: "#FFFFFF"
            border.width: 2
            transform: Rotation {
                angle: 2
            } 
        }
        ComboBox {
            id: session
            anchors.fill: parent
            model: sddm.sessions
            currentIndex: sddm.lastSession || 0
            
            padding: 0
            leftPadding: 0
            rightPadding: 0
            
            rotation: 2
            
            background: Item {
                // Empty
            } 
            
            contentItem: Text {
                text: session.currentText
                color: "#FFFFFF"
                font.family: root.headerFont
                font.pixelSize: 32
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            
            delegate: ItemDelegate {
                width: session.width
                contentItem: Text {
                    text: modelData.name
                    color: highlighted ? "#D92323" : "#FFFFFF"
                    font.family: root.bodyFont
                    font.pixelSize: 20
                    font.bold: true
                }
                background: Rectangle {
                    color: "#000000"
                    border.color: "#333"
                }
            }
            
            popup: Popup {
                y: parent.height - 5
                width: parent.width
                height: contentItem.implicitHeight
                padding: 10
                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: session.popup.model
                    currentIndex: session.highlightedIndex
                    delegate: ItemDelegate {
                        width: parent.width
                        text: modelData.name
                        font.family: root.bodyFont; font.bold: true
                        contentItem: Text {
                            text: parent.text
                            color: parent.highlighted ? "#D92323" : "#FFFFFF"
                            font: parent.font
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.highlighted ? "#222222" : "transparent"
                        }
                    }
                }
                background: Rectangle {
                    color: "#000000"
                    border.color: "#FFFFFF"
                    border.width: 2
                }
            }
        }
    }
}

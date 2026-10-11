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
        source: "Assets/Fonts/p5hatty.ttf"
    }
    property string headerFont: "p5hatty"
    property string bodyFont: "Arsenal"
    property real scaleFactor: Math.min(root.width / 1920, root.height / 1080)

    // Delayed suspend
    property bool suspendPending: false
    property int suspendRemaining: 0
    property var suspendOptions: [
        { label: "NOW",    secs: 0 },
        { label: "5 MIN",  secs: 300 },
        { label: "15 MIN", secs: 900 },
        { label: "30 MIN", secs: 1800 },
        { label: "1 HOUR", secs: 3600 }
    ]

    function formatTime(s) {
        var m = Math.floor(s / 60)
        var r = s % 60
        return m + ":" + (r < 10 ? "0" : "") + r
    }

    function startSuspend(secs) {
        if (secs <= 0) {
            sddm.suspend()
        } else {
            suspendRemaining = secs
            suspendPending = true
        }
    }

    Timer {
        interval: 1000
        running: root.suspendPending
        repeat: true
        onTriggered: {
            root.suspendRemaining -= 1
            if (root.suspendRemaining <= 0) {
                root.suspendPending = false
                sddm.suspend()
            }
        }
    }

    Image {
        id: bg
        anchors.fill: parent
        source: "Assets/Images/background.png"
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
            pass.forceActiveFocus()
        }
    }

    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: uiGroup; property: "anchors.rightMargin"; to: root.width * 0.10 + 20; duration: 50 }
        NumberAnimation { target: uiGroup; property: "anchors.rightMargin"; to: root.width * 0.10 - 20; duration: 50 }
        NumberAnimation { target: uiGroup; property: "anchors.rightMargin"; to: root.width * 0.10 + 20; duration: 50 }
        NumberAnimation { target: uiGroup; property: "anchors.rightMargin"; to: root.width * 0.10; duration: 50 }
    }

    // Dagger attack animation
    SequentialAnimation {
        id: daggerAttack
        ScriptAction {
            script: daggerImg.visible = true
        }

        ParallelAnimation {
            NumberAnimation { target: daggerImg; property: "x"; from: 320; to: 100; duration: 100; easing.type: Easing.OutExpo }
            NumberAnimation { target: daggerImg; property: "y"; from: 150; to: -15; duration: 100; easing.type: Easing.OutExpo }
            NumberAnimation { target: daggerImg; property: "scale"; from: 2.0; to: 0.6; duration: 100; easing.type: Easing.OutExpo }
        }

        // Wobble after impact
        SequentialAnimation {
            NumberAnimation { target: daggerImg; property: "rotation"; from: 45; to: 40; duration: 40 }
            NumberAnimation { target: daggerImg; property: "rotation"; from: 40; to: 50; duration: 40 }
            NumberAnimation { target: daggerImg; property: "rotation"; from: 50; to: 45; duration: 40 }
        }

        PauseAnimation {
            duration: 400
        }

        ScriptAction {
            script: sddm.login(userPicker.currentText, pass.text, session.currentIndex)
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
                property var days: ["Assets/Images/sunday.png", "Assets/Images/monday.png", "Assets/Images/tuesday.png", "Assets/Images/wednesday.png", "Assets/Images/thursday.png", "Assets/Images/friday.png", "Assets/Images/saturday.png"]
                source: days[new Date().getDay()]
                fillMode: Image.PreserveAspectFit
                Layout.preferredHeight: 60
                Layout.preferredWidth: 180
                Layout.alignment: Qt.AlignRight
                smooth: true
                transform: Rotation { angle: -3 }
            }

            RowLayout {
                spacing: 10
                Layout.alignment: Qt.AlignRight
                Image {
                    source: "Assets/Images/playtime.png"
                    fillMode: Image.PreserveAspectFit
                    Layout.preferredHeight: 25
                    Layout.preferredWidth: 100
                    transform: Rotation { angle: -2 }
                }
                Text {
                    id: timeLabel
                    text: Qt.formatTime(new Date(), "hh:mm")
                    color: "#FFFFFF"
                    font.family: root.headerFont
                    font.pixelSize: 36
                    style: Text.Outline
                    styleColor: "black"
                    transform: Rotation { angle: -3 }
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

        // Slide-in animation
        ParallelAnimation {
            id: enterAnim
            NumberAnimation {
                target: uiGroup
                property: "anchors.rightMargin"
                from: -uiGroup.width
                to: root.width * 0.10
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
            source: "Assets/Images/header.png"
            width: 450
            height: 180
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            fillMode: Image.PreserveAspectFit
            transform: Rotation { angle: -5 }
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
                    source: "Assets/Images/input_bg.png"
                    fillMode: Image.Stretch
                    mirror: true
                }
                // User selector
                ComboBox {
                    id: userPicker
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 8
                    width: parent.width * 0.8
                    height: 60
                    model: userModel
                    textRole: "name"
                    currentIndex: userModel.lastIndex

                    padding: 0
                    leftPadding: 0
                    rightPadding: 0

                    background: Item {}
                    indicator: Item {}

                    contentItem: Text {
                        text: userPicker.currentText
                        color: "#FFFFFF"
                        font.family: root.bodyFont
                        font.pixelSize: 28
                        font.bold: true
                        font.italic: true
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    delegate: ItemDelegate {
                        width: userPicker.popup.width - userPicker.popup.leftPadding - userPicker.popup.rightPadding
                        height: 64
                        highlighted: userPicker.highlightedIndex === index
                        contentItem: Text {
                            text: model.name
                            color: parent.highlighted ? "#D92323" : "#FFFFFF"
                            font.family: root.bodyFont
                            font.pixelSize: 28
                            font.bold: true
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                        background: Rectangle {
                            color: parent.highlighted ? "#222222" : "#000000"
                            border.color: "#333"
                        }
                    }

                    // User list popup
                    popup: Popup {
                        y: userPicker.height + 5
                        width: 450
                        x: (userPicker.width - width) / 2
                        height: Math.min(contentItem.implicitHeight + topPadding + bottomPadding,
                                         root.height * 0.6)
                        padding: 10
                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: userPicker.popup.visible ? userPicker.delegateModel : null
                            currentIndex: userPicker.highlightedIndex
                        }
                        background: Rectangle {
                            color: "#000000"
                            border.color: "#FFFFFF"
                            border.width: 2
                        }
                    }

                    KeyNavigation.down: pass
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                Image {
                    anchors.fill: parent
                    source: "Assets/Images/input_bg.png"
                    fillMode: Image.Stretch
                    transform: Rotation { angle: 2 }
                }
                TextField {
                    id: pass
                    anchors.centerIn: parent
                    width: parent.width * 0.8
                    anchors.verticalCenterOffset: 12
                    placeholderText: "Password"
                    focus: true
                    Component.onCompleted: forceActiveFocus()
                    echoMode: TextInput.Password
                    color: "#FFFFFF"
                    placeholderTextColor: "#DDDDDD"
                    font.family: root.bodyFont
                    font.pixelSize: 24
                    font.bold: true
                    font.italic: true
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    background: Item {}
                    onAccepted: daggerAttack.start()
                }
            }

            // Login button area
            Item {
                id: btnContainer
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                Layout.topMargin: 20

                // Dagger clipper
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
                        source: "Assets/Images/dagger.png"
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

                // Login button
                Button {
                    id: loginButton
                    anchors.fill: parent
                    onClicked: daggerAttack.start()

                    background: Item {
                        Image {
                            id: btnImg
                            source: "Assets/Images/login_btn.png"
                            anchors.centerIn: parent
                            width: 400
                            height: 80
                            fillMode: Image.PreserveAspectFit
                            scale: loginButton.hovered ? 1.05 : 1.0
                            Behavior on scale {
                                NumberAnimation { duration: 100 }
                            }
                        }

                        ColorOverlay {
                            anchors.fill: btnImg
                            source: btnImg
                            color: "#D92323"
                            opacity: loginButton.hovered ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation { duration: 200 }
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
                id: susp
                text: root.suspendPending ? "SUSPEND " + root.formatTime(root.suspendRemaining) : "SUSPEND"
                onClicked: {
                    // Click cancels a running countdown
                    if (root.suspendPending)
                        root.suspendPending = false
                    else
                        suspendMenu.open()
                }
                background: Item {}
                contentItem: Text {
                    text: parent.text
                    color: root.suspendPending ? "#D92323" : "white"
                    font.family: root.headerFont
                    font.pixelSize: 24
                }

                Popup {
                    id: suspendMenu
                    y: susp.height + 10
                    x: (susp.width - width) / 2
                    width: 220
                    padding: 10
                    height: contentItem.implicitHeight + topPadding + bottomPadding

                    contentItem: Column {
                        spacing: 0
                        Repeater {
                            model: root.suspendOptions
                            ItemDelegate {
                                width: 200
                                height: 52
                                contentItem: Text {
                                    text: modelData.label
                                    color: parent.hovered ? "#D92323" : "#FFFFFF"
                                    font.family: root.bodyFont
                                    font.pixelSize: 24
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                background: Rectangle {
                                    color: parent.hovered ? "#222222" : "#000000"
                                    border.color: "#333"
                                }
                                onClicked: {
                                    suspendMenu.close()
                                    root.startSuspend(modelData.secs)
                                }
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
            Text {
                text: "/"
                color: "#D92323"
                font.bold: true
                font.pixelSize: 20
            }
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
                onClicked: sddm.powerOff()
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

            transform: Rotation { angle: -10 }
            z: 10

            Image {
                id: hatBase
                source: "Assets/Images/hat.png"
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
                source: "Assets/Images/fire1.png"
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
                    flameSprite.source = "Assets/Images/fire" + parent.frame + ".png"
                }
            }
        }
    }

    // Session selector (bottom-left)
    Item {
        id: sessionCard
        width: 300
        height: 50
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 40

        Component.onCompleted: sessAnim.start()
        // Slide-in animation
        NumberAnimation {
            id: sessAnim
            target: sessionCard
            property: "anchors.leftMargin"
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
            transform: Rotation { angle: 2 }
        }

        ComboBox {
            id: session
            anchors.fill: parent
            model: sessionModel
            textRole: "name"
            currentIndex: sessionModel.lastIndex

            // Restore the last used session
            Component.onCompleted: currentIndex = sessionModel.lastIndex

            padding: 0
            leftPadding: 0
            rightPadding: 0
            rotation: 2

            background: Item {}

            contentItem: Text {
                text: session.currentText
                color: "#FFFFFF"
                font.family: root.headerFont
                font.pixelSize: 32
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            delegate: ItemDelegate {
                width: session.width
                highlighted: session.highlightedIndex === index
                contentItem: Text {
                    text: model.name
                    color: parent.highlighted ? "#D92323" : "#FFFFFF"
                    font.family: root.bodyFont
                    font.pixelSize: 20
                    font.bold: true
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: parent.highlighted ? "#222222" : "#000000"
                    border.color: "#333"
                }
            }

            // Session list popup (opens upward)
            popup: Popup {
                y: -height - 5
                width: session.width
                height: Math.min(contentItem.implicitHeight + topPadding + bottomPadding,
                                 root.height * 0.6)
                padding: 10
                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: session.popup.visible ? session.delegateModel : null
                    currentIndex: session.highlightedIndex
                }
                background: Rectangle {
                    color: "#000000"
                    border.color: "#FFFFFF"
                    border.width: 2
                }
            }
        }
    }

    // Virtual keyboard (toggle icon at top-right)
    Loader {
        id: kbLoader
        anchors.fill: parent
        z: 100
        source: "VirtualKeyboardPanel.qml"
        // Give the keyboard the password field
        onLoaded: item.target = pass
    }

    Item {
        id: kbToggle
        width: 70
        height: 50
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 30
        anchors.rightMargin: 30
        z: 50
        rotation: -4
        // Hidden if the keyboard panel failed to load
        visible: kbLoader.status === Loader.Ready

        property bool kbActive: kbLoader.item ? kbLoader.item.shown : false
        property color lineColor: (kbArea.containsMouse || kbActive) ? "#D92323" : "#FFFFFF"

        scale: kbArea.containsMouse ? 1.08 : 1.0
        Behavior on scale { NumberAnimation { duration: 100 } }

        Rectangle {
            anchors.fill: parent
            radius: 4
            color: "#000000"
            border.color: kbToggle.lineColor
            border.width: 3

            Column {
                anchors.centerIn: parent
                spacing: 4

                Row {
                    spacing: 3
                    Repeater {
                        model: 6
                        Rectangle { width: 7; height: 7; color: kbToggle.lineColor }
                    }
                }
                Row {
                    spacing: 3
                    Repeater {
                        model: 6
                        Rectangle { width: 7; height: 7; color: kbToggle.lineColor }
                    }
                }
                Rectangle {
                    width: 36
                    height: 6
                    color: kbToggle.lineColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        MouseArea {
            id: kbArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (kbLoader.item)
                    kbLoader.item.shown = !kbLoader.item.shown
                // Keep focus on the password field
                pass.forceActiveFocus()
            }
        }
    }
}

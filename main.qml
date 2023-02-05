import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: root
    width: 820
    height: 450
    visible: true
    color: "lightblue"
    title: qsTr("Music Player")

    property bool isPlaying: false
    property string currentSongName: "NaN"
    property int currentSongIndex: -1
    property int numberOfSong: 0
    property int songDuration: 0
    property int songPosition: 0
    property real progressBarStep: 0
    property int currentVolume: playerModel.volume
    property url playButtonUrl: "images/play.png"
    property url pauseButtonUrl: "images/pause.png"

    signal currentSongChanged(int newSongIndex)
    signal volumnAdjusted(int currentVolume)
    signal positionAdjusted(int currentPosition)

    function playSelectedSong() {
        root.currentSongChanged(currentSongIndex)
        playerModel.play()
        isPlaying = true
        playButtonImage.source = pauseButtonUrl
        currentSongName = playerModel.currentSong
        songTimer.running = true
        animation.paused = false
        songPosition = 0
        console.log("Now Playing " + currentSongName + ". Volumne = " + currentVolume)
    }

    function msToHMS(ms) {
        // 1- Convert to seconds:
        var seconds = ms / 1000;

        // 2- Extract hours:
        var hours = parseInt(seconds / 3600); // 3600 seconds in 1 hour
        seconds = parseInt(seconds % 3600); // extract the remaining seconds after extracting hours

        // 3- Extract minutes:
        var minutes = parseInt(seconds / 60); // 60 seconds in 1 minute

        // 4- Keep only seconds not extracted to minutes:
        seconds = parseInt(seconds % 60);

        // 5 - Format so it shows a leading zero if needed
        let hoursStr = ("00" + hours).slice(-2);
        let minutesStr = ("00" + minutes).slice(-2);
        let secondsStr = ("00" + seconds).slice(-2);

        if (hours !== 0) {
            return(hoursStr + ":" + minutesStr + ":" + secondsStr);
        } else {
            return(minutesStr + ":" + secondsStr);
        }
    }

    Connections {
        id: playerModelConnection
        target: playerModel

        onCurrentSongDurationChanged: {
            songDuration = data
            progressBarStep = 400000/songDuration
            console.log("Duration = " + songDuration)
        }
    }

    ListView {
        id: songNameListView
        spacing: 2
        width: 200
        height: 250
        currentIndex: currentSongIndex
        x: 80
        y: 50

        ScrollBar.vertical: ScrollBar {
            anchors.right: parent.left
        }

        model: playerModel.songNameList
        delegate: RowLayout {
            id: delegateNameRow
            spacing: 0
            property int indexOfThisDelegate: index

            Rectangle{
                width: 30
                height: 30
                color: delegateNameRow.ListView.isCurrentItem ? "darkslategray" : "lightcoral"
                Text {
                    text: indexOfThisDelegate + 1
                    font.pointSize: 12
                    color: delegateNameRow.ListView.isCurrentItem ? "white" : "black"
                    leftPadding: 8
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle{
                id: memberDataRect
                width: 280
                height: 30
                color: delegateNameRow.ListView.isCurrentItem ? "darkslategray" : "lightcoral"

                Item {
                    anchors.fill: parent
                    property string text: modelData
                    property string spacing: "        "
                    property string combined: text + spacing
                    property string display: combined.substring(step) + combined.substring(0, step)
                    property int step: 0

                    Timer {
                        id: textRunningTimer
                        interval: 200
                        running: true
                        repeat: true
                        onTriggered: parent.step = (parent.step + 1) % parent.combined.length
                    }

                    Text {
                        id: memberDataText
                        text: delegateNameRow.ListView.isCurrentItem ? parent.display : modelData
                        font.pointSize: 12
                        color: delegateNameRow.ListView.isCurrentItem ? "white" : "black"
                        leftPadding: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 280
                        maximumLineCount: 1
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: memberDataRectArea
                    anchors.fill: parent
                    onClicked: {
                        console.log("Clicked on " + modelData)
                        songNameListView.currentIndex = index
                        currentSongIndex = index
                        currentSongName = modelData
                        root.playSelectedSong()
                    }
                }
            }
        }

        Component.onCompleted: {
            numberOfSong = songNameListView.count
        }
    }

    Slider {
        id: songProgressBar
        from: 0
        to: 400
        stepSize: progressBarStep
        orientation: Qt.Horizontal
        value: songPosition

        anchors.horizontalCenter: parent.horizontalCenter
        y: 353
        width: 400
        height: belowProgressBar.implicitHeight

        background:Rectangle {
            id: belowProgressBar
            implicitHeight: 7
            width: parent.width
            radius: 31
            color: "#DEDDE3"
            opacity: 90

            Rectangle {
                id: aboveProcessBar
                width: songProgressBar.visualPosition * parent.width
                height: parent.height + 1
                radius: 37
                color: "coral"
            }
        }
        handle: Item{}
        onMoved: {
            if (currentSongIndex < 0) {
                console.log("Position adjusted, but no song is selected")
                value = 0
            } else{
                playerModel.pause()
                songPosition = value
                root.positionAdjusted(songPosition)
                if (value < 400){
                    playerModel.play()
                    isPlaying = true
                    playButtonImage.source = pauseButtonUrl
                    songTimer.running = true
                    animation.paused = false
                }
                console.log("Position adjusted, the position is now: " + songPosition)
            }
        }
    }

    Timer {
        id: songTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            if (songPosition < 400){
                songPosition = songPosition + progressBarStep
            } else {
                running = false
                animation.paused = true
                playButtonImage.source = playButtonUrl
            }
        }
    }

    Text {
        id: durationText
        text: msToHMS(songDuration)
        anchors {
            left: songProgressBar.right
            leftMargin: 10
            verticalCenter: songProgressBar.verticalCenter
        }
        font.pointSize: 10
        font.bold: true
        color: "darkslategrey"
    }

    Text {
        id: positionText
        text: msToHMS((songPosition*songDuration)/400)
        anchors {
            right: songProgressBar.left
            rightMargin: 10
            verticalCenter: songProgressBar.verticalCenter
        }
        font.pointSize: 10
        font.bold: true
        color: "darkslategrey"
    }

    Rectangle {
        id: animationRect
        x: 460
        y: 30
        AnimatedImage {
            id: animation;
            source: "images/spinning.gif"
            paused: true
            speed: 1
        }
    }

    RowLayout {
        id: buttonsLayout
        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 30

        Button {
            id: backButton

            contentItem: Image {
                id: backButtonImage
                opacity: backButton.down ? 0.7 : 1.0
                anchors.horizontalCenter: backButtonRect.horizontalCenter
                anchors.verticalCenter: backButtonRect.verticalCenter
                source: "images/back.png"
            }

            background: Rectangle {
                id: backButtonRect
                anchors.bottom: parent.bottom
                width: 45
                height: 45
                opacity: enabled ? 1 : 0.3
                border.color: backButton.down ? "darkgray" : "black"
                border.width: 1
                radius: 5
                color: "darkslategray"
            }

            onClicked: {
                console.log("Clicked on backButton")
                if (currentSongIndex > 0){
                    currentSongIndex = currentSongIndex - 1
                    songNameListView.currentIndex = currentSongIndex
                    root.playSelectedSong()
                } else {
                    currentSongIndex = numberOfSong - 1
                    songNameListView.currentIndex = currentSongIndex
                    root.playSelectedSong()
                }
            }
        }

        Button {
            id: playButton

            contentItem: Image {
                id: playButtonImage
                opacity: playButton.down ? 0.7 : 1.0
                anchors.horizontalCenter: playButtonRect.horizontalCenter
                anchors.verticalCenter: playButtonRect.verticalCenter
                source: {
                    if (isPlaying) {
                        pauseButtonUrl
                    } else {
                        playButtonUrl
                    }
                }
            }

            background: Rectangle {
                id: playButtonRect
                anchors.bottom: parent.bottom
                width: 45
                height: 45
                opacity: enabled ? 1 : 0.3
                border.color: playButton.down ? "darkgray" : "black"
                border.width: 1
                radius: 5
                color: "darkslategray"
            }

            onClicked: {
                if (isPlaying) {
                    console.log("Clicked on pauseButton")
                    playerModel.pause()
                    isPlaying = false
                    playButtonImage.source = playButtonUrl
                    songTimer.running = false
                    animation.paused = true
                } else {
                    if (currentSongIndex < 0) {
                        console.log("Clicked on playButton but no song is selected")
                    } else {
                        console.log("Clicked on playButton")
                        playerModel.play()
                        isPlaying = true
                        playButtonImage.source = pauseButtonUrl
                        songTimer.running = true
                        animation.paused = false
                    }
                }
                if (songPosition >= 400) {
                    playSelectedSong()
                }
            }
        }

        Button {
            id: nextButton

            contentItem: Image {
                id: nextButtonImage
                opacity: nextButton.down ? 0.7 : 1.0
                anchors.horizontalCenter: nextButtonRect.horizontalCenter
                anchors.verticalCenter: nextButtonRect.verticalCenter
                source: "images/next.png"
            }

            background: Rectangle {
                id: nextButtonRect
                anchors.bottom: parent.bottom
                width: 45
                height: 45
                opacity: enabled ? 1 : 0.3
                border.color: nextButton.down ? "darkgray" : "black"
                border.width: 1
                radius: 5
                color: "darkslategray"
            }

            onClicked: {
                console.log("Clicked on nextButton")
                if (currentSongIndex < numberOfSong - 1){
                    currentSongIndex = currentSongIndex + 1
                    songNameListView.currentIndex = currentSongIndex
                    root.playSelectedSong()
                } else {
                    currentSongIndex = 0
                    songNameListView.currentIndex = currentSongIndex
                    root.playSelectedSong()
                }
            }
        }
    }

    Slider {
        id: volumeSlider
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 37
        anchors.rightMargin: 130
        height: volumeSliderBelow.implicitHeight
        width: 140
        from: 0
        to: 100
        stepSize: 1
        orientation: Qt.Horizontal
        value: currentVolume
        background:Rectangle {
            id: volumeSliderBelow
            implicitHeight: 6
            width: parent.width
            radius: 31
            color: "#DEDDE3"
            opacity: 95

            Rectangle {
                width: volumeSlider.visualPosition * parent.width
                height: parent.height
                radius: 37
                color: "darkslategrey"
            }
        }
        onMoved: {
            root.volumnAdjusted(value)
            console.log("Volume adjusted, the volume is now: " + value)
        }
        handle: Item{}
    }

    Text {
        id: volumeText
        text: "Volume: " + currentVolume
        anchors {
            bottom: volumeSlider.top
            bottomMargin: 6
            horizontalCenter: volumeSlider.horizontalCenter
        }
        font.pointSize: 8
        font.bold: true
        color: "darkslategrey"
    }

    Component.onCompleted: {
        currentSongChanged.connect(playerModel.handleCurrentSongChanged)
        volumnAdjusted.connect(playerModel.handleVolumeAdjusted)
        positionAdjusted.connect(playerModel.handleCurrentPositionChanged)
    }
}

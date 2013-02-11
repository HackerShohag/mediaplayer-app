/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Ugo Riboni <ugo.riboni@canonical.com>
 *  Michał Sawicz <michal.sawicz@canonical.com>
 *  Renato Araujo Oliveira Filho <renato@canonical.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtQuick.Window 2.0
import QtMultimedia 5.0
import QtSensors 5.0

Rectangle {
    id: mediaPlayer
    width: screenWidth
    height: screenHeight

    property string orientation: "0"
    property string formFactor: "tv"
    property real volume: playerLoader.item.volume
    property bool appActive: Qt.application.active

    property variant nativeOrientation: Screen.primaryOrientation

    onAppActiveChanged: {
        if (!appActive && playerLoader.item) {
            playerLoader.item.pause()
        }
    }

    Loader {
        id: playerLoader
        source: "player/VideoPlayer.qml"
        focus: true
        anchors.fill: parent
        clip: true
        onLoaded: {
            item.focus = true
            item.playUri(playUri)
            item.rotating = Qt.binding(function () { return rotatingTransition.running } )
        }

        state: mediaPlayer.orientation != "" ? mediaPlayer.orientation : (screenHeight <= screenWidth ? "0" : "270")

        Component.onCompleted: {
            state = Qt.binding(function () {
                return mediaPlayer.orientation != "" ? mediaPlayer.orientation : (screenHeight <= screenWidth ? "0" : "270")
            })
        }

        states:  [
          State {
            name: "0"
            PropertyChanges {
              target: mediaPlayer
              rotation: 0
              width: screenWidth
              height: screenHeight
              x: 0
              y: 0
            }
          },
          State {
            name: "180"
            PropertyChanges {
              target: mediaPlayer
              rotation: 180
              width: screenWidth
              height: screenHeight
              x: 0
              y: 0
            }
          },
          State {
            name: "270"
            PropertyChanges {
              target: mediaPlayer
              rotation: 270
              width: screenHeight
              height: screenWidth
              x: (screenWidth - screenHeight) / 2
              y: -(screenWidth - screenHeight) / 2
            }
          },
          State {
            name: "90"
            PropertyChanges {
              target: mediaPlayer
              rotation: 90
              width: screenHeight
              height: screenWidth
              x: (screenWidth - screenHeight) / 2
              y: -(screenWidth - screenHeight) / 2
            }
          }
        ]

        transitions: [
          Transition {
            id: rotatingTransition
            ParallelAnimation {
              RotationAnimation {
                properties: "rotation"
                duration: 250
                direction: RotationAnimation.Shortest
              }
              PropertyAnimation {
                target: mediaPlayer
                properties: "x,y,width,height"
                duration: 250
              }
            }
          }
        ]

        OrientationSensor {
            id: orientationSensor
            active: true

            // Causes the media player UI to rotate when the target device is rotated
            onReadingChanged: {
                setOrientation("sensor", reading.orientation)
            }
        }
    }

    onNativeOrientationChanged:  {
        setOrientation("qpa", nativeOrientation)
    }

    function setOrientation(type, orient) {
        // Set the orientation based on the orientation sensor
        if (type == "sensor") {
            if (orient == OrientationReading.LeftUp) {
                mediaPlayer.orientation = "270"
            }
            else if (orient == OrientationReading.RightUp) {
                mediaPlayer.orientation = "90"
            }
            else if (orient == OrientationReading.TopUp) {
                mediaPlayer.orientation = "0"
            }
            else if (orient == OrientationReading.TopDown) {
                mediaPlayer.orientation = "180"
            }
        }
        else if (type == "qpa") {
            // Set the orientation based on the QPlatformScreen from qpa
            if (orient == Qt.LandscapeOrientation)
                mediaPlayer.orientation = "270"
            else if (orient == Qt.InvertedLandscapeOrientation)
                mediaPlayer.orientation = "90"
            else if (orient == Qt.PortraitOrientation)
                mediaPlayer.orientation = "0"
            else if (orient == Qt.InvertedPortraitOrientation)
                mediaPlayer.orientation = "180"
        }
        else {
            console.log("Unknown type: " + type + ", error setting orientation.")
        }
    }

    Connections {
        target: playerLoader.item
        onStatusChanged: {
            if (playerLoader.item.status === MediaPlayer.EndOfMedia) {
                Qt.quit()
            }
        }
    }

    function rotateClockwise() {
        if (orientation == "") orientation = playerLoader.state
        if (orientation == "0") orientation = "270"
        else if (orientation == "270") orientation = "180"
        else if (orientation == "180") orientation = "90"
        else orientation = "0"
    }

    function rotateCounterClockwise() {
        if (orientation == "") orientation = playerLoader.state
        if (orientation == "0") orientation = "90"
        else if (orientation == "90") orientation = "180"
        else if (orientation == "180") orientation = "270"
        else orientation = "0"
    }

    Keys.onReleased: {
        if (!event.isAutoRepeat
            && (event.key == Qt.Key_F11 || event.key == Qt.Key_F)) {
            event.accepted = true
            application.toggleFullscreen();
        } else if (!event.isAutoRepeat && event.key == Qt.Key_BracketLeft) {
            event.accepted = true
            rotateClockwise()
        } else if (!event.isAutoRepeat && event.key == Qt.Key_BracketRight) {
            event.accepted = true
            rotateCounterClockwise()
        }
    }
}

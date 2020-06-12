/****************************************************************************
**
** Copyright (C) TERIFLIX Entertainment Spaces Pvt. Ltd. Bengaluru
** Author: Prashanth N Udupa (prashanth.udupa@teriflix.com)
**
** This code is distributed under GPL v3. Complete text of the license
** can be found here: https://www.gnu.org/licenses/gpl-3.0.txt
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/

import Scrite 1.0
import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Material 2.12

/**
  ToolButton from QtQuick.Controls is what we normally use in Scrite.
  ToolButton2 customises the built-in ToolButton to provide a standard behaviour
    across all tool-buttons in Scrite.

  This component (ToolButton3) is for use specifically in the new main-window toolbar.
  This new toolbar design is based on UI/UX suggestions from Surya Vasishta.
  */

Item {
    id: toolButton

    property string iconSource: ""
    property real suggestedWidth: 42
    property real suggestedHeight: suggestedWidth
    property alias shortcut: toolButtonShortcut.sequence
    property string shortcutText: "" + shortcut
    property bool down: toolButtonMouseArea.pressed
    property bool checkable: false
    property bool checked: false
    property alias hovered: toolButtonMouseArea.containsMouse
    property string text

    signal toggled()
    signal clicked()

    width: suggestedWidth
    height: suggestedHeight

    Rectangle {
        id: downIndicator
        anchors.fill: parent
        color: Qt.rgba(0,0,0,0.15)
        visible: parent.checkable & parent.checked || parent.down
        radius: 6
    }

    Image {
        anchors.fill: parent
        anchors.margins: anchorMargins
        source: parent.iconSource
        fillMode: Image.PreserveAspectFit
        opacity: enabled ? (toolButtonMouseArea.containsMouse ? 1 : 0.9) : 0.45
        property real anchorMargins: toolButtonMouseArea.containsMouse ? 8 : 10
        Behavior on anchorMargins { NumberAnimation { duration: 250 } }
    }

    Shortcut {
        id: toolButtonShortcut
        context: Qt.ApplicationShortcut
        enabled: !modalDialog.active
        onActivated: toolButton.click()
    }

    ToolTip.text: text + "\t(" + shortcut + ")"
    ToolTip.visible: toolButtonMouseArea.containsMouse ? toolTipVisibility.get : false

    DelayedPropertyBinder {
        id: toolTipVisibility
        initial: false
        set: toolButtonMouseArea.containsMouse
        delay: 1000
    }

    MouseArea {
        id: toolButtonMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: toolButton.click()
    }

    function click() {
        if(checkable) {
            checked = !checked
            toggled()
        } else {
            clicked()
        }
    }
}
/****************************************************************************
**
** Copyright (C) Prashanth Udupa, Bengaluru
** Email: prashanth.udupa@gmail.com
**
** This code is distributed under GPL v3. Complete text of the license
** can be found here: https://www.gnu.org/licenses/gpl-3.0.txt
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/

import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import Scrite 1.0

Item {
    id: documentUI
    width: 1470
    height: 865

    Rectangle {
        id: appToolBarArea
        anchors.left: parent.left
        anchors.right: parent.right
        height: appToolBar.height + 10
        color: "lightgray"

        ToolBar {
            id: appToolBar

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            background: Rectangle {
                color: appToolBarArea.color
            }

            Row {
                id: appFileTools
                spacing: 5

                ToolButton2 {
                    icon.source: "../icons/content/create.png"
                    text: "New"
                    shortcut: "Ctrl+N"
                    shortcutText: "N"
                    onClicked: {
                        if(scriteDocument.modified)
                            askQuestion({
                                "question": "Do you want to save your current project first?",
                                "okButtonText": "Yes",
                                "cancelButtonText": "No",
                                "callback": function(val) {
                                    if(val) {
                                        if(scriteDocument.fileName !== "")
                                            scriteDocument.save()
                                        else {
                                            cmdSave.doClick()
                                            return
                                        }
                                    }
                                    resetContentAnimation.start()
                                }
                            }, this)
                        else
                            resetContentAnimation.start()
                    }
                }

                ToolButton2 {
                    icon.source: "../icons/file/folder_open.png"
                    text: "Open"
                    shortcut: "Ctrl+O"
                    shortcutText: "O"
                    onClicked: {
                        if(scriteDocument.modified)
                            askQuestion({
                                "question": "Do you want to save your current project first?",
                                "okButtonText": "Yes",
                                "cancelButtonText": "No",
                                "callback": function(val) {
                                    if(val) {
                                        if(scriteDocument.fileName !== "")
                                            scriteDocument.save()
                                        else {
                                            cmdSave.doClick()
                                            return
                                        }
                                    }
                                    fileDialog.launch("OPEN")
                                }
                            }, this)
                        else
                            fileDialog.launch("OPEN")
                    }
                }

                ToolButton2 {
                    id: cmdSave
                    icon.source: "../icons/content/save.png"
                    text: "Save"
                    shortcut: "Ctrl+S"
                    shortcutText: "S"
                    onClicked: doClick()
                    function doClick() {
                        if(scriteDocument.fileName === "")
                            fileDialog.launch("SAVE")
                        else
                            scriteDocument.save()
                    }
                }

                ToolButton2 {
                    display: AbstractButton.TextBesideIcon
                    text: "Save As"
                    shortcut: "Ctrl+Shift+S"
                    shortcutText: "Shift+S"
                    onClicked: fileDialog.launch("SAVE")
                }

                Rectangle {
                    width: 1
                    height: parent.height
                    color: "black"
                }

                ToolButton2 {
                    icon.source: "../icons/file/file_download.png"
                    text: "Import"
                    shortcut: "Ctrl+Shift+I"
                    shortcutText: "Shift+I"
                    down: importMenu.visible
                    onClicked: importMenu.visible = true

                    Item {
                        anchors.top: parent.bottom
                        anchors.left: parent.left

                        Menu {
                            id: importMenu

                            Repeater {
                                model: scriteDocument.supportedImportFormats

                                MenuItem {
                                    text: modelData
                                    onClicked: {
                                        if(scriteDocument.modified)
                                            askQuestion({
                                                "question": "Do you want to save your current project first?",
                                                "okButtonText": "Yes",
                                                "cancelButtonText": "No",
                                                "callback": function(val) {
                                                    if(val) {
                                                        if(scriteDocument.fileName !== "")
                                                            scriteDocument.save()
                                                        else {
                                                            cmdSave.doClick()
                                                            return
                                                        }
                                                    }
                                                    fileDialog.launch("IMPORT " + modelData)
                                                }
                                            }, this)
                                        else
                                            fileDialog.launch("IMPORT " + modelData)
                                    }
                                }
                            }
                        }
                    }
                }

                ToolButton2 {
                    icon.source: "../icons/file/file_upload.png"
                    text: "Export"
                    shortcut: "Ctrl+Shift+E"
                    shortcutText: "Shift+E"
                    down: exportMenu.visible
                    onClicked: exportMenu.visible = true

                    Item {
                        anchors.top: parent.bottom
                        anchors.left: parent.left

                        Menu {
                            id: exportMenu

                            Repeater {
                                model: scriteDocument.supportedExportFormats

                                MenuItem {
                                    text: modelData
                                    onClicked: fileDialog.launch("EXPORT " + modelData)
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: 1
                    height: parent.height
                    color: "black"
                }

                ToolButton2 {
                    icon.source: "../icons/action/settings_applications.png"
                    text: "Settings"
                    shortcut: "Ctrl+,"
                    shortcutText: ","
                    onClicked: {
                        modalDialog.popupSource = this
                        modalDialog.sourceComponent = optionsDialogComponent
                        modalDialog.active = true
                    }
                }
            }
        }

        Item {
            anchors.right: parent.right
            width: parent.width - appFileTools.width - 20
            height: parent.height

            Rectangle {
                anchors.fill: globalSceneEditorToolbar
                anchors.margins: -5
                opacity: 0.25
                radius: 8
                border { width: 1; color: "black" }
                color: globalSceneEditorToolbar.enabled ? "white" : "black"
            }

            SceneEditorToolbar {
                id: globalSceneEditorToolbar
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: appLogo.left
                binder: sceneEditor ? sceneEditor.binder : null
                editor: sceneEditor ? sceneEditor.editor : null
                enabled: sceneEditor ? sceneEditor.editorHasActiveFocus : false
                property Item sceneEditor
            }

            Image {
                id: appLogo
                source: "../images/teriflix_logo.png"
                height: parent.height
                smooth: true
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        modalDialog.sourceComponent = aboutBoxComponent
                        modalDialog.popupSource = parent
                        modalDialog.active = true
                    }
                }
            }
        }
    }

    Loader {
        id: contentLoader
        active: true
        sourceComponent: documentUiContentComponent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: appToolBarArea.bottom
        anchors.bottom: parent.bottom
        onActiveChanged: {
            globalSceneEditorToolbar.sceneEditor = null
        }
    }

    SequentialAnimation {
        id: resetContentAnimation
        property string filePath
        property var callback
        property bool openFileDialog: false

        PropertyAnimation {
            target: contentLoader
            properties: "opacity"
            from: 1; to: 0
            duration: 100
        }

        ScriptAction {
            script: {
                contentLoader.active = false
                if(resetContentAnimation.filePath === "")
                    scriteDocument.reset()
                else
                    resetContentAnimation.callback(resetContentAnimation.filePath)
                resetContentAnimation.filePath = ""
                resetContentAnimation.callback = undefined
                contentLoader.active = true

                if(resetContentAnimation.openFileDialog)
                    fileDialog.open()
                resetContentAnimation.openFileDialog = false
            }
        }

        PropertyAnimation {
            target: contentLoader
            properties: "opacity"
            from: 0; to: 1
            duration: 100
        }
    }

    Component {
        id: documentUiContentComponent

        SplitView {
            orientation: Qt.Vertical

            Rectangle {
                SplitView.preferredHeight: documentUI.height * 0.75
                SplitView.minimumHeight: documentUI.height * 0.5

                SplitView {
                    anchors.fill: parent
                    orientation: Qt.Horizontal

                    Rectangle {
                        SplitView.preferredWidth: documentUI.width * 0.4
                        color: "lightgray"

                        Rectangle {
                            id: structureEditor
                            anchors.fill: parent
                            anchors.margins: 2
                            border { width: 1; color: "gray" }
                            radius: 5
                            color: Qt.rgba(1,1,1,0.5)

                            property var tabs: ["Structure", "Notebook"]

                            Item {
                                id: structureEditorTabs
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: 5
                                height: 45
                                property int currentIndex: 0

                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    anchors.bottom: parent.bottom
                                    color: "black"
                                }

                                Row {
                                    height: parent.height
                                    anchors.centerIn: parent

                                    Repeater {
                                        id: structureEditorTabGenerator
                                        model: structureEditor.tabs

                                        Item {
                                            width: tabLabel.width + 120
                                            height: structureEditorTabs.height
                                            property bool isActiveTab: structureEditorTabs.currentIndex === index

                                            Rectangle {
                                                anchors.fill: parent
                                                anchors.margins: isActiveTab ? 0 : 3
                                                color: isActiveTab ? "white" : "lightgray"
                                                border.width: 1
                                                border.color: "black"

                                                Text {
                                                    id: tabLabel
                                                    text: modelData
                                                    anchors.centerIn: parent
                                                    font.pixelSize: isActiveTab ? 18 : 14
                                                    font.bold: isActiveTab
                                                }

                                                Rectangle {
                                                    width: parent.width-2
                                                    height: 3
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    anchors.verticalCenter: parent.bottom
                                                    color: "white"
                                                    visible: isActiveTab
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: structureEditorTabs.currentIndex = index
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                anchors.fill: structureEditorContent
                                anchors.margins: -1
                                border { width: 1; color: "lightgray" }
                                radius: 5
                            }

                            SwipeView {
                                id: structureEditorContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: structureEditorTabs.bottom
                                anchors.bottom: parent.bottom
                                anchors.margins: 5
                                clip: true

                                interactive: false
                                currentIndex: structureEditorTabs.currentIndex

                                StructureView {
                                    id: structureView
                                    onRequestEditor: {
                                        if(scriteDocument.structure.currentElementIndex >= 0)
                                            editorLoader.sourceComponent = sceneEditorComponent
                                        else
                                            editorLoader.sourceComponent = screenplayEditorComponent
                                    }
                                }

                                NotebookView { }
                            }
                        }
                    }

                    Rectangle {
                        SplitView.preferredWidth: documentUI.width * 0.6
                        color: "lightgray"

                        TextArea {
                            readOnly: true
                            width: parent.width*0.7
                            anchors.centerIn: parent
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 30
                            enabled: false
                            visible: editorLoader.item == null
                            text: "Select a scene on the canvas or in the screenplay to edit its content here."
                        }

                        Loader {
                            id: editorLoader
                            anchors.fill: parent
                            sourceComponent: scriteDocument.screenplay.elementCount > 0 ? screenplayEditorComponent : null
                        }
                    }
                }
            }

            Item {
                ScreenplayView {
                    id: screenplayView
                    anchors.fill: parent
                    anchors.margins: 5
                    border { width: 1; color: "lightgray" }
                    radius: 5
                    onRequestEditor: editorLoader.sourceComponent = screenplayEditorComponent
                }
            }
        }
    }

    Component {
        id: screenplayEditorComponent

        Rectangle {
            id: screenplayEditorItem
            clip: true
            color: "lightgray"

            ScreenplayEditor {
                id: screenplayEditor
                anchors.fill: parent
                onCurrentSceneEditorChanged: globalSceneEditorToolbar.sceneEditor = currentSceneEditor
            }
        }
    }

    Component {
        id: sceneEditorComponent

        Rectangle {
            id: sceneEditorView
            color: sceneEditor.backgroundColor

            SceneEditor {
                id: sceneEditor
                anchors.fill: parent
                property StructureElement element: scriteDocument.structure.elementAt(scriteDocument.structure.currentElementIndex)
                scene: element ? element.scene : null
            }

            Component.onCompleted: globalSceneEditorToolbar.sceneEditor = sceneEditor
        }
    }

    Component {
        id: aboutBoxComponent
        AboutBox { }
    }

    Component {
        id: optionsDialogComponent
        OptionsDialog { }
    }

    FileDialog {
        id: fileDialog
        nameFilters: modes[mode].nameFilters
        selectFolder: false
        selectMultiple: false
        folder: shortcuts.home
        sidebarVisible: true
        selectExisting: modes[mode].selectExisting
        property string mode: "OPEN"

        property ErrorReport errorReport: Aggregation.findErrorReport(scriteDocument)
        Notification.title: modes[mode].notificationTitle
        Notification.text: errorReport.errorMessage
        Notification.active: errorReport.hasError
        Notification.autoClose: false

        Component.onCompleted: {
            var availableModes = {
                "OPEN": {
                    "nameFilters": ["Scrite Projects (*.scrite)"],
                    "selectExisting": true,
                    "callback": function(path) {
                        scriteDocument.open(path)
                    },
                    "reset": true,
                    "notificationTitle": "Opening Scrite Project"
                },
                "SAVE": {
                    "nameFilters": ["Scrite Projects (*.scrite)"],
                    "selectExisting": false,
                    "callback": function(path) {
                        scriteDocument.saveAs(path)
                    },
                    "reset": false,
                    "notificationTitle": "Saving Scrite Project"
                }
            }

            scriteDocument.supportedImportFormats.forEach(function(format) {
                availableModes["IMPORT " + format] = {
                    "nameFilters": scriteDocument.importFormatFileSuffix(format),
                    "selectExisting": true,
                    "callback": function(path) {
                        scriteDocument.importFile(path, format)
                    },
                    "reset": true,
                    "notificationTitle": "Creating Scrite project from " + format
                }
            })

            scriteDocument.supportedExportFormats.forEach(function(format) {
                availableModes["EXPORT " + format] = {
                    "nameFilters": scriteDocument.exportFormatFileSuffix(format),
                    "selectExisting": false,
                    "callback": function(path) {
                        scriteDocument.exportFile(path, format)
                    },
                    "reset": false,
                    "notificationTitle": "Exporting Scrite project to " + format
                }
            })

            modes = availableModes
        }

        property var modes

        function launch(launchMode) {
            mode = launchMode
            var modeInfo = modes[mode]
            if(modeInfo["reset"] === true) {
                resetContentAnimation.openFileDialog = true
                resetContentAnimation.start()
            } else
                open()
        }

        onAccepted: {
            resetContentAnimation.filePath = app.urlToLocalFile(fileUrl)
            resetContentAnimation.callback = modes[mode].callback
            resetContentAnimation.start()
        }
    }
}

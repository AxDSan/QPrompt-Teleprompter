/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2023 Javier O. Cordero Pérez
 **
 ** This file is part of QPrompt.
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, version 3 of the License.
 **
 ** This program is distributed in the hope that it will be useful,
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ** GNU General Public License for more details.
 **
 ** You should have received a copy of the GNU General Public License
 ** along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **
 ****************************************************************************/

import QtQuick 2.12
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import Qt.labs.platform 1.1 as Labs
import QtCore 6.5

import com.cuperino.qprompt 1.0

Kirigami.ApplicationWindow {
    id: root
    property bool __fullScreen: false
    property bool __fakeFullscreen: false
    property bool __autoFullScreen: false
    readonly property bool fullScreenOrFakeFullScreen: visibility===Kirigami.ApplicationWindow.FullScreen || __fakeFullscreen && __fullScreen && visibility===Kirigami.ApplicationWindow.Maximized
    // The following line includes macOS among the list of platforms where full screen buttons are hidden. This is done intentionally because macOS provides its own full screen buttons on the window frame and global menu. We shall not mess with what users of each platform expect.
    property bool fullScreenPlatform: Kirigami.Settings.isMobile || ['android', 'ios', 'wasm', 'tvos', 'qnx', 'ipados', 'osx'].indexOf(Qt.platform.os)!==-1
    //readonly property bool __translucidBackground: !Material.background.a // === 0
    //readonly property bool __translucidBackground: !Kirigami.Theme.backgroundColor.a && ['ios', 'wasm', 'tvos', 'qnx', 'ipados'].indexOf(Qt.platform.os)===-1
    property bool __translucidBackground: true
    readonly property bool __windowStayOnTop: root.pageStack.currentItem.footer.windowStaysOnTop
    property bool shadows: false
    readonly property bool __isMobile: Kirigami.Settings.isMobile
    readonly property bool themeIsMaterial: Kirigami.Settings.style==="Material" // || Kirigami.Settings.isMobile
    // mobileOrSmallScreen helps determine when to follow mobile behaviors from desktop non-mobile devices
    readonly property bool mobileOrSmallScreen: Kirigami.Settings.isMobile || root.width < 1220
    //readonly property bool __translucidBackground: false
    // Scrolling settings
    property bool __scrollAsDial: false
    property bool __invertArrowKeys: false
    property bool __invertScrollDirection: false
    property bool __noScroll: false
    property bool __telemetry: true
    property bool forceQtTextRenderer: false
    property bool passiveNotifications: true
    property bool __throttleWheel: true
    property int __wheelThrottleFactor: 8
    //property int prompterVisibility: Kirigami.ApplicationWindow.Maximized
    property double __opacity: 1
    property int __iDefault: 3
    property int onDiscard: Prompter.CloseActions.Ignore
    property bool ee: false
    property bool theforce: false
    property int transparencyRestartModulus: 1

    title: root.pageStack.currentItem.document.fileName + (root.pageStack.currentItem.document.modified?"*":"") + " - " + aboutData.displayName
    width: 1220  // Set at 1220 to show all functionality at a glance. Set to 1200 to fit both 1280 4:3 and 1200 height monitors. Keep at or bellow 1024 and at or above 960, for best usability with common 4:3 resolutions
    height: 728  // Keep and test at 728 so that it works well with 1366x768 screens.
    // Making width and height start maximized
    //width: screen.desktopAvailableWidth
    //height: screen.desktopAvailableHeight
    minimumWidth: Kirigami.Settings.isMobile ? 291 : 351 // 338
    minimumHeight: minimumWidth

    Settings {
        category: "mainWindow"
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height
        property alias fakeFullScreen: root.__fakeFullscreen
    }
    Settings {
        category: "scroll"
        property alias noScroll: root.__noScroll
        property alias scrollAsDial: root.__scrollAsDial
        property alias invertScrollDirection: root.__invertScrollDirection
        property alias invertArrowKeys: root.__invertArrowKeys
        property alias throttleWheel: root.__throttleWheel
        property alias wheelThrottleFactor: root.__wheelThrottleFactor
    }
    Settings {
        category: "editor"
        property alias forceQtTextRenderer: root.forceQtTextRenderer
    }
    Settings {
        category: "prompter"
        property alias stepsDefault: root.__iDefault
    }
    Settings {
        category: "background"
        property alias opacity: root.__opacity
        property alias transparency: root.__translucidBackground
        property alias shadows: root.shadows
    }
    Settings {
        category: "telemetry"
        property alias enabled: root.__telemetry
    }

    //// Theme management
    //Material.theme: themeSwitch.checked ? Material.Dark : Material.Light  // This is correct, but it isn't work working, likely because of Kirigami

    // Make backgrounds transparent
    //Material.background: "transparent"
    color: root.__translucidBackground ? "transparent" : "initial"
    // More ways to enforce transparency across systems
    //visible: true
    readonly property int hideDecorators: root.pageStack.currentItem.overlay.atTop && !root.pageStack.currentItem.viewport.forcedOrientation && parseInt(root.pageStack.currentItem.prompter.state)!==Prompter.States.Editing || Qt.platform.os==="osx" && root.pageStack.currentItem.prompterBackground.opacity!==1 || __fullScreen && __fakeFullscreen && visibility===Kirigami.ApplicationWindow.Maximized ? Qt.FramelessWindowHint : Qt.Window
    flags: this.__windowStayOnTop ? hideDecorators | Qt.WindowStaysOnTopHint : hideDecorators

    background: Rectangle {
        id: appTheme
        color: __backgroundColor
        opacity: (root.pageStack.layers.depth > 1 || (!root.__translucidBackground || root.pageStack.currentItem.prompterBackground.opacity===1)) ? 1.0 : 0.0
        //readonly property color __fontColor: parent.Material.theme===Material.Light ? "#212121" : "#fff"
        //readonly property color __iconColor: parent.Material.theme===Material.Light ? "#232629" : "#c3c7d1"
        //readonly property color __backgroundColor: __translucidBackground ? (parent.Material.theme===Material.Dark ? "#303030" : "#fafafa") : Kirigami.Theme.backgroundColor
        //readonly property color __backgroundColor: __translucidBackground ? (themeSwitch.checked ? "#303030" : "#fafafa") : Kirigami.Theme.backgroundColor
        property int selection: 0
        //readonly property color __backgroundColor: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 1)
        property color __backgroundColor: switch(appTheme.selection) {
            case 0: return Qt.rgba(Kirigami.Theme.backgroundColor.r/4, Kirigami.Theme.backgroundColor.g/4, Kirigami.Theme.backgroundColor.b/4, 1);
            case 1: return "#303030";
            case 2: return "#FAFAFA";
        }
    }

    // Full screen
    visibility: __fullScreen ? (__fakeFullscreen ? Kirigami.ApplicationWindow.Maximized : Kirigami.ApplicationWindow.FullScreen) : (!__autoFullScreen ? Kirigami.ApplicationWindow.AutomaticVisibility : (parseInt(root.pageStack.currentItem.prompter.state)===Prompter.States.Editing ? Kirigami.ApplicationWindow.Maximized : (__fakeFullscreen ? Kirigami.ApplicationWindow.Maximized : Kirigami.ApplicationWindow.FullScreen)))

    onWidthChanged: {
        root.pageStack.currentItem.footer.paragraphSpacingSlider.update()
    }

    // Open save dialog on closing
    onClosing: function (close) {
        root.onDiscard = Prompter.CloseActions.Quit
        if (root.pageStack.currentItem.document.modified) {
            closeDialog.open()
            close.accepted = false
        }
    }

    function loadAboutPage() {
        root.pageStack.layers.clear()
        root.pageStack.layers.push(aboutPageComponent, {aboutData: aboutData})
    }
    function loadPathsPage() {
        root.pageStack.layers.clear()
        root.pageStack.layers.push(pathsPageComponent, {})
    }
    function loadRemoteControlPage() {
        root.pageStack.layers.clear()
        root.pageStack.layers.push(remoteControlPageComponent, {})
    }
    function loadTelemetryPage() {
        root.pageStack.layers.clear()
        root.pageStack.layers.push(telemetryPageComponent)
    }

    // Left Global Drawer
    globalDrawer: Kirigami.GlobalDrawer {
        id: globalMenu

        property int bannerCounter: 0
        // isMenu: true
        title: aboutData.displayName
        titleIcon: ["android"].indexOf(Qt.platform.os)===-1 ? "qrc:/qt/qml/com/cuperino/qprompt/images/qprompt.png" : "qrc:/qt/qml/com/cuperino/qprompt/images/qprompt-logo-wireframe.png"
//        bannerVisible: true
//        onBannerClicked: {
//            bannerCounter++;
//            // Enable easter eggs.
//            if (!(bannerCounter%10))
//                ee = true
//        }
        onOpened: function() {
            cursorAutoHide.reset();
        }
        onClosed: function() {
            cursorAutoHide.restart();
        }
        actions: [
            Kirigami.Action {
                text: i18nc("Main menu and global menu actions", "&New")
                //icon.name: "document-new"
                icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/document-new.svg"
                shortcut: StandardKey.New
                onTriggered: root.pageStack.currentItem.document.newDocument()
            },
            Kirigami.Action {
                text: i18nc("Main menu and global menu actions", "&Open")
                //icon.name: "document-open"
                icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/document-open.svg"
                shortcut: StandardKey.Open
                onTriggered: {
                    root.onDiscard = Prompter.CloseActions.Open
                    root.pageStack.currentItem.document.open()
                }
            },
            Kirigami.Action {
                text: i18nc("Main menu and global menu actions", "&Open remote file")
                //icon.name: "document-open-remote"
                icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/document-open-remote.svg"
                onTriggered: {
                    root.onDiscard = Prompter.CloseActions.Network
                    root.pageStack.currentItem.document.openFromNetwork()
                }
            },
            Kirigami.Action {
                text: i18nc("Main menu and global menu actions", "&Save")
                //icon.name: "document-save"
                icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/document-save.svg"
                shortcut: StandardKey.Save
                onTriggered: {
                    root.onDiscard = Prompter.CloseActions.Ignore
                    root.pageStack.currentItem.document.saveDialog()
                }
            },
            Kirigami.Action {
                text: i18nc("Main menu and global menu actions", "Save &As")
                //icon.name: "document-save-as"
                icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/document-save-as.svg"
                shortcut: StandardKey.SaveAs
                onTriggered: {
                    root.onDiscard = Prompter.CloseActions.Ignore
                    root.pageStack.currentItem.document.saveAsDialog()
                }
            },
            Kirigami.Action {
                visible: false
                text: i18nc("Main menu actions", "&Recent Files")
                //icon.name: "document-open-recent"
                icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/document-open-recent.svg"
                //Kirigami.Action {
                    //text: i18n("View Action 1")
                    //onTriggered: showPassiveNotification(i18n("View Action 1 clicked"))
                //}
            },
            Kirigami.Action {
                text: i18nc("Main menu actions. Menu regarding input settings.", "&Controls Settings")
                //icon.name: "transform-browse" // "hand"
                icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/transform-browse.svg"
                Kirigami.Action {
                    visible: ["android", "ios", "tvos", "ipados", "qnx"].indexOf(Qt.platform.os)===-1
                    text: i18nc("Main menu and global menu actions. Opens dialog to configure keyboard inputs.", "Keyboard Inputs")
                    //icon.name: "key-enter" // "keyboard"
                    icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/key-enter.svg"
                    onTriggered: root.pageStack.currentItem.keyConfigurationOverlay.open()
                }
                Kirigami.Action {
                    visible: ["android", "ios", "tvos", "ipados", "qnx"].indexOf(Qt.platform.os)===-1
                    text: i18nc("Open 'scroll settings' from main menu and global menu actions", "Scroll throttle settings")
                    //icon.name: "gnumeric-object-scrollbar" // "keyboard"
                    icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/gnumeric-object-scrollbar.svg"
                    onTriggered: wheelSettings.open()
                }
                Kirigami.Action {
                    text: i18nc("Main menu and global menu actions. Have up arrow behave like down arrow and vice versa while prompting.", "Invert &arrow keys")
                    enabled: !root.__noScroll
                    //icon.name: "circular-arrow-shape"
                    icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/circular-arrow-shape.svg"
                    checkable: true
                    checked: root.__invertArrowKeys
                    onTriggered: root.__invertArrowKeys = checked
                }
                Kirigami.Action {
                    text: i18nc("Main menu and global menu actions. Invert scroll direction while prompting.", "Invert &scroll direction")
                    enabled: !root.__noScroll
                    //icon.name: "gnumeric-object-scrollbar"
                    icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/gnumeric-object-scrollbar.svg"
                    checkable: true
                    checked: root.__invertScrollDirection
                    onTriggered: root.__invertScrollDirection = checked
                }
                Kirigami.Action {
                    text: i18nc("Main menu and global menu actions. Have touchpad and mouse wheel scrolling adjust velocity instead of scrolling like most other apps.", "Use scroll as velocity &dial")
                    enabled: !root.__noScroll
                    //icon.name: "filename-bpm-amarok"
                    icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/filename-bpm-amarok.svg"
                    // ToolTip.text: i18n("Use mouse and touchpad scroll as speed dial while prompting")
                    checkable: true
                    checked: root.__scrollAsDial
                    onTriggered: root.__scrollAsDial = checked
                }
                Kirigami.Action {
                    text: i18nc("Main menu and global menu actions. Touchpad scrolling and mouse wheel use have no effect while prompting.", "Disable scrolling while prompting")
                    //icon.name: "paint-none"
                    icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/paint-none.svg"
                    checkable: true
                    checked: root.__noScroll
                    onTriggered: root.__noScroll = checked
                }
            },
            Kirigami.Action {
                text: i18nc("Main menu actions", "Other &Settings")
                //icon.name: "configure"
                icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/configure.svg"
//                 Kirigami.Action {
//                     text: i18n("Telemetry")
//                     //icon.name: "document-send"
//                     onTriggered: {
//                         root.loadTelemetryPage()
//                     }
//                 }
                Kirigami.Action {
                    text: i18nc("Main menu actions. Load Path Settings page.", "External Tools and Applications")
                    visible: ['android', 'ios', 'tvos', 'wasm'].indexOf(Qt.platform.os)===-1
                    icon.name: "akonadiconsole"
                    // icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/akonadiconsole.svg"
                    onTriggered: loadPathsPage();
                }
                Kirigami.Action {
                    text: i18nc("Main menu actions. Opens dialog for choosing layout direction.", "Layout direction")
                    icon.source: Qt.application.layoutDirection===Qt.LeftToRight ? "qrc:/qt/qml/com/cuperino/qprompt/icons/format-text-direction-rtl.svg" : "qrc:/qt/qml/com/cuperino/qprompt/icons/format-text-direction-ltr.svg"
                    onTriggered: layoutDirectionSettings.open()
                }
                Kirigami.Action {
                    text: i18nc("Main menu actions. Enters Performance tweaks submenu.", "Performance tweaks")
                    // Kirigami.Action {
                    //     text: i18nc("Main menu actions", "Disable screen projections")
                    //     enabled: !checked
                    //     checkable: true
                    //     checked: !projectionManager.isEnabled
                    //     onTriggered: projectionManager.toggle()
                    // }
                    Kirigami.Action {
                        text: i18nc("Main menu actions", "Disable timers")
                        enabled: !checked
                        checkable: true
                        checked: !root.pageStack.currentItem.viewport.timer.timersEnabled
                        onTriggered: root.pageStack.currentItem.viewport.timer.enabled = !checked
                    }
                    Kirigami.Action {
                        id: hideFormattingToolsWhilePromptingSetting
                        enabled: !hideFormattingToolsAlwaysSetting.checked
                        text: i18nc("Main menu actions. Hides formatting tools while not in edit mode.", "Auto hide formatting tools")
                        icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/list-remove.svg"
                        checkable: true
                        checked: root.pageStack.currentItem.footer.hideFormattingToolsWhilePrompting
                        onTriggered: root.pageStack.currentItem.footer.hideFormattingToolsWhilePrompting = checked
                    }
                    Kirigami.Action {
                        id: hideFormattingToolsAlwaysSetting
                        text: i18nc("Main menu actions", "Always hide formatting tools")
                        icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/newline.svg"
                        checkable: true
                        checked: root.pageStack.currentItem.footer.hideFormattingToolsAlways
                        onTriggered: root.pageStack.currentItem.footer.hideFormattingToolsAlways = checked
                    }
                    Kirigami.Action {
                        id: enableOverlayContrastSetting
                        text: i18nc("Main menu actions. Disables contrast effect for the reading region overlay.", "Disable overlay contrast")
                        icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/edit-opacity.svg"
                        checkable: true
                        checked: root.pageStack.currentItem.overlay.disableOverlayContrast
                        onTriggered: root.pageStack.currentItem.overlay.disableOverlayContrast = checked
                    }
                    Kirigami.Action {
                        id: transparencySetting
                        property bool dirty: false
                        visible: ["android", "ios", "tvos", "ipados", "qnx"].indexOf(Qt.platform.os)===-1
                        text: i18n("Disable background transparency")
                        icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/contrast.svg"
                        checkable: true
                        checked: !root.__translucidBackground
                        onTriggered: {
                            root.__translucidBackground = !root.__translucidBackground;
                            if (!transparencySetting.dirty) {
                                transparencySetting.dirty = true;
                                if (transparencyRestartModulus % 2) {
                                    restartDialog.visible = true;
                                    transparencyRestartModulus = 0;
                                }
                                else
                                    transparencyRestartModulus++;
                            }
                        }
                    }
                    Kirigami.Action {
                        id: subpixelSetting
                        text: i18nc("Main menu actions. QPrompt switches between two text rendering techniques when the base font size exceeds 120px. Enabling this option forces QPrompt to always use the default renderer, which features smoother sub-pixel animations.", "Force sub-pixel text renderer past 120px")
                        // Hiding option because only Qt text renderer is used on devices of greater pixel density, due to bug in rendering native fonts while scaling is enabled.
                        visible: ['android', 'ios', 'wasm', 'tvos', 'qnx', 'ipados'].indexOf(Qt.platform.os)===-1 && screen.devicePixelRatio === 1.0
                        // icon.name: "format-font-size-more"
                        icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/format-font-size-more.svg"
                        checkable: true
                        checked: root.forceQtTextRenderer
                        onTriggered: root.forceQtTextRenderer = checked
                    }
                }
                Kirigami.Action {
                    text: i18nc("Main menu actions. Enters Other tweaks submenu.", "Other tweaks")
                    icon.source: ""
                    Kirigami.Action {
                        text: i18nc("Main menu actions. Enable local file auto reload", "Local file auto reload")
                        icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/document-open.svg"
                        checkable: true
                        checked: root.pageStack.currentItem.document.autoReload
                        onTriggered: root.pageStack.currentItem.document.autoReload = checked
                    }
                    Kirigami.Action {
                        id: fakeFullscreenSetting
                        text: i18nc("Main menu actions. Fake fullscreen behavior instead of requesting true fullscreen", "Fake fullscreen behavior")
                        visible: ['linux'].indexOf(Qt.platform.os)!==-1
                        icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/view-fullscreen.svg"
                        checkable: true
                        checked: root.__fakeFullscreen
                        onTriggered: root.__fakeFullscreen = checked
                    }
                }
//                 Kirigami.Action {
//                     text: i18nc("Main menu actions", "Restore factory defaults")
//                     //icon.name: "edit-clear-history"
//                     icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/edit-clear-history.svg"
//                     onTriggered: {
//                         showPassiveNotification(i18n("Feature not yet implemented"))
//                     }
//                 }
            },
            Kirigami.Action {
                text: i18nc("Main menu actions. Load about page.", "Abou&t %1", aboutData.displayName)
                //icon.name: "help-about"
                icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/help-about.svg"
                onTriggered: loadAboutPage()
            },
            Kirigami.Action {
                visible: !Kirigami.Settings.isMobile
                text: i18nc("Main menu and global menu actions", "&Quit")
                //icon.name: "application-exit"
                icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/application-exit.svg"
                shortcut: StandardKey.Quit
                onTriggered: close()
            },
            // Global shortcuts
            // On ESC pressed, return to PrompterEdit mode.
            Kirigami.Action {
                visible: false
                onTriggered: {
                    // Close all sub pages
                    if (root.pageStack.layers.depth > 1) {
                        root.pageStack.layers.clear();
                        root.pageStack.currentItem.prompter.restoreFocus()
                    }
                    // Close open drawers
                    else if (root.pageStack.currentItem.markersDrawer.drawerOpen)
                        root.pageStack.currentItem.markersDrawer.toggle()
                    // Close open overlay sheets
                    else if (root.pageStack.currentItem.countdownConfiguration.opened)
                        root.pageStack.currentItem.countdownConfiguration.close()
                    else if (root.pageStack.currentItem.keyConfigurationOverlay.opened)
                        root.pageStack.currentItem.keyConfigurationOverlay.close()
                    else if (root.pageStack.currentItem.namedMarkerConfiguration.opened)
                        root.pageStack.currentItem.namedMarkerConfiguration.close()
                    else if (root.pageStack.currentItem.networkDialog.opened)
                        root.pageStack.currentItem.networkDialog.close()
                    else if (root.pageStack.currentItem.pointerConfiguration.opened)
                        root.pageStack.currentItem.pointerConfiguration.close()
                    else if (layoutDirectionSettings.opened)
                        layoutDirectionSettings.close()
                    else if (wheelSettings.opened)
                        wheelSettings.close()
                    // Close find, compare against enabled instead of isOpen to prevent closing find while it is invisible.
                    else if (root.pageStack.currentItem.find.enabled)
                        root.pageStack.currentItem.find.close()
                    // If editing while prompting, return focus to prompter, thus leaving edit while prompting mode.
                    else if (parseInt(root.pageStack.currentItem.prompter.state)===Prompter.States.Prompting && root.pageStack.currentItem.editor.focus)
                        root.pageStack.currentItem.prompter.focus = true;
                    // Return to edit mode if prompter is in focus
                    else if (root.pageStack.currentItem.prompter.activeFocus)
                        root.pageStack.currentItem.prompter.cancel()
                    // In any other situation, restore focus to the prompter
                    else
                       root.pageStack.currentItem.prompter.restoreFocus()
                }
                shortcut: StandardKey.Cancel
            },
            Kirigami.Action {
                visible: false
                onTriggered: root.__fullScreen = !root.__fullScreen
                shortcut: StandardKey.FullScreen
            }
        ]
        topContent: RowLayout {
            Button {
                text: i18nc("Main menu and global actions. Load document that welcomes users.", "Load &Welcome")
                flat: true
                onClicked: {
                    root.pageStack.currentItem.document.loadGuide()
                    globalMenu.close()
                }
            }
            // Button {
            //     text: i18nc("Main menu and global actions.", "Remote")
            //     flat: true
            //     onClicked: {
            //         root.pageStack.layers.push(remoteControlPageComponent, {})
            //         globalMenu.close()
            //     }
            // }
            // Button {
            //     id: themeSwitch
            //     text: i18nc("Main menu and global actions.", "Dark &Mode")
            //     flat: true
            //     onClicked: {
            //         appTheme.selection = (appTheme.selection + 1) % 3;
            //         const bg = Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 1);
            //         console.log(bg);
            //         // If the system theme is active, and its background is either black or the exact same as that of either the material light o dark theme's, skip the system theme.
            //         if (appTheme.selection===0 && (Qt.colorEqual(bg, "#000000") || Qt.colorEqual(bg, "#FAFAFA") || Qt.colorEqual(bg, "#303030")))
            //             appTheme.selection = (appTheme.selection + 1) % 3
            //         showPassiveNotification(i18n("Feature not fully implemented"))
            //     }
            // }
        }
        content: [
            Button {
                visible: {
                    const date = new Date();
                    return ee || date.getMonth()===4 && date.getDate()===4
                }
                text: i18n("Darth mode")
                flat: true
                checkable: true
                checked: root.theforce
                onClicked: {
                    root.theforce = checked
                    globalMenu.close()
                }
            }
        ]
    }

    LayoutDirectionSettingsOverlay {
        id: layoutDirectionSettings
    }

    WheelSettingsOverlay {
        id: wheelSettings
    }

    Labs.MenuBar {
        id: nativeMenus
        window: root
        menus: [
        Labs.Menu {
            title: i18nc("Global menu actions", "&File")

            Labs.MenuItem {
                text: i18nc("Main menu and global menu actions", "&New")
                onTriggered: root.pageStack.currentItem.document.newDocument()
            }
            Labs.MenuItem {
                text: i18nc("Main menu and global menu actions", "&Open")
                onTriggered: root.pageStack.currentItem.document.open()
            }
            Labs.MenuItem {
                text: i18nc("Main menu and global menu actions", "&Save")
                onTriggered: root.pageStack.currentItem.document.saveDialog()
            }
            Labs.MenuItem {
                text: i18nc("Main menu and global menu actions", "Save &As…")
                onTriggered: root.pageStack.currentItem.document.saveAsDialog()
            }
            Labs.MenuSeparator { }
            Labs.MenuItem {
                text: i18nc("Main menu and global menu actions", "&Quit")
                onTriggered: close()
            }
        },

        Labs.Menu {
            title: i18nc("Global menu actions", "&Edit")

            Labs.MenuItem {
                text: i18nc("Global menu actions", "&Undo")
                enabled: root.pageStack.currentItem.editor.canUndo
                onTriggered: root.pageStack.currentItem.editor.undo()
            }
            Labs.MenuItem {
                text: i18nc("Global menu actions", "&Redo")
                enabled: root.pageStack.currentItem.editor.canRedo
                onTriggered: root.pageStack.currentItem.editor.redo()
            }
            Labs.MenuSeparator { }
            Labs.MenuItem {
                text: i18nc("Global menu and editor context menu actions", "&Copy")
                enabled: root.pageStack.currentItem.editor.selectedText
                onTriggered: root.pageStack.currentItem.editor.copy()
            }
            Labs.MenuItem {
                text: i18nc("Global menu and editor context menu actions", "Cu&t")
                enabled: root.pageStack.currentItem.editor.selectedText
                onTriggered: root.pageStack.currentItem.editor.cut()
            }
            Labs.MenuItem {
                text: i18nc("Global menu and editor context menu actions", "&Paste")
                enabled: root.pageStack.currentItem.editor.canPaste
                onTriggered: root.pageStack.currentItem.editor.paste()
            }
        },

        Labs.Menu {
            title: i18nc("Global menu actions", "&View")

            Labs.MenuItem {
                text: i18nc("Global menu actions", "Full &screen")
                visible: !fullScreenPlatform
                checkable: true
                checked: root.__fullScreen
                onTriggered: root.__fullScreen = !root.__fullScreen
            }
            //Labs.MenuItem {
            //    text: i18n("&Auto full screen")
            //    checkable: true
            //    checked: root.__autoFullScreen
            //    onTriggered: root.__autoFullScreen = !root.__autoFullScreen
            //}
            Labs.MenuSeparator { }
            Labs.Menu {
                title: i18nc("Global menu actions. Indicators highlight reading region.", "&Indicators")
                Labs.MenuItem {
                    text: i18nc("Global menu actions. Shows pointer to the left of the reading region.", "&Left Pointer")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.LeftPointer
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.LeftPointer
                }
                Labs.MenuItem {
                    text: i18nc("Global menu actions. Shows pointer to the right of the reading region.", "&Right Pointer")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.RightPointer
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.RightPointer
                }
                Labs.MenuItem {
                    text: i18nc("Global menu actions. Shows pointers to the left and right of the reading region.", "B&oth Pointers")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.Pointers
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.Pointers
                }
                Labs.MenuSeparator { }
                Labs.MenuItem {
                    text: i18nc("Global menu actions. Translucent bars indicate reading region.", "&Bars")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.Bars
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.Bars
                }
                Labs.MenuItem {
                    text: i18nc("Global menu actions. Translucent bars and left pointer indicate reading region.", "Bars Lef&t")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.BarsLeft
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.BarsLeft
                }
                Labs.MenuItem {
                    text: i18nc("Global menu actions. Translucent bars and right pointer indicate reading region.", "Bars Ri&ght")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.BarsRight
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.BarsRight
                }
                Labs.MenuSeparator { }
                Labs.MenuItem {
                    text: i18nc("Global menu actions. Enable all reading region indicators.", "&All")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.All
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.All
                }
                Labs.MenuItem {
                    text: i18nc("Global menu actions. Disable all reading region indicators.", "&Hidden")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.None
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.None
                }
            }
            Labs.Menu {
                title: i18nc("Global menu actions. Reading region indicates where a talent should be reading from.", "Readin&g region")
                Labs.MenuItem {
                    text: i18nc("Global menu actions. Align reading region to top of prompter.", "&Top")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.positionState) === ReadRegionOverlay.PositionStates.Top
                    onTriggered: root.pageStack.currentItem.overlay.positionState = ReadRegionOverlay.PositionStates.Top
                }
                Labs.MenuItem {
                    text: i18nc("Global menu actions. Align reading region to vertical center of prompter.", "&Middle")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.positionState) === ReadRegionOverlay.PositionStates.Middle
                    onTriggered: root.pageStack.currentItem.overlay.positionState = ReadRegionOverlay.PositionStates.Middle
                }
                Labs.MenuItem {
                    text: i18nc("Global menu actions. Align reading region to bottom of prompter.", "&Bottom")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.positionState) === ReadRegionOverlay.PositionStates.Bottom
                    onTriggered: root.pageStack.currentItem.overlay.positionState = ReadRegionOverlay.PositionStates.Bottom
                }
                Labs.MenuSeparator { }
                Labs.MenuItem {
                    text: i18nc("Global menu actions. Enables drag and drop positioning of reading region.", "F&ree placement")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.positionState) === ReadRegionOverlay.PositionStates.Free
                    onTriggered: root.pageStack.currentItem.overlay.positionState = ReadRegionOverlay.PositionStates.Free
                }
                Labs.MenuItem {
                    text: i18nc("Global menu actions. Fix positioning of reading region to what was set in \"Free placement\" mode.", "C&ustom (Fixed placement)")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.positionState) === ReadRegionOverlay.PositionStates.Fixed
                    onTriggered: root.pageStack.currentItem.overlay.positionState = ReadRegionOverlay.PositionStates.Fixed
                }
            }
        },

        Labs.Menu {
            title: i18nc("Global menu actions", "For&mat")

            Labs.MenuItem {
                text: i18nc("Global menu actions", "&Bold")
                checkable: true
                checked: root.pageStack.currentItem.document.bold
                onTriggered: root.pageStack.currentItem.document.bold = checked
            }
            Labs.MenuItem {
                text: i18nc("Global menu actions", "&Italic")
                checkable: true
                checked: root.pageStack.currentItem.document.italic
                onTriggered: root.pageStack.currentItem.document.italic = checked
            }
            Labs.MenuItem {
                text: i18nc("Global menu actions", "&Underline")
                checkable: true
                checked: root.pageStack.currentItem.document.underline
                onTriggered: root.pageStack.currentItem.document.underline = checked
            }
            Labs.MenuSeparator { }
            Labs.MenuItem {
                text: Qt.application.layoutDirection===Qt.LeftToRight ? i18nc("Global menu and editor actions. Text alignment.", "Align &Left") : i18nc("Global menu and editor actions. Text alignment.", "Align &Right")
                checkable: true
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? root.pageStack.currentItem.document.alignment === Qt.AlignLeft : root.pageStack.currentItem.document.alignment === Qt.AlignRight
                onTriggered: {
                    if (Qt.application.layoutDirection===Qt.LeftToRight)
                        root.pageStack.currentItem.document.alignment = Qt.AlignLeft
                    else
                        root.pageStack.currentItem.document.alignment = Qt.AlignRight
                }
            }
            Labs.MenuItem {
                text: i18nc("Global menu actions. Text alignment.", "Align Cen&ter")
                checkable: true
                checked: root.pageStack.currentItem.document.alignment === Qt.AlignHCenter
                onTriggered: root.pageStack.currentItem.document.alignment = Qt.AlignHCenter
            }
            Labs.MenuItem {
                text: Qt.application.layoutDirection===Qt.LeftToRight ? i18nc("Global menu actions. Text alignment.", "Align &Right") : i18nc("Global menu actions. Text alignment.", "Align &Left")
                checkable: true
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? root.pageStack.currentItem.document.alignment === Qt.AlignRight : root.pageStack.currentItem.document.alignment === Qt.AlignLeft
                onTriggered: {
                    if (Qt.application.layoutDirection===Qt.LeftToRight)
                        root.pageStack.currentItem.document.alignment = Qt.AlignRight
                    else
                        root.pageStack.currentItem.document.alignment = Qt.AlignLeft
                }
            }
            // Justify is proven to make text harder to read for some readers. So I'm commenting out all text justification options from the program. I'm not removing them, only commenting out in case someone needs to re-enable. This article links to various sources that validate my decision: https://kaiweber.wordpress.com/2010/05/31/ragged-right-or-justified-alignment/ - Javier
            //Labs.MenuItem {
            //    text: i18nc("Global menu actions. Text alignment.", "Align &Justify")
            //    checkable: true
            //    checked: root.pageStack.currentItem.document.alignment === Qt.AlignJustify
            //    onTriggered: root.pageStack.currentItem.document.alignment = Qt.AlignJustify
            //}
            Labs.MenuSeparator { }
            Labs.MenuItem {
                text: i18nc("Global menu actions. Opens dialog to format currently selected text.", "C&haracter")
                onTriggered: root.pageStack.currentItem.document.showFontDialog();
            }
            Labs.MenuItem {
                text: i18nc("Global menu actions. Opens dialog to color currently selected text.", "Fo&nt Color")
                onTriggered: root.pageStack.currentItem.colorDialog.open()
            }
        },

        Labs.Menu {
            title: i18nc("Global menu actions. Menu regarding input settings.", "Controls")

            Labs.MenuItem {
                text: i18nc("Main menu and global menu actions. Touchpad scrolling and mouse wheel use have no effect while prompting.", "Disable scrolling while prompting")
                checkable: true
                checked: root.__noScroll
                onTriggered: root.__noScroll = checked
            }
            Labs.MenuItem {
                text: i18nc("Main menu and global menu actions. Have touchpad and mouse wheel scrolling adjust velocity instead of scrolling like most other apps.", "Use scroll as velocity &dial")
                enabled: !root.__noScroll
                checkable: true
                checked: root.__scrollAsDial
                onTriggered: root.__scrollAsDial = checked
            }
            Labs.MenuSeparator { }
            Labs.MenuItem {
                text: i18nc("Main menu and global menu actions. Have up arrow behave like down arrow and vice versa while prompting.", "Invert &arrow keys")
                enabled: !root.__noScroll
                checkable: true
                checked: root.__invertArrowKeys
                onTriggered: root.__invertArrowKeys = checked
            }
            Labs.MenuItem {
                text: i18nc("Main menu and global menu actions. Invert scroll direction while prompting.", "Invert &scroll direction")
                enabled: !root.__noScroll
                checkable: true
                checked: root.__invertScrollDirection
                onTriggered: root.__invertScrollDirection = checked
            }
        },

        Labs.Menu {
            title: i18nc("Global menu actions", "&Help")

            Labs.MenuItem {
                text: i18nc("Global menu actions", "Report &Bug…")
                onTriggered: Qt.openUrlExternally("Global menu actions", "https://feedback.qprompt.app")
                icon.name: "tools-report-bug"
            }
            Labs.MenuSeparator { }
            //Labs.MenuItem {
            //     visible: false
            //     text: i18n("Get &Studio Edition")
            //     onTriggered: Qt.openUrlExternally("https://studio.qprompt.app/")
            //     icon.name: "software-center"
            //}
            //Labs.MenuSeparator { }
            Labs.MenuItem {
                text: i18nc("Main menu and global actions. Load document that welcomes users.", "Load &Welcome")
                icon.name: "help-info"
                onTriggered: root.pageStack.currentItem.document.loadGuide()
            }
            Labs.MenuSeparator { }
            Labs.MenuItem {
                text: i18nc("Global menu actions. Load about page. \"About AppName\"", "Abou&t %1", aboutData.displayName)
                onTriggered: root.loadAboutPage()
                icon.source: "qrc:/qt/qml/com/cuperino/qprompt/images/qprompt.png"
            }
        }
        ]
    }

    // Right Context Drawer
    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
        onOpened: function() {
            cursorAutoHide.reset();
        }
        onClosed: function() {
            cursorAutoHide.restart();
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: function (wheel) {
                root.pageStack.currentItem.viewport.mouse.wheel(wheel)
            }
        }
    }
    MouseArea {
        height: 40
        anchors.left: parent.left
        anchors.right: parent.right
        acceptedButtons: Qt.NoButton
        onWheel: function (wheel) {
            root.pageStack.currentItem.viewport.mouse.wheel(wheel)
        }
    }

    CursorAutoHide {
        id: cursorAutoHide
        ignored: root.pageStack.currentItem.markersDrawer
        anchors.fill: parent
    }

    // Top bar foreground hack for window dragging
    WindowDragger {
        anchors {
            top: parent.top;
            left: parent.left;
        }
        window: root
        height: 40
        width: 120
        enabled: !Kirigami.Settings.isMobile && pageStack.globalToolBar.actualStyle !== Kirigami.ApplicationHeaderStyle.None
        onClicked: {
            root.pageStack.layers.clear();
        }
    }

    // Kirigami PageStack and PageRow
    pageStack.globalToolBar.toolbarActionAlignment: Qt.AlignHCenter
    pageStack.initialPage: prompterPageComponent
    // Auto hide global toolbar on fullscreen
    pageStack.globalToolBar.style:
        if (Kirigami.Settings.isMobile) {
            if (root.pageStack.layers.depth > 1)
                return Kirigami.ApplicationHeaderStyle.Titles
            else
                return Kirigami.ApplicationHeaderStyle.None
        }
        else {
            if (parseInt(root.pageStack.currentItem.prompter.state)!==Prompter.States.Editing &&
                    (fullScreenOrFakeFullScreen || root.pageStack.currentItem.overlay.atTop && !root.pageStack.currentItem.viewport.forcedOrientation))
                return Kirigami.ApplicationHeaderStyle.None;
            else
                return Kirigami.ApplicationHeaderStyle.ToolBar;
        }

    // The following is not possible in the current version of Kirigami, but it should be:
    //pageStack.globalToolBar.background: Rectangle {
        //color: appTheme.__backgroundColor
    //}
    //property alias root.pageStack.currentItem: root.pageStack.currentItem
    //property alias root.pageStack.currentItem: root.pageStack.layers.currentItem
    // End of Kirigami PageStack configuration

    // Patch current page's events to outside its scope.
    //Connections {
        //target: pageStack.currentItem
        ////onTest: {  // Old syntax, use to support 5.12 and lower.
        //function onTest(data) {
            //console.log("Connection successful, received:", data)
        //}
    //}

    /*Binding {
        //target: pageStack.layers.item
        //target: pageStack.initialPage
        //target: pageStack.layers.currentItem
        //target: prompter
        property: "italic"
        value: root.italic
    }*/

    onFrameSwapped: {
        // Thus runs from here because there's no event that occurs on each bit of scroll, and this takes much less CPU than a timer, is more precise and scales better.
        root.pageStack.currentItem.prompter.markerCompare();
        // Update Projections
        if (projectionManager.isEnabled/* && projectionManager.model.count*/)
            // Recount projections on each for loop iteration to prevent value from going stale because a window was closed from a different thread.
            for (var i=0; i<projectionManager.projections.count; i++) {
                const w = projectionManager.projections.objectAt(i);
                if (w!==null && root.visible)
                    w.update();
                else
                    break;
            }
    }

    ProjectionsManager {
        id: projectionManager
        backgroundColor: root.pageStack.currentItem.prompterBackground.color
        backgroundOpacity: root.pageStack.currentItem.prompterBackground.opacity
        // Forward to prompter and not editor to prevent editing from projection windows
        forwardTo: root.pageStack.currentItem.viewport
    }

    // Prompter Page Component {
    Component {
        id: prompterPageComponent
        PrompterPage {}
    }

    // Page Components
    Component {
        id: aboutPageComponent
        AboutPage {}
    }
    Component {
        id: pathsPageComponent
        PathsPage {}
    }
    Component {
        id: remoteControlPageComponent
        RemotePage {}
    }
    Component {
        id: telemetryPageComponent
        TelemetryPage {}
    }

   // Dialogues
   Labs.MessageDialog {
       id: restartDialog
       title: i18nc("Restart application_name", "Restart %1", aboutData.displayName)
       text: i18nc("application needs to restart for this change to fully take effect.\n\nWould you like to restart application now? All changes to document will be lost.", "%1 needs to restart for this change to fully take effect.\n\nWould you like to restart %1 now? All changes to document will be lost.", aboutData.displayName)
       buttons: Labs.MessageDialog.Yes | Labs.MessageDialog.No
       modality: Qt.WindowModal
       onYesClicked: {
           qmlutil.restartApplication()
       }
   }

   Labs.MessageDialog {
       id : closeDialog
       title: i18nc("Title for save before closing dialog", "Save Document")
       text: i18n("Save changes to document before closing?")
       //icon: StandardIcon.Question
       buttons: (Labs.MessageDialog.Save | Labs.MessageDialog.Discard | Labs.MessageDialog.Cancel)
       //standardButtons: StandardButton.Save | StandardButton.Discard | StandardButton.Cancel
       modality: Qt.WindowModal
       onDiscardClicked: {
       // onDiscard: {
           //switch (parseInt(root.onDiscard)) {
               //case Prompter.CloseActions.LoadGuide: root.pageStack.currentItem.document.loadGuide(); break;
               //case Prompter.CloseActions.LoadNew: root.pageStack.currentItem.document.newDocument(); break;
               //case Prompter.CloseActions.Quit: Qt.quit();
               ////case Prompter.CloseActions.Quit:
               ////default: Qt.quit();
           //}

           //document.saveAs(saveDialog.file)
           //root.pageStack.currentItem.document.isNewFile = true
           switch (parseInt(root.onDiscard)) {
               case Prompter.CloseActions.LoadGuide:
                   root.pageStack.currentItem.document.modified = false
                   root.pageStack.currentItem.document.loadGuide();
                   break;
               case Prompter.CloseActions.LoadNew:
                   root.pageStack.currentItem.document.modified = false
                   root.pageStack.currentItem.document.newDocument();
                   break;
               case Prompter.CloseActions.Open:
                   root.pageStack.currentItem.openDialog.open();
                   break;
               case Prompter.CloseActions.Network:
                   root.pageStack.currentItem.networkDialog.open();
                   break;
               case Prompter.CloseActions.Quit:
                   Qt.quit();
                   break;
               //case Prompter.CloseActions.Ignore:
               default:
                   break;
           }
       }
       //onSaveClicked: root.pageStack.currentItem.document.saveDialog(true)
       onAccepted:
       {
           root.pageStack.currentItem.document.saveDialog(parseInt(root.onDiscard)===Prompter.CloseActions.Quit)
       }
    }
    QmlUtil {
        id: qmlutil
    }
}

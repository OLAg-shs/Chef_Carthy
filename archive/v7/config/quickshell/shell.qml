import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    id: root

    // Design Tokens - Frosted Glass & Palette
    readonly property color colBgFrosted: Qt.rgba(0.945, 0.922, 0.867, 0.90)
    readonly property color colSurface: Qt.rgba(0.973, 0.957, 0.918, 0.94)
    readonly property color colSurfaceAlt: Qt.rgba(0.910, 0.878, 0.808, 0.88)
    readonly property color colText: '#2B2A28'
    readonly property color colTextMuted: '#6E6A5F'
    readonly property color colAccent: '#A6534A'
    readonly property color colAccentHover: '#C06A5F'
    readonly property color colBorder: Qt.rgba(0.863, 0.827, 0.745, 0.9)
    readonly property int radLg: 22
    readonly property int radMd: 14
    readonly property int radSm: 8

    // Popover Visibility States
    property bool quickSettingsOpen: false
    property bool notificationsOpen: false
    property bool powerMenuOpen: false
    property bool desktopCreatorOpen: false
    property bool volumeOpen: false
    property bool wifiOpen: false

    property bool dndEnabled: false
    property int volumeLevel: 65
    property bool isMuted: false
    property bool wifiEnabled: true

    // Dynamic Island State (Compact at rest, expands only on hover)
    property bool islandHovered: false
    property bool islandExpanded: false
    property bool isPlaying: false
    property string trackTitle: 'Hikaru Utada - Simple & Clean'
    property string currentDateStr: 'Chef OS • System Ready'
    property var waveHeights: [6, 12, 18, 10, 22, 14, 8, 16, 20, 12, 15, 9]

    // Desktop Creator state
    property string selectedIcon: ''
    property string desktopLabel: ''

    // Curated Vibe Icons List
    readonly property var vibeIcons: [
        { 'glyph': '󰋜', 'name': 'Home' },
        { 'glyph': '󰅪', 'name': 'Code' },
        { 'glyph': '󰖟', 'name': 'Web' },
        { 'glyph': '󰎈', 'name': 'Music' },
        { 'glyph': '󰄀', 'name': 'Camera' },
        { 'glyph': '󰂱', 'name': 'Book' },
        { 'glyph': '󰭹', 'name': 'Chat' },
        { 'glyph': '󰊴', 'name': 'Game' },
        { 'glyph': '󰏘', 'name': 'Design' },
        { 'glyph': '󰃖', 'name': 'Work' },
        { 'glyph': '󰅐', 'name': 'Coffee' },
        { 'glyph': '󰋑', 'name': 'Heart' }
    ]

    // Grace period timer for Dynamic Island collapse
    Timer {
        id: collapseTimer
        interval: 500
        repeat: false
        onTriggered: {
            if (!root.islandHovered) {
                root.islandExpanded = false
            }
        }
    }

    function expandIsland() {
        collapseTimer.stop()
        root.islandHovered = true
        root.islandExpanded = true
    }

    function collapseIslandDelayed() {
        root.islandHovered = false
        collapseTimer.restart()
    }

    // Audio & Network Background Pollers
    Process {
        id: getVolProc
        command: ['wpctl', 'get-volume', '@DEFAULT_AUDIO_SINK@']
        stdout: SplitParser {
            onRead: data => {
                let match = data.match(/Volume:\s+([0-9.]+)/)
                if (match) {
                    root.volumeLevel = Math.round(parseFloat(match[1]) * 100)
                }
                root.isMuted = data.includes('[MUTED]')
            }
        }
    }

    // Media Poller
    Process {
        id: mediaPoller
        command: ['playerctl', 'status']
        stdout: SplitParser {
            onRead: data => {
                let s = data.trim().toLowerCase()
                root.isPlaying = (s === 'playing')
            }
        }
    }

    Process {
        id: titlePoller
        command: ['playerctl', 'metadata', 'title']
        stdout: SplitParser {
            onRead: data => {
                let t = data.trim()
                if (t !== '') root.trackTitle = t
            }
        }
    }

    Process {
        id: datePoller
        command: ['date', '+%A, %B %-d • %H:%M']
        stdout: SplitParser {
            onRead: data => {
                let d = data.trim()
                if (d !== '') root.currentDateStr = d
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!getVolProc.running) getVolProc.running = true
            if (!mediaPoller.running) mediaPoller.running = true
            if (root.isPlaying && !titlePoller.running) titlePoller.running = true
            if (!datePoller.running) datePoller.running = true
        }
    }

    // Waveform Animation Timer (only animates when playing AND island expanded)
    Timer {
        interval: 90
        running: root.isPlaying && root.islandExpanded
        repeat: true
        onTriggered: {
            let next = []
            for (let i = 0; i < 10; i++) {
                next.push(4 + Math.floor(Math.random() * 18))
            }
            root.waveHeights = next
        }
    }

    // Helper Processes
    Process {
        id: setVolProc
        property string volStr: '0.65'
        command: ['wpctl', 'set-volume', '@DEFAULT_AUDIO_SINK@', volStr]
    }

    Process {
        id: muteProc
        command: ['wpctl', 'set-mute', '@DEFAULT_AUDIO_SINK@', 'toggle']
    }

    Process {
        id: wifiOnProc
        command: ['nmcli', 'radio', 'wifi', 'on']
    }

    Process {
        id: wifiOffProc
        command: ['nmcli', 'radio', 'wifi', 'off']
    }

    Process {
        id: lockProc
        command: ['hyprlock']
    }

    Process {
        id: logoutProc
        command: ['hyprctl', 'dispatch', 'exit']
    }

    Process {
        id: rebootProc
        command: ['systemctl', 'reboot']
    }

    Process {
        id: shutdownProc
        command: ['systemctl', 'poweroff']
    }

    Process {
        id: createWsProc
        command: ['/usr/local/bin/chef-workspace-manager', 'create', '', '']
    }

    function setVolume(val) {
        root.volumeLevel = val
        setVolProc.volStr = (val / 100).toFixed(2)
        if (!setVolProc.running) setVolProc.running = true
    }

    function toggleMute() {
        root.isMuted = !root.isMuted
        if (!muteProc.running) muteProc.running = true
    }

    function toggleWifi() {
        root.wifiEnabled = !root.wifiEnabled
        if (root.wifiEnabled) {
            if (!wifiOnProc.running) wifiOnProc.running = true
        } else {
            if (!wifiOffProc.running) wifiOffProc.running = true
        }
    }

    function createDesktop() {
        console.log('createDesktop triggered with icon: ' + root.selectedIcon + ' label: ' + root.desktopLabel)
        if (root.selectedIcon === '') return
        createWsProc.command = ['/usr/local/bin/chef-workspace-manager', 'create', root.selectedIcon, root.desktopLabel]
        createWsProc.running = true
        root.selectedIcon = ''
        root.desktopLabel = ''
        root.desktopCreatorOpen = false
    }

    // IPC Controller for CLI / Waybar
    IpcHandler {
        target: 'chefos'
        function expandIsland() {
            root.expandIsland()
        }
        function collapseIsland() {
            root.islandHovered = false
            root.islandExpanded = false
        }
        function playMusic() {
            root.isPlaying = true
        }
        function pauseMusic() {
            root.isPlaying = false
        }
        function toggleQuickSettings() {
            root.quickSettingsOpen = !root.quickSettingsOpen
            if (root.quickSettingsOpen) {
                root.volumeOpen = false
                root.wifiOpen = false
                root.notificationsOpen = false
                root.powerMenuOpen = false
                root.desktopCreatorOpen = false
            }
        }
        function toggleVolume() {
            root.volumeOpen = !root.volumeOpen
            if (root.volumeOpen) {
                root.quickSettingsOpen = false
                root.wifiOpen = false
                root.notificationsOpen = false
                root.powerMenuOpen = false
                root.desktopCreatorOpen = false
            }
        }
        function toggleWifi() {
            root.wifiOpen = !root.wifiOpen
            if (root.wifiOpen) {
                root.quickSettingsOpen = false
                root.volumeOpen = false
                root.notificationsOpen = false
                root.powerMenuOpen = false
                root.desktopCreatorOpen = false
            }
        }
        function toggleDesktopCreator() {
            root.desktopCreatorOpen = !root.desktopCreatorOpen
            if (root.desktopCreatorOpen) {
                root.quickSettingsOpen = false
                root.volumeOpen = false
                root.wifiOpen = false
                root.notificationsOpen = false
                root.powerMenuOpen = false
            }
        }
        function toggleNotifications() {
            root.notificationsOpen = !root.notificationsOpen
            if (root.notificationsOpen) {
                root.quickSettingsOpen = false
                root.volumeOpen = false
                root.wifiOpen = false
                root.powerMenuOpen = false
                root.desktopCreatorOpen = false
            }
        }
        function togglePowerMenu() {
            root.powerMenuOpen = !root.powerMenuOpen
            if (root.powerMenuOpen) {
                root.quickSettingsOpen = false
                root.volumeOpen = false
                root.wifiOpen = false
                root.notificationsOpen = false
                root.desktopCreatorOpen = false
            }
        }
        function closeAll() {
            root.quickSettingsOpen = false
            root.volumeOpen = false
            root.wifiOpen = false
            root.notificationsOpen = false
            root.powerMenuOpen = false
            root.desktopCreatorOpen = false
        }
    }

    // ==========================================
    // 0. DYNAMIC ISLAND (TOP-CENTER FLOATING PILL)
    // ==========================================
    PanelWindow {
        id: islandWindow
        visible: true
        color: 'transparent'
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
            top: true
            left: true
            right: true
        }

        Item {
            anchors.fill: parent
            height: 48

            Rectangle {
                id: islandPill
                anchors.top: parent.top
                anchors.topMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                height: 36
                width: root.islandExpanded ? 380 : 130
                radius: 18
                color: root.colBgFrosted
                border.color: root.colBorder
                border.width: 1

                Behavior on width {
                    NumberAnimation { duration: 300; easing.type: Easing.OutBack }
                }

                MouseArea {
                    id: islandArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: root.expandIsland()
                    onExited: root.collapseIslandDelayed()
                }

                // Compact Idle State (Always visible at rest, regardless of whether music is playing)
                RowLayout {
                    anchors.centerIn: parent
                    visible: !root.islandExpanded
                    spacing: 6
                    opacity: !root.islandExpanded ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Text {
                        text: 'Chef OS'
                        font.family: 'Noto Sans'
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: root.colText
                    }
                    Rectangle {
                        width: 16
                        height: 16
                        radius: 4
                        color: root.colAccent
                        Text {
                            anchors.centerIn: parent
                            text: '印'
                            font.family: 'Noto Sans'
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: '#FFFFFF'
                        }
                    }
                }

                // Hover-Expanded State
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    visible: root.islandExpanded
                    spacing: 8
                    opacity: root.islandExpanded ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    // When music IS playing:
                    Text {
                        visible: root.isPlaying
                        text: '󰎈'
                        font.family: 'JetBrainsMono Nerd Font'
                        font.pixelSize: 15
                        color: root.colAccent
                    }
                    Text {
                        visible: root.isPlaying
                        text: root.trackTitle
                        font.family: 'Noto Sans'
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: root.colText
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    RowLayout {
                        visible: root.isPlaying
                        spacing: 3
                        Repeater {
                            model: root.waveHeights
                            delegate: Rectangle {
                                width: 3
                                height: modelData
                                radius: 1.5
                                color: root.colAccent
                                Layout.alignment: Qt.AlignVCenter
                                Behavior on height { NumberAnimation { duration: 80 } }
                            }
                        }
                    }

                    // When NO music is playing:
                    Text {
                        visible: !root.isPlaying
                        text: '󰃭'
                        font.family: 'JetBrainsMono Nerd Font'
                        font.pixelSize: 14
                        color: root.colAccent
                    }
                    Text {
                        visible: !root.isPlaying
                        text: root.currentDateStr
                        font.family: 'Noto Sans'
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: root.colText
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    Rectangle {
                        visible: !root.isPlaying
                        width: 8
                        height: 8
                        radius: 4
                        color: '#4CAF50'
                    }
                }
            }
        }
    }

    // ==========================================
    // 1. DESKTOP CREATOR POPOVER (MANDATORY ICON)
    // ==========================================
    PanelWindow {
        id: creatorWindow
        visible: root.desktopCreatorOpen
        color: 'transparent'
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.desktopCreatorOpen = false
        }

        Rectangle {
            id: creatorCard
            width: 380
            height: 420
            x: 74
            y: 40
            color: root.colBgFrosted
            border.color: root.colBorder
            border.width: 1
            radius: root.radLg

            scale: visible ? 1.0 : 0.88
            opacity: visible ? 1.0 : 0.0
            Behavior on scale { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 200 } }

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: 'New Desktop'
                        font.family: 'Noto Sans'
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: root.colText
                        Layout.fillWidth: true
                    }
                    Button {
                        text: '✕'
                        background: Rectangle {
                            color: parent.hovered ? root.colSurfaceAlt : 'transparent'
                            radius: 12
                            width: 28; height: 28
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            color: root.colTextMuted
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: root.desktopCreatorOpen = false
                    }
                }

                // Label Input
                TextField {
                    id: labelInput
                    Layout.fillWidth: true
                    height: 38
                    placeholderText: 'Desktop Name (optional)'
                    placeholderTextColor: root.colTextMuted
                    color: root.colText
                    font.family: 'Noto Sans'
                    font.pixelSize: 13
                    background: Rectangle {
                        color: root.colSurface
                        border.color: labelInput.activeFocus ? root.colAccent : root.colBorder
                        border.width: 1
                        radius: root.radMd
                    }
                    onTextChanged: root.desktopLabel = text
                }

                Label {
                    text: 'Choose Vibe Icon (Mandatory):'
                    font.family: 'Noto Sans'
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: root.selectedIcon === '' ? root.colAccent : root.colTextMuted
                }

                // 4x3 Icon Selection Grid
                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    rowSpacing: 8
                    columnSpacing: 8

                    Repeater {
                        model: root.vibeIcons
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 52
                            radius: root.radMd
                            color: root.selectedIcon === modelData.glyph ? root.colAccent : (iconMouse.containsMouse ? root.colSurface : root.colSurfaceAlt)
                            border.color: root.selectedIcon === modelData.glyph ? root.colAccent : root.colBorder
                            border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 2
                                Text {
                                    text: modelData.glyph
                                    font.family: 'JetBrainsMono Nerd Font'
                                    font.pixelSize: 20
                                    color: root.selectedIcon === modelData.glyph ? '#FFFFFF' : root.colText
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Text {
                                    text: modelData.name
                                    font.family: 'Noto Sans'
                                    font.pixelSize: 9
                                    font.weight: Font.DemiBold
                                    color: root.selectedIcon === modelData.glyph ? '#FFFFFF' : root.colTextMuted
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }

                            MouseArea {
                                id: iconMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.selectedIcon = modelData.glyph
                            }
                        }
                    }
                }

                // Action Button (Enabled only when icon is picked)
                Button {
                    id: createBtn
                    Layout.fillWidth: true
                    height: 42
                    enabled: root.selectedIcon !== ''
                    background: Rectangle {
                        color: root.selectedIcon !== '' ? (createBtn.hovered ? root.colAccentHover : root.colAccent) : root.colSurfaceAlt
                        radius: root.radMd
                    }
                    contentItem: Text {
                        text: root.selectedIcon !== '' ? 'Create Desktop' : 'Pick an Icon to Create'
                        font.family: 'Noto Sans'
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: root.selectedIcon !== '' ? '#FFFFFF' : root.colTextMuted
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: root.createDesktop()
                }
            }
        }
    }

    // ==========================================
    // 2. VOLUME POPOVER (iOS SOUND CARD)
    // ==========================================
    PanelWindow {
        id: volumeWindow
        visible: root.volumeOpen
        color: 'transparent'
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.volumeOpen = false
        }

        Rectangle {
            id: volCard
            width: 320
            height: 230
            x: 74
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 80
            color: root.colBgFrosted
            border.color: root.colBorder
            border.width: 1
            radius: root.radLg

            scale: visible ? 1.0 : 0.88
            opacity: visible ? 1.0 : 0.0
            Behavior on scale { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 200 } }

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: '󰕾'
                        font.family: 'JetBrainsMono Nerd Font'
                        font.pixelSize: 20
                        color: root.colAccent
                    }
                    Label {
                        text: 'Sound & Volume'
                        font.family: 'Noto Sans'
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: root.colText
                        Layout.fillWidth: true
                    }
                    Text {
                        text: root.volumeLevel + '%'
                        font.family: 'Noto Sans'
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: root.colText
                    }
                }

                // iOS Pill Slider
                Slider {
                    id: volSlider
                    Layout.fillWidth: true
                    height: 38
                    from: 0
                    to: 100
                    value: root.volumeLevel
                    onMoved: root.setVolume(Math.round(value))

                    background: Rectangle {
                        x: volSlider.leftPadding
                        y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                        width: volSlider.availableWidth
                        height: 28
                        radius: 14
                        color: root.colSurfaceAlt

                        Rectangle {
                            width: volSlider.visualPosition * parent.width
                            height: parent.height
                            color: root.colAccent
                            radius: 14
                        }
                    }

                    handle: Rectangle {
                        x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                        y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                        width: 26
                        height: 26
                        radius: 13
                        color: '#FFFFFF'
                        border.color: root.colBorder
                        border.width: 1
                    }
                }

                // Output Selector & Mute
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        color: root.colSurface
                        border.color: root.colBorder
                        border.width: 1
                        radius: root.radMd

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            Text {
                                text: '󰋋 Output: Built-in Audio'
                                font.family: 'Noto Sans'
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: root.colText
                                Layout.fillWidth: true
                            }
                        }
                    }

                    Button {
                        width: 80
                        height: 40
                        background: Rectangle {
                            color: root.isMuted ? root.colAccent : root.colSurface
                            border.color: root.colBorder
                            border.width: 1
                            radius: root.radMd
                        }
                        contentItem: Text {
                            text: root.isMuted ? 'Muted' : 'Mute'
                            font.family: 'Noto Sans'
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: root.isMuted ? '#FFFFFF' : root.colText
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: root.toggleMute()
                    }
                }
            }
        }
    }

    // ==========================================
    // 3. WI-FI POPOVER (iOS NETWORK CARD)
    // ==========================================
    PanelWindow {
        id: wifiWindow
        visible: root.wifiOpen
        color: 'transparent'
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.wifiOpen = false
        }

        Rectangle {
            id: wifiCard
            width: 340
            height: 300
            x: 74
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 120
            color: root.colBgFrosted
            border.color: root.colBorder
            border.width: 1
            radius: root.radLg

            scale: visible ? 1.0 : 0.88
            opacity: visible ? 1.0 : 0.0
            Behavior on scale { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 200 } }

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: ''
                        font.family: 'JetBrainsMono Nerd Font'
                        font.pixelSize: 20
                        color: root.colAccent
                    }
                    Label {
                        text: 'Wi-Fi Networks'
                        font.family: 'Noto Sans'
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: root.colText
                        Layout.fillWidth: true
                    }
                    Switch {
                        checked: root.wifiEnabled
                        onToggled: root.toggleWifi()
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: root.colBorder }

                // Connected network card
                Rectangle {
                    Layout.fillWidth: true
                    height: 56
                    color: root.colSurface
                    border.color: root.colBorder
                    border.width: 1
                    radius: root.radMd

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        Text {
                            text: '󰈀'
                            font.family: 'JetBrainsMono Nerd Font'
                            font.pixelSize: 18
                            color: root.colAccent
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: 'Ethernet ens33'
                                font.family: 'Noto Sans'
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: root.colText
                            }
                            Text {
                                text: 'Connected • 172.16.241.130'
                                font.family: 'Noto Sans'
                                font.pixelSize: 10
                                color: root.colTextMuted
                            }
                        }
                    }
                }

                Label {
                    text: 'Available Networks:'
                    font.family: 'Noto Sans'
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: root.colTextMuted
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    color: root.colSurfaceAlt
                    border.color: root.colBorder
                    border.width: 1
                    radius: root.radSm

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        Text {
                            text: ''
                            font.family: 'JetBrainsMono Nerd Font'
                            font.pixelSize: 14
                            color: root.colTextMuted
                        }
                        Text {
                            text: 'ChefOS-5G'
                            font.family: 'Noto Sans'
                            font.pixelSize: 12
                            color: root.colText
                            Layout.fillWidth: true
                        }
                        Text {
                            text: '󰌾'
                            font.family: 'JetBrainsMono Nerd Font'
                            font.pixelSize: 12
                            color: root.colTextMuted
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // 4. QUICK SETTINGS (iOS CONTROL CENTER)
    // ==========================================
    PanelWindow {
        id: qsWindow
        visible: root.quickSettingsOpen
        color: 'transparent'
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.quickSettingsOpen = false
        }

        Rectangle {
            id: qsCard
            width: 340
            height: Math.min(parent.height - 24, 480)
            x: 74
            y: 12
            color: root.colBgFrosted
            border.color: root.colBorder
            border.width: 1
            radius: root.radLg

            scale: visible ? 1.0 : 0.88
            opacity: visible ? 1.0 : 0.0
            Behavior on scale { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 200 } }

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: 'Control Center'
                        font.family: 'Noto Sans'
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: root.colText
                        Layout.fillWidth: true
                    }
                    Button {
                        text: '✕'
                        background: Rectangle {
                            color: parent.hovered ? root.colSurfaceAlt : 'transparent'
                            radius: 12
                            width: 28; height: 28
                        }
                        contentItem: Text {
                            text: parent.text
                            color: root.colTextMuted
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: root.quickSettingsOpen = false
                    }
                }

                // 2x2 Toggle Grid
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 10
                    columnSpacing: 10

                    // Wi-Fi Tile
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: root.colSurface
                        border.color: root.colBorder
                        border.width: 1
                        radius: root.radMd

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            Text {
                                text: ''
                                font.family: 'JetBrainsMono Nerd Font'
                                font.pixelSize: 20
                                color: root.wifiEnabled ? root.colAccent : root.colTextMuted
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: 'Wi-Fi'
                                    font.family: 'Noto Sans'
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    color: root.colText
                                }
                                Text {
                                    text: root.wifiEnabled ? 'On' : 'Off'
                                    font.family: 'Noto Sans'
                                    font.pixelSize: 10
                                    color: root.colTextMuted
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.toggleWifi()
                        }
                    }

                    // Bluetooth Tile
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: root.colSurface
                        border.color: root.colBorder
                        border.width: 1
                        radius: root.radMd

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            Text {
                                text: '󰂯'
                                font.family: 'JetBrainsMono Nerd Font'
                                font.pixelSize: 20
                                color: root.colAccent
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: 'Bluetooth'
                                    font.family: 'Noto Sans'
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    color: root.colText
                                }
                                Text {
                                    text: 'Ready'
                                    font.family: 'Noto Sans'
                                    font.pixelSize: 10
                                    color: root.colTextMuted
                                }
                            }
                        }
                    }

                    // DND Tile
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: root.dndEnabled ? root.colAccent : root.colSurface
                        border.color: root.dndEnabled ? root.colAccent : root.colBorder
                        border.width: 1
                        radius: root.radMd

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            Text {
                                text: '󰂛'
                                font.family: 'JetBrainsMono Nerd Font'
                                font.pixelSize: 20
                                color: root.dndEnabled ? '#FFFFFF' : root.colTextMuted
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: 'Do Not Disturb'
                                    font.family: 'Noto Sans'
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    color: root.dndEnabled ? '#FFFFFF' : root.colText
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.dndEnabled = !root.dndEnabled
                        }
                    }

                    // Night Light Tile
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: root.colSurface
                        border.color: root.colBorder
                        border.width: 1
                        radius: root.radMd

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            Text {
                                text: '󰃜'
                                font.family: 'JetBrainsMono Nerd Font'
                                font.pixelSize: 20
                                color: root.colTextMuted
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: 'Night Light'
                                    font.family: 'Noto Sans'
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    color: root.colText
                                }
                            }
                        }
                    }
                }

                // Volume Section
                Rectangle {
                    Layout.fillWidth: true
                    height: 70
                    color: root.colSurface
                    border.color: root.colBorder
                    border.width: 1
                    radius: root.radMd

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: '󰕾 Sound (' + root.volumeLevel + '%)'
                                font.family: 'Noto Sans'
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: root.colText
                                Layout.fillWidth: true
                            }
                        }

                        Slider {
                            id: qsVolSlider
                            Layout.fillWidth: true
                            height: 28
                            from: 0
                            to: 100
                            value: root.volumeLevel
                            onMoved: root.setVolume(Math.round(value))
                            background: Rectangle {
                                width: qsVolSlider.availableWidth
                                height: 16
                                radius: 8
                                color: root.colSurfaceAlt
                                Rectangle {
                                    width: qsVolSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: root.colAccent
                                    radius: 8
                                }
                            }
                        }
                    }
                }

                // Brightness Section
                Rectangle {
                    Layout.fillWidth: true
                    height: 70
                    color: root.colSurface
                    border.color: root.colBorder
                    border.width: 1
                    radius: root.radMd

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: '󰃠 Display Brightness'
                                font.family: 'Noto Sans'
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: root.colText
                                Layout.fillWidth: true
                            }
                        }

                        Slider {
                            id: qsBrtSlider
                            Layout.fillWidth: true
                            height: 28
                            from: 10
                            to: 100
                            value: 100
                            background: Rectangle {
                                width: qsBrtSlider.availableWidth
                                height: 16
                                radius: 8
                                color: root.colSurfaceAlt
                                Rectangle {
                                    width: qsBrtSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: root.colAccent
                                    radius: 8
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    // ==========================================
    // 5. NOTIFICATIONS CONTROL CENTER
    // ==========================================
    PanelWindow {
        id: notifWindow
        visible: root.notificationsOpen
        color: 'transparent'
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.notificationsOpen = false
        }

        Rectangle {
            id: notifCard
            width: 360
            height: Math.min(parent.height - 24, 600)
            anchors.right: parent.right
            anchors.rightMargin: 12
            y: 12
            color: root.colBgFrosted
            border.color: root.colBorder
            border.width: 1
            radius: root.radLg

            scale: visible ? 1.0 : 0.88
            opacity: visible ? 1.0 : 0.0
            Behavior on scale { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 200 } }

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: 'Notifications'
                        font.family: 'Noto Sans'
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: root.colText
                        Layout.fillWidth: true
                    }
                    Button {
                        text: 'Clear All'
                        background: Rectangle {
                            color: parent.hovered ? root.colBorder : root.colSurface
                            border.color: root.colBorder
                            border.width: 1
                            radius: root.radMd
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: 'Noto Sans'
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: root.colText
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                // DND Toggle
                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    color: root.colSurface
                    border.color: root.colBorder
                    border.width: 1
                    radius: root.radMd

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        Text {
                            text: 'Do Not Disturb'
                            font.family: 'Noto Sans'
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            color: root.colText
                            Layout.fillWidth: true
                        }
                        Switch {
                            checked: root.dndEnabled
                            onToggled: root.dndEnabled = checked
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: root.colBorder }

                // Notification Cards
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    model: [
                        { 'app': 'Chef OS', 'summary': 'Dynamic Island Active', 'body': 'Hover-activated Dynamic Island & Desktop Identity loaded.', 'time': 'Just now' },
                        { 'app': 'Network', 'summary': 'Connected', 'body': 'Wired interface ens33 online.', 'time': '25m ago' }
                    ]
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 74
                        color: root.colSurface
                        border.color: root.colBorder
                        border.width: 1
                        radius: root.radMd

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 2
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: modelData.app + ' • ' + modelData.summary
                                    font.family: 'Noto Sans'
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    color: root.colText
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: modelData.time
                                    font.family: 'Noto Sans'
                                    font.pixelSize: 10
                                    color: root.colTextMuted
                                }
                            }
                            Text {
                                text: modelData.body
                                font.family: 'Noto Sans'
                                font.pixelSize: 11
                                color: root.colTextMuted
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // 6. POWER MENU MODAL
    // ==========================================
    PanelWindow {
        id: powerWindow
        visible: root.powerMenuOpen
        color: 'transparent'
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.35)
            MouseArea {
                anchors.fill: parent
                onClicked: root.powerMenuOpen = false
            }
        }

        Rectangle {
            id: powerCard
            width: 440
            height: 200
            anchors.centerIn: parent
            color: root.colBgFrosted
            border.color: root.colBorder
            border.width: 1
            radius: root.radLg

            scale: visible ? 1.0 : 0.88
            opacity: visible ? 1.0 : 0.0
            Behavior on scale { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 200 } }

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: 'Power Session'
                        font.family: 'Noto Sans'
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: root.colText
                        Layout.fillWidth: true
                    }
                    Button {
                        text: '✕'
                        background: Rectangle {
                            color: parent.hovered ? root.colSurfaceAlt : 'transparent'
                            radius: 12
                            width: 28; height: 28
                        }
                        contentItem: Text {
                            text: parent.text
                            color: root.colTextMuted
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: root.powerMenuOpen = false
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    // Lock
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: lockArea.containsMouse ? root.colSurface : root.colSurfaceAlt
                        border.color: root.colBorder
                        border.width: 1
                        radius: root.radMd

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                text: '󰌾'
                                font.family: 'JetBrainsMono Nerd Font'
                                font.pixelSize: 24
                                color: root.colText
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: 'Lock'
                                font.family: 'Noto Sans'
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: root.colText
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                        MouseArea {
                            id: lockArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.powerMenuOpen = false
                                if (!lockProc.running) lockProc.running = true
                            }
                        }
                    }

                    // Logout
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: logoutArea.containsMouse ? root.colSurface : root.colSurfaceAlt
                        border.color: root.colBorder
                        border.width: 1
                        radius: root.radMd

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                text: '󰍃'
                                font.family: 'JetBrainsMono Nerd Font'
                                font.pixelSize: 24
                                color: root.colText
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: 'Log Out'
                                font.family: 'Noto Sans'
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: root.colText
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                        MouseArea {
                            id: logoutArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.powerMenuOpen = false
                                if (!logoutProc.running) logoutProc.running = true
                            }
                        }
                    }

                    // Reboot
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: rebootArea.containsMouse ? root.colSurface : root.colSurfaceAlt
                        border.color: root.colBorder
                        border.width: 1
                        radius: root.radMd

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                text: '󰜉'
                                font.family: 'JetBrainsMono Nerd Font'
                                font.pixelSize: 24
                                color: root.colAccent
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: 'Restart'
                                font.family: 'Noto Sans'
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: root.colAccent
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                        MouseArea {
                            id: rebootArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.powerMenuOpen = false
                                if (!rebootProc.running) rebootProc.running = true
                            }
                        }
                    }

                    // Shutdown
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: shutdownArea.containsMouse ? root.colAccentHover : root.colAccent
                        border.color: root.colAccent
                        border.width: 1
                        radius: root.radMd

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                text: '󰐥'
                                font.family: 'JetBrainsMono Nerd Font'
                                font.pixelSize: 24
                                color: '#FFFFFF'
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: 'Shut Down'
                                font.family: 'Noto Sans'
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: '#FFFFFF'
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                        MouseArea {
                            id: shutdownArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.powerMenuOpen = false
                                if (!shutdownProc.running) shutdownProc.running = true
                            }
                        }
                    }
                }
            }
        }
    }
}
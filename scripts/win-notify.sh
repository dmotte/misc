#!/bin/bash

set -e

# This script can be used in Git Bash to display a balloon tip notification in
# the Windows taskbar

# Usage examples:
#   ./win-notify.sh MyText MyTitle Warning Warning
#   ./win-notify.sh MyText MyTitle Error Error
#   ./win-notify.sh MyText

export BALLOON_TIP_TEXT="${1:?}" BALLOON_TIP_TITLE="$2"
readonly notify_icon="${3:-Information}"
export BALLOON_TIP_ICON="${4:-Info}"

# shellcheck disable=SC2016
exec powershell -NoProfile -Command '
    Add-Type -AssemblyName System.Windows.Forms

    $objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon

    $objNotifyIcon.Icon = [System.Drawing.SystemIcons]::'"$notify_icon"'
    $objNotifyIcon.BalloonTipIcon = $Env:BALLOON_TIP_ICON
    $objNotifyIcon.BalloonTipTitle = $Env:BALLOON_TIP_TITLE
    $objNotifyIcon.BalloonTipText = $Env:BALLOON_TIP_TEXT
    $objNotifyIcon.Visible = $true

    $objNotifyIcon.ShowBalloonTip(0)
'

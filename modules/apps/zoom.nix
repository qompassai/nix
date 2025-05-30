# ~/.dotfiles/modules/1/zoom.nix
# ------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ config, pkgs, lib, ... }:

let
  zoomusConf = ''
    [General]
    %2B8gcPZIuASRcihpYJW6UA83rPnH%2B7ifu11s9xp3p8Rc%23=1746821690
    63tJmSFEpYg9dR34FZPBHK8VKGPcUT1yDVJWSS9UTuU%23=1746821690
    GeoLocale=system
    SensitiveInfoMaskOn=true
    ShowBiDirecSyncNoti=true
    UeJ7AgrtBappnQjaaFui4jk8yVCY2K4zE14gyE34Rzo%23=1746821690
    autoPlayGif=true
    autoScale=true
    bForceMaximizeWM=false
    captureHDCamera=true
    cefInstanceCountLimit=-1
    cefRefreshTime=0
    chatListPanelLastWidth=230
    com.disable.connection.pk.status=false
    com.zoom.client.langid=0
    conf.webserver=https://us05web.zoom.us
    conf.webserver.vendor.default=https://zoom.us
    currentMeetingId=9358450242
    deviceID=04:7C:16:AA:B9:25
    disableCef=false
    enable.host.auto.grab=true
    enableAlphaBuffer=true
    enableCefGpu=true
    enableCefLog=false
    enableCefTa=true
    enableCloudSwitch=true
    enableLog=true
    enableMiniWindow=true
    enableQmlCache=true
    enableScreenSaveGuard=false
    enableStartMeetingWithRoomSystem=false
    enableTestMode=false
    enableWaylandShare=true
    enablegpucomputeutilization=false
    fake.version=
    flashChatTime=0
    forceEnableTrayIcon=true
    forceSSOURL=
    hideCrashReport=false
    host.auto.grab.interval=10
    isTransCoding=false
    jK9BkbV8zNjw7whdX9AnddbmbOu4N8hVKwVt8iDnC38%23=1746821690
    logLevel=info
    newMeetingWithVideo=true
    noSandbox=true
    pOoALJyX%2BqjXWD3Cr1Q4lH5ZpVshFjYob0SH3xBr2jQ%23=1746821690
    playSoundForNewMessage=false
    shareBarTopMargin=0
    showOneTimePTAICTipHubble=true
    showOneTimeQAMostUpvoteHubble=true
    showOneTimeQueriesOptionTip=true
    showOneTimeTranslationUpSellTip=false
    showSystemTitlebar=true
    speaker_volume=255
    sso_domain=.zoom.us
    sso_gov_domain=.zoomgov.com
    system.audio.type=default
    timeFormat12HoursEnable=true
    translationFreeTrialTipShowTime=0
    upcoming_meeting_header_image=
    useSystemTheme=true
    userEmailAddress=foamedmap@gmail.com
    xwayland=true

    [1VGa6fEsTQYEquYOdMv]
    j1V5NQSTWNQPlSB8TSaIgvM%23=1746821691

    [AS]
    showframewindow=true

    [CodeSnippet]
    lastCodeType=0
    wrapMode=0

    [XQUNtcsCEP9AZEM]
    raMascPNauP8AMY%2BuhHsEUqln%2Bg%23=1746821690

    [e2oewir4]
    zlsEjhEtnrfV\1\RNfupD3GFHXnLPoOTzI%23=1746821690

    [p2j01nOS5WVbsNRvQFnMTmH5SbwLdPoVQxAt]
    B0jJHc%23=1746821690

    [pvKc9SrvNy]
    UrM6djKC7sBYYhjF2xNCSHVpXDpFealQ%23=1746821690
  '';
in
{
  options.zoom = {
    enable = lib.mkEnableOption "Enable Zoom configuration";
    user = lib.mkOption {
      type = lib.types.str;
      description = "The user to install zoomus.conf for";
    };
  };

  config = lib.mkIf config.zoom.enable {
    users.users.${config.zoom.user}.home.file.".config/zoomus.conf".text = zoomusConf;
  };
}


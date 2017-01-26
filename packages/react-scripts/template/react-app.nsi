
!include nsDialogs.nsh
!include LogicLib.nsh

!ifndef VERSION
  !define VERSION "version"
!endif

!ifndef NAME
  !define NAME "installer"
!endif

!ifndef INSTALLDIR
  !error "please configure an installation directory (/DINSTALLDIR=<somewhere>)"
!endif

Name "${NAME}"

XPStyle on
SetCompressor lzma

; now, for testing
InstallDir "${INSTALLDIR}"

OutFile "${NAME}-${VERSION}.exe"

Var OldServiceName
Var OldServerHostName
Var OldServerPortNumber
Var FrontendOldConfigButton

Var ResetServiceName
Var ResetServerHostName
Var ResetServerPortNumber
Var FrontendResetConfigButton

Var ServiceNameText
Var ServiceNameLabel
Var ServiceNameField

Var ServerHostNameText
Var ServerHostNameLabel
Var ServerHostNameField

Var ServerPortNumberText
Var ServerPortNumberLabel
Var ServerPortNumberField

Var ReadmeBox
Var ReadmeState

Var ConfigBox
Var ConfigState

Var Dialog

ReserveFile serviceConfig.ini

Page components
Page directory
Page custom FrontendConfiguration FrontendValidation " [serviceConfig.ini]"
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

Function ReadConfigurations

  SetOutPath $INSTDIR

  ReadINIStr $OldServiceName "$INSTDIR\serviceConfig.ini" service name
  ReadINIStr $OldServerHostName "$INSTDIR\serviceConfig.ini" service hostname
  ReadINIStr $OldServerPortNumber "$INSTDIR\serviceConfig.ini" service port

  ; service configuration
  File serviceConfig.ini

  ReadINIStr $ResetServiceName "$INSTDIR\serviceConfig.ini" service name
  ReadINIStr $ResetServerHostName "$INSTDIR\serviceConfig.ini" service hostname
  ReadINIStr $ResetServerPortNumber "$INSTDIR\serviceConfig.ini" service port

  ${IF} $OldServiceName != ""
    StrCpy $ServiceNameText $OldServiceName
    StrCpy $ServerHostNameText $OldServerHostName
    StrCpy $ServerPortNumberText $OldServerPortNumber
  ${ELSE}
    StrCpy $ServiceNameText $ResetServiceName
    StrCpy $ServerHostNameText $ResetServerHostName
    StrCpy $ServerPortNumberText $ResetServerPortNumber
  ${ENDIF}

FunctionEnd

Function FrontendConfiguration

  Call ReadConfigurations

  nsDialogs::Create 1018
  Pop $Dialog

  ${If} $Dialog == error
    Abort
  ${EndIf}

  ${NSD_CreateLabel} 0 0 100% 12u "Service Name"
  Pop $ServiceNameLabel

  ${NSD_CreateText} 0 13u 100% 12u $ServiceNameText
  Pop $ServiceNameField


  ${NSD_CreateLabel} 0 26u 100% 12u "Server Host Name"
  Pop $ServerHostNameLabel

  ${NSD_CreateText} 0 39u 100% 12u $ServerHostNameText
  Pop $ServerHostNameField

  ${NSD_CreateLabel} 0 52u 100% 12u "Server Port Number"
  Pop $ServerPortNumberLabel

  ${NSD_CreateText} 0 65u 100% 12u $ServerPortNumberText
  Pop $ServerPortNumberField

  ${NSD_CreateButton} 0 78u 50% 12u "Reset to installer configuration"
  Pop $FrontendResetConfigButton

  ${NSD_OnClick} $FrontendResetConfigButton FrontendResetConfig

  ${IF} $OldServiceName != ""
    ${NSD_CreateButton} 50% 78u 50% 12u "Reset to installed configuration"
    Pop $FrontendOldConfigButton

    ${NSD_OnClick} $FrontendOldConfigButton FrontendOldConfig
  ${ENDIF}

  nsDialogs::Show

FunctionEnd

Function FrontendResetConfig
  ${NSD_SetText} $ServiceNameField $ResetServiceName
  ${NSD_SetText} $ServerHostNameField $ResetServerHostName
  ${NSD_SetText} $ServerPortNumberField $ResetServerPortNumber
FunctionEnd

Function FrontendOldConfig
  ${NSD_SetText} $ServiceNameField $OldServiceName
  ${NSD_SetText} $ServerHostNameField $OldServerHostName
  ${NSD_SetText} $ServerPortNumberField $OldServerPortNumber
FunctionEnd

; TODO: need to validate user inputs?
Function FrontendValidation

  ${NSD_GetText} $ServiceNameField $ServiceNameText
  ${NSD_GetText} $ServerHostNameField $ServerHostNameText
  ${NSD_GetText} $ServerPortNumberField $ServerPortNumberText

  ; not easy to do real validation here
  ${IF} $ServiceNameText == ""
    Abort
  ${ENDIF}

  WriteINIStr "$INSTDIR\serviceConfig.ini" service name $ServiceNameText
  WriteINIStr "$INSTDIR\serviceConfig.ini" service hostname $ServerHostNameText
  WriteINIStr "$INSTDIR\serviceConfig.ini" service port $ServerPortNumberText
  FlushINI "$INSTDIR\serviceConfig.ini"

FunctionEnd


Section "!Install Server and Service Files"

  SetOutPath $INSTDIR

  ; (see ReadConfigurations)
  ; File serviceConfig.ini

  File README.md

  ; service helpers
  File service.js
  File helper.bat

  ; service
  File server.js
  File package.json
  File /nonfatal sample-serviceConfig.ini

  ; served contents (avoid accumulating old revision-tagged versions)
!ifdef CONTENTS
  RMDir /r "$INSTDIR\${CONTENTS}"
  File /r ${CONTENTS}
!endif

  WriteUninstaller "$INSTDIR\uninstaller.exe"

  ${IF} $ConfigState == 1
    ExecShell "edit" "$INSTDIR\serviceConfig.ini"
  ${ENDIF}

  ${IF} $ReadmeState == 1
    ExecShell "edit" "$INSTDIR\README.md"
  ${ENDIF}

SectionEnd

Section /o "npm install Service dependencies"

  SetOutPath $INSTDIR

  ExecWait "$INSTDIR\helper.bat npm"

SectionEnd

Section /o "Start Server as Service"

  SetOutPath $INSTDIR

  IfFileExists "$INSTDIR\node_modules" 0 +2
    ExecWait "$INSTDIR\helper.bat serviceinstall"

SectionEnd

Section "Uninstall"

  SetOutPath $INSTDIR

  ; service
  ExecWait "$INSTDIR\helper.bat servicestop"
  ExecWait "$INSTDIR\helper.bat serviceuninstall"


  Delete "$INSTDIR\README.md"

  ; service configuration
  Delete "$INSTDIR\serviceConfig.ini"

  ; service helpers
  Delete "$INSTDIR\service.js"
  Delete "$INSTDIR\helper.bat"

  ; service
  Delete "$INSTDIR\server.js"
  Delete "$INSTDIR\package.json"
  Delete "$INSTDIR\sample-serviceConfig.ini"

  ; served contents
!ifdef CONTENTS
  RMDir /r "$INSTDIR\${CONTENTS}"
!endif

  ; generated files
  Delete "$INSTDIR\log.txt"
  RMDir /r "$INSTDIR\node_modules"

  Delete "$INSTDIR\uninstaller.exe"
  RMDir "$INSTDIR"

SectionEnd

!define PRODUCT_NAME "Nicotine+"
!define PRODUCT_VERSION "1.2.14"
!define PRODUCT_PUBLISHER "Nicotine+ Team"
!define PRODUCT_WEB_SITE "http://www.nicotine-plus.org"
!define PRODUCT_DIR_REGKEY "Software\Nicotine+"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

!include "MUI.nsh"
!include "LogicLib.nsh"
!include "WinVer.nsh"

!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE_3LINES
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_ICON "..\..\files\win32\nicotine-installer.ico"
!define MUI_UNICON "..\..\files\win32\nicotine-installer.ico"
!define MUI_HEADERIMAGE_BITMAP "..\..\files\win32\modern-header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\..\files\win32\modern-wizard.bmp"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\..\COPYING"
; Validate installation directory
!define MUI_DIRECTORYPAGE_VERIFYONLEAVE
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE ValidateInstDir
!insertmacro MUI_PAGE_DIRECTORY
Page custom ShortCuts
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

ReserveFile "shortcuts.ini"
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

Name "${PRODUCT_NAME} (${PRODUCT_VERSION})"
OutFile "${PRODUCT_NAME}-${PRODUCT_VERSION}.exe"
InstallDir "$PROGRAMFILES\Nicotine+"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Section "Core" Core
  SectionIn RO
  SetOverwrite on
  SetOutPath "$INSTDIR"
  File /r "..\..\dist\"
SectionEnd

; This function check if python24.dll exists
Function ValidateInstDir
  ${If} ${FileExists} "$INSTDIR\python24.dll"
    MessageBox MB_OK|MB_ICONEXCLAMATION "The choosen directory contains python24.dll.$\n\
This probably means you are installing over an old Nicotine+ (< 1.2.10) installation. It is not supported.$\n$\n\
Please choose another directory or cancel this setup, uninstall the previous Nicotine+ version and then, install this one again."
    Abort
  ${EndIf}
FunctionEnd

Function ShortCuts
  !insertmacro MUI_HEADER_TEXT "Nicotine+ shortcuts" "Please choose where shortctus will be created"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "shortcuts.ini"
FunctionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  ; Let's check if and old config exists and move it to APPDATA if possible
  ${If} ${FileExists} "$INSTDIR\config"
    DetailPrint "Old configuration detected."
    ${If} ${FileExists} "$APPDATA\nicotine"
      DetailPrint "Nicotine+ configuration already exists in APPDATA. Don't move the old one."
    ${Else}
      CreateDirectory "$APPDATA\nicotine"
      Rename "$INSTDIR\config" "$APPDATA\nicotine\config"
      DetailPrint  "Old Nicotine+ configuration moved to current user APPDATA."
    ${EndIf}
  ${EndIf}
  ReadINIStr $0 "$PLUGINSDIR\shortcuts.ini" "Field 2" "State"
  ${if} $0 = 1
    CreateShortCut "$SMPROGRAMS\Nicotine+.lnk" "$INSTDIR\nicotine.exe"
  ${endif}
  ReadINIStr $0 "$PLUGINSDIR\shortcuts.ini" "Field 3" "State"
  ${if} $0 = 1
    CreateShortCut "$DESKTOP\Nicotine+.lnk" "$INSTDIR\nicotine.exe" "" "$INSTDIR\files\win32\nicotine.ico" 0
  ${endif}
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${Core} "Required files"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Function .onInit
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "shortcuts.ini"
  ${IfNot} ${AtLeastWin2000}
    MessageBox MB_OK|MB_ICONEXCLAMATION "Nicotine+ requires Windows 2000 or later."
    Quit
  ${EndIf}
FunctionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  Delete "$INSTDIR\uninst.exe"
  Delete "$SMPROGRAMS\Nicotine+.lnk"
  Delete "$DESKTOP\Nicotine+.lnk"
  RMDir /r "$INSTDIR"
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd

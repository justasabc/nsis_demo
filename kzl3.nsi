; by kzl
;--------------------------------
; user defined constants
!define PRODUCT_NAME "Virtual Art Country"
!define PRODUCT_VERSION "1.0.3"
!define PRODUCT_PUBLISHER "PKUGIS"
!define PRODUCT_WEBSITE "http://www.gaudiart.com/Special/showwo/"
!define PAGE_ID Application
; registry key value
!define PRODUCT_ROOT_KEY HKLM
!define PRODUCT_DIR_SUB_KEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_NAME}.exe"
!define PRODUCT_UN_SUB_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_STARTMENU_REG_VALUENAME "NSIS:StartMenuDir"

; constants related with current folder
!define PRODUCT_EXE_NAME "Virtual Art County.exe"
!define PRODUCT_LICENSE ".\licenses.txt"
!define PRODUCT_README ".\readme.txt"

;--------------------------------
;Include Modern UI
!include "MUI2.nsh"
;Interface Settings
;These settings apply to all pages.

; show warning message box if cancel
!define MUI_ABORTWARNING
;!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
;!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
;--------------------------------
;Pages

; installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${PRODUCT_LICENSE}"
!insertmacro MUI_PAGE_COMPONENTS
; store the install dir into $INSTDIR
!insertmacro MUI_PAGE_DIRECTORY

;Variables
Var StartMenuFolder
;Store the folder in $StartMenuFolder
!define PRODUCT_EXE_PATH "$INSTDIR\${PRODUCT_NAME}.exe" 

!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "${PRODUCT_NAME}"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UN_SUB_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REG_VALUENAME}"
!insertmacro MUI_PAGE_STARTMENU ${PAGE_ID} $StartMenuFolder
!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_RUN_CHECKED
!define MUI_FINISHPAGE_RUN "${PRODUCT_EXE_PATH}"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_FINISHPAGE_SHOWREADME "{PRODUCT_README}"
!insertmacro MUI_PAGE_FINISH

;uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;Languages files
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "TradChinese"
; MUI end---

;--------------------------------
;General
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "${PRODUCT_NAME} ${PRODUCT_VERSION} Installer.exe"
; 3 ways to modify $INSTDIR : InstallDir InstallDirRegKey  MUI_PAGE_DIRECTORY
InstallDir "$PROGRAMFILES\${PRODUCT_NAME}"
;This attribute tells the installer to check a string in the registry, and use it for the install dir if that string is valid. If this attribute is present, it will override the InstallDir attribute if the registry key is valid, otherwise it will fall back to the InstallDir default.
;Get installation folder from registry if available
;HKLM is for all users, HKCU is for the current user.
;InstallDirRegKey HKCU "Software\Modern UI Test" ""
InstallDirRegKey ${PRODUCT_ROOT_KEY} "${PRODUCT_DIR_SUB_KEY}" ""

ShowInstDetails show  
; hide show
ShowUnInstDetails show

;Request application privileges for Windows Vista
;none|user|highest|admin
;must be admin to create folder and copy files!!!
RequestExecutionLevel admin
;--------------------------------
;Installer Sections

Function .onInit
!insertmacro MUI_LANGDLL_DISPLAY
; dialog to choose language
FunctionEnd

Section "Main Section" SEC01
Call CopyAllFiles
Call CreateShortCuts
Call WriteUninstaller2ControlPanel
Call Bind2Client
SectionEnd

;copy files
FUNCTION CopyAllFiles
; Sets the output path ($OUTDIR) and creates it (recursively if necessary)
SetOutPath $INSTDIR
;on|off|try|ifnewer|ifdiff|lastused
SetOverwrite ifnewer
; copy all files to install dir
FILE /r /x *.nsi /x SecondLife *

; copy second life settings to appdata folder
SetOutPath $APPDATA
FILE /r SecondLife
FunctionEnd

; create shortcuts
FUNCTION CreateShortCuts
!define PRODUCT_UN_EXE_PATH "$INSTDIR\Uninstall.exe"

; start menu dir
!define START_MENU_DIR "$SMPROGRAMS\$StartMenuFolder"
!insertmacro MUI_STARTMENU_WRITE_BEGIN ${PAGE_ID}
CreateDirectory "${START_MENU_DIR}"
CreateShortCut "${START_MENU_DIR}\${PRODUCT_NAME}.lnk" "${PRODUCT_EXE_PATH}"
CreateShortCut "${START_MENU_DIR}\Uninstall.lnk" "${PRODUCT_UN_EXE_PATH}"

; Website
!define PRODUCT_WEBSITE_PATH "$INSTDIR\${PRODUCT_NAME}.url"
WriteIniStr "${PRODUCT_WEBSITE_PATH}" "InternetShortcut" "URL" "${PRODUCT_WEBSITE}"
CreateShortCut "${START_MENU_DIR}\Website.lnk" "${PRODUCT_WEBSITE_PATH}"

; desktop
CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "${PRODUCT_EXE_PATH}"
!insertmacro MUI_STARTMENU_WRITE_END
FunctionEnd

; write uninstaller info to control panel
; http://nsis.sourceforge.net/Add_uninstall_information_to_Add/Remove_Programs
FUNCTION WriteUninstaller2ControlPanel
;Create uninstaller
WriteUninstaller "${PRODUCT_UN_EXE_PATH}"
;WriteRegStr root_key subkey key_name value
;Store installation folder
WriteRegStr ${PRODUCT_ROOT_KEY} "${PRODUCT_DIR_SUB_KEY}" ""  "${PRODUCT_EXE_PATH}"

;Write uninstaller to control panel
WriteRegStr ${PRODUCT_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}" "DisplayIcon" "${PRODUCT_EXE_PATH}"
WriteRegStr ${PRODUCT_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}" "DisplayName" "${PRODUCT_NAME}"
WriteRegStr ${PRODUCT_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
WriteRegStr ${PRODUCT_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
WriteRegStr ${PRODUCT_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}" "UninstallString" "$INSTDIR\Uninstall.exe"
WriteRegStr ${PRODUCT_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}" "URLInfoAbout" "${PRODUCT_WEBSITE}"
WriteRegStr ${PRODUCT_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}" "HelpLine" "${PRODUCT_WEBSITE}"

Call ComputeEstimatedSize
FunctionEnd

; compute EstimatedSize and write to registry
!include "FileFunc.nsh"
FUNCTION ComputeEstimatedSize
${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
IntFmt $0 "0x%08X" $0
WriteRegDWORD ${PRODUCT_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}" "EstimatedSize" "$0"
FunctionEnd

;Bind secondlife protocol to client
FUNCTION Bind2Client
WriteRegStr HKEY_CLASSES_ROOT "secondlife" "(default)" "URL:Second Life"
WriteRegStr HKEY_CLASSES_ROOT "secondlife" "URL Protocol" ""
WriteRegStr HKEY_CLASSES_ROOT "secondlife\DefaultIcon" "" '"$INSTDIR\${PRODUCT_NAME}.exe"'
WriteRegExpandStr HKEY_CLASSES_ROOT "secondlife\shell\open\command" "" '"${PRODUCT_EXE_PATH}" -url "%1"'
FunctionEnd
;--------------------------------
;Uninstaller Section

; system callback
Function un.onInit
;!insertmacro MUI_UNGETLANGUAGE
MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
Abort
FunctionEnd

; system callback
Function un.onUninstSuccess
HideWindow
MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Section Uninstall
Call un.DeleteAllFiles
Call un.DeleteAllRegkeys 
SetAutoClose true
SectionEnd

FUNCTION un.DeleteAllFiles
; delete start menu dir
!insertmacro MUI_STARTMENU_GETFOLDER ${PAGE_ID} $StartMenuFolder
RMDir /r "$SMPROGRAMS\$StartMenuFolder" 
; delete desktop
Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
; delete install dir
RMDir /r $INSTDIR
FunctionEnd

FUNCTION un.DeleteAllRegkeys
;DeleteRegKey /ifempty ${PRODUCT_ROOT_KEY} "${PRODUCT_SUB_KEY}"
DeleteRegKey ${PRODUCT_ROOT_KEY} "${PRODUCT_DIR_SUB_KEY}"
DeleteRegKey ${PRODUCT_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}"
FunctionEnd

!include "MUI2.nsh"
;!include "FileAssociation.nsh"
; ERROR by kzl
;---------------------
;Variables
	Var StartMenuFolder
!define Version 1.0.3
;General
;
;	Name and file
	Name "Virtual Art Country"
	OutFile "Virtual Art Country ${Version} Installer.exe"
;	Default installation folder
	InstallDir "$PROGRAMFILES\Virtual Art Country"
;	Request application privileges for windows 7
	RequestExecutionLevel admin


;---------------------
;Interface Settings
	!define MUI_ABORTWARNING

;---------------------
;Pages
	!insertmacro MUI_PAGE_COMPONENTS
	!insertmacro MUI_PAGE_DIRECTORY
;	Start Menu Folder Page Configuration
	!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU"
	!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Virtual Art Country ${Version}"
	!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
	!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
	!insertmacro MUI_PAGE_INSTFILES
	!insertmacro MUI_UNPAGE_CONFIRM
	!insertmacro MUI_UNPAGE_INSTFILES

;----------------------
;Languages
	!define MUI_LANGDLL_ALLLANGUAGES
	!insertmacro MUI_LANGUAGE "English" ;1st language is default
	!insertmacro MUI_LANGUAGE "SimpChinese"
	!insertmacro MUI_LANGUAGE "TradChinese"

;-----------------------
;Installer Sections
Function .onInit
	!insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Section "Virtual Art Country Client" SecClient
	SetOutPath "$INSTDIR"
	FILE /r /x *.nsi /x SecondLife *
	;Store installation folder
	WriteRegStr HKCU "Software\Virtual Art Country ${Version}" "" $INSTDIR
	WriteUninstaller "$INSTDIR\Uninstall.exe"
	;Write uninstaller to control panel
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Virtual Art Country ${Version}" "DisplayName" "Virtual Art Country ${Version}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Virtual Art Country ${Version}" "UninstallString" "$INSTDIR\Uninstall.exe"

        ; kzl
	;Bind secondlife protocol to client
	WriteRegStr HKEY_CLASSES_ROOT "secondlife" "(default)" "URL:Second Life"
	WriteRegStr HKEY_CLASSES_ROOT "secondlife" "URL Protocol" ""
	WriteRegStr HKEY_CLASSES_ROOT "secondlife\DefaultIcon" "" '"$INSTDIR\Virtual Art Country.exe"'
	WriteRegExpandStr HKEY_CLASSES_ROOT "secondlife\shell\open\command" "" '"$INSTDIR\Virtual Art Country.exe" -url "%1"'

	!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
	CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
	CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
	CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Virtual Art Country.lnk" "$INSTDIR\Virtual Art Country.exe"
	CreateShortCut "$DESKTOP\Virtual Art Country.lnk" "$INSTDIR\Virtual Art Country.exe"
	!insertmacro MUI_STARTMENU_WRITE_END

	SetOutPath "$APPDATA"
	FILE /r SecondLife
SectionEnd

;----------------------------
;Unistaller Section
Section "Uninstall"
	RMDir /r "$INSTDIR"
	DeleteRegKey /ifempty HKCU "Software\Virtual Art Country ${Version}"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Virtual Art Country ${Version}"
	!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
	Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk"
	Delete "$SMPROGRAMS\$StartMenuFolder\Virtual Art Country.lnk"
	RMDir "$SMPROGRAMS\$StartMenuFolder"
	Delete "$DESKTOP\Virtual Art Country.lnk"
SectionEnd

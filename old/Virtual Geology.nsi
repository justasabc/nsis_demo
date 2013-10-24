!include "MUI2.nsh"
;!include "FileAssociation.nsh"

;General
;
;	Name and file
	Name "Virtual Geology"
	OutFile "Virtual Geology 1.0 Installer.exe"
;	Default installation folder
	InstallDir "$PROGRAMFILES\Virtual Geology"
;	Request application privileges for windows 7
	RequestExecutionLevel admin

;---------------------
;Variables
	Var StartMenuFolder

;---------------------
;Interface Settings
	!define MUI_ABORTWARNING

;---------------------
;Pages
	!insertmacro MUI_PAGE_COMPONENTS
	!insertmacro MUI_PAGE_DIRECTORY
;	Start Menu Folder Page Configuration
	!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU"
	!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Virtual Geology 1.0"
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

Section "Virtual Geology Client" SecClient
	SetOutPath "$INSTDIR"
	FILE /r /x *.nsi /x SecondLife *
	;Store installation folder
	WriteRegStr HKCU "Software\Virtual Geology 1.0" "" $INSTDIR
	WriteUninstaller "$INSTDIR\Uninstall.exe"
	;Write uninstaller to control panel
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Virtual Geology 1.0" "DisplayName" "Virtual Geology 1.0"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Virtual Geology 1.0" "UninstallString" "$INSTDIR\Uninstall.exe"

	!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
	CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
	CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
	CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Virtual Geology.lnk" "$INSTDIR\Virtual Geology.exe"
	CreateShortCut "$DESKTOP\Virtual Geology.lnk" "$INSTDIR\Virtual Geology.exe"
	!insertmacro MUI_STARTMENU_WRITE_END

	SetOutPath "$APPDATA"
	FILE /r SecondLife
SectionEnd

;----------------------------
;Unistaller Section
Section "Uninstall"
	RMDir /r "$INSTDIR"
	DeleteRegKey /ifempty HKCU "Software\Virtual Geology 1.0"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Virtual Geology 1.0"
	!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
	Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk"
	Delete "$SMPROGRAMS\$StartMenuFolder\Virtual Geology.lnk"
	RMDir "$SMPROGRAMS\$StartMenuFolder"
	Delete "$DESKTOP\Virtual Geology.lnk"
SectionEnd

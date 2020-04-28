!include version.nsh
!include x64.nsh
!include MUI2.nsh
!define MUI_ICON "..\tasch1.ico"
!define MUI_UNICON "..\tasch1.ico"
!define MUI_ABORTWARNING
!define MUI_COMPONENTSPAGE_SMALLDESC
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH
!insertmacro MUI_LANGUAGE "German"
;!define LVM_GETITEMCOUNT 0x1004
!define LVM_GETITEMTEXT 0x102D
;--------------------------------------------------------------------------------------------------------
; Product Version
;--------------------------------------------------------------------------------------------------------
VIProductVersion "${_VERSION}"
VIAddVersionKey  "ProductName" "${_PRODUCT}"
VIAddVersionKey  "ProductVersion" "${_VERSION}"
VIAddVersionKey  "FileDescription" "${_COMMENT}"
VIAddVersionKey  "CompanyName" "${_COMPANY}"
VIAddVersionKey  "LegalCopyright" "${_COPYRIGHT}"
VIAddVersionKey  "FileVersion" "${_VERSION}"
VIAddVersionKey  "InternalName" "${_INTERNAL}"
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
; The name of the installer
;--------------------------------------------------------------------------------------------------------
Name "Tasch1"

;--------------------------------------------------------------------------------------------------------
; The file to write
;--------------------------------------------------------------------------------------------------------
OutFile "..\Tasch1_setup.exe"

;--------------------------------------------------------------------------------------------------------
; The default installation directory
;--------------------------------------------------------------------------------------------------------
InstallDir $PROGRAMFILES\Tasch1

;--------------------------------------------------------------------------------------------------------
; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
;--------------------------------------------------------------------------------------------------------
InstallDirRegKey HKLM "Software\unattended.ch\Tasch1" "Install_Dir"

;--------------------------------------------------------------------------------------------------------
; Request application privileges for Windows Vista
;--------------------------------------------------------------------------------------------------------
RequestExecutionLevel admin

;--------------------------------------------------------------------------------------------------------
; The stuff to install
;--------------------------------------------------------------------------------------------------------
Section "Tasch1 (required)"
  SectionIn RO
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  File "..\Tasch1.exe"
  SetOutPath $INSTDIR\scripts
  File "..\scripts\*.*"
  SetOutPath $INSTDIR\locale
  File "..\locale\*.mo"
  ; Write the installation path into the registry
  WriteRegStr HKLM "SOFTWARE\Lucas Imark\Tasch1" "Install_Dir" "$INSTDIR"
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tasch1" "DisplayName" "Tasch1"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tasch1" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tasch1" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tasch1" "NoRepair" 1
  WriteUninstaller "uninstall.exe"
SectionEnd

;--------------------------------------------------------------------------------------------------------
; Optional section (can be disabled by the user)
;--------------------------------------------------------------------------------------------------------
Section "Start Menu Shortcuts"
  CreateDirectory "$SMPROGRAMS\Tasch1"
  CreateShortCut "$SMPROGRAMS\Tasch1\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut "$SMPROGRAMS\Tasch1\Tasch1.lnk" "$INSTDIR\Tasch1.exe" "" "$INSTDIR\Tasch1.exe" 0
  StrCpy $0 "$TEMP\install.log"
  Push $0
  Call DumpLog
SectionEnd

;--------------------------------------------------------------------------------------------------------
; Uninstaller
;--------------------------------------------------------------------------------------------------------
Section "Uninstall"
;  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tasch1" "mySQL"
;  StrCmp $0 "" done
;		ExecWait 'msiexec /qb /x {38766225-85FA-469B-A373-82BF1923A7E4} ALLUSERS=2 REBOOT=ReallySuppress'
;		ExecWait 'msiexec /qb /x {DD30399D-5BF8-4C15-AA2B-2456B3B2B7BA} ALLUSERS=2 REBOOT=ReallySuppress'
;done:
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tasch1"
  DeleteRegKey HKLM "SOFTWARE\Lucas Imark\Tasch1"
  ; Remove files and uninstaller
  Delete $INSTDIR\Tasch1.exe
  Delete $INSTDIR\uninstall.exe
  Delete $INSTDIR\scripts\*.*
  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\Tasch1\*.*"
  ; Remove directories used
  RMDir "$SMPROGRAMS\Tasch1"
  RMDir "$INSTDIR\scripts"
  RMDir "$INSTDIR"
  StrCpy $0 "$TEMP\uninstall.log"
  Push $0
  Call un.DumpLog
SectionEnd

;--------------------------------------------------------------------------------------------------------
; Dump to logfile
;--------------------------------------------------------------------------------------------------------
Function DumpLog
;--------------------------------------------------------------------------------------------------------
  Exch $5
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $6
 
  FindWindow $0 "#32770" "" $HWNDPARENT
  GetDlgItem $0 $0 1016
  StrCmp $0 0 exit
  FileOpen $5 $5 "w"
  StrCmp $5 "" exit
    SendMessage $0 ${LVM_GETITEMCOUNT} 0 0 $6
    System::Alloc ${NSIS_MAX_STRLEN}
    Pop $3
    StrCpy $2 0
    System::Call "*(i, i, i, i, i, i, i, i, i) i \
      (0, 0, 0, 0, 0, r3, ${NSIS_MAX_STRLEN}) .r1"
    loop: StrCmp $2 $6 done
      System::Call "User32::SendMessageA(i, i, i, i) i \
        ($0, ${LVM_GETITEMTEXT}, $2, r1)"
      System::Call "*$3(&t${NSIS_MAX_STRLEN} .r4)"
      FileWrite $5 "$4$\r$\n"
      IntOp $2 $2 + 1
      Goto loop
    done:
      FileClose $5
      System::Free $1
      System::Free $3
  exit:
    Pop $6
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Pop $0
    Exch $5
FunctionEnd

;--------------------------------------------------------------------------------------------------------
; Dump to logfile
;--------------------------------------------------------------------------------------------------------
Function un.DumpLog
;--------------------------------------------------------------------------------------------------------
  Exch $5
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $6
 
  FindWindow $0 "#32770" "" $HWNDPARENT
  GetDlgItem $0 $0 1016
  StrCmp $0 0 exit
  FileOpen $5 $5 "w"
  StrCmp $5 "" exit
    SendMessage $0 ${LVM_GETITEMCOUNT} 0 0 $6
    System::Alloc ${NSIS_MAX_STRLEN}
    Pop $3
    StrCpy $2 0
    System::Call "*(i, i, i, i, i, i, i, i, i) i \
      (0, 0, 0, 0, 0, r3, ${NSIS_MAX_STRLEN}) .r1"
    loop: StrCmp $2 $6 done
      System::Call "User32::SendMessageA(i, i, i, i) i \
        ($0, ${LVM_GETITEMTEXT}, $2, r1)"
      System::Call "*$3(&t${NSIS_MAX_STRLEN} .r4)"
      FileWrite $5 "$4$\r$\n"
      IntOp $2 $2 + 1
      Goto loop
    done:
      FileClose $5
      System::Free $1
      System::Free $3
  exit:
    Pop $6
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Pop $0
    Exch $5
FunctionEnd

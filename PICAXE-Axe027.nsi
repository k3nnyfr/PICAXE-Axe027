;NSIS Installer for PICAXE-Axe027 Driver
;
;Ecrit par Alexandre Gauvrit

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"
  !include "x64.nsh"

;--------------------------------
;General

Name "Axe027 Drivers"
OutFile "PICAXE-Axe027.exe"
VIProductVersion "1.0"

ComponentText "Axe027 Drivers"

  
;--------------------------------
;Elements

!define MUI_HEADERIMAGE
!define MUI_ICON "picaxe.ico"
!define MUI_HEADERIMAGE_BITMAP "picaxe-header.bmp" ; optional
!define MUI_WELCOMEFINISHPAGE_BITMAP "picaxe-welcomefinish.bmp"
;--------------------------------
;Pages

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES

;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "French"

;--------------------------------

Section "Installation du Driver" SecDummy
	SectionIn RO
	SetOutPath "C:\Drivers\"
	
	File /r "amd64"
	File /r "i386"
	File "future.cer"
	File "ftdibus.cat"
	File "ftdibus.inf"
	File "ftdiport.cat"
	File "ftdiport.inf"
	File "PICAXE-Axe027.nsi"
	
	Push C:\Drivers\future.cer
	Call AddCertificateToStore
	
	nsExec::ExecToLog '"Certutil -addstore -f TrustedPublisherC:\Drivers\future.cer"'
	${DisableX64FSRedirection}
	nsExec::ExecToLog '"$SYSDIR\PnPutil.exe" -i -a "C:\Drivers\ftdibus.inf"'
	nsExec::ExecToLog '"$SYSDIR\PnPutil.exe" -i -a "C:\Drivers\ftdiport.inf"'
	${EnableX64FSRedirection}
		
	#InstDrv::InstallDriver $TEMP\ftdibus.inf
	#InstDrv::InstallDriver $TEMP\ftdiport.inf
	
SectionEnd

!define CERT_QUERY_OBJECT_FILE 1
!define CERT_QUERY_CONTENT_FLAG_ALL 16382
!define CERT_QUERY_FORMAT_FLAG_ALL 14
!define CERT_STORE_PROV_SYSTEM 10
!define CERT_STORE_OPEN_EXISTING_FLAG 0x4000
!define CERT_SYSTEM_STORE_LOCAL_MACHINE 0x20000
!define CERT_STORE_ADD_ALWAYS 4

;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecDummy ${LANG_FRENCH} "Installation du driver PICAXE Axe027"

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDummy} $(DESC_SecDummy)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END
 
Function AddCertificateToStore
 
  Exch $0
  Push $1
  Push $R0
 
  System::Call "crypt32::CryptQueryObject(i ${CERT_QUERY_OBJECT_FILE}, w r0, \
    i ${CERT_QUERY_CONTENT_FLAG_ALL}, i ${CERT_QUERY_FORMAT_FLAG_ALL}, \
    i 0, i 0, i 0, i 0, i 0, i 0, *i .r0) i .R0"
 
  ${If} $R0 <> 0
 
    System::Call "crypt32::CertOpenStore(i ${CERT_STORE_PROV_SYSTEM}, i 0, i 0, \
      i ${CERT_STORE_OPEN_EXISTING_FLAG}|${CERT_SYSTEM_STORE_LOCAL_MACHINE}, \
      w 'ROOT') i .r1"
 
    ${If} $1 <> 0
 
      System::Call "crypt32::CertAddCertificateContextToStore(i r1, i r0, \
        i ${CERT_STORE_ADD_ALWAYS}, i 0) i .R0"
      System::Call "crypt32::CertFreeCertificateContext(i r0)"
 
      ${If} $R0 = 0
 
        StrCpy $0 "Unable to add certificate to certificate store"
 
      ${Else}
 
        StrCpy $0 "success"
 
      ${EndIf}
 
      System::Call "crypt32::CertCloseStore(i r1, i 0)"
 
    ${Else}
 
      System::Call "crypt32::CertFreeCertificateContext(i r0)"
 
      StrCpy $0 "Unable to open certificate store"
 
    ${EndIf}
 
  ${Else}
 
    StrCpy $0 "Unable to open certificate file"
 
  ${EndIf}
 
  Pop $R0
  Pop $1
  Exch $0
 
FunctionEnd
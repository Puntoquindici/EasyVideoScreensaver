; Inno Setup script for Easy Video Screensaver
; Requires Inno Setup 6.3 or later (uses ArchitecturesInstallIn64BitMode=x64compatible).
;
; Build:
;   1. Compile the project in Release configuration (produces bin\Release\EasyVideoScreensaver.scr)
;   2. Compile this script: ISCC.exe EasyVideoScreensaver.iss   (or open it in the Inno Setup IDE)
;   Output: Output\EasyVideoScreensaverSetup.exe

#define MyAppName      "Easy Video Screensaver"
#define MyAppVersion   "1.2.0"
; Original author of the software (MIT license). Change if you publish under a different name.
#define MyAppPublisher "Tony Federer"
#define MyAppURL       "https://github.com/tonyfederer/EasyVideoScreensaver"
#define MyScr          "EasyVideoScreensaver.scr"
#define BuildDir       "..\EasyVideoScreensaver\bin\Release"

[Setup]
; Unique ID for this application: never change it between versions.
AppId={{6F2C1B7E-3A54-4D8B-9E1A-5C0B7D42A9F3}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
VersionInfoVersion={#MyAppVersion}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
LicenseFile=..\License.rtf
OutputDir=Output
OutputBaseFilename=EasyVideoScreensaverSetup
SetupIconFile=..\EasyVideoScreensaver\video.ico
UninstallDisplayIcon={app}\video.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
; The .scr goes into the Windows system folder, so administrator rights are required.
PrivilegesRequired=admin
; The executable is AnyCPU: on 64-bit Windows it runs as 64-bit, so install into the 64-bit System32.
ArchitecturesAllowed=x86compatible or x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Signing (optional): configure a SignTool in the IDE (Tools > Configure Sign Tools), then uncomment:
; SignTool=mysigntool
; SignedUninstaller=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"

[Tasks]
; Checked by default: outside System32 the screensaver may not be listed in the Windows picker,
; so it is activated through the registry for the user running the installer.
Name: "setactive"; Description: "Set {#MyAppName} as the active screensaver for the current user"

[Files]
; NOTE: the screensaver is installed in the application folder, not in System32:
; the .NET executable fails to start when launched from System32 (verified on Windows 10).
Source: "{#BuildDir}\{#MyScr}";        DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildDir}\{#MyScr}.config"; DestDir: "{app}"; Flags: ignoreversion
; Documentation, license (MIT requires it to travel with the software) and icon.
Source: "..\Readme.md";                DestDir: "{app}"; Flags: ignoreversion
Source: "..\License.rtf";              DestDir: "{app}"; Flags: ignoreversion
Source: "..\EasyVideoScreensaver\video.ico"; DestDir: "{app}"; Flags: ignoreversion

[InstallDelete]
; Remove the copy placed in System32 by the previous version of this installer.
Type: files; Name: "{sys}\{#MyScr}"
Type: files; Name: "{sys}\{#MyScr}.config"

[Icons]
; Opens the settings dialog (/c).
Name: "{group}\{#MyAppName} Settings"; Filename: "{app}\{#MyScr}"; Parameters: "/c"; IconFilename: "{app}\video.ico"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"

[Registry]
Root: HKCU; Subkey: "Control Panel\Desktop"; ValueType: string; ValueName: "SCRNSAVE.EXE"; ValueData: "{app}\{#MyScr}"; Tasks: setactive; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Control Panel\Desktop"; ValueType: string; ValueName: "ScreenSaveActive"; ValueData: "1"; Tasks: setactive

[Run]
; Offer to open the settings dialog at the end of the installation.
Filename: "{app}\{#MyScr}"; Parameters: "/c"; Description: "Choose the video now"; Flags: postinstall nowait skipifsilent

[Code]
// Block installation if .NET Framework 4.8 is missing (Release >= 528040).
function IsDotNet48Installed: Boolean;
var
  Release: Cardinal;
begin
  Result := RegQueryDWordValue(HKLM, 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full', 'Release', Release)
            and (Release >= 528040);
end;

function InitializeSetup: Boolean;
begin
  Result := True;
  if not IsDotNet48Installed then
  begin
    MsgBox('{#MyAppName} requires .NET Framework 4.8.' + #13#10 +
           'Install it from https://dotnet.microsoft.com/download/dotnet-framework/net48 and run this setup again.',
           mbError, MB_OK);
    Result := False;
  end;
end;

[Setup]
AppId={{C0F22A12-B5D1-4F2B-9B5D-1F2B9B5D1F2B}}
AppName=TrueCash
AppVersion=1.1.0
;AppVerName=True Cash 1.1.0
AppPublisher=Satya Kommula
AppPublisherURL=https://github.com/satyakommula/truecash
DefaultDirName={autopf}\TrueCash
DisableProgramGroupPage=yes
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
OutputDir=..\build\windows\x64\installer
OutputBaseFilename=truecash_setup
SetupIconFile=..\windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\truecash.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\TrueCash"; Filename: "{app}\truecash.exe"
Name: "{autodesktop}\TrueCash"; Filename: "{app}\truecash.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\truecash.exe"; Description: "{cm:LaunchProgram,TrueCash}"; Flags: nowait postinstall skipifsilent

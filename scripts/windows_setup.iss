#define MyAppExeName "trueledger.exe"

#ifndef AppVersion
  #define AppVersion GetFileVersion("..\build\windows\x64\runner\Release\" + MyAppExeName)
#endif

[Setup]
AppId={C0F22A12-B5D1-4F2B-9B5D-1F2B9B5D1F2B}
AppName=TrueLedger
AppVersion={#AppVersion}
AppPublisher=Satya Kommula
AppPublisherURL=https://github.com/satyakommula/TrueLedger
DefaultDirName={pf}\TrueLedger
PrivilegesRequired=admin

DisableProgramGroupPage=yes
DisableWelcomePage=yes
DisableReadyPage=yes
DisableFinishedPage=yes

OutputDir=..\build\windows\x64\installer
OutputBaseFilename=TrueLedger
SetupIconFile=..\windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\trueledger.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\TrueLedger"; Filename: "{app}\trueledger.exe"
Name: "{autodesktop}\TrueLedger"; Filename: "{app}\trueledger.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\trueledger.exe"; Flags: nowait postinstall skipifsilent
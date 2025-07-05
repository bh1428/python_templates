; INNO Setup script for {{ cookiecutter.app_description }}
; Copyright (C) {{ cookiecutter.copyright_year }} {{ cookiecutter.app_author }} ({{ cookiecutter.app_author_email }}) - All Rights Reserved
#include "version.iss"
#define MyAppName "{{ cookiecutter.repo_name }}"
#define MyCompany "{{ cookiecutter.author_company }}"
#define MyAppExe "{{ cookiecutter.repo_name }}.exe"

[Setup]
AppId={{ '{{' }}{{ uuid4() }}{{ '}' }}
AppName={{ '{' }}#MyAppName{{ '}' }}
AppVersion={{ '{' }}#MyAppVersion{{ '}' }}
AppPublisher="{{ '{' }}#MyCompany{{ '}' }}"
DefaultDirName={{ '{' }}autopf{{ '}' }}\{{ '{' }}#MyAppName{{ '}' }}
DefaultGroupName={{ '{' }}#MyAppName{{ '}' }}
AllowNoIcons=yes
DisableProgramGroupPage=true
LicenseFile="LICENSE"
OutputDir="dist"
OutputBaseFilename="{{ '{' }}#MyAppName{{ '}' }} setup {{ '{' }}#MyAppVersion{{ '}' }}"
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
SetupIconFile="images\{{ cookiecutter.repo_name }}.ico"
UninstallDisplayIcon="{{ '{' }}app{{ '}' }}\{{ '{' }}#MyAppExe{{ '}' }}"
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: desktopicon; Description: "Create a desktop icon"; GroupDescription: "Additional icons:";
Name: desktopicon\common; Description: "For all users"; GroupDescription: "Additional icons:"; Flags: exclusive unchecked
Name: desktopicon\user; Description: "For the current user only"; GroupDescription: "Additional icons:"; Flags: exclusive
Name: quicklaunchicon; Description: "Create a Quick Launch icon"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
Source: "build_info.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "cmdline_options.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\{{ cookiecutter.repo_name }}\{{ '{' }}#MyAppExe{{ '}' }}"; DestDir: "{{ '{' }}app{{ '}' }}"; Flags: ignoreversion
Source: "dist\{{ cookiecutter.repo_name }}\lib\*"; DestDir: "{{ '{' }}app{{ '}' }}\lib"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{{ '{' }}group{{ '}' }}\{{ '{' }}#MyAppName{{ '}' }}"; Filename: "{{ '{' }}app{{ '}' }}\{{ '{' }}#MyAppExe{{ '}' }}"
Name: "{{ '{' }}group{{ '}' }}\{{ '{' }}cm:UninstallProgram,{{ '{' }}#MyAppName{{ '}}' }}"; Filename: "{{ '{' }}uninstallexe{{ '}' }}"
Name: "{{ '{' }}autodesktop}\{{ '{' }}#MyAppName{{ '}' }}"; Filename: "{{ '{' }}app{{ '}' }}\{{ '{' }}#MyAppExe{{ '}' }}"; Tasks: desktopicon

[InstallDelete]
Type: filesandordirs; Name: "{{ '{' }}app{{ '}' }}\lib"

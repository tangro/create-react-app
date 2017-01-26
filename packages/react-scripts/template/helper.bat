@echo off

echo %1

if "%1"=="npm" goto npm

if "%1"=="serviceinstall" goto serviceinstall
if "%1"=="serviceuninstall" goto serviceuninstall

if "%1"=="servicestop" goto servicestop
if "%1"=="servicestart" goto servicestart
if "%1"=="servicerestart" goto servicerestart

if "%1"=="buildinstaller" goto buildinstaller

goto end

:npm

npm install >> log.txt 2>&1
goto end

:serviceinstall

node service.js install >> log.txt 2>&1
goto end

:servicestop

node service.js stop >> log.txt 2>&1
goto end

:servicestart

node service.js start >> log.txt 2>&1
goto end

:servicerestart

node service.js restart >> log.txt 2>&1
goto end

:serviceuninstall

node service.js uninstall >> log.txt 2>&1
goto end

:buildinstaller

SETLOCAL EnableDelayedExpansion
SET INIFILE=serviceConfig.ini
SET SECTION=none

rem read name and version from ini file
echo == processing %INIFILE%
for /f "usebackq tokens=1,*eol=|delims==" %%a in (%INIFILE%) do (
  if "%%b"=="" (
    set SECTION=%%a
    echo !SECTION!
  ) else if "!SECTION!"=="[service]" (
    echo %%a=%%b
    if "%%a"=="version" (
      SET %%a=%%b
    ) else if "%%a"=="name" (
      SET %%a=%%b
    ) else if "%%a"=="installDir" (
      SET %%a=%%b
    ) else if "%%a"=="contents" (
      SET %%a=%%b
    )
  )
)

if not defined installDir (
  echo "aborted: please configure an installation directory (installDir=<somewhere>)"
  exit /b
)

if defined contents (
  "C:/Program Files (x86)/NSIS/makensis.exe" /DVERSION="%version%" /DNAME="%name%" /DINSTALLDIR="%installDir%" /DCONTENTS="%contents%" %name%.nsi
) else (
  "C:/Program Files (x86)/NSIS/makensis.exe" /DVERSION="%version%" /DNAME="%name%" /DINSTALLDIR="%installDir%" %name%.nsi
)
goto end

:end

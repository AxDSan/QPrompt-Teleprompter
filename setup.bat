@echo off
REM ============================================================
REM QPrompt Setup Script (Native Windows version)
REM This script mirrors the business logic of setup.sh
REM without relying on bash.
REM ============================================================

setlocal EnableDelayedExpansion

REM ----- Configuration -----
set "QT_VER=6.8.2"
set "PLATFORM=windows"

REM Detect architecture
if /I "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
    set "COMPILER=mingw_arm64"
) else (
    set "COMPILER=mingw_64"
)

REM Default installation prefix and tool commands
set "CMAKE_INSTALL_PREFIX=install"
set "CMAKE=cmake"
set "CPACK=cpack"
set "CMAKE_CONFIGURATION_TYPES=Debug;Release;RelWithDebInfo;MinSizeRel"

REM Get input parameters:
REM   %1 = CMAKE_BUILD_TYPE (default: Release on Windows)
REM   %2 = CMAKE_PREFIX_PATH (default: C:\Qt\<QT_VER>\<COMPILER>\)
REM   %3 = CLEAR or CLEAR_ALL flag
if "%~1"=="" (
    set "CMAKE_BUILD_TYPE=Release"
) else (
    set "CMAKE_BUILD_TYPE=%~1"
)

if "%~2"=="" (
    set "CMAKE_PREFIX_PATH=C:\Qt\%QT_VER%\%COMPILER%\"
) else (
    set "CMAKE_PREFIX_PATH=%~2"
)

set "CLEAR=false"
set "CLEAR_ALL=false"
if /I "%~3"=="CLEAR" (
    set "CLEAR=true"
) else if /I "%~3"=="CLEAR_ALL" (
    set "CLEAR=true"
    set "CLEAR_ALL=true"
)

REM For installation directories – mimic the bash logic:
REM Default: AppDir = install and AppDirUsr = install\usr
set "AppDir=install"
set "AppDirUsr=install\usr"
if not exist "%AppDirUsr%" mkdir "%AppDirUsr%"

REM Display usage and settings
echo.
echo USAGE: setup.bat ^<CMAKE_BUILD_TYPE^> ^<CMAKE_PREFIX_PATH^> [CLEAR ^| CLEAR_ALL]
echo.
echo Settings:
echo   CMAKE_BUILD_TYPE: %CMAKE_BUILD_TYPE%
echo   CMAKE_PREFIX_PATH: %CMAKE_PREFIX_PATH%
echo.
echo This script sets up QPrompt for Windows using native tools.
pause

REM ----- Directory Cleanup -----
if "%CLEAR_ALL%"=="true" (
    echo Clearing build and install directories...
    rmdir /s /q build
    rmdir /s /q install
) else if "%CLEAR%"=="true" (
    echo Clearing build directory...
    rmdir /s /q build
)

if not exist build mkdir build
if not exist install mkdir install

REM ----- Install Dependencies via winget -----
echo Installing dependencies via winget...
winget install -e --id Kitware.CMake
winget install -e --id Ninja-build.Ninja
winget install -e --id JRSoftware.InnoSetup

REM ----- Update Git Submodules -----
echo Updating git submodules...
git submodule update --init --recursive

REM ----- Setup Python Virtual Environment -----
echo Setting up Python virtual environment...
python -m venv venv
call venv\Scripts\activate.bat
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

REM ----- Initialize MSVC Environment -----
echo Initializing MSVC environment...
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64

REM ----- Download and Extract gettext Binary -----
set "FILENAME=gettext0.21-iconv1.16-shared-64.zip"
echo Downloading %FILENAME%...
curl -Lo build\%FILENAME% "https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.21-v1.16/%FILENAME%"
echo Extracting %FILENAME% to %CMAKE_PREFIX_PATH%...
powershell -Command "Expand-Archive -Force 'build\\%FILENAME%' '%CMAKE_PREFIX_PATH%'"

REM ----- VCPKG Setup and Package Installation -----
echo Bootstrapping VCPKG...
if exist "3rdparty\vcpkg\bootstrap-vcpkg.bat" (
    call 3rdparty\vcpkg\bootstrap-vcpkg.bat -disableMetrics
) else (
    echo VCPKG bootstrap script not found!
    goto :eof
)
set "VCPKG=3rdparty\vcpkg\vcpkg.exe"

echo Installing VCPKG packages...
%VCPKG% install --x-install-root "%CMAKE_PREFIX_PATH%" gettext gettext-libintl

echo Copying VCPKG packages...
for /d %%P in (3rdparty\vcpkg\packages\*) do (
    echo Processing package: %%P
    xcopy /E /I /Y "%%P\*" "%CMAKE_PREFIX_PATH%"
    xcopy /E /I /Y "%%P\*" "install"
)

REM ----- Build KDE Frameworks Dependencies -----
echo Building KDE Frameworks dependencies...
REM Define tier lists (example: tier 0 and tier 1)
set "TIER0=3rdparty\extra-cmake-modules"
set "TIER1=3rdparty\kcoreaddons 3rdparty\kirigami"
for %%D in (%TIER0% %TIER1%) do (
    echo ~~~ Building dependency: %%D ~~~
    if "%CLEAR_ALL%"=="true" (
        rmdir /s /q "%%D\build"
    )
    %CMAKE% -DCMAKE_CONFIGURATION_TYPES=%CMAKE_CONFIGURATION_TYPES% -DBUILD_TESTING=OFF -DBUILD_QCH=OFF -DCMAKE_PREFIX_PATH="%CMAKE_PREFIX_PATH%" -DCMAKE_INSTALL_PREFIX="%CMAKE_INSTALL_PREFIX%" -B "%%D\build" "%%D"
    %CMAKE% --build "%%D\build" --config %CMAKE_BUILD_TYPE%
    set "DESTDIR=%AppDir%"
    %CMAKE% --install "%%D\build"
    xcopy /E /I /Y "%AppDirUsr%\*" "%CMAKE_PREFIX_PATH%"
)

REM ----- Build QHotkey -----
echo Building QHotkey...
if "%CLEAR_ALL%"=="true" (
    rmdir /s /q "3rdparty\QHotkey\build"
)
%CMAKE% -DCMAKE_CONFIGURATION_TYPES=%CMAKE_CONFIGURATION_TYPES% -DBUILD_SHARED_LIBS=ON -DCMAKE_PREFIX_PATH="%CMAKE_PREFIX_PATH%" -DCMAKE_INSTALL_PREFIX="%CMAKE_INSTALL_PREFIX%" -DQT_DEFAULT_MAJOR_VERSION=6 -B "3rdparty\QHotkey\build" "3rdparty\QHotkey"
%CMAKE% --build "3rdparty\QHotkey\build" --config %CMAKE_BUILD_TYPE%
set "DESTDIR=%AppDir%"
%CMAKE% --install "3rdparty\QHotkey\build"
xcopy /E /I /Y "%AppDirUsr%\*" "%CMAKE_PREFIX_PATH%"

REM ----- Build QPrompt -----
echo Building QPrompt...
%CMAKE% -DCMAKE_CONFIGURATION_TYPES=%CMAKE_CONFIGURATION_TYPES% -DCMAKE_PREFIX_PATH="%CMAKE_PREFIX_PATH%" -DCMAKE_INSTALL_PREFIX="%CMAKE_INSTALL_PREFIX%" -B build .
%CMAKE% --build build --config %CMAKE_BUILD_TYPE%
set "DESTDIR=%AppDir%"
%CMAKE% --install build

REM ----- Deploy Qt Libraries and Package Build -----
echo Deploying Qt libraries...
set "NSIS_PATH=C:\Program Files (x86)\NSIS"
set PATH=%PATH%;%NSIS_PATH%
"%CMAKE_PREFIX_PATH%\bin\windeployqt.exe" "install\bin\%CMAKE_BUILD_TYPE%\QPrompt.exe"

echo Creating package with cpack...
pushd build
%CPACK%
popd

echo.
echo Setup completed.
pause
endlocal
@echo off
setlocal enabledelayedexpansion

:: Detect architecture
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
    set ARCH=x64
) else (
    set ARCH=x86
)

:: Check for required tools
where cmake >nul 2>&1 || (
    echo CMake not found. Please install CMake.
    exit /b 1
)
where git >nul 2>&1 || (
    echo Git not found. Please install Git.
    exit /b 1
)

:: Initialize and update submodules
git submodule update --init --recursive

:: Setup VCPKG
if not exist "3rdparty\vcpkg\vcpkg.exe" (
    pushd 3rdparty\vcpkg
    call bootstrap-vcpkg.bat
    popd
)

:: Install dependencies via VCPKG
3rdparty\vcpkg\vcpkg.exe install qt5-base:!ARCH!-windows^
    qt5-declarative:!ARCH!-windows^
    qt5-quickcontrols2:!ARCH!-windows^
    qt5-svg:!ARCH!-windows^
    qt5-tools:!ARCH!-windows^
    qt5-translations:!ARCH!-windows^
    qt5-winextras:!ARCH!-windows

:: Build KDE Framework dependencies
mkdir build-kde 2>nul
pushd build-kde
cmake -G "Visual Studio 17 2022" -A !ARCH! ^
    -DCMAKE_TOOLCHAIN_FILE=..\3rdparty\vcpkg\scripts\buildsystems\vcpkg.cmake ^
    -DCMAKE_BUILD_TYPE=Release ^
    ..\3rdparty\extra-cmake-modules
cmake --build . --config Release
cmake --install . --config Release

cmake -G "Visual Studio 17 2022" -A !ARCH! ^
    -DCMAKE_TOOLCHAIN_FILE=..\3rdparty\vcpkg\scripts\buildsystems\vcpkg.cmake ^
    -DCMAKE_BUILD_TYPE=Release ^
    ..\3rdparty\kcoreaddons
cmake --build . --config Release
cmake --install . --config Release

cmake -G "Visual Studio 17 2022" -A !ARCH! ^
    -DCMAKE_TOOLCHAIN_FILE=..\3rdparty\vcpkg\scripts\buildsystems\vcpkg.cmake ^
    -DCMAKE_BUILD_TYPE=Release ^
    ..\3rdparty\kirigami
cmake --build . --config Release
cmake --install . --config Release
popd

:: Build QHotkey
mkdir build-qhotkey 2>nul
pushd build-qhotkey
cmake -G "Visual Studio 17 2022" -A !ARCH! ^
    -DCMAKE_TOOLCHAIN_FILE=..\3rdparty\vcpkg\scripts\buildsystems\vcpkg.cmake ^
    -DCMAKE_BUILD_TYPE=Release ^
    ..\3rdparty\QHotkey
cmake --build . --config Release
cmake --install . --config Release
popd

:: Build QPrompt
mkdir build 2>nul
pushd build
cmake -G "Visual Studio 17 2022" -A !ARCH! ^
    -DCMAKE_TOOLCHAIN_FILE=..\3rdparty\vcpkg\scripts\buildsystems\vcpkg.cmake ^
    -DCMAKE_BUILD_TYPE=Release ^
    ..
cmake --build . --config Release
popd

echo Build completed successfully
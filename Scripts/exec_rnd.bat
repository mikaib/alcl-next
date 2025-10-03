@echo off

rem haxe Build.hxml && hl ./Build/out.hl && cmake ./out -B ./out/build -Wno-dev >nul && cmake --build ./out/build --config Debug -- /verbosity:quiet /nologo && powershell -Command "Write-Host 'Build complete' -ForegroundColor Green" && start /wait /b ./out/build/Debug/alcl.exe
haxe Build.hxml && hl ./Build/out.hl && cmake ./out -B ./out/build -Wno-dev >nul && cmake --build ./out/build --config Debug -- /verbosity:quiet /nologo && start /wait /b ./out/build/Debug/alcl.exe
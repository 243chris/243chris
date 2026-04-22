@echo off
cd /d "%~dp0"
C:\src\flutter-sdk\bin\flutter.bat build apk --debug
pause
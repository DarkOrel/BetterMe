@echo off
REM Flutter run script with system message filtering
REM Filters out Samsung and Google system message spam
REM All Flutter errors and exceptions remain visible

echo Starting Flutter with clean logs (filtering system messages)...
echo.

REM Redirect stderr to stdout, then filter out spam messages
flutter run 2>&1 | findstr /V "MSHandlerLifeCycle" | findstr /V "isMultiSplitHandlerRequested" | findstr /V "GoogleApiManager" | findstr /V "FlagRegistrar" | findstr /V "ProviderInstaller" | findstr /V "Phenotype.API"


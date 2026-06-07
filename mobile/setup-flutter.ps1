# Add Flutter to PATH for this session and run mobile setup.
$flutterBin = "C:\src\flutter\bin"
if (-not (Test-Path "$flutterBin\flutter.bat")) {
    Write-Error "Flutter not found at C:\src\flutter. Extract flutter_windows_*-stable.zip to C:\src\flutter"
    exit 1
}

$env:Path = "$flutterBin;$env:Path"
Write-Host "Flutter: $(flutter --version 2>&1 | Select-Object -First 1)"

Set-Location $PSScriptRoot
flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

flutter analyze
Write-Host ""
Write-Host "To add Flutter permanently: System Properties > Environment Variables > Path > New > C:\src\flutter\bin"
Write-Host "Run app: flutter run -d chrome   (or connect Android device / emulator)"

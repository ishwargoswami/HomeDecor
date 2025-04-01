# PowerShell script to build APK and prepare for GitHub release

# Version information - update this before running
$versionName = "1.0.0"
$versionCode = "1"

Write-Host "Starting release build process for DecorHome v$versionName..." -ForegroundColor Green

# Clean the project
Write-Host "Cleaning project..." -ForegroundColor Cyan
flutter clean

# Update version in pubspec.yaml
Write-Host "Updating version in pubspec.yaml..." -ForegroundColor Cyan
$pubspecPath = "pubspec.yaml"
$pubspecContent = Get-Content $pubspecPath -Raw
$newContent = $pubspecContent -replace "version: .*", "version: $versionName+$versionCode"
Set-Content -Path $pubspecPath -Value $newContent

# Build the release APK
Write-Host "Building release APK with no tree shake icons..." -ForegroundColor Cyan
flutter build apk --release --no-tree-shake-icons

# Check if build was successful
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Create the release directory if it doesn't exist
$releaseDir = "release"
if (-not (Test-Path $releaseDir)) {
    New-Item -ItemType Directory -Path $releaseDir
}

# Copy and rename the APK
$apkSource = "build/app/outputs/flutter-apk/app-release.apk"
$apkDest = "$releaseDir/decor_home_v$versionName.apk"

if (Test-Path $apkSource) {
    Write-Host "Copying APK to release directory..." -ForegroundColor Cyan
    Copy-Item -Path $apkSource -Destination $apkDest -Force
    
    # Get file size for display
    $apkSize = (Get-Item $apkDest).Length / 1MB
    Write-Host "APK created successfully: $apkDest ($($apkSize.ToString('0.00')) MB)" -ForegroundColor Green
    
    # Generate release notes template
    $releaseNotesPath = "$releaseDir/release_notes_v$versionName.md"
    @"
# DecorHome v$versionName Release Notes

## What's New
- Feature 1
- Feature 2
- Feature 3

## Bug Fixes
- Fixed issue 1
- Fixed issue 2

## Download
Direct download: https://github.com/ishwargoswami/HomeDecor/releases/download/v$versionName/decor_home_v$versionName.apk
"@ | Set-Content -Path $releaseNotesPath
    
    Write-Host "Release notes template created at: $releaseNotesPath" -ForegroundColor Green
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Edit the release notes with your changes" -ForegroundColor Yellow
    Write-Host "2. Create a new GitHub release with tag 'v$versionName'" -ForegroundColor Yellow
    Write-Host "3. Upload '$apkDest' to the GitHub release" -ForegroundColor Yellow
    Write-Host "4. Update README.md with the new download link" -ForegroundColor Yellow
} else {
    Write-Host "APK file not found at expected location: $apkSource" -ForegroundColor Red
} 
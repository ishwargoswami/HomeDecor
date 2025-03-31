$pattern = "package:flutter_foodybite/"
$replacement = "package:decor_home/"

$files = Get-ChildItem -Path "lib" -Recurse -Include "*.dart"

foreach ($file in $files) {
    Write-Host "Processing $($file.FullName)"
    $content = Get-Content -Path $file.FullName -Raw
    if ($content -match $pattern) {
        $newContent = $content -replace $pattern, $replacement
        Set-Content -Path $file.FullName -Value $newContent
        Write-Host "Updated imports in $($file.FullName)"
    }
}

Write-Host "All imports have been updated!" 
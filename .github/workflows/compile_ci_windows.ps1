param(
    [string]$SourceModPath = "addons\sourcemod",
    [string]$OutputPath = "ci-build\plugins"
)

Write-Host "🔨 Starting SourcePawn compilation..."

# Создаем папку для вывода
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

# Находим все .sp файлы
$spFiles = Get-ChildItem -Path "$SourceModPath\scripting" -Filter "*.sp" -Recurse

if ($spFiles.Count -eq 0) {
    Write-Host "⚠️  No .sp files found!"
    exit 1
}

Write-Host "📄 Found $($spFiles.Count) .sp files"

# Компилируем каждый файл
foreach ($file in $spFiles) {
    $pluginName = $file.BaseName
    Write-Host "  🔨 Compiling $pluginName.sp..."
    
    & "$SourceModPath\scripting\spcomp.exe" $file.FullName -o"$OutputPath\$pluginName.smx"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    ✅ $pluginName.smx compiled successfully"
    } else {
        Write-Host "    ❌ Failed to compile $pluginName.sp"
        exit 1
    }
}

Write-Host "✅ Compilation complete!"
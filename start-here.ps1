# =================================================================
# MASTER SETUP SCRIPT
# =================================================================
# Setup script voor een schone machine
$username = "joostvanberkum" # <--- VUL HIER JE USERNAME IN (ZONDER @)
$branch   = "main"

# 1. PRE-FLIGHT CHECK: Gereedschap installeren
Write-Host "Stap 0: Installeren van basisgereedschap..." -ForegroundColor Cyan

# Installeer Terminal voor een betere interface
winget install --id Microsoft.WindowsTerminal -e --accept-source-agreements

# Installeer Git (essentieel voor verder gebruik)
winget install --id Git.Git -e --accept-source-agreements

Write-Host "Bezig met ophalen van configuratie voor $username..." -ForegroundColor Cyan

# 1. Taal en Regio
Write-Host "Stap 1: Taal en Regio instellen..." -ForegroundColor Cyan
$Languages = New-Object System.Collections.Generic.List[string]
$Languages.Add("en-US")
$Languages.Add("nl-NL")
Set-WinUserLanguageList -LanguageList $Languages -Force

# 2. Voorkeuren instellen (Dark mode, Taakbalk, Taal)
Write-Host "Stap 2: Systeemvoorkeuren toepassen..." -ForegroundColor Yellow
$prefScript = "https://raw.githubusercontent.com/$username/windows-config/$branch/scripts/set-preferences.ps1"
Invoke-RestMethod -Uri $prefScript | PowerShell -ExecutionPolicy Bypass

# 3. WinGet Recepten uitvoeren
Write-Host "Stap 2: Software installeren via WinGet..." -ForegroundColor Yellow
$recepten = @("business.dsc.yaml", "dev-tools.dsc.yaml", "personal.dsc.yaml")

foreach ($recept in $recepten) {
    $url = "https://raw.githubusercontent.com/$username/windows-config/$branch/recipes/$recept"
    Write-Host "Uitvoeren van recept: $recept" -ForegroundColor White
    winget configure -f $url --accept-configuration-agreements --accept-source-agreements
}

Write-Host "INSTALLATIE VOLTOOID!" -ForegroundColor Green
Write-Host "Systeem is ingericht! Start de machine opnieuw op voor de taalinstellingen." -ForegroundColor Green

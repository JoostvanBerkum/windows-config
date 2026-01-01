# =================================================================
# MASTER SETUP SCRIPT - Joost van Berkum (Versie 2.0)
# =================================================================
$username = "JoostvanBerkum"
$branch   = "main"

# Stap 0: Voorbereiding en Basisgereedschap
Write-Host "Stap 0: Voorbereiding en basisgereedschap..." -ForegroundColor Cyan

# Schakel de configuratie-modus in (lost de rode foutmelding op)
winget configure --enable

# Herstel winget bronnen (lost de MSStore certificaatfout op)
winget source reset --force

# Installeer tools met --silent en specifiek van de 'winget' bron
winget install --id Microsoft.WindowsTerminal -e --source winget --accept-package-agreements --accept-source-agreements --silent
winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements --silent

# Stap 1: Taal en Regio
Write-Host "Stap 1: Taal en Regio instellen..." -ForegroundColor Cyan
$Languages = New-Object System.Collections.Generic.List[string]
$Languages.Add("en-US")
$Languages.Add("nl-NL")
Set-WinUserLanguageList -LanguageList $Languages -Force

# Stap 2: Systeemvoorkeuren toepassen
Write-Host "Stap 2: Systeemvoorkeuren toepassen..." -ForegroundColor Yellow
# Let op: 'Scripts' met hoofdletter S (zoals in jouw mappenstructuur)
$prefScript = "https://raw.githubusercontent.com/$username/windows-config/$branch/Scripts/set-preferences.ps1"
Invoke-RestMethod -Uri $prefScript | PowerShell -ExecutionPolicy Bypass

# Stap 3: WinGet Recepten uitvoeren
Write-Host "Stap 3: Software installeren via WinGet Recepten..." -ForegroundColor Yellow
$recepten = @("business.dsc.yaml", "dev-tools.dsc.yaml", "personal.dsc.yaml")

foreach ($recept in $recepten) {
    # Let op: 'Recipes' met hoofdletter R
    $url = "https://raw.githubusercontent.com/$username/windows-config/$branch/Recipes/$recept"
    Write-Host "--- Uitvoeren van recept: $recept ---" -ForegroundColor White
    # Geen '--accept-source-agreements' meer hier (bestaat niet voor configure)
    winget configure -f $url --accept-configuration-agreements
}

Write-Host "INSTALLATIE VOLTOOID!" -ForegroundColor Green
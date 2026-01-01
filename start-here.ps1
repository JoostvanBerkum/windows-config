# =================================================================
# GEOPTIMALISEERD MASTER SETUP SCRIPT - Joost van Berkum
# =================================================================
$username = "JoostvanBerkum" # Let op hoofdletters
$branch   = "main"

# Stap 0: WinGet repareren en Basisgereedschap
Write-Host "Stap 0: WinGet bronnen herstellen en basisgereedschap installeren..." -ForegroundColor Cyan
# Forceer winget bronnen om de certificaatfout te omzeilen
winget source reset --force

# Installeer tools specifiek van de 'winget' bron om de MSStore-fout te negeren
winget install --id Microsoft.WindowsTerminal -e --source winget --accept-package-agreements --accept-source-agreements
winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements

# Stap 1: Taal en Regio
Write-Host "Stap 1: Taal en Regio instellen..." -ForegroundColor Cyan
$Languages = New-Object System.Collections.Generic.List[string]
$Languages.Add("en-US")
$Languages.Add("nl-NL")
Set-WinUserLanguageList -LanguageList $Languages -Force

# Stap 2: Systeemvoorkeuren
Write-Host "Stap 2: Systeemvoorkeuren toepassen..." -ForegroundColor Yellow
# We gebruiken de exacte hoofdletters van je mappen: Scripts
$prefScript = "https://raw.githubusercontent.com/$username/windows-config/$branch/Scripts/set-preferences.ps1"
Invoke-RestMethod -Uri $prefScript | PowerShell -ExecutionPolicy Bypass

# Stap 3: WinGet Recepten
Write-Host "Stap 3: Software installeren via WinGet Recepten..." -ForegroundColor Yellow
$recepten = @("business.dsc.yaml", "dev-tools.dsc.yaml", "personal.dsc.yaml")

foreach ($recept in $recepten) {
    # We gebruiken de exacte hoofdletters van je mappen: Recipes
    $url = "https://raw.githubusercontent.com/$username/windows-config/$branch/Recipes/$recept"
    Write-Host "--- Uitvoeren van recept: $recept ---" -ForegroundColor White
    # Verwijderde --accept-source-agreements (bestaat niet voor configure)
    winget configure -f $url --accept-configuration-agreements
}

Write-Host "INSTALLATIE VOLTOOID!" -ForegroundColor Green
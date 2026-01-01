# =================================================================
# MASTER SETUP SCRIPT - Joost van Berkum (Versie 2.2 - 2024-06-10)
# Dit script automatiseert de initiële setup van een Windows 10/11 systeem.
# Het voert de volgende stappen uit:
# 0. Voorbereiding en installatie van basisgereedschap (Windows Terminal, Git)
# 1. Instellen van taal en regio (Nederlands en Engels)
# 2. Toepassen van systeemvoorkeuren via een extern script
# 3. Installeren van software via WinGet recepten (business, dev-tools, personal
# Let op: Pas de variabelen $username en $branch aan indien nodig.
# Bronbestanden worden opgehaald van GitHub.
# Gebruik: Voer dit script uit in een PowerShell venster met Administrator rechten.
# Zorg ervoor dat de uitvoeringsbeleid is ingesteld op 'Bypass' of 'Unrestricted'.
# Voor vragen of aanpassingen, neem contact op met Joost van Berkum.
# Versiegeschiedenis:
# - 2.2 (2024-06-10): Toegevoegd --silent aan winget installaties in Stap 0.
# - 2.1 (2024-05-15): Toegevoegd pauze na winget configure om stabiliteit te verbeteren.
# - 2.0 (2024-04-01): Overgeschakeld naar winget configure voor recepteninstallatie.
# - 1.0 (2023-12-20): Eerste versie van het setup script.
# =================================================================
$username = "JoostvanBerkum"
$branch   = "main"

# Stap 0: Voorbereiding en Basisgereedschap
Write-Host "Stap 0: Voorbereiding en basisgereedschap..." -ForegroundColor Cyan

# Schakel de configuratie-modus in (lost de rode foutmelding op)
winget configure --enable

# Pauzeer kort om winget klaar te laten zijn
Start-Sleep -Seconds 5

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
    $antwoord = Read-Host "Wil je het recept '$recept' uitvoeren? (y/n)"
    
    if ($antwoord -eq 'y') {
        $url = "https://raw.githubusercontent.com/$username/windows-config/$branch/Recipes/$recept"
        Write-Host "Bezig met uitvoeren van $recept..." -ForegroundColor White
        # --verbose toegevoegd zodat je precies ziet wat er gebeurt
        winget configure -f $url --accept-configuration-agreements --accept-source-agreements  --disable-interactivity --verbose
    } else {
        Write-Host "Recept $recept overgeslagen." -ForegroundColor Gray
    }
}
# Alternatieve automatische uitvoering zonder prompts:
# foreach ($recept in $recepten) {
#     # Let op: 'Recipes' met hoofdletter R
#     $url = "https://raw.githubusercontent.com/$username/windows-config/$branch/Recipes/$recept"
#     Write-Host "--- Uitvoeren van recept: $recept ---" -ForegroundColor White
#     # Geen '--accept-source-agreements' meer hier (bestaat niet voor configure)
#     winget configure -f $url --accept-configuration-agreements --verbose
# }

Write-Host "INSTALLATIE VOLTOOID!" -ForegroundColor Green
Read-Host "Druk op Enter om dit venster te sluiten..."
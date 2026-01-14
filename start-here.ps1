# =================================================================
# MASTER SETUP SCRIPT - Joost van Berkum (Versie 2.6 2026-01-14)
# =================================================================
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
# - 2.6 2026-01-14): Toegevoegd functie voor aangepaste Office installatie (E3 Shared Licensing).
# - 2.5 2026-01-14): Toegevoegd AOfficeSuite recept optie in start-here.ps1.
# - 2.4 2026-01-01): Toegevoegd --verbose aan winget configure opdrachten voor betere logging.
# - 2.3 2026-01-01): Verwijderd onnodige --accept-source-agreements bij winget configure opdrachten.
# - 2.2 2026-01-01): Toegevoegd --silent aan winget installaties in Stap 0.
# - 2.1 2026-01-01) : Toegevoegd pauze na winget configure om stabiliteit te verbeteren.
# - 2.0 2026-01-01) : Overgeschakeld naar winget configure voor recepteninstallatie.
# - 1.0 2026-01-01) : Eerste versie van het setup script.
# =================================================================
# =================================================================
# CONFIGURATIE - Pas deze waarden aan naar wens
# =================================================================
$InstallDutch = $false     # $true om Nederlands als extra taal toe te voegen
$Business     = $false       # $true voor Business recept
$OfficeSuite  = $false      # $true voor Aangepaste Office (Word/Excel/PP)
$DevTools     = $false      # $true voor Dev-tools recept
$Personal     = $false      # $true voor Personal recept
$Spotify      = $false     # $true voor Spotify recept

$username = "JoostvanBerkum"
$branch   = "main"

Write-Host "Versie 2.6 van start-here.ps1 wordt gestart..." -ForegroundColor Cyan

# --- FUNCTIE VOOR OFFICE (ODT) ---
function Install-OfficeCustom {
    Write-Host "Bezig met aangepaste Office installatie (E3 Shared Licensing)..." -ForegroundColor Cyan
    $workDir = "C:\Temp\OfficeSetup"
    New-Item -ItemType Directory -Path $workDir -Force | Out-Null

    $odtUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_17328-20162.exe"
    $xmlUrl = "https://raw.githubusercontent.com/$username/windows-config/$branch/Settings/OfficeConfig.xml"

    Invoke-WebRequest -Uri $odtUrl -OutFile "$workDir\odt.exe"
    Invoke-WebRequest -Uri $xmlUrl -OutFile "$workDir\configuration.xml"

    Start-Process -FilePath "$workDir\odt.exe" -ArgumentList "/extract:$workDir /quiet" -Wait
    Start-Process -FilePath "$workDir\setup.exe" -ArgumentList "/configure $workDir\configuration.xml" -Wait
    Write-Host "Office installatie voltooid!" -ForegroundColor Green
}

# Stap 0: Voorbereiding en "Moeilijke" Apps
Write-Host "Stap 0: Voorbereiding en installatie van kritieke apps..." -ForegroundColor Cyan

Set-WinHomeLocation -GeoId 176  # Nederland
winget configure --enable
winget source reset --force

# Hier werkt --accept-source-agreements wél
$criticalApps = @("Microsoft.WindowsTerminal", "Git.Git")
foreach ($app in $criticalApps) {
    Write-Host "Bezig met $app..." -ForegroundColor White
    winget install --id $app -e --source winget --accept-package-agreements --accept-source-agreements --silent
}

# Chrome Enterprise (negeert de hash-fout van de consumentenversie)
winget install --id Google.Chrome.EXE -e --source winget --accept-package-agreements --accept-source-agreements --silent

# 3. Citrix installeren via de 'winget' bron (NIET de msstore bron)
# We gebruiken --source winget om de regio-vragen van de Store te omzeilen
Write-Host "Citrix Workspace installeren via winget-bron..." -ForegroundColor White
winget install --id Citrix.Workspace -e --source winget --accept-package-agreements --accept-source-agreements --silent

# Stap 1: Taal en Toetsenbord (Beide US-International)
Write-Host "Stap 1: Taal instellen met US-International toetsenbord..." -ForegroundColor Cyan
$LanguageList = New-WinUserLanguageList -Language "en-US"
$LanguageList[0].InputMethodTips.Clear()
$LanguageList[0].InputMethodTips.Add('0409:00020409') # en-US met US-Intl

if ($InstallDutch) {
    $LanguageList.Add("nl-NL")
    $LanguageList[1].InputMethodTips.Clear()
    $LanguageList[1].InputMethodTips.Add('0413:00020409') # nl-NL met US-Intl
}
Set-WinUserLanguageList -LanguageList $LanguageList -Force

# Stap 2: Systeemvoorkeuren
Write-Host "Stap 2: Systeemvoorkeuren toepassen..." -ForegroundColor Yellow
$prefScript = "https://raw.githubusercontent.com/$username/windows-config/$branch/Scripts/set-preferences.ps1"
Invoke-RestMethod -Uri $prefScript | PowerShell -ExecutionPolicy Bypass

# Stap 3: WinGet Recepten & Office
if ($OfficeSuite) { Install-OfficeCustom }

Write-Host "Stap 3: DSC Recepten uitvoeren..." -ForegroundColor Yellow
$receptenMap = @{
    "business.dsc.yaml"  = $Business
    "dev-tools.dsc.yaml" = $DevTools
    "personal.dsc.yaml"  = $Personal
    "spotify.dsc.yaml"   = $Spotify
}

foreach ($recept in $receptenMap.Keys) {
    if ($receptenMap[$recept]) {
        $url = "https://raw.githubusercontent.com/$username/windows-config/$branch/Recipes/$recept"
        Write-Host "Bezig met $recept..." -ForegroundColor White
        # GEEN --accept-source-agreements hier (veroorzaakt fout in image_25622b.png)
        winget configure -f $url --accept-configuration-agreements --verbose
    }
}

Write-Host "INSTALLATIE VOLTOOID!" -ForegroundColor Green
Read-Host "Druk op Enter om dit venster te sluiten..."

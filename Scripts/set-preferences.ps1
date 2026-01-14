# =================================================================
# CONFIGURATIE - Pas deze waarden aan naar wens
# =================================================================
$DarkMode      = $true      # $true voor Dark Mode, $false voor Light Mode
$TaskbarLeft   = $true      # $true voor links, $false voor het midden
$InstallDutch  = $true      # $true om NL taalpakket toe te voegen voor spelling
# =================================================================

Write-Host "--- Systeemvoorkeuren toepassen ---" -ForegroundColor Cyan

# 1. Dark Mode / Light Mode
Write-Host "Modus instellen (Dark/Light)..."
$themeValue = if ($DarkMode) { 0 } else { 1 }
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value $themeValue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value $themeValue

# 2. Taakbalk Positie
Write-Host "Taakbalk positie instellen..."
$taskbarValue = if ($TaskbarLeft) { 0 } else { 1 }
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value $taskbarValue

# 3. Taal en Spelling (Engels UI, NL spelling)
Write-Host "Taal en toetsenbord configureren..." -ForegroundColor Cyan

# 3.1 Start altijd met Engels (en-US) als basis
$LanguageList = New-WinUserLanguageList -Language "en-US"

# 3.2 Forceer US-International voor Engels (verwijdert de standaard US-indeling)
$LanguageList[0].InputMethodTips.Clear()
$LanguageList[0].InputMethodTips.Add('0409:00020409')

# 3.3 Alleen als $InstallDutch 'true' is, voegen we Nederlands toe
if ($InstallDutch) {
    Write-Host "Nederlands (nl-NL) toevoegen aan de lijst..." -ForegroundColor Cyan
    $LanguageList.Add("nl-NL")
    
    # Forceer ook hier US-International (0413 is de code voor Nederlands)
    $LanguageList[1].InputMethodTips.Clear()
    $LanguageList[1].InputMethodTips.Add('0413:00020409')
}

# 3.4. Pas de lijst geforceerd toe op de gebruiker
Set-WinUserLanguageList -LanguageList $LanguageList -Force

# 4. Verkenner: Bestandsextensies altijd weergeven (Essentieel voor power users)
Write-Host "Verkenner instellen: Toon extensies..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

Write-Host "Klaar! Sommige wijzigingen zijn pas zichtbaar na herstart van de Verkenner of Windows." -ForegroundColor Green
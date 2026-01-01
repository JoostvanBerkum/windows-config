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
if ($InstallDutch) {
    Write-Host "Taalinstellingen configureren (EN-US + NL-NL)..."
    $Languages = New-Object System.Collections.Generic.List[string]
    $Languages.Add("en-US")
    $Languages.Add("nl-NL")
    Set-WinUserLanguageList -LanguageList $Languages -Force
}

# 4. Verkenner: Bestandsextensies altijd weergeven (Essentieel voor power users)
Write-Host "Verkenner instellen: Toon extensies..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

Write-Host "Klaar! Sommige wijzigingen zijn pas zichtbaar na herstart van de Verkenner of Windows." -ForegroundColor Green
# This script creates multiple user accounts in Intune environment.
# It reads user details from a JSON file and creates accounts accordingly.

# Import the required module
param(
    $tenantDomain = "erabliereapi.onmicrosoft.com",
    $jsonFilePath = ".\EntrepriseDatabase\users.json",
    $needToInstallModule = $false
)

# ASCII art for Freddycoder Setup Demo Intune Environment
Write-Host "
 _____             _     _                     _             
|  ___| __ ___  __| | __| |_   _  ___ ___   __| | ___ _ __   
| |_ | '__/ _ \/ _` |/ _` | | | |/ __/ _ \ / _` |/ _ \ '__|  
|  _|| | |  __/ (_| | (_| | |_| | (_| (_) | (_| |  __/ |     
|_|  |_|  \___|\__,_|\__,_|\__, |\___\___/ \__,_|\___|_|     
 ____                      |___/_       _                    
|  _ \  ___ _ __ ___   ___   |_ _|_ __ | |_ _   _ _ __   ___ 
| | | |/ _ \ '_ ` _ \ / _ \   | || '_ \| __| | | | '_ \ / _ \
| |_| |  __/ | | | | | (_) |  | || | | | |_| |_| | | | |  __/
|____/ \___|_| |_|_|_|\___/  |___|_| |_|\__|\__,_|_| |_|\___|
| ____|_ ____   _(_)_ __ ___  _ __  _ __ ___   ___ _ __ | |_ 
|  _| | '_ \ \ / / | '__/ _ \| '_ \| '_ ` _ \ / _ \ '_ \| __|
| |___| | | \ V /| | | | (_) | | | | | | | | |  __/ | | | |_ 
|_____|_| |_|\_/ |_|_|  \___/|_| |_|_| |_| |_|\___|_| |_|\__|
"

if ($needToInstallModule -eq $true) {
    Write-Host "Installation du module Microsoft.Graph..."
    Install-Module Microsoft.Graph -Verbose
}
Write-Host "Importation du module Microsoft.Graph..."
Import-Module Microsoft.Graph.Authentication -Verbose
Import-Module Microsoft.Graph.Users -Verbose

Write-Host "Connexion à Microsoft Graph avec les autorisations nécessaires..."
Connect-MgGraph `
    -Scopes User.ReadWrite.All, Directory.ReadWrite.All, LicenseAssignment.ReadWrite.All `
    -NoWelcome `
    -Verbose

function New-Password {
    # Génère un mot de passe aléatoire conforme aux exigences de complexité
    $length = 12
    $complexity = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+[]{}|;:,.<>?'
    $password = -join ((1..$length) | ForEach-Object { $complexity[(Get-Random -Minimum 0 -Maximum $complexity.Length)] })
    return @{
        ForceChangePasswordNextSignIn = $true
        Password = $password
    }
}

# Paramètres – à adapter
$jsonData = Get-Content -Raw -Path $jsonFilePath | ConvertFrom-Json
foreach ($user in $jsonData) {
    $displayName = $user.displayName
    $firstName = $user.firstName
    $lastName = $user.lastName
    $userPrincipalName = $user.userPrincipalName
    $usageLocation = $user.usageLocation
    $licenseSkuPartNumber = $user.licenseSkuPartNumber
    $password = New-Password
    $passwordProfile = @{
        forceChangePasswordNextSignIn = $false
        password = $password.Password
    }
    $mailNickname = "$firstName$lastName".ToLower();

    Write-Host "Création de l'utilisateur : $displayName / $userPrincipalName"
    $newUser = New-MgUser `
        -DisplayName $displayName `
        -GivenName $firstName `
        -Surname $lastName `
        -MailNickname $mailNickname `
        -UserPrincipalName $userPrincipalName `
        -UsageLocation $usageLocation `
        -PasswordProfile $passwordProfile `
        -AccountEnabled `
        -Verbose

    Write-Host "Utilisateur créé : $($newUser.Id) / $userPrincipalName : Password temporaire : $($passwordProfile.Password)"

    # 2. Récupérer le SKU de licence disponible
    $sku = Get-MgSubscribedSku -All | Where-Object { $_.SkuPartNumber -eq $licenseSkuPartNumber }
    if (-not $sku) {
        Write-Error "SKU '$licenseSkuPartNumber' non trouvé dans le tenant."
        Write-Host "SKU disponibles :"
        Get-MgSubscribedSku -All | ForEach-Object { Write-Host " - $($_.SkuPartNumber)" }
        return
    }
    Write-Host "SKU trouvé : $($sku.SkuPartNumber) (ID : $($sku.SkuId))"

    # 3. Assigner la licence à l’utilisateur
    Set-MgUserLicense -UserId $newUser.Id `
        -AddLicenses @{ SkuId = $sku.SkuId } `
        -RemoveLicenses @()

    Write-Host "Licence assignée à l'utilisateur : $userPrincipalName"
}
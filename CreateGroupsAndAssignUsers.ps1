# This script creates multiple groups and assigns user accounts in Intune environment.
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
Import-Module Microsoft.Graph.Groups -Verbose

Write-Host "Connexion à Microsoft Graph avec les autorisations nécessaires..."
Connect-MgGraph `
    -Scopes User.ReadWrite.All, Directory.ReadWrite.All, LicenseAssignment.ReadWrite.All `
    -NoWelcome `
    -Verbose

# Paramètres – à adapter
$jsonData = Get-Content -Raw -Path $jsonFilePath | ConvertFrom-Json
foreach ($user in $jsonData) {
    $userPrincipalName = $user.userPrincipalName

    if ($null -ne $user.groups) {
        foreach ($groupName in $user.groups) {
            Write-Host "Vérification de l'existence du groupe : $groupName"
            $group = Get-MgGroup -Filter "displayName eq '$groupName'" -ErrorAction SilentlyContinue

            if ($null -eq $group) {
                Write-Host "Création du groupe : $groupName"
                $mailEnabled = $false
                $group = New-MgGroup `
                    -DisplayName $groupName `
                    -MailEnabled:$mailEnabled `
                    -MailNickname ($groupName -replace ' ', '') `
                    -SecurityEnabled:$true
                    
            } else {
                Write-Host "Le groupe '$groupName' existe déjà."
            }

            Write-Host "Ajout de l'utilisateur '$userPrincipalName' au groupe '$groupName'"
            $userObj = Get-MgUser -UserId $userPrincipalName
            $userId = $userObj.Id
            Write-Host "User ID: $($userId)"
            New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $userId
        }
    }
}
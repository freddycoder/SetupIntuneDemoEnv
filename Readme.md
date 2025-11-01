# Setup Intune Demo Environment

This repository contains scripts and instructions to set up a demo environment for Microsoft Intune. The environment includes sample devices, users, and policies to help you explore and demonstrate Intune capabilities.

## Prerequisites

- An active Microsoft 365 subscription with Intune enabled.
> You can get a free trial of intune on a new tenant. [Instruction](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/free-trial-sign-up)

### Setup MDM Autority

If you haven't already set Intune as your Mobile Device Management (MDM) authority, follow these steps:

To validate or set the MDM authority to Intune, follow these steps:
1. Sign in to the [Microsoft Intune admin center](https://intune.microsoft.com/).
2. Go to **Tenant administration**
3. In the details pane, check for MDM Authority status. If it is not set to Intune MDM Authority, follow the instructions below to set it.

#### For first-time setup

Look for an orange banner at the top of the screen that prompts you to set the MDM authority.
Click the banner to open the Mobile Device Management Authority settings page.
Choose Microsoft Intune MDM Authority from the available options and save. 

#### If the banner is not visible

Alternatively, go to this url directly: [Set MDM Authority](https://intune.microsoft.com/#view/Microsoft_Intune_Enrollment/ChooseMDMAuthorityBlade)
Select Microsoft Intune MDM Authority and save your changes.

#### About the Entra P2 trial licence

You can ignore this licence for the first two steps. The Entra P2 trial licence can be obtained at step 3 when you setup device enrollment.

## Setup users

You can create demo users using the provided PowerShell script `CreateUsers.ps1`. This script will create users in your Azure AD and assign them the necessary licenses.

### Running the CreateUsers.ps1 script

1. Open PowerShell with administrative privileges.
2. Navigate to the directory where the `CreateUsers.ps1` script is located.
3. Run the script using the following command:
```powershell
.\CreateUsers.ps1
```

4. Follow the prompts to authenticate and allow the script to create users in your Azure AD.
5. The script will create users and assign them the specified licenses.
6. Once the script completes, you will see a confirmation message for each user created.

### If the script doesn't work, you can proceed manually:

1. Create the users using the [Intune Documentation](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/quickstart-create-user).

## Setup Groups and assign users

You can create groups and assign users to them using the provided PowerShell script `CreateGroupsAndAssignUsers.ps1`. This script will create groups in your Azure AD and assign the specified users to them.

You can also proceed manually by following the [Intune Documentation](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/quickstart-create-group).

## Setup device enrollment

[Intune Documentation](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/quickstart-setup-auto-enrollment)

## Register windows devices

[Intune Documentation](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/quickstart-enroll-windows-device)
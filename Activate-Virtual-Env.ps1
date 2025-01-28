# ------------------------------------------------------------------------------
#
# Author: Mario Martínez Molina
# Date: 06/07/2024
#
# Description:
# This script activates a specified Python virtual environment located in the
# default virtual environment directory (~/.virtualenvs). It first checks if
# the requested virtual environment exists. If it does not, the script prints
# an error message and lists all available virtual environments. If the
# environment exists it activates the environment using the Activate.ps1 script
# located within the environment's Script directory.
#
# Usage:
# ActivateVirtualEnv.ps1 <VirtualEnvironmentName>
#
# ------------------------------------------------------------------------------

# Function to get all virtual environments in the ~/.virtualenvs directory
function Get-VirtualEnvs {
    return Get-ChildItem -Path "$HOME/.virtualenvs" -Directory | Select-Object -ExpandProperty Name
}

# Check if the script was called with at least one argument
if ($args.Count -eq 0) {
    Write-Host "Usage: ActivateVirtualEnv.ps1 <VirtualEnvironmentName>`n"

    # List available virtual environments
    Write-Host "Current virtual environments:"
    foreach ($env in Get-VirtualEnvs) {
        Write-Host "* $env"
    }

    exit
}

function Read-YesNoChoice {
    Param (
        [Parameter(Mandatory=$true)][String]$Title,
        [Parameter(Mandatory=$true)][String]$Message,
        [Parameter(Mandatory=$false)][Int]$DefaultOption = 0
    )

    $No = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'No'
    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Yes'
    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($No, $Yes)

    return $host.ui.PromptForChoice($Title, $Message, $Options, $DefaultOption)
}

# Extract the virtual environment name from the arguments
$envName = $args[0]

# Get all available virtual environments
$availableEnvs = Get-VirtualEnvs

# Check if the specified environment exists
if (-not $availableEnvs.Contains($envName)) {
    # Print error message
    Write-Host "Error: The virtual environment '$envName' does not exist."

    # List available virtual environments
    Write-Host "Current virtual environments:"
    foreach ($env in $availableEnvs) {
        Write-Host "* $env"
    }

    # Offer the user to create the virtual environment
    $createVEnv = Read-YesNoChoice -Title "Would you like to create the '$envName' virtual environment?" -Message "Yes or No?"

    if ($createVEnv) {
        & python -m venv "$HOME/.virtualenvs/$envName"
    }
    else {
        exit
    }
}

# Construct the path to the virtual environment
# Ensure the path is expanded to the actual path
$envPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("UserProfile"), ".virtualenvs", $envName)

# Activate the virtual environment
& "$envPath/Scripts/Activate.ps1"

#Requires -RunAsAdministrator
$ErrorActionPreference = 'SilentlyContinue'
<#	
	.NOTES
	===========================================================================
	 Created on:   	10/14/2019 17:39
	 Created by:   	evkapsal
	 Organization: 	Microsoft 
	 Filename:  AzurePalUpdate.ps1   	
	===========================================================================
	.DESCRIPTION
		This PowerShell Script Help you to update Partner Account Link to your customer Azure Subscription.
		If you are a Microsoft Parnter and you are working in your customer Azure Environment Please ensure that you have link 
		your Partner ID, in order for Microsoft to recognize your ACR.
		More details here: https://docs.microsoft.com/en-us/azure/billing/billing-partner-admin-link-started

	===========================================================================
	Disclaimer
	The sample scripts provided here are not supported under any Microsoft standard support program or service. 
	All scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, 
	any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the 
	sample scripts and documentation remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation, production, 
	or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, 
	business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or 
	documentation, even if Microsoft has been advised of the possibility of such damages.
#>


#Mandatory Variables Setup
function Install-AzureAZModule
{	
		try
		{
			Write-Host -ForegroundColor Yellow -BackgroundColor Black "Starting AZ module installation"
			Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
			Install-Module -Name Az -AllowClobber
		}
		catch
		{
			$ErrorMessage = $_.Exception.Message
			Write-Error "Somethink Wrong Happened with powershell AZ Module Installation.Details: $($ErrorMessage)"
			exit
		}
		finally
		{
			$versionaz = (Get-InstalledModule AZ -AllVersions | Select-Object Version)
			if ($versionaz)
			{
			Write-Host -ForegroundColor Green -BackgroundColor Black "Powershell AZ module Succesfully Installed"
			}
		}
}

function Get-CustomerSubscription
	{
		Param (
			[Parameter(Mandatory = $true, HelpMessage = "Input Customer Azure Tenant ID - Example:XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX")]
			[ValidateNotNullorEmpty()]
			[string]$TenantID
		)
		Write-Host "Your Customer Tenant ID: $($TenantID)"
	return $TenantID
	}

function Get-MPNID
	{
		Param (
			[Parameter(Mandatory = $true, HelpMessage = "Input Your (MPN) PartnerID Number - Example:12345")]
			[ValidateNotNullorEmpty()]
			[string]$MPNID
		)
	Write-Host " Your MPN ID $($MPNID)"
	return $MPNID
	}

function Get-PowerShellModules
{
	try
	{
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "Trying to find old PowerShell Azure Modules"
		$powershellversions = (Get-InstalledModule AzureRM -AllVersions -ErrorAction SilentlyContinue | Select-Object Version -ErrorAction SilentlyContinue)
		
		
	}
	finally
	{
		if ($powershellversions)
		{
			foreach ($version in $powershellversions)
			{
				if (($version.version.Major -eq "5") -or ($version.version.Major -eq "6"))
				{
					Write-Host -ForegroundColor Yellow -BackgroundColor Black "Found unsupported PowerShell Version: $($version.version.ToString())"
					Write-Host -ForegroundColor Yellow -BackgroundColor Black "New Powershell Azure Module is needed"
					$unsupportedversion = $true
				}
			}
		}
		else
		{
			$powershellazmodule = (Get-InstalledModule AZ -AllVersions -ErrorAction SilentlyContinue | Select-Object Version -ErrorAction SilentlyContinue)
			if ($powershellazmodule)
			{
				Write-Host -ForegroundColor Green -BackgroundColor Black "Powershell AZ Module is already Installed"
			}
			else
			{
				Install-AzureAZModule
			}
			
		}
	}
	while ($unsupportedversion)
	{
		$Message = "Press Continue to Uninstall old version and install new Powershell Azure Module"
		$Title = "Continue or Cancel"
		Add-Type -AssemblyName System.Windows.Forms | Out-Null
		$MsgBox = [System.Windows.Forms.MessageBox]
		$Decision = $MsgBox::Show($Message, $Title, "OkCancel", "Information")
		If ($Decision -eq "Cancel")
		{
			exit
		}
		else
		{
			Write-Host -ForegroundColor Yellow -BackgroundColor Black	"Starting Powershell Update Process"
			Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
			try
			{
				Write-Host -ForegroundColor Green -BackgroundColor Black	"Starting Powershell Uninstall Process"
				Uninstall-Module AzureRM -AllVersions -Force
			}
			catch
			{
				$ErrorMessage = $_.Exception.Message
				Write-Error "Somethink Wrong Happened with powershell AZ.Account Module.Details: $($ErrorMessage)"
				exit
			}
			finally
			{
				Install-AzureAZModule
			}
		}
		
	}
}

#Start PAL Registration Process
Write-Host -ForegroundColor Yellow  -BackgroundColor Black	"Starting PAL Registration Process"
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Enter Mandatory details below"
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Ensure that you have access to your customer subscription with your credentials before you start the PAL process"

$TenantID = Get-CustomerSubscription
$MPNID = Get-MPNID
Get-PowerShellModules

Try
	{
	$module = Get-InstalledModule Az.Accounts
	}
catch
	{
	$ErrorMessage = $_.Exception.Message
	Write-Error "Somethink Wrong Happened with powershell AZ.Account Module.Details: $($ErrorMessage)"
	exit
	}

Try
	{
	$module2 = Get-InstalledModule Az.ManagementPartner -ErrorAction SilentlyContinue
	if (!$module2)
		{
		Write-Host -ForegroundColor Red -BackgroundColor Black "We didn't found Az.ManagementPartner Module. Trying to Install..."
		Install-Module -Name Az.ManagementPartner
		$installed = Get-InstalledModule Az.ManagementPartner -ErrorAction SilentlyContinue
		if ($installed)
			{
				Write-Host -ForegroundColor Green -BackgroundColor Black "Saccusfully installed Az.ManagementPortal Module"
			}
		}
	}
catch
	{
		$ErrorMessage = $_.Exception.Message
		Write-Error "Somethink Wrong Happened with powershell AZ.Account Module.Details: $($ErrorMessage)"
		exit
	}


Write-Host -ForegroundColor Yellow -BackgroundColor Black "Connecting to Azure Subscription. Please enter your credentials to Connect"
Connect-AzAccount -TenantId $($TenantID)
Try
	{
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "Trying to Update Partner Account Link..."
	
		Update-AzManagementPartner -PartnerId $MPNID
	}
Catch
	{
		$ErrorMessage = $_.Exception.Message
		Write-Error "Somethink Wrong Happened with PAL Registration.Details: $($ErrorMessage)"
		exit
	}
Finally
	{
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "You have succesfully update your Partner Account Link"
	}


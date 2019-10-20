# AzurePalUpdate

This PowerShell script can help you to update Azure Partner Link to your customer Tenant. This will help your company to ensure that Microsoft recognize your customer ACR as your contribution.

## Getting Started

In order to run the script, open a PowerShell with administration privileges (**Run As Administrator**) and run the script following the guide within the script.

### Prerequisites

There are 2 parameters that you have to fulfill in order to create / update PAL.

First you need to have your Customer Tenant ID and access to this ID with your account.

```
Tenant ID : Example:XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
```

Second you need to have your Microsoft Partner ID

```
MPN ID: Example:12345
```

## Running the Script

Script is checking first your Azure PowerShell Modules.
Latest Az PowerShell Module is needed. For this there is a process inside the script to update your old AzureRM module to the latest.

More Details for the new AZ poweshell module:
[PowerShell AZ Module Details](https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-2.8.0) - PowerShell Module Used.
Also there is step by step guide on how your can update PAL from Azure Portal or Azure CLI here:
[Update Azure PAL Step by Step](https://docs.microsoft.com/en-us/azure/billing/billing-partner-admin-link-started)

### Example

Below there is an example on how the script is taking actions in order to update the PAL.

![](https://raw.githubusercontent.com/evkapsal/AzurePALUpdate/master/Pal.PNG)


## Authors

* **Evangelos Kapsalakis** - *Initial work* - [evkapsal](https://github.com/evkapsal)


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


# Net

Net is a PowerShell module for inspecting network configuration data from PowerShell.

## Prerequisites

- PowerShell with `Microsoft.PowerShell.PSResourceGet` available for `Install-PSResource`.
- The [PSModule framework](https://github.com/PSModule) is used for building, testing, and publishing the module.

## Installation

Install the module from the PowerShell Gallery:

```powershell
Install-PSResource -Name Net
Import-Module -Name Net
```

## Commands

- `Get-NetIPConfiguration` retrieves network interface IP configuration, including addresses, prefix lengths, gateways, and DNS servers.

## Usage

List IP configuration for all interfaces:

```powershell
Get-NetIPConfiguration
```

List active IPv4 configuration only:

```powershell
Get-NetIPConfiguration -InterfaceStatus Up -AddressFamily IPv4
```

The command is also available through the `IPConfig` alias:

```powershell
IPConfig -AddressFamily IPv6
```

## Documentation

Command documentation is published at [psmodule.io/Net](https://psmodule.io/Net/).

## Contributing

Issues and pull requests are welcome. Please use the repository issue tracker to report bugs, request features, or discuss improvements.

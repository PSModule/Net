function Get-NetIPConfiguration {
    <#
        .SYNOPSIS
        Retrieves IP configuration details for network interfaces on the system.

        .DESCRIPTION
        This function gathers IP configuration data, including IP addresses, subnet masks, gateway addresses,
        and DNS servers for all network interfaces. It supports optional filtering by interface operational status
        (Up or Down) and address family (IPv4 or IPv6). The output includes detailed per-address information in
        a structured object format for each network interface and IP address combination.

        .EXAMPLE
        Get-NetIPConfiguration

        Output:
        ```powershell
        InterfaceName : Ethernet
        Description   : Intel(R) Ethernet Connection
        Status        : Up
        AddressFamily : InterNetwork
        IPAddress     : 192.168.1.10
        PrefixLength  : 24
        SubnetMask    : 255.255.255.0
        Gateway       : 192.168.1.1
        DNSServers    : 8.8.8.8, 1.1.1.1
        ```

        Retrieves the IPv4 configuration for all network interfaces that are currently operational (Up).

        .OUTPUTS
        IPConfig

        .LINK
        https://psmodule.io/Net/Functions/Get-NetIPConfiguration
    #>

    [Alias('IPConfig')]
    [OutputType([IPConfig])]
    [CmdletBinding()]
    param(
        # Filters interfaces based on operational status ('Up' or 'Down')
        [Parameter()]
        [ValidateSet('Up', 'Down')]
        [string] $InterfaceStatus,

        # Filters IP addresses by address family ('IPv4' or 'IPv6')
        [Parameter()]
        [ValidateSet('IPv4', 'IPv6')]
        [string] $AddressFamily
    )

    # Map AddressFamily parameter to .NET enum
    $familyEnum = $null
    if ($AddressFamily) {
        $familyEnum = if ($AddressFamily -eq 'IPv4') {
            [System.Net.Sockets.AddressFamily]::InterNetwork
        } else {
            [System.Net.Sockets.AddressFamily]::InterNetworkV6
        }
    }

    $interfaces = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces()

    # Apply optional interface status filter using enum for robustness
    if ($InterfaceStatus) {
        $statusEnum = [System.Net.NetworkInformation.OperationalStatus]::$InterfaceStatus
        $interfaces = $interfaces | Where-Object { $_.OperationalStatus -eq $statusEnum }
    }

    foreach ($adapter in $interfaces) {
        $ipProps = $adapter.GetIPProperties()

        # Filter unicast addresses by address family if requested
        $unicast = $ipProps.UnicastAddresses
        if ($familyEnum) {
            $unicast = $unicast | Where-Object { $_.Address.AddressFamily -eq $familyEnum }
        }

        foreach ($addr in $unicast) {
            [IPConfig]::new($adapter, $addr, $ipProps)
        }
    }
}

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
        PSCustomObject. Returns a custom object containing details such as interface name, IP address,
        address family, subnet mask, and DNS/gateway configuration for each matching network adapter and address.

        PSCustomObject. Each object reflects a single unicast address instance associated with the matched adapter.

        .LINK
        https://psmodule.io/Net/Functions/Get-NetIPConfiguration
    #>

    [Alias('IPConfig')]
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
            $prefixLength = $addr.PrefixLength
            $mask = if ($addr.Address.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork) {
                Get-SubnetMaskFromPrefix $prefixLength
            } else {
                # IPv6 masks are represented by prefix length
                $null
            }

            [PSCustomObject]@{
                InterfaceName = $adapter.Name
                Description   = $adapter.Description
                Status        = $adapter.OperationalStatus
                AddressFamily = $addr.Address.AddressFamily.ToString()
                IPAddress     = $addr.Address.IPAddressToString
                PrefixLength  = $prefixLength
                SubnetMask    = $mask
                Gateway       = ($ipProps.GatewayAddresses |
                        ForEach-Object { $_.Address.IPAddressToString }) -join ', '
                DNSServers    = ($ipProps.DnsAddresses |
                        ForEach-Object { $_.IPAddressToString }) -join ', '
            }
        }
    }
}

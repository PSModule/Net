class IPConfig {
    # The interface name
    [string] $InterfaceName

    # The interface description
    [string] $Description

    # The interface status
    [System.Net.NetworkInformation.OperationalStatus] $Status

    # The address family
    [string] $AddressFamily

    # The IP address
    [string] $IPAddress

    # The prefix length
    [int] $PrefixLength

    # The subnet mask
    [string] $SubnetMask

    # The gateway
    [string] $Gateway

    # The DNS servers
    [string] $DNSServers

    IPConfig(
        [System.Net.NetworkInformation.NetworkInterface] $Interface,
        [System.Net.NetworkInformation.UnicastIPAddressInformation] $AddressInformation,
        [System.Net.NetworkInformation.IPInterfaceProperties] $InterfaceProperties
    ) {
        $this.InterfaceName = $Interface.Name
        $this.Description = $Interface.Description
        $this.Status = $Interface.OperationalStatus
        switch ($AddressInformation.Address.AddressFamily) {
            ([System.Net.Sockets.AddressFamily]::InterNetwork) { $this.AddressFamily = 'IPv4'; break }
            ([System.Net.Sockets.AddressFamily]::InterNetworkV6) { $this.AddressFamily = 'IPv6'; break }
            default { $this.AddressFamily = $AddressInformation.Address.AddressFamily.ToString() }
        }
        $this.IPAddress = $AddressInformation.Address.IPAddressToString
        $this.PrefixLength = $AddressInformation.PrefixLength

        if ($AddressInformation.Address.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork) {
            $this.SubnetMask = [IPConfig]::ConvertPrefixToMask($AddressInformation.PrefixLength)
        } else {
            # IPv6 masks are represented by prefix length
            $this.SubnetMask = $null
        }

        $this.Gateway = ($InterfaceProperties.GatewayAddresses | ForEach-Object { $_.Address.IPAddressToString }) -join ', '
        $this.DNSServers = ($InterfaceProperties.DnsAddresses | ForEach-Object { $_.IPAddressToString }) -join ', '
    }

    hidden static [string] ConvertPrefixToMask([int] $prefixLength) {
        if ($prefixLength -le 0) { return '0.0.0.0' }
        if ($prefixLength -ge 32) { return '255.255.255.255' }

        [int[]] $octets = 0, 0, 0, 0
        $bits = $prefixLength
        for ($i = 0; $i -lt 4; $i++) {
            $take = [Math]::Min(8, $bits)
            if ($take -le 0) {
                $octets[$i] = 0
            } else {
                $octets[$i] = 255 - ([math]::Pow(2, (8 - $take)) - 1)
            }
            $bits -= $take
        }
        return ($octets -join '.')
    }
}

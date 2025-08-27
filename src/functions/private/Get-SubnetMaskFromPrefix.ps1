function Get-SubnetMaskFromPrefix {
    <#
        .SYNOPSIS
        Converts a CIDR prefix length into a subnet mask in dotted decimal notation.

        .DESCRIPTION
        The Get-SubnetMaskFromPrefix function accepts an integer prefix (e.g., 24) and converts it into a corresponding
        subnet mask (e.g., 255.255.255.0). It supports prefix lengths from 0 through 32. If the input prefix is outside
        this valid range, the function returns `$null`. This is useful when translating CIDR-style network definitions
        into traditional subnet mask format.

        .EXAMPLE
        Get-SubnetMaskFromPrefix -prefix 24

        Output:
        ```powershell
        255.255.255.0
        ```

        Converts a /24 prefix to the subnet mask 255.255.255.0.

        .OUTPUTS
        System.String

        .NOTES
        The subnet mask string in dotted decimal format (e.g., 255.255.255.0).
        Returns `$null` if the prefix is not within the valid range (0–32).

        .LINK
        https://psmodule.io/Net/Functions/Get-SubnetMaskFromPrefix
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The CIDR prefix length (0–32) to convert into a subnet mask.
        [Parameter(Mandatory)]
        [int] $prefix
    )

    if ($prefix -lt 0 -or $prefix -gt 32) { return $null }

    $bytes = [byte[]](0..3 | ForEach-Object {
            # Calculate the number of subnet bits for this octet (max 8, min 0)
            $bits = [Math]::Max([Math]::Min($prefix - (8 * $_), 8), 0)
            if ($bits -le 0) {
                # If no bits are set for this octet, value is 0
                0
            } elseif ($bits -ge 8) {
                # If all bits are set for this octet, value is 255
                255
            } else {
                # For partial octets, shift 0xFF left by (8 - $bits) to set the correct number of bits,
                # then mask with 0xFF to ensure only 8 bits are used
                ((0xFF -shl (8 - $bits)) -band 0xFF)
            }
        })
    [System.Net.IPAddress]::new($bytes).ToString()
}

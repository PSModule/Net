#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.8.0'; GUID = 'a699dea5-2c73-4616-a270-1f7abb777e71' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax: known issue.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'Used to create a secure string for testing.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', '',
    Justification = 'Log outputs to GitHub Actions logs.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidLongLines', '',
    Justification = 'Long test descriptions and skip switches'
)]
[CmdletBinding()]
param()

Describe 'Net' {
    Context 'Get-NetIPConfiguration' {
        It 'returns expected results' {
            $results = Get-NetIPConfiguration
            LogGroup 'Results' {
                Write-Host "$($results | Out-String)"
            }
            $results | Should -BeOfType 'IPConfig'
        }

        It 'IPConfig alias works' {
            $results = IPConfig
            LogGroup 'Results' {
                Write-Host "$($results | Format-List | Out-String)"
            }
            $results | Should -BeOfType 'IPConfig'
        }
    }
}

#Requires -Modules Pester
<#
.SYNOPSIS
    Tests the WSMan Trust module
.EXAMPLE
    Invoke-Pester 
.NOTES
    This script originated from work found here:  https://github.com/kmarquette/PesterInAction
#>

# Maybe the top of the file should have a hashtable of commands and their parameters?

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$module = Split-Path -Leaf $here

Describe "Module: $module" -Tags Unit {
    
    # TODO This section should use Module in the same way as the others
    Context "Module Configuration" {
        
        It "Has a root module file ($module.psm1)" {        
            
            "$here\$module.psm1" | Should Exist
        }

        It "Is valid Powershell (Has no script errors)" {

            $contents = Get-Content -Path "$here\$module.psm1" -ErrorAction SilentlyContinue
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should Be 0
        }

        It "Has a manifest file ($module.psd1)" {
            
            "$here\$module.psd1" | Should Exist
        }

        It "Contains a root module path in the manifest (RootModule = '.\$module.psm1')" {
            
            "$here\$module.psd1" | Should Exist
            "$here\$module.psd1" | Should Contain "\.\\$module.psm1"
        }

        It "Is valid Powershell (Has no script errors)" {
            $contents = Get-Content -Path "$here\$module.psm1" -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should Be 0
        }
    }

    if (get-module $Module) {remove-module $Module}
    import-Module "$here\$module.psd1" -ErrorAction SilentlyContinue
    $Global:Module = Get-Module $module -ErrorAction SilentlyContinue    
    $Global:Functions = $Global:Module.ExportedCommands.Keys

    Context 'Module loads and Functions exist' {
        
        # THE NEXT LINE IS NOT GENERIC
        $ExportedCommands = 'Get-WSManTrust','New-WSManTrust','Remove-WSManTrust'
        
        It 'Module should load without error' {
            # THE NEXT LINE IS NOT GENERIC
            $Global:Module.Name | Should Be 'WSManTrust'
        }

        It 'Exported commands should include all functions' {
            $Global:Functions | Should Be $ExportedCommands
        }
    }

    Context 'Help provided for Functions' {
        
        Foreach ($Function in $Global:Functions) {

            $Help = Get-Help $Function

            It "$Function should have a non-default Synopsis section in help" {                
                $Help.Synopsis | Should Not Match "\r\n$Function*"
                }

            It "$Function should have help examples" {
                $Help.Examples.Example.Count | Should Not Be 0
                }

            # THE NEXT LINE IS NOT GENERIC
            If ($Function -eq 'Remove-WSManTrust') {
                $ParamNames = 'hostname','all'
                It "$Function should have correct parameter names" {
                    (Get-Command $Function).Parameters.Keys | Should Be $ParamNames
                }
            }
        }
    }

    Context 'Unit test each module (REQUIRES ADMIN)' {
        
        $Example = '10.0.0.1'
        $Start = (Get-Item -Path WSMan:\localhost\Client\TrustedHosts | % Value).split(',')
        Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $Example -Concatenate -Force
        $List = Get-WSManTrust

        It 'Should return a list that includes the example' {            
            $List.Contains($Example) | Should Be $true
        }
        
        Remove-WSManTrust $Example
        $Remove = Get-WSManTrust

        It 'List should not contain host after removing' {
            $Remove.Contains($Example) | Should Be $false
        }

        New-WSManTrust $Example
        $Add = Get-WSManTrust
        
        It 'Hosts list should contain example host' {            
            $Add.Contains($Example) | Should Be $true
        }

        Remove-WSManTrust -all
        $RemoveAll = Get-WSManTrust

        It 'List should be cleared' {
            $RemoveAll | Should Be ''
        }
    }
}

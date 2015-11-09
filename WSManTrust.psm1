<#
.SYNOPSIS
    Returns the list of hosts that are trusted for WSMan connections.
.EXAMPLE
    Get-WSManTrust

    Returns an array of hostnames.
#>
function Get-WSManTrust {
    (Get-Item -Path WSMan:\localhost\Client\TrustedHosts | % Value).split(',')
}

<#
.SYNOPSIS
    Adds a host to the trust list for WSMan
.EXAMPLE
    Net-WSManTrust 10.0.0.1

    Adds the IP address to the list of hosts trusted by WSMan.
.EXAMPLE
    Net-WSManTrust servername

    Adds the hostname to the list of hosts trusted by WSMan.
.EXAMPLE
    Net-WSManTrust 10.0.0.1,10.0.0.2

    Adds all names in the array to the list of hosts trusted by WSMan.
#>
function New-WSManTrust {
param(
[string]$hostname
)
    Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $hostname -Concatenate -Force
}

<#
.SYNOPSIS
    Removes hosts from the list of hosts trusted by WSMan
.EXAMPLE
    Remove-WSManTrust 10.0.0.1

    Removes the hostname from the list of trusted WSMan hosts.
.EXAMPLE
    Remove-WSManTrust 10.0.0.1,10.0.0.2

    Removes the hostnames from the list of trusted WSMan hosts.
.EXAMPLE
    Remove-WSManTrust -all

    Removes all hostnames from the list of trusted WSMan hosts.
#>
function Remove-WSManTrust {
param(
[string]$hostname,
[switch]$all
)
    if ($all) {
        Clear-Item -Path WSMan:\localhost\Client\TrustedHosts -Force
      }
    else {
        foreach ($n in Get-WSManTrust) {[string]$list += $n+','}
        $list = $list.replace($hostname+',',$null).replace($hostname,$null).trimend(',')
        if ($list.length -eq 0) {
            Clear-Item -Path WSMan:\localhost\Client\TrustedHosts -Force
        }
        else {
            Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $list -Force
        }
    }
}

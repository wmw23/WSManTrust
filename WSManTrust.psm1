function Get-WSManTrust {
    (Get-Item -Path WSMan:\localhost\Client\TrustedHosts | % Value).split(',')
}

function New-WSManTrust {
param(
[string]$hostname
)
    Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $hostname -Concatenate -Force
}

function Remove-WSManTrust {
param(
[string]$hostname,
[switch]$all
)
    if ($all) {
        Clear-Item -Path WSMan:\localhost\Client\TrustedHosts -Force
      }
    else {
        $list = Get-WSManTrust
        $list = $list.replace($hostname+',','').replace($hostname,'')
        Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $list -Force
    }
}

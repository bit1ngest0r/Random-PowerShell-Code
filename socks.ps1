function socks {

    [CmdletBinding(DefaultParameterSetName = 'On')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'On')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Username,

        [Parameter(Mandatory = $true, ParameterSetName = 'On')]
        [ValidateNotNullOrEmpty()]	
        [String]
        $ComputerName,

        [Parameter(ParameterSetName = 'On')]
        [ValidateNotNullOrEmpty()]	
        [String]
        $PrivateKeyFile,

        [Parameter(ParameterSetName = 'On', HelpMessage = 'Format should be Option=Value')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Options,

        [Parameter(ParameterSetName = 'On')]
        [ValidateRange(1,65535)]
        [Int]
        $SSHPort = 22,

        [Parameter(ParameterSetName = 'On')]
        [ValidateRange(1,65535)]
        [Int]
        $TunnelPort = 1337,

        [Parameter(ParameterSetName = 'Off')]
        [Switch]
        $Off,

        [Parameter(ParameterSetName = 'Status')]
        [Switch]
        $Status
    )
    if ($Off.IsPresent) {
        Set-Itemproperty -Path "HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyServer -Value ''
	    Set-Itemproperty -Path "HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 0
        Get-CimInstance -ClassName Win32_Process | 
            Where-Object {$_.Name -eq 'ssh.exe'} | 
            Where-Object {$_.CommandLine -like '*ssh*-f -C -q -N -D*'} | 
            ForEach-Object {Stop-Process -Id $_.ProcessId -Force}
    }
    elseif ($Status.IsPresent) {
        $checkProxyUp = Get-CimInstance -ClassName Win32_Process | Where-Object {$_.Name -eq 'ssh.exe'} | Where-Object {$_.CommandLine -like '*ssh*-f -C -q -N -D*'}
        if ($checkProxyUp) { return 'Up' }
        else { return 'Down' }
    }
    else {
        $checkProxyUp = Get-CimInstance -ClassName Win32_Process | Where-Object {$_.Name -eq 'ssh.exe'} | Where-Object {$_.CommandLine -like '*ssh*-f -C -q -N -D*'}
        if ($checkProxyUp ) {
            return
        }
        else {
            $argumentList = @("$Username@$ComputerName", "-p $SSHPort", '-f', '-C', '-q', '-N', "-D $TunnelPort")
            if ($PrivateKeyFile) { $argumentList += "-i $PrivateKeyFile" }
            if ($Options) { $argumentList += "-o $Options" }

            
            Set-Itemproperty -Path "HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyServer -Value "socks=localhost`:$TunnelPort"
            Set-Itemproperty -Path "HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 1
            Start-Process ssh -ArgumentList $argumentList -NoNewWindow -LoadUserProfile -Wait
        }
    }

}

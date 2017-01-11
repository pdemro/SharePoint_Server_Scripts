Add-PSSnapin microsoft.sharepoint.powershell

if($false) {
    $rootCert = (Get-SPCertificateAuthority).RootCertificate

    $rootCert.Export("Cert") | Set-Content c:\path\to\certificates\ConsumingFarmRoot.cer -Encoding byte
}


if($false) { 
    $stsCert = (Get-SPSecurityTokenServiceConfig).LocalLoginProvider.SigningCertificate

    $stsCert.Export("Cert") | Set-Content c:\path\to\certificates\ConsumingFarmSTS.cer -Encoding byte
}

if($false) {
    $trustCert = Get-PfxCertificate c:\path\to\certificates\PublishingFarmRoot.cer

    New-SPTrustedRootAuthority "<Unique name of authority>" -Certificate $trustCert
}

if($false) {
    Get-SPFarm | Select Id
}


if($false) {
    Receive-SPServiceApplicationConnectionInfo -FarmUrl "<uri from Get-SPTopologyServiceApplication on publishing farm >"


    New-SPProfileServiceApplicationProxy -Name "User Profile Service Remote" -Uri "<string from receive-spserviceapplicationconnectioninfo"
}
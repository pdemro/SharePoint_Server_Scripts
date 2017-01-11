Add-PSSnapin microsoft.sharepoint.powershell

if($false) {
    $rootCert = (Get-SPCertificateAuthority).RootCertificate

    $rootCert.Export("Cert") | Set-Content c:\path\to\certificates\PublishingFarmRoot.cer -Encoding byte
}


if($false) {
    $trustCert = Get-PfxCertificate c:\path\to\certificates\ConsumingFarmRoot.cer

    New-SPTrustedRootAuthority "<unique authority name>" -Certificate $trustCert
}

if($false) {
    $stsCert = Get-PfxCertificate c:\path\to\certificates\ConsumingFarmSTS.cer
    New-SPTrustedServiceTokenIssuer "<unique token issuer name>" -Certificate $stsCert
}

if($false) {
    Publish-SPServiceApplication -Identity <SA GUID>
}

#To set permission to the Application Discovery and Load Balancing Service Application for a consuming farm by using Windows PowerShell
#This part is much simpler by using the UI.  These specific instructions don't apply to the UPS (see comment below)
if($false) {
    #Get-SPFarm | Select Id

    $security=Get-SPTopologyServiceApplication | Get-SPServiceApplicationSecurity

    $claimprovider=(Get-SPClaimProvider System).ClaimProvider

    $principal=New-SPClaimsPrincipal -ClaimType "http://schemas.microsoft.com/sharepoint/2009/08/claims/farmid" -ClaimProvider $claimprovider -ClaimValue <consumer farm id>

    Grant-SPObjectSecurity -Identity $security -Principal $principal -Rights "Full Control"

    Get-SPTopologyServiceApplication | Set-SPServiceApplicationSecurity -ObjectSecurity $security
}

#To enable access to the User Profile service application, you must give the consuming farm's web application pool identity (that is, DOMAIN\Username) the permission instead of the consuming farm ID.

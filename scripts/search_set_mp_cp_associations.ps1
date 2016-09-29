
$ssa = get-spenterprisesearchserviceapplication -identity "SSA Name"
$proposal_sections_filter = "PL"
$past_performance_filter = "PLPP"

#$proposal_sections_filter = "PLRole"

$proposal_sections_regex = "some_prefix_(.*)"
$past_performance_regex = "some_prefix_(.*)"


function AddCrawledPropertyToManagedProperty {
    Param(
            [Microsoft.Office.Server.Search.Administration.ManagedProperty] $mp,
            [string] $cpName
    );

    if((Get-SPEnterpriseSearchMetadataCrawledProperty -SearchApplication $ssa -Name $cpName -EA SilentlyContinue) -ne $null){
        $cp = Get-SPEnterpriseSearchMetadataCrawledProperty -SearchApplication $ssa -Name $cpName

        try {
            New-SPEnterpriseSearchMetadataMapping -SearchApplication $ssa -ManagedProperty $mp -CrawledProperty $cp[0] -EA Stop
            #ac $importlog "$(Get-Date),$($mp.Name),[INF],Metadata Mapping,$term"

            #if($cp -is [system.array]){
            #    ac $importlog "$(Get-Date),$($mp.Name),[WRN],Metadata Mapping,$term,More than one crawled property selected only the first has been used" 
            #}
        } catch {
            Write-Host "Something went wrong :) $($Error[0].Exception.Message)" -ForegroundColor Red
            #ac $importlog "$(Get-Date),$($mp.Name),[ERR],Metadata Mapping,$term"
            #ac $importlogerr "$(Get-Date),$($mp.Name),[ERR],Metadata Mapping,$($Error[0].Exception.Message)"
        }
        
    }
    else {
        write-host "Could not find crawled property to add:" $cp
    }

}


function RemoveCpManagedPropertyMapping {
    Param(
            [Microsoft.Office.Server.Search.Administration.ManagedProperty] $mp,
            [string] $cpName
    );

    if((Get-SPEnterpriseSearchMetadataCrawledProperty -SearchApplication $ssa -Name $cpName -EA SilentlyContinue) -ne $null){
        
        try{
            $cp = Get-SPEnterpriseSearchMetadataCrawledProperty -SearchApplication $ssa -Name $cpName

            $map = Get-SPEnterpriseSearchMetadataMapping -SearchApplication $ssa -ManagedProperty $mp -CrawledProperty $cp

            Remove-SPEnterpriseSearchMetadataMapping -Identity $map -confirm:$false
        }
        catch { 
            Write-Host "Something went wrong :) $($Error[0].Exception.Message)" -ForegroundColor Red
            #ac $importlog "$(Get-Date),$($mp.Name),[ERR],Metadata Mapping,$term"
            #ac $importlogerr "$(Get-Date),$($mp.Name),[ERR],Metadata Mapping,$($Error[0].Exception.Message)"
        }
    }
    else {
        write-host "Could not find crawled property to remove:" $cp
    }

}


Get-SPEnterpriseSearchMetadataManagedProperty -SearchApplication $ssa -Limit All `
    | ?{$_.Name -like "$($proposal_sections_filter)*"} `
    | %{


    $mp = $_;

    write-host $mp.Name -ForegroundColor Gray

    if($mp.Queryable -eq $false){
        write-host "setting querable to true" -ForegroundColor Green

        $mp.Queryable = $true
        $mp.Update();

        #exit
    }
}

if($false) {


Get-SPEnterpriseSearchMetadataManagedProperty -SearchApplication $ssa -Limit All `
    | ?{$_.Name -like "$($past_performance_filter)*"} `
    | %{
    
    $mp = $_;
    $mpmap = @();
    $legacyCps = @();

    write-host $mp.Name;

    Get-SPEnterpriseSearchMetadataMapping -SearchApplication $ssa -ManagedProperty $mp.Name | %{
        $mpmap += $_.CrawledPropertyName
        
        write-host $_.CrawledPropertyName -ForegroundColor Gray

        $match = $_.CrawledPropertyName -match $past_performance_regex
        if($match) {
            $legacyCps += $_.CrawledPropertyName
        }
    }
    #if($false){
    foreach($cp in $legacyCps) {
        $match = $cp -match $past_performance_regex;
        $suffix = $Matches[1];
        $plCpName = "some_old_prefix" + $suffix

        $ppCpName = "some_new_prefix"+ $suffix
        
        if($mpmap.IndexOf($ppCpName) -ge 0) {
            write-host $ppCpName "crawled Property has already been added!"
        }
        else {
            write-host "Adding Crawled Property:" $ppCpName -ForegroundColor Green
            AddCrawledPropertyToManagedProperty $mp $ppCpName
            #exit
        }

        if($mpmap.IndexOf($plCpName) -ge 0) {
            write-host "Found a bad crawled property.  Deleting" $plCpName -ForegroundColor Red
            RemoveCpManagedPropertyMapping $mp $plCpName
            #exit
        }
    }
    #}
}

}
. "D:\wsb\SharePoint_Server_Scripts\scripts\deploy_wsp\deployHelper.ps1"

#TODO - make this pull the latest modified folder and build the object

function getLatestFolder {
    Param(
        [string]$folder
    )

    return Get-ChildItem $folder | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime -desc | Select-Object -f 1
}

function getWsps {
    Param(
        [string]$folder
    )

    #todo filter on .wsp
    return Get-ChildItem $folder
}


function createDeploymentArray{
    Param(
        [object[]]$files
    )

    # [WspDeploymentObject[]] $WspDeploymentObject = @(
    #     (new-object WspDeploymentObject("", "")),
    #     (new-object WspDeploymentObject("", ""))
    # )
    
    $WspDeploymentObject = @()

    foreach($file in $files) {
        $WspDeploymentObject+=((New-Object WspDeploymentObject($file.Name,$file.FullName)))
    }


    return $WspDeploymentObject
}

$folder = getLatestFolder -folder "D:\wsb\deployment"

$wsps = getWsps -folder $folder.FullName

$array = createDeploymentArray -files $wsps


deployWsp -deploymentArray $array
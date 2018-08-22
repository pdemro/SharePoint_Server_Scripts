. ".\deploy_wsp.ps1"

[WspDeploymentObject[]] $WspDeploymentObject = @(
    (new-object WspDeploymentObject("", "")),
    (new-object WspDeploymentObject("", ""))
)


deployWsp -deploymentArray $WspDeploymentObject
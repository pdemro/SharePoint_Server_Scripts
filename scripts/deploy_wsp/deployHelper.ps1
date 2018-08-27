add-pssnapin microsoft.sharepoint.powershell

try {   # Wrap in a try-catch in case we try to add this type twice.
    # Create a class to hold an IIS Application Service's Information.
    Add-Type -TypeDefinition @"
        using System; 
         
        public class WspDeploymentObject
        {
            // The name of the Website in IIS.
            public string Identity { get; set;}
             
            // The path to the Application, relative to the Website root.
            public string LiteralPath { get; set; }

            public WspDeploymentObject(string identity, string literalPath) {
                this.Identity = identity;
                this.LiteralPath = literalPath;
            }
        }
"@
} catch {}

# deployWsp -deploymentArray -identity -literalpath 
function deployWsp {
    Param(
        [WspDeploymentObject[]]$deploymentArray,
        [string]$identity,
        [string]$literalPath
    )
    

    #TODO Pull this method out to a common library
    function reinstallSolution {
        Param(
            [string]$identity,
            [string]$literalPath
        )
        $solutionName = $identity

        $solutionFullName = $literalpath #$directory + $solutionName
        $farm = get-spfarm
        $solution = $farm.Solutions | where-object {$_.Name -eq $solutionName}

        uninstall-spsolution -identity $solutionName -Confirm:$false

        while ($solution.Deployed -eq $true) {
            write-host "waiting to uninstall.."
            start-sleep -seconds 5
        }

        while ($solution.JobExists -eq $true) {
            write-host "waiting for the solution to actually be retracted"
            start-sleep -seconds 5
        }

        remove-spsolution -identity $solutionName -Confirm:$false

        #write-host "wait"
        #start-sleep -seconds 2000

        add-spsolution -literalpath $solutionFullName

        write-host "Added solution.. giving it a few seconds"
        start-sleep -seconds 10

        install-spsolution -identity $solutionName -gacdeployment -Force

        $farm = get-spfarm
        $customKeywordSearchSol = $farm.Solutions | where-object {$_.Name -eq $solutionName}

        start-sleep -seconds 10

        #TODO if this iterates more than 10 times then re-attempt the install
        while ($customKeywordSearchSol.Deployed -eq $false) {
            write-host "waiting for the solution to be deployed"
            start-sleep -seconds 5
        }

        write-host "Solution deployment for" $solutionName "Complete"
    }

    if($deploymentArray) {
        foreach ($deploymentObject in $deploymentArray) {
            write-host "Deploying $($deploymentObject.Identity) from $($deploymentObject.LiteralPath)"
            reinstallSolution -identity $deploymentObject.Identity -literalPath $deploymentObject.LiteralPath
        }
    } else {
        write-host "Deploying $($Identity) from $($LiteralPath)"

        reinstallSolution -identity $identity -literalPath $literalPath
    }

    iisreset

    net stop SPTimerV4
    net start SPTimerV4
    
    # $warmupWebs = "http://win-bon5g1qr9mv:2016/", $siteUrl, "http://cv.sp16.com/sites/DemroXI"
    # C:\Users\pdemro\source\repos\SharePoint_Server_Scripts\scripts\reinstall_solution\dependencies\spbestwarmup.ps1 -url $warmupWebs
    D:\wsb\SharePoint_Server_Scripts\scripts\spbestwarmup\SPBestWarmUp.ps1
}


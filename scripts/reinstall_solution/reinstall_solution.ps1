add-pssnapin microsoft.sharepoint.powershell

$webUrl = "http://chnmicsp01/"
$caUrl = "https://caf06.mantech.com"
$solutionName = "customkeywordsearch.wsp"
$solutionDir = "c:\users\a-pdemro\documents\"
$solutionFullName = $solutionDir + $solutionName

$farm = get-spfarm
$solution = $farm.Solutions | where-object {$_.Name -eq $solutionName}

uninstall-spsolution -identity customkeywordsearch.wsp -webapplication $webUrl -Confirm:$false

while($solution.Deployed -eq $true){
    write-host "waiting to uninstall.."
    start-sleep -seconds 5
}

while($solution.JobExists -eq $true) {
    write-host "waiting for the solution to actually be retracted"
    start-sleep -seconds 5
}

#start-sleep -seconds 20

remove-spsolution -identity $solutionName -Confirm:$false

add-spsolution -literalpath $solutionFullName

write-host "Added solution.. giving it 10 seconds or so"
start-sleep -seconds 10

install-spsolution -identity $solutionName -gacdeployment -webapplication $webUrl

$farm = get-spfarm
$customKeywordSearchSol = $farm.Solutions | where-object {$_.Name -eq $solutionName}

while($customKeywordSearchSol.Status -ne "Online") {
    write-host "waiting for the solution to be deployed"
    start-sleep -seconds 5
}

.\dependencies\spbestwarmup.ps1 -url $webUrl,$caUrl
﻿add-pssnapin microsoft.sharepoint.powershell

function reinstallSolution {
    Param(
      [string]$codeDirectory,
      [string]$solutionTitle,
      [string]$directory,
      [array]$warmupWebs
    )
    $solutionName = $solutionTitle+".wsp"

    $solutionFullName = $directory+$solutionName
    $farm = get-spfarm
    $solution = $farm.Solutions | where-object {$_.Name -eq $solutionName}

    uninstall-spsolution -identity $solutionName -Confirm:$false

    while($solution.Deployed -eq $true){
        write-host "waiting to uninstall.."
        start-sleep -seconds 5
    }

    while($solution.JobExists -eq $true) {
        write-host "waiting for the solution to actually be retracted"
        start-sleep -seconds 5
    }

    remove-spsolution -identity $solutionName -Confirm:$false

    #write-host "wait"
    #start-sleep -seconds 2000

    add-spsolution -literalpath $solutionFullName

    write-host "Added solution.. giving it a few seconds"
    start-sleep -seconds 5

    install-spsolution -identity $solutionName -gacdeployment -Force

    $farm = get-spfarm
    $customKeywordSearchSol = $farm.Solutions | where-object {$_.Name -eq $solutionName}

    start-sleep -seconds 10

    while($customKeywordSearchSol.Deployed -eq $false) {
        write-host "waiting for the solution to be deployed"
        start-sleep -seconds 5
    }

    write-host "Solution deployment for" $solutionName "Complete"
}

#not used
function upgradeSolution {
    Param(
      [string]$codeDirectory,
      [string]$solutionTitle,
      [string]$directory,
      [array]$warmupWebs
    )
    $solutionName = $solutionTitle+".wsp"

    $solutionFullName = $directory+$solutionName
    
    update-spsolution -identity $solutionName -literalpath $solutionFullName -gacdeployment

    $farm = get-spfarm
    $solution = $farm.Solutions | where-object {$_.Name -eq $solutionName}

    write-host "Sent update command.. waiting a few seconds"
    start-sleep -seconds 15

    while($solution.Status -ne "Online" -or $customKeywordSearchSol.Deployed -eq $false) {
        write-host "waiting for the solution to be deployed"
        start-sleep -seconds 5
    }

    write-host "Solution update for" $solutionName "Complete"
}

#Make sure to build/save packages in visual studio prior to executing this script
#todo add this piece to a config file
msbuild /t:Package C:\wsb\cvng\Mantech-ConstantView-Upgrade\src\Mantech.ConstantView.SharePoint.Solution\Mantech.ConstantView.SharePoint.Solution.csproj
mv C:\wsb\cvng\Mantech-ConstantView-Upgrade\src\Mantech.ConstantView.SharePoint.Solution\bin\Debug\Mantech.ConstantView.SharePoint.wsp C:\wsb\cvng\Mantech-ConstantView-Upgrade\Mantech.ConstantView.SharePoint.wsp -Force

# msbuild /t:Package c:\path\to\project2\project2.csproj
# mv c:\path\to\project2\bin\Debug\project2.wsp c:\path\to\packages\project2.wsp -Force

#reinstallSolution -solutionTitle "Mantech.ConstantView.App" -directory "C:\Users\pdemro\Desktop\deployment\2018-08-15_11-03\" -warmupWebs $warmupWebs
reinstallSolution -solutionTitle "Mantech.ConstantView.SharePoint" -directory "C:\wsb\cvng\Mantech-ConstantView-Upgrade\" -warmupWebs $warmupWebs

#$siteUrl = "http://demro.sp16.com"

# Testing a site definition (delete and recreate every time)
# $site = get-spsite($siteUrl)
# $site.Delete()

#Can't remember why this was necessary - pretty sure permissions related
# $command = "add-pssnapin microsoft.sharepoint.powershell;new-spsite -name 'Test Collaboration Site' -url $siteUrl -OwnerAlias 'sp16\pdemro' -Language 1033 -Template 'MTCOLLAB#0'"
# powershell.exe -command $command
#new-spsite -url $siteUrl -OwnerAlias "sp16\pdemro" -Language 1033 -Template "MTCOLLAB#0"

iisreset

net stop SPTimerV4
net start SPTimerV4

# $warmupWebs = "http://win-bon5g1qr9mv:2016/", $siteUrl, "http://cv.sp16.com/sites/DemroXI"
# C:\Users\pdemro\source\repos\SharePoint_Server_Scripts\scripts\reinstall_solution\dependencies\spbestwarmup.ps1 -url $warmupWebs
spbestwarmup.ps1 #assumes spbestwarmup is in the path


#Enable-SPFeature -Identity "e44eda44-7398-4a51-b4fc-dab9f7b75c6b" -Url $siteUrl



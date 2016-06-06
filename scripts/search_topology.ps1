Search_Service_Application_AnalyticsReportingStoreDB_d46c19df5ff74c7e9659804930146481
Search_Service_Application_CrawlStoreDB_02a6188e16194544ad247f2e9a3b8565
Search_Service_Application_DB_4009bb890b344bb2a5f9cf2603adae30
Search_Service_Application_LinksStoreDB_a925752015124b7e8ac88232393dead2

$serverName = ""

$IndexLocation = "E:\Index4"
$hosta=get-spenterprisesearchserviceinstance -identity $serverName

#$ssa = Get-SPEnterpriseSearchServiceApplication
$newTopology = New-SPEnterpriseSearchTopology -SearchApplication $ssa

New-SPEnterpriseSearchAdminComponent -SearchTopology $newTopology -SearchServiceInstance $hostA
New-SPEnterpriseSearchCrawlComponent -SearchTopology $newTopology -SearchServiceInstance $hostA
New-SPEnterpriseSearchContentProcessingComponent -SearchTopology $newTopology -SearchServiceInstance $hostA
New-SPEnterpriseSearchAnalyticsProcessingComponent -SearchTopology $newTopology -SearchServiceInstance $hostA
New-SPEnterpriseSearchQueryProcessingComponent -SearchTopology $newTopology -SearchServiceInstance $hostA
New-SPEnterpriseSearchIndexComponent -SearchTopology $newTopology -SearchServiceInstance $hostA -IndexPartition 0 -RootDirectory $IndexLocation


Set-SPEnterpriseSearchTopology -Identity $newTopology


get-SPEnterpriseSearchServiceInstance -Identity $serverName
Do {write-host -NoNewline .;Sleep 10; $searchInstance = Get-SPEnterpriseSearchServiceInstance -Identity $serverName} while ($searchInstance.Status -ne "Online")
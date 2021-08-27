
$qualysCred = Get-Credential
$qualysServer = "qualysguard.qg3.apps.qualys.com"
$cookie = Connect-Qualys -qualysCred $qualysCred -qualysServer $qualysServer
$cookie

$reports=Get-QualysReportList -qualysServer $qualysServer -cookie $cookie

<#region Modification need to report list function need to convert to an object
foreach ($n in 0..($data.Length -1)){
$data.Get($n).TITLE.'#cdata-section' #title of report
$data.Get($n)}} #data of report

        ID                  : 4781104
        TITLE               : TITLE
        TYPE                : Scan
        USER_LOGIN          : drect3pm1
        LAUNCH_DATETIME     : 2021-08-20T08:38:07Z
        OUTPUT_FORMAT       : PDF
        SIZE                : 181.4 KB
        STATUS              : STATUS
        EXPIRATION_DATETIME : 2021-08-27T08:38:11Z


#Need to build object
}
#>#endregion

Get-QualysReport -cookie $cookie -qualysServer $qualysServer -id $reports[5].id -outFilePath c:\temp\


$scans=Get-QualysScanList -qualysServer $qualysServer -cookie $cookie

$scans[2].REF
Get-QualysScanResults -scanRef "scan/1628481977.84195" -brief -qualysServer $qualysServer -cookie $cookie

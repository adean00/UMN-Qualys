#region Connect-Qualys
function Connect-Qualys{
    <#
        .Synopsis
        Connect to Qualys API and get back session $cookie for all other functions

        .DESCRIPTION
            Connect to Qualys API and get back session $cookie for all other functions.

        .PARAMETER qualysCred
            use Get-Credential to create a PSCredential with the username and password of an account that has access to Qualys

        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.
        
        .PARAMETER assetTagging
            There are two different api endpoints, the new one is Asset Management and Tagging.  Use this switch to get a cookie to make calls to Asset Management and Tagging

        .EXAMPLE
            $cookie = Connect-Qualys -qualysCred $qualysCred -qualysServer $qualysServer
        
        .EXAMPLE
            $cookie = Connect-Qualys -qualysCred $qualysCred -qualysServer $qualysServer -assetTagging
            
        .Notes
            Author: Travis Sobeck, Kyle Weeks
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$qualysCred,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [switch]$assetTagging
        
    )

    Begin{}
    Process
    {
        $qualysuser = $qualysCred.UserName
        $qualysPswd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($qualysCred.Password))
   
        if ($assetTagging)
        {
            $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($qualysuser+':'+$qualysPswd))	
            $header += @{"Authorization" = "Basic $auth"}	    
            $response = Invoke-RestMethod -Uri "https://$qualysServer/qps/rest/portal/version" -Method GET -SessionVariable cookie -Headers $header
            return $cookie

        }
        else
        {
            ############# Log in ############# 
            ## URL for Logging In/OUT
        
            ## Login/out
            $logInBody = @{
                action = "login"
                username = $qualysuser
                password = $qualysPswd
            }

            ## Log in SessionVariable captures the cookie
            $uri = "https://$qualysServer/api/2.0/fo/session/"
            $response = Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"} -Uri $uri -Method Post -Body $logInBody -SessionVariable cookie
            return $cookie
        }
        
    }
    End{}
}
#endregion

#region Get-QualysReportList
function Get-QualysReportList{
    <#
        .Synopsis
            Get list of Qualys Reports

        .DESCRIPTION
            Get list of Qualys Reports
            
        .PARAMETER id
            (Optional) Qualys Report ID, use this to get details on a specific ID

        .PARAMETER qualysServer
                FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie

        .EXAMPLE
            

        .EXAMPLE
            
    #>

    [CmdletBinding()]
    Param
    (
        [string]$id,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ## Create URL, see API docs for path
        #########################     
        $actionBody = @{action = "list"}
        if($id){$actionBody['id'] = $id}
        [xml]$returnedXML = Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"} -Uri "https://$qualysServer/api/2.0/fo/report/" -Method Get -Body $actionBody -WebSession $cookie
        $data = $returnedXML.REPORT_LIST_OUTPUT.RESPONSE.REPORT_LIST.REPORT
        foreach ($item in $data) {
            $hash = @{            
                Title = $item.Title.'#cdata-section'
                ID = $item.Id
                Type = $item.type
                USER_LOGIN = $item.USER_LOGIN
                Launch_dateTime = $item.Launch_dateTime
                Output_format = $item.output_format
                Size = $item.Size
                Status = $item.STATUS.STATE
                Expiration_DateTime = $item.Expiration_DateTime
            }                           
                                            
        $Object = New-Object PSObject -Property $hash
        #Add a custom typename to the object
        $object.pstypenames.insert(0,'UMN-Qualys.ReportList')
        $Object
        }
    }
    End{}
}
#endregion

#region Get-QualysScanList
function Get-QualysScanList{
    <#
        .Synopsis
            Get list of Qualys Scans

        .DESCRIPTION
            Get list of Qualys Scans
            
        .PARAMETER scanRef
            (Optional) Qualys Scan Reference, use this to get details on a specific Scan

        .PARAMETER additionalOptions
            See documentation for full list of additional options and pass in as hashtable

            .PARAMETER qualysServer
        FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie

        .EXAMPLE
            

        .EXAMPLE
            
    #>

    [CmdletBinding()]
    Param
    (
        [string]$scanRef,

        [System.Collections.Hashtable]$additionalOptions,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ## Create URL, see API docs for path
        #########################
        $actionBody = @{action = "list"}
        if($scanRef){$actionBody['scan_ref'] = $scanRef}
        if($additionalOptions){$actionBody += $additionalOptions}
        [xml]$returnedXML = Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"} -Uri "https://$qualysServer/api/2.0/fo/scan/" -Method Get -Body $actionBody -WebSession $cookie
        $data = $returnedXML.SCAN_LIST_OUTPUT.RESPONSE.SCAN_LIST.SCAN

            foreach ($item in $data) {
                $hash = @{            
                    Title = $item.Title.'#cdata-section'
                    REF = $item.REF
                    Type = $item.type
                    USER_LOGIN = $item.USER_LOGIN
                    Launch_dateTime = $item.Launch_dateTime
                    PROCESSING_PRIORITY = $item.PROCESSING_PRIORITY
                    Status = $item.STATUS.STATE
                    DURATION = $item.DURATION
                    PROCESSED = $item.PROCESSED
                    TARGET = $item.TARGET.'#cdata-section'
                }                           
                                                
            $Object = New-Object PSObject -Property $hash
            #Add a custom typename to the object
            $object.pstypenames.insert(0,'UMN-Qualys.ReportList')
            $Object

        }
    }
    End{}
}
#endregion






#$qualysCred = Get-Credential
$qualysServer = "qualysguard.qg3.apps.qualys.com"
$cookie = Connect-Qualys -qualysCred $qualysCred -qualysServer $qualysServer
#$rlist=Get-QualysReportList -qualysServer $qualysServer -cookie $cookie
$slist=Get-QualysScanList -qualysServer $qualysServer -cookie $cookie
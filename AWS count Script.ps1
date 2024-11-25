Clear-Host
Install-Module -Name AWS.Tools.EC2 -Force 
Set-AWSCredential -AccessKey "REMOVED" -SecretKey "REMOVED" -StoreAs "PROFILENAME-AWS"
Set-AWSCredential -ProfileName "PROFILENAME-AWS"

######
## This script will generate errors where some resources may not be allowed in that region
## this script will generate errors where the account does not have access to regions
## the script will continue and output the final results to csv. 
######

## *LOCATION OF RESULTS * ##
$csvFilePath = "C:\temp\aws_resources.csv"


$resources = @(
    @{ Name = "EC2Instance"; Command = "Get-EC2Instance"; Ratio = 1 },
    @{ Name = "DynamoDB"; Command = "Get-DDBTableList"; Ratio = 3 },
    @{ Name = "LambdaFunctions"; Command = "Get-LMFunctionList"; Ratio = 3 },
    @{ Name = "APIGateway-REST"; Command = "Get-AGRestApiList"; Ratio = 3 },
    @{ Name = "APIGatewayV2"; Command = "Get-AG2ApiList"; Ratio = 3 },
    @{ Name = "RDSInstance"; Command = "Get-RDSDBInstance"; Ratio = 3 }
)

$results = @()
$regions = @("us-east-2","us-east-1","us-west-1","us-west-2","af-south-1","ap-east-1","ap-south-1","ap-northeast-3","ap-northeast-2","ap-southeast-1","ap-southeast-2","ap-northeast-1","ca-central-1","cn-north-1","cn-northwest-1","eu-central-1","eu-west-1","eu-west-2","eu-south-1","eu-west-3","eu-north-1","me-south-1","sa-east-1")

foreach ($region in $regions) {
    foreach ($resource in $resources) {
        Write-Host "Executing code for region: $region, Resource: $($resource.Name)"
        
        $instances = & $resource.Command -Region $region

      $count = 0

       if ($resource.Name -eq "EC2Instance") {
          $count = $instances.Count
       }

           elseif ($resource.Name -eq "RDSInstance") {
               $count = $instances.Count
           } 
        
           elseif ($resource.Name -eq "DynamoDB") {
                $count = $instances.Count
            }
        
            elseif ($resource.Name -eq "LambdaFunctions") {
                $count = ($instances | Measure-Object).Count
            }     
        
            elseif ($resource.Name -eq "APIGateway-REST") {
                $count = ($instances.Name | Measure-Object).Count
            } 
        
            else ($resource.Name -eq "APIGatewayV2") {
                $count = ($instances.Name | Measure-Object).Count
            } 
        }
        
        # adjusted = count/ ratio
        $adjustedCount = $count / $resource.Ratio
       
        # ******************* Round up **********************
        $roundedAdjustedCount = [math]::Ceiling($adjustedCount)
        
        #results  count
        $result = [PSCustomObject]@{
            Resource      = $resource.Name
            Region        = $region
            Count         = $count
            AdjustedCount = $roundedAdjustedCount
            Ratio         = $resource.Ratio
        }

        # Add the result to the results array
        $results += $result
    }
}
$results

$results | Export-Csv -Path $csvFilePath -NoTypeInformation
$jsonOutput = $results | ConvertTo-Json -Depth 3
Write-Output $jsonOutput


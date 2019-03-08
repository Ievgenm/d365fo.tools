﻿
<#
    .SYNOPSIS
        Generate labels for a package / module / model
        
    .DESCRIPTION
        Generate labels for a package / module / model using the builtin "labelc.exe"
        
    .PARAMETER Module
        Name of the package that you want to work against
        
    .PARAMETER OutputDir
        The path to the folder to save generated artifacts
        
    .PARAMETER LogDir
        The path to the folder to save logs
        
    .PARAMETER MetaDataDir
        The path to the meta data directory for the environment
        
        Default path is the same as the aos service PackagesLocalDirectory
        
    .PARAMETER ReferenceDir
        The full path of a folder containing all assemblies referenced from X++ code
        
        Default path is the same as the aos service PackagesLocalDirectory
        
    .PARAMETER BinDir
        The path to the bin directory for the environment
        
        Default path is the same as the aos service PackagesLocalDirectory\bin
        
    .EXAMPLE
        PS C:\> Invoke-D365ModuleLabelGeneration -Module MyModel
        
        This will use the default paths and start the labelc.exe with the needed parameters to labels from the MyModel package.
        The default output from the generation process will be silenced.
        
        If an error should occur, both the standard output and error output will be written to the console / host.
        
    .EXAMPLE
        PS C:\> Invoke-D365ModuleLabelGeneration -Module MyModel -ShowOriginalProgress
        
        This will use the default paths and start the labelc.exe with the needed parameters to labels from the MyModel package.
        The output from the compile will be written to the console / host.
        
    .NOTES
        Tags: Compile, Model, Servicing, Label, Labels
        
        Author: Ievgen Miroshnikov (@IevgenMir)
        
        Author: Mötz Jensen (@Splaxi)
#>


function Invoke-D365ModuleLabelGeneration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 1 )]
        [string] $Module,

        [Parameter(Mandatory = $False, Position = 2 )]
        [Alias('Output')]
        [string] $OutputDir = (Join-Path $Script:MetaDataDir $Module),

        [Parameter(Mandatory = $False, Position = 3 )]
        [string] $LogDir = (Join-Path $Script:DefaultTempPath $Module),

        [Parameter(Mandatory = $False, Position = 4 )]
        [string] $MetaDataDir = $Script:MetaDataDir,

        [Parameter(Mandatory = $False, Position = 5)]
        [string] $ReferenceDir = $Script:MetaDataDir,

        [Parameter(Mandatory = $False, Position = 6 )]
        [string] $BinDir = $Script:BinDirTools,

        [Parameter(Mandatory = $False, Position = 7 )]
        [switch] $ShowOriginalProgress
    )

    Invoke-TimeSignal -Start

    $tool = "labelc.exe"
    $executable = Join-Path $BinDir $tool

    if (-not (Test-PathExists -Path $MetaDataDir, $BinDir -Type Container)) {return}
    if (-not (Test-PathExists -Path $executable -Type Leaf)) {return}
    if (-not (Test-PathExists -Path $LogDir -Type Container -Create)) {return}

    $logFile = Join-Path $LogDir "Dynamics.AX.$Module.labelc.log"
    $logErrorFile = Join-Path $LogDir "Dynamics.AX.$Module.labelc.err"
  
    $params = @("-metadata=`"$MetaDataDir`"",
        "-modelmodule=`"$Module`"",
        "-output=`"$OutputDir\Resources`"",
        "-outlog=`"$logFile`"",
        "-errlog=`"$logErrorFile`""
    )
    
    Invoke-Process -Executable $executable -Params $params -ShowOriginalProgress $ShowOriginalProgress

    Invoke-TimeSignal -End

    [PSCustomObject]@{
        OutLogFile = $logFile
        ErrorLogFile = $logErrorFile
    }
}
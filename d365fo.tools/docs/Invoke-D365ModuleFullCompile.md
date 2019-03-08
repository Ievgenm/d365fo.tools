﻿---
external help file: d365fo.tools-help.xml
Module Name: d365fo.tools
online version:
schema: 2.0.0
---

# Invoke-D365ModuleFullCompile

## SYNOPSIS
Compile a package

## SYNTAX

```
Invoke-D365ModuleFullCompile [-Module] <String> [[-OutputDir] <String>] [[-LogDir] <String>]
 [[-MetaDataDir] <String>] [[-ReferenceDir] <String>] [[-BinDir] <String>] [-ShowOriginalProgress]
 [<CommonParameters>]
```

## DESCRIPTION
Compile a package using the builtin "xppc.exe" executable to compile source code, "labelc.exe" to compile label files and "reportsc.exe" to compile reports

## EXAMPLES

### EXAMPLE 1
```
Invoke-D365CompileModule -Module MyModel
```

This will use the default paths and start the xppc.exe with the needed parameters to copmile MyModel package.

## PARAMETERS

### -Module
The package to compile

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputDir
The path to the folder to save assemblies

```yaml
Type: String
Parameter Sets: (All)
Aliases: Output

Required: False
Position: 3
Default value: (Join-Path $Script:MetaDataDir $Module)
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogDir
The path to the folder to save logs

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: (Join-Path $Script:DefaultTempPath $Module)
Accept pipeline input: False
Accept wildcard characters: False
```

### -MetaDataDir
The path to the meta data directory for the environment

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: $Script:MetaDataDir
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReferenceDir
The full path of a folder containing all assemblies referenced from X++ code

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: $Script:MetaDataDir
Accept pipeline input: False
Accept wildcard characters: False
```

### -BinDir
The path to the bin directory for the environment

Default path is the same as the aos service PackagesLocalDirectory\bin

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: $Script:BinDirTools
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowOriginalProgress
{{Fill ShowOriginalProgress Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Tags: Compile, Model, Servicing

Author: Ievgen Miroshnikov (@IevgenMir)

## RELATED LINKS

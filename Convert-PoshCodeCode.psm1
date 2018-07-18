function New-MarkDownFile {
    param (
        $InputObject,
        $FileName
    )

    $InputObject
    $markdown = @"
---
Author: $($InputObject.author)
Publisher: $($InputObject.publisher)
Copyright: $($InputObject.copyright)
Email: $($InputObject.email)
Version: $($InputObject.version)
Encoding: $($InputObject.encoding)
License: $($InputObject.license)
PoshCode ID: $($InputObject.'x-poshcode-id')
Published Date: $($InputObject.'x-published')
Archived Date: $($InputObject.'x-archived')
---

# $($InputObject.title) - $($InputObject.name)

## Description

$($InputObject.description)

## Comments

$($InputObject.comment)

## Usage

$($InputObject.usage)

## TODO

$($InputObject.todo)

## $($InputObject.type)

``$($InputObject.function)``

## Code

``$($InputObject.code)``

"@

    # New-Item -Path /Users/josh.rickard/Desktop/output_markdown/ -Name $FileName -ItemType File -Force
    if (-not(Get-ChildItem -Path /Users/josh.rickard/Desktop/output_markdown/$FileName -ErrorAction SilentlyContinue)) {
        $markdown | Out-File -FilePath /Users/josh.rickard/Desktop/output_markdown/$FileName -Force
    }
}



function Get-MDObject {
    param (
        $FileName,
        $MDObject
    )

    Get-Content -Path $FileName.FullName -TotalCount 20 | Select-String -Pattern “#\s+(\w+|[a-zA-Z]-)*\:” -AllMatches |
        Foreach-Object {
        #$_.Matches
        $comments += $_.line
        $comments += $_.context.postcontext
        $Key = (($_.line).Split(":")[0]).Replace("# ", "")
        $Value = (($_.line).Split(":")[1]).Trim()

        $MDObject | Add-Member -NotePropertyName $Key.ToLower() -NotePropertyValue $Value.ToLower() -Force
    }
    return $MDObject
}


function Get-CodeCode {
    param (
        $FileName,
        $CodeObject
    )

    $Code = @()
    Get-Content -Path $FileName.FullName | select-string -Pattern "(#\s+|#\w+|#\s+\w+)" -notmatch | ForEach-Object {
        $Code += $_.line + "`n"
    }
    $CodeObject | Add-Member -NotePropertyName code -NotePropertyValue $Code -Force
    return $CodeObject
}

function Convert-PoshCodeCode {

    $ReturnObject = New-Object -TypeName PSCustomObject

    Get-ChildItem -Path '/Users/josh.rickard/Downloads/zip' -File| ForEach-Object {
        $ReturnObject = Get-MDObject -FileName $_ -MDObject $ReturnObject
        $ReturnObject = Get-CodeCode -FileName $_ -CodeObject $ReturnObject

        New-MarkDownFile -InputObject $ReturnObject -FileName "$($_.Name).md"
        $ReturnObject = New-Object -TypeName PSCustomObject
    }
}

Convert-PoshCodeCode
# Change working directory to this script location
# Previous one will be restored at the end of the script, or if an error occurs
Push-Location $PSScriptRoot
trap {
    Pop-Location
    break
}

$allContent = Get-Content -ErrorAction Stop .\input.txt
$typesValuesMapArray = New-Object System.Collections.ArrayList
$typesValuesMap = $null
$lastLine = $allContent[$allContent.Count - 1]

$totalLines = $allContent.Count
for ($i = 0; $i -lt $totalLines; $i++) {
    $line = $allContent[$i]

    if ($line.StartsWith('seeds: ')) {
        $trimmedLine = $line.TrimStart('seeds: ').Trim()

        $seeds = $trimmedLine.Split(' ')
    }

    if ($line.EndsWith(' map:')) {
        $trimmedLine = $line.TrimEnd(' map:').Trim()
        $types = $trimmedLine.Split('-to-')
        $typesValuesMap = [PSCustomObject]@{
            left   = $types[0]
            right  = $types[1]
            values = New-Object System.Collections.ArrayList
        }
    }

    if ($line -match '^[0-9]') {
        $trimmedLine = $line.Trim()
        # Convert string array to int64 array
        # Otherwise it will do stuff like "50" + 1 = "501"
        $map = $trimmedLine.Split(' ')
        $typesValuesMap.values.Add(@($map[0], $map[1], $map[2])) > $null
    }

    if (((-not $line) -or ($line -eq $lastLine)) -and ($typesValuesMap)) {
        $typesValuesMapArray.Add($typesValuesMap) > $null
    }
}

#$typesValuesMapArray

[int64]$lowestValue = [int64]::MaxValue
foreach ($seed in $seeds) {
    #Write-Progress -Activity "Calculating final value of seeds" -Status $seed -PercentComplete ((($seeds.IndexOf($seed) + 1) / $seeds.Count) * 100)
    [int64]$currentValue = [int64]$seed
    #Write-Host "$seed : "
    :typesValuesMapLoop foreach ($typesValuesMap in $typesValuesMapArray) {
        #Write-Host -NoNewline "$currentValue "

        foreach ($map in $typesValuesMap.values) {
            $mapInt = $map | ForEach-Object { [int64]$_ }
            if ($currentValue -ge $mapInt[1] -and $currentValue -lt ($mapInt[1] + $mapInt[2])) {
                $currentValue += ([int64] ($mapInt[0] - $mapInt[1]))
                continue typesValuesMapLoop
            }
        }
        # If we exit here, we can just keep the current value
    }
    #Write-Host "$currentValue"

    if ($currentValue -lt $lowestValue) {
        $lowestValue = [int64]$currentValue
    }
}
$lowestValue

## SECOND PART
Write-Host '------------------------------'

[int64]$lowestValue = [int64]::MaxValue
$i = 0
while ($i -lt $seeds.Count) {
    [int64]$start = $seeds[$i]
    [int64]$range = $seeds[$i + 1]
    Write-Progress -Activity 'Calculating final value of seeds' -Id 0 -Status $seed -PercentComplete ((($i + 1) / $seeds.Count) * 100)

    for ($i = 0; $i -lt $range; $i++) {
        [int64]$currentValue = [int64] ([int64]$i + [int64]$start)
        Write-Progress -Activity "Calculating final value of seeds $start to $($start + $range)" -Id 1 -ParentId 0 -Status $currentValue -PercentComplete ((($i + 1) / $range) * 100)
        #Write-Host "$seed : "
        :typesValuesMapLoop foreach ($typesValuesMap in $typesValuesMapArray) {
            #Write-Host -NoNewline "$currentValue "

            foreach ($map in $typesValuesMap.values) {
                $mapInt = $map | ForEach-Object { [int64]$_ }
                if ($currentValue -ge $mapInt[1] -and $currentValue -lt ($mapInt[1] + $mapInt[2])) {
                    $currentValue += ([int64] ($mapInt[0] - $mapInt[1]))
                    continue typesValuesMapLoop
                }
            }
            # If we exit here, we can just keep the current value
        }
        #Write-Host "$currentValue"

        if ($currentValue -lt $lowestValue) {
            $lowestValue = [int64]$currentValue
        }
    }

    $i += 2
}
$lowestValue

Pop-Location
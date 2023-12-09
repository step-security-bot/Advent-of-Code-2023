# Change working directory to this script location
# Previous one will be restored at the end of the script, or if an error occurs
Push-Location $PSScriptRoot
trap {
    Pop-Location
    break
}

$allContent = Get-Content -ErrorAction Stop .\input.txt

$histories = New-Object System.Collections.Generic.List[int[]]
foreach ($line in $allContent) {
    $histories.Add($line.Split(' '))
}

$sumNextValue = 0 # Part 1
$sumPreviousValue = 0 # Part 2
foreach ($history in $histories) {
    Write-Host -NoNewline "$($histories.IndexOf($history) + 1)/$($histories.Count)`r"

    $historyPyramid = New-Object System.Collections.Generic.List[System.Collections.Generic.List[int]]
    $historyPyramid.Add($history)

    # Create the pyramid for $history
    $pyramidLine = New-Object System.Collections.Generic.List[int]
    while ($true) {
        $previousPyramidLine = $historyPyramid[0]

        $left = $previousPyramidLine[0]
        for ($i = 1; $i -lt $previousPyramidLine.Count; $i++) {
            $right = $previousPyramidLine[$i]
            $pyramidLine.Add($right - $left)
            $left = $right
        }

        $historyPyramid.Insert(0, $pyramidLine)

        $shouldBreak = $true
        foreach ($number in $pyramidLine) {
            if ($number -ne 0) {
                $shouldBreak = $false
                break
            }
        }
        if ($shouldBreak) {
            break
        }

        $pyramidLine = New-Object System.Collections.Generic.List[int]
    }

    # Part 1 : Create the next value by going from bottom to top
    $historyPyramid[0].Add(0)
    for ($i = 1; $i -lt $historyPyramid.Count; $i++) {
        $historyPyramid[$i].Add($historyPyramid[$i][-1] + $historyPyramid[$i - 1][-1])
    }

    # Part 2 : Create the previous value by going from bottom to top
    $historyPyramid[0].Insert(0, 0)
    for ($i = 1; $i -lt $historyPyramid.Count; $i++) {
        $historyPyramid[$i].Insert(0, $historyPyramid[$i][0] - $historyPyramid[$i - 1][0])
    }

    # Display the pyramid
    <# $tabs = ''
    for ($i = $historyPyramid.Count - 1; $i -ge 0; $i--) {
        $line = $historyPyramid[$i]
        Write-Output "$tabs$($line -join "`t`t")"
        $tabs += "`t"
    }
    Write-Output ('-' * 240) #>

    $sumNextValue += $historyPyramid[-1][-1]
    $sumPreviousValue += $historyPyramid[-1][0]
}
$sumNextValue
Write-Host '------------------------------'
$sumPreviousValue

Pop-Location
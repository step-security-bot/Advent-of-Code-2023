# Change working directory to this script location
# Previous one will be restored at the end of the script, or if an error occurs
Push-Location $PSScriptRoot
trap {
    Pop-Location
    break
}

## FIRST PART

$allContent = Get-Content -ErrorAction Stop .\input.txt
$sum = 0
$currentLine = 0

:lineLoop foreach ($line in $allContent) {
    $currentLine++
    $allBags = $line.Split(':')[1].Trim().Replace(' ', '')

    # Loop through each set of cubes
    # If one of them have too much cubes, skip to next lineLoop
    foreach ($bag in $allBags.Split(';')) {
        foreach ($color in $bag.Split(',')) {
            # $color is in format 'CountColor' without a space between both
            switch -Wildcard ($color) {
                '*red*' {
                    $count = [int] $color.Trim('red')
                    if ($count -gt 12) {
                        Write-Output "Line $currentLine : $count red cubes"
                        continue lineLoop
                    }
                }
                '*green*' {
                    $count = [int] $color.Trim('green')
                    if ($count -gt 13) {
                        Write-Output "Line $currentLine : $count green cubes"
                        continue lineLoop
                    }
                }
                '*blue*' {
                    $count = [int] $color.Trim('blue')
                    if ($count -gt 14) {
                        Write-Output "Line $currentLine : $count blue cubes"
                        continue lineLoop
                    }
                }
            }
        }
    }

    $sum += $currentLine
}
$sum

## SECOND PART
Write-Host '------------------------------'

$sum = 0
$currentLine = 0

:lineLoop foreach ($line in $allContent) {
    $currentLine++
    $allBags = $line.Split(':')[1].Trim().Replace(' ', '')
    $red = 0
    $green = 0
    $blue = 0

    # Loop through each set of cubes
    # If one of them have too much cubes, skip to next lineLoop
    foreach ($bag in $allBags.Split(';')) {
        foreach ($color in $bag.Split(',')) {
            # $color is in format 'CountColor' without a space between both
            switch -Wildcard ($color) {
                '*red*' {
                    $count = [int] $color.Trim('red')
                    if ($count -gt $red) {
                        $red = $count
                    }
                }
                '*green*' {
                    $count = [int] $color.Trim('green')
                    if ($count -gt $green) {
                        $green = $count
                    }
                }
                '*blue*' {
                    $count = [int] $color.Trim('blue')
                    if ($count -gt $blue) {
                        $blue = $count
                    }
                }
            }
        }
    }

    Write-Output "Line $currentLine : $red red cubes, $green green cubes, $blue blue cubes"
    $sum += ($red * $green * $blue)
}
$sum

Pop-Location
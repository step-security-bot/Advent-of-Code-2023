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

for ($lineIndex = 0; $lineIndex -lt $allContent.Length; $lineIndex++) {
    $currentNumber = ''
    $numberIsValid = $false
    $line = $allContent[$lineIndex]

    for ($columnIndex = 0; $columnIndex -lt $line.Length; $columnIndex++) {
        # Check if at least one character around is a symbol
        if ($line[$columnIndex] -match '[0-9]') {
            $currentNumber += $line[$columnIndex]

            # No need to check if it's already valid
            if (-not $numberIsValid) {

                # For each line around...
                :aroundLoop for ($charlineIndex = $lineIndex - 1; $charlineIndex -le $lineIndex + 1; $charlineIndex++) {
                    if ($charlineIndex -lt 0 -or $charlineIndex -ge $allContent.Length) {
                        continue
                    }

                    # For each column around...
                    for ($charColumnIndex = $columnIndex - 1; $charColumnIndex -le $columnIndex + 1; $charColumnIndex++) {
                        if ($charColumnIndex -lt 0 -or $charColumnIndex -ge $line.Length) {
                            continue
                        }

                        if ($allContent[$charlineIndex][$charColumnIndex] -match '[^0-9.]') {
                            $numberIsValid = $true
                            break aroundLoop
                        }
                    }
                }
            }
        }
        # Add number to sum if it's valid
        else {
            if ($currentNumber -ne '') {
                if ($numberIsValid) {
                    $sum += [int]$currentNumber
                }
                else {
                    Write-Host "Line $lineIndex : Invalid number $currentNumber"
                }

                # Reset current number and its validity
                $currentNumber = ''
                $numberIsValid = $false
            }
        }

        if ($columnIndex -eq $line.Length - 1) {
            if ($currentNumber -ne '') {
                if ($numberIsValid) {
                    $sum += [int]$currentNumber
                }
                else {
                    Write-Host "Line $lineIndex : Invalid number $currentNumber"
                }

                # Reset current number and its validity
                $currentNumber = ''
                $numberIsValid = $false
            }
        }
    }
}
$sum

## SECOND PART
Write-Host '------------------------------'

$allContent = Get-Content -ErrorAction Stop .\input.txt
$sum = 0

function GetWholeNumber($lineIndex, $columnIndex) {
    $line = $allContent[$lineIndex]
    $currentColumnIndex = $columnIndex

    # Go at the first digit
    while ($currentColumnIndex -ge 0 -and $line[$currentColumnIndex] -match '[0-9]') {
        $currentColumnIndex--
    }
    $currentColumnIndex++ # The while stop one character before

    # Get whole number
    $number = ''
    while ($currentColumnIndex -lt $line.Length -and $line[$currentColumnIndex] -match '[0-9]') {
        $number += $line[$currentColumnIndex]
        $currentColumnIndex++
    }

    # "return" in powershell write-output its arguments and exit the function
    # All others write-output happening in the function are also returned, even without "return"
    # So there are two ways to deal with returns :
    #   - Take the last(s) returned values of the function
    #   - Don't deal with it and use scoped variables instead
    $Script:number = [int]$number
}

for ($lineIndex = 0; $lineIndex -lt $allContent.Length; $lineIndex++) {
    for ($columnIndex = 0; $columnIndex -lt $allContent[$lineIndex].Length; $columnIndex++) {
        # Oh no...
        if ($allContent[$lineIndex][$columnIndex] -eq '*') {
            $numbers = New-Object System.Collections.Generic.List[int]

            # Top line
            $threeChars = $allContent[$lineIndex - 1][$columnIndex - 1] + $allContent[$lineIndex - 1][$columnIndex] + $allContent[$lineIndex - 1][$columnIndex + 1]
            switch -Regex ($threeChars) {
                '[0-9][^0-9][0-9]' {
                    GetWholeNumber ($lineIndex - 1) ($columnIndex - 1)
                    $numbers.Add($number)
                    GetWholeNumber ($lineIndex - 1) ($columnIndex + 1)
                    $numbers.Add($number)
                }
                '[0-9][^0-9][^0-9]' {
                    GetWholeNumber ($lineIndex - 1) ($columnIndex - 1)
                    $numbers.Add($number)
                }
                '[^0-9][^0-9][0-9]' {
                    GetWholeNumber ($lineIndex - 1) ($columnIndex + 1)
                    $numbers.Add($number)
                }
                '.[0-9].' {
                    GetWholeNumber ($lineIndex - 1) ($columnIndex)
                    $numbers.Add($number)
                }
            }

            # Middle line
            $threeChars = $allContent[$lineIndex][$columnIndex - 1] + $allContent[$lineIndex][$columnIndex] + $allContent[$lineIndex][$columnIndex + 1]
            switch -Regex ($threeChars) {
                '[0-9].[0-9]' {
                    GetWholeNumber ($lineIndex) ($columnIndex - 1)
                    $numbers.Add($number)
                    GetWholeNumber ($lineIndex) ($columnIndex + 1)
                    $numbers.Add($number)
                }
                '[0-9].[^0-9]' {
                    GetWholeNumber ($lineIndex) ($columnIndex - 1)
                    $numbers.Add($number)
                }
                '[^0-9].[0-9]' {
                    GetWholeNumber ($lineIndex) ($columnIndex + 1)
                    $numbers.Add($number)
                }
            }

            # Bottom line
            $threeChars = $allContent[$lineIndex + 1][$columnIndex - 1] + $allContent[$lineIndex + 1][$columnIndex] + $allContent[$lineIndex + 1][$columnIndex + 1]
            switch -Regex ($threeChars) {
                '[0-9][^0-9][0-9]' {
                    GetWholeNumber ($lineIndex + 1) ($columnIndex - 1)
                    $numbers.Add($number)
                    GetWholeNumber ($lineIndex + 1) ($columnIndex + 1)
                    $numbers.Add($number)
                }
                '[0-9][^0-9][^0-9]' {
                    GetWholeNumber ($lineIndex + 1) ($columnIndex - 1)
                    $numbers.Add($number)
                }
                '[^0-9][^0-9][0-9]' {
                    GetWholeNumber ($lineIndex + 1) ($columnIndex + 1)
                    $numbers.Add($number)
                }
                '.[0-9].' {
                    GetWholeNumber ($lineIndex + 1) ($columnIndex)
                    $numbers.Add($number)
                }
            }

            if ($numbers.Count -eq 2) {
                $sum += $numbers[0] * $numbers[1]
            }
        }
    }
}
$sum

Pop-Location
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
    $line = $allContent[$lineIndex]

    # Single-digit numbers have two spaces around, reduce to one space
    $editedLine = $line.Split(':')[1].Trim() -replace '\s+', ' '
    $winningNumbers, $myNumbers = $editedLine.Split('|')

    $winningNumbersArray = $winningNumbers.Trim().Split(' ')
    $myNumbersArray = $myNumbers.Trim().Split(' ')

    $currentSum = 0
    foreach ($myNumber in $myNumbersArray) {
        if ($winningNumbersArray.Contains($myNumber)) {
            if ($currentSum -eq 0) {
                $currentSum = 1
            }
            else {
                $currentSum *= 2
            }
        }
    }

    $sum += $currentSum
    Write-Output "Line $lineIndex : $currentSum"
}
$sum

## SECOND PART
Write-Host '------------------------------'

$allContent = Get-Content -ErrorAction Stop .\input.txt
$sum = 0

# Initialize array with 1 for each card (because there is at least the original)
$sumPerLine = @(1) * $allContent.Length

# For each card it first gets the numbers of matches
# Then for 1 to the numbers of matches it adds the numbers of cards of itself to the subsequent card
# For example if card 2 has 3 cards and 2 matches , it will add 3 to card 3 and 3 to card 4
for ($lineIndex = 0; $lineIndex -lt $allContent.Length; $lineIndex++) {
    $line = $allContent[$lineIndex]

    $editedLine = $line.Split(':')[1].Trim() -replace '\s+', ' '
    $winningNumbers, $myNumbers = $editedLine.Split('|')

    $winningNumbersArray = $winningNumbers.Trim().Split(' ')
    $myNumbersArray = $myNumbers.Trim().Split(' ')

    $currentSum = 0
    foreach ($myNumber in $myNumbersArray) {
        if ($winningNumbersArray.Contains($myNumber)) {
            $currentSum++
        }
    }

    for ($i = 1; $i -le $currentSum; $i++) {
        $sumPerLine[$lineIndex + $i] += $sumPerLine[$lineIndex]
    }
}

$totalSum = 0
for ($i = 0; $i -lt $sumPerLine.Length; $i++) {
    $sum = $sumPerLine[$i]
    $totalSum += $sum
    Write-Output "Card $i : $sum"
}
$totalSum

Pop-Location
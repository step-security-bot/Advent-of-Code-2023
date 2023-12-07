# Change working directory to this script location
# Previous one will be restored at the end of the script, or if an error occurs
Push-Location $PSScriptRoot
trap {
    Pop-Location
    break
}

$allContent = Get-Content -ErrorAction Stop .\input.txt
[string[]]$cardsTypes = @('2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A')

## FIRST PART

$cardsBidsStrength = New-Object System.Collections.ArrayList

function GetHandStrength([string]$hand) {
    $card1, $card2, $card3, $card4, $card5 = $hand.ToCharArray()

    [int[]]$strength = @(0, 0, 0, 0, 0, 0)
    $occurences = New-Object System.Collections.Generic.List[int]
    for ($cardTypeIndex = 0; $cardTypeIndex -lt $cardsTypes.Length; $cardTypeIndex++) {
        $occurence = 0
        for ($cardInHandIndex = 0; $cardInHandIndex -lt $hand.Length; $cardInHandIndex++) {
            if ($hand[$cardInHandIndex] -eq $cardsTypes[$cardTypeIndex]) {
                $strength[$cardInHandIndex + 1] = $cardTypeIndex
                $occurence++
            }
        }
        $occurences.Add($occurence)
    }

    $maxOccurence = ($occurences | Measure-Object -Maximum).Maximum

    switch ($maxOccurence) {
        5 {
            $strength[0] = 6
        }
        4 {
            $strength[0] = 5
        }
        3 {
            if ($occurences.Contains(2)) {
                $strength[0] = 4
            }
            else {
                $strength[0] = 3
            }
        }
        2 {
            $nbOccurenceTwo = 0
            foreach ($occurence in $occurences) {
                if ($occurence -eq 2) {
                    $nbOccurenceTwo++
                }
            }

            if ($nbOccurenceTwo -eq 2) {
                $strength[0] = 2
            }
            else {
                $strength[0] = 1
            }
        }
        1 {
            $strength[0] = 0
        }
    }

    return $strength
}

for ($index = 0; $index -lt $allContent.Length; $index++) {
    $splittedLine = $allContent[$index].Split(' ')
    [int[]]$strength = GetHandStrength $splittedLine[0]

    $cardsBidsStrength.Add([PSCustomObject]@{
            cards         = [string]$splittedLine[0]
            bid           = [int]$splittedLine[1]
            strengthType  = [int]$strength[0]
            strengthCard1 = [int]$strength[1]
            strengthCard2 = [int]$strength[2]
            strengthCard3 = [int]$strength[3]
            strengthCard4 = [int]$strength[4]
            strengthCard5 = [int]$strength[5]
        }) > $null
}
$sortedCardsBidsStrength = $cardsBidsStrength | Sort-Object strengthType, strengthCard1, strengthCard2, strengthCard3, strengthCard4, strengthCard5
$sortedCardsBidsStrength | Format-Table

$sortedBids = $sortedCardsBidsStrength.bid
$total = 0
for ($bidIndex = 0; $bidIndex -lt $sortedBids.Length; $bidIndex++) {
    $total += $sortedBids[$bidIndex] * ($bidIndex + 1)
}
$total

## SECOND PART
Write-Host '------------------------------'

$cardsBidsStrength = New-Object System.Collections.ArrayList

function GetHandStrengthJoker([string]$hand) {
    $card1, $card2, $card3, $card4, $card5 = $hand.ToCharArray()

    [int[]]$strength = @(0, 0, 0, 0, 0, 0)
    $occurences = New-Object System.Collections.Generic.List[int]
    for ($cardTypeIndex = 0; $cardTypeIndex -lt $cardsTypes.Length; $cardTypeIndex++) {
        $occurence = 0
        for ($cardInHandIndex = 0; $cardInHandIndex -lt $hand.Length; $cardInHandIndex++) {
            if ($hand[$cardInHandIndex] -eq $cardsTypes[$cardTypeIndex]) {
                # Joker is the weakest card
                if ($cardTypeIndex -eq 9) {
                    $strength[$cardInHandIndex + 1] = -1
                }
                else {
                    $strength[$cardInHandIndex + 1] = $cardTypeIndex
                }
                $occurence++
            }
        }
        $occurences.Add($occurence)
    }

    $occurencesNotJoker = $occurences[0..8] + $occurences[10..12]
    $maxOccurenceNotJoker = ($occurencesNotJoker | Measure-Object -Maximum).Maximum
    $occurenceJoker = $occurences[9]
    $maxOccurence = $maxOccurenceNotJoker + $occurenceJoker

    # Create an array of occurences with max value (beside joker) and joker value set to 0
    $occurencesNotJokerNotMax = $occurences
    $occurencesNotJokerNotMax[$occurencesNotJokerNotMax.IndexOf($maxOccurenceNotJoker)] = 0
    $occurencesNotJokerNotMax[9] = 0


    switch ($maxOccurence) {
        5 {
            $strength[0] = 6
        }
        4 {
            $strength[0] = 5
        }
        3 {
            if ($occurencesNotJokerNotMax.Contains(2)) {
                $strength[0] = 4
            }
            else {
                $strength[0] = 3
            }
        }
        2 {
            $nbOccurenceTwo = 1
            foreach ($occurence in $occurencesNotJokerNotMax) {
                if ($occurence -eq 2) {
                    $nbOccurenceTwo++
                }
            }

            if ($nbOccurenceTwo -eq 2) {
                $strength[0] = 2
            }
            else {
                $strength[0] = 1
            }
        }
        1 {
            $strength[0] = 0
        }
    }

    return $strength
}

for ($index = 0; $index -lt $allContent.Length; $index++) {
    $splittedLine = $allContent[$index].Split(' ')
    [int[]]$strength = GetHandStrengthJoker $splittedLine[0]

    $cardsBidsStrength.Add([PSCustomObject]@{
            cards         = [string]$splittedLine[0]
            bid           = [int]$splittedLine[1]
            strengthType  = [int]$strength[0]
            strengthCard1 = [int]$strength[1]
            strengthCard2 = [int]$strength[2]
            strengthCard3 = [int]$strength[3]
            strengthCard4 = [int]$strength[4]
            strengthCard5 = [int]$strength[5]
        }) > $null
}
$sortedCardsBidsStrength = $cardsBidsStrength | Sort-Object strengthType, strengthCard1, strengthCard2, strengthCard3, strengthCard4, strengthCard5
$sortedCardsBidsStrength | Format-Table

$sortedBids = $sortedCardsBidsStrength.bid
$total = 0
for ($bidIndex = 0; $bidIndex -lt $sortedBids.Length; $bidIndex++) {
    $total += $sortedBids[$bidIndex] * ($bidIndex + 1)
}
$total

Pop-Location
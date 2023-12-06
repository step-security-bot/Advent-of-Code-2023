# Change working directory to this script location
# Previous one will be restored at the end of the script, or if an error occurs
Push-Location $PSScriptRoot
trap {
    Pop-Location
    break
}

## FIRST PART

$allContent = Get-Content -ErrorAction Stop .\input.txt
$times = ($allContent[0] -replace '\s+', ' ').Split(': ')[1].Split(' ')
$distances = ($allContent[1] -replace '\s+', ' ').Split(': ')[1].Split(' ')

$sums = New-Object System.Collections.Generic.List[int]
for ($tdIndex = 0; $tdIndex -lt $times.Length; $tdIndex++) {
    [int]$time = $times[$tdIndex]
    [int]$distance = $distances[$tdIndex]

    $sum = 0
    for ($timeHolding = 0; $timeHolding -le $time; $timeHolding++) {
        $distanceTraveled = $timeHolding * ($time - $timeHolding)
        if ($distanceTraveled -gt $distance) {
            $sum++
        }
    }
    $sums.Add($sum)
}

$total = 1
foreach ($sum in $sums) {
    $total *= $sum
}
$total

## SECOND PART
Write-Host '------------------------------'

[sbyte]$lastPercentage = -1

[long]$timeMerged = $times -join ''
[long]$distanceMerged = $distances -join ''

$total = 0
for ([long]$timeHolding = 0; $timeHolding -le $timeMerged; $timeHolding++) {
    # Updating progress shown
    [sbyte]$percentage = (($timeHolding / $timeMerged) * 100)
    if ($percentage -gt $lastPercentage) {
        $lastPercentage = $percentage
        Write-Progress -Activity 'Counting all possible wins' -Status $timeHolding -PercentComplete $percentage
    }

    $distanceTraveled = $timeHolding * ($timeMerged - $timeHolding)
    if ($distanceTraveled -gt $distanceMerged) {
        $total++
    }
}
$total

Pop-Location
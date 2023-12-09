# Change working directory to this script location
# Previous one will be restored at the end of the script, or if an error occurs
Push-Location $PSScriptRoot
trap {
    Pop-Location
    break
}

$allContent = Get-Content -ErrorAction Stop .\input.txt

## FIRST PART

$leftRightInstructions = $allContent[0].ToCharArray()

# Initialize arrays with fixed size
$nodeLength = $allContent.Length - 2 # Left right instructions and empty line
$elements = New-Object string[] $nodeLength
$lefts = New-Object string[] $nodeLength
$rights = New-Object string[] $nodeLength

for ($i = 2; $i -lt $allContent.Length; $i++) {
    $line = $allContent[$i]
    $line -match '^(\w+) = \((\w+), (\w+)\)$' > $null

    $elements[$i - 2] = $Matches[1]
    $lefts[$i - 2] = $Matches[2]
    $rights[$i - 2] = $Matches[3]
}

$steps = 0
[string]$currentElement = 'AAA'
$lriIndex = 0 # Left right instructions index

while ($currentElement -ne 'ZZZ') {

    # Find matching element and apply left/right instruction
    for ($i = 0; $i -lt $elements.Length; $i++) {
        if ($elements[$i] -eq $currentElement) {
            switch ($leftRightInstructions[$lriIndex]) {
                'L' { $currentElement = $lefts[$i] }
                'R' { $currentElement = $rights[$i] }
            }
            break
        }
    }

    $lriIndex++
    if ($lriIndex -eq $leftRightInstructions.Length) {
        $lriIndex = 0
    }

    $steps++
    if ($steps % 1000 -eq 0) {
        Write-Host -NoNewline "$steps`r"
    }
}
$steps

## SECOND PART
Write-Host '------------------------------'

# Initialize starting positions
$currentElements = New-Object System.Collections.Generic.List[string]
foreach ($element in $elements) {
    if ($element.EndsWith('A')) {
        $currentElements.Add($element)
    }
}

$stepsNeeded = New-Object int[] $currentElements.Count

for ($currentElementsIndex = 0; $currentElementsIndex -lt $currentElements.Count; $currentElementsIndex++) {
    $stepsNeeded[$currentElementsIndex] = 0
    $steps = 0
    $lriIndex = 0
    $currentElement = $currentElements[$currentElementsIndex]

    $progressActivity = "Calculating steps needed ($($currentElementsIndex + 1)/$($currentElements.Count))"
    Write-Progress -Activity $progressActivity -Id 0 -PercentComplete (($currentElementsIndex + 1) / $currentElements.Count * 100)

    while (-not ($currentElement.EndsWith('Z'))) {

        # Find matching element and apply left/right instruction
        for ($i = 0; $i -lt $elements.Length; $i++) {
            if ($elements[$i] -eq $currentElement) {
                switch ($leftRightInstructions[$lriIndex]) {
                    'L' { $currentElement = $lefts[$i] }
                    'R' { $currentElement = $rights[$i] }
                }
                break
            }
        }

        $lriIndex++
        if ($lriIndex -eq $leftRightInstructions.Length) {
            $lriIndex = 0
        }

        $steps++
        if ($steps % 1000 -eq 0) {
            Write-Progress -Activity "$progressActivity : $steps" -Id 0 -PercentComplete (($currentElementsIndex + 1) / $currentElements.Count * 100)
        }
    }
    $stepsNeeded[$currentElementsIndex] = $steps
}
Write-Progress -Activity $progressActivity -Completed
Write-Host 'Steps needed:'
$stepsNeeded

# Calculate least common multiple of all steps needed

function GreatestCommonDivisor($a, $b) {

    # Didn't use a recursive call everywhere because the eucliden algorithm was reaching the recursion limit
    # The binary algorithm use less recursive calls so it would probably have worked
    while ($a -ne $b) {

        # End
        if ($a -eq 0) {
            return $b
        }
        elseif ($b -eq 0) {
            return $a
        }

        # $a even and $b even
        elseif ((($a % 2) -eq 0) -and (($b % 2) -eq 0)) {
            return ((GreatestCommonDivisor ($a / 2) ($b / 2)) * 2)
        }
        # $a even and $b odd
        elseif ((($a % 2) -eq 0) -and (($b % 2) -eq 1)) {
            $a /= 2
        }
        # $a odd and $b even
        elseif ((($a % 2) -eq 1) -and (($b % 2) -eq 0)) {
            $b /= 2
        }
        # $a odd and $b odd
        else {
            if ($a -gt $b) {
                $a = ($a - $b) / 2
            }
            else {
                $b = ($b - $a) / 2
            }
        }

        $count++
        # Binary algorithm is so fast we can display the progress at each loop without noticeable performance impact
        if ($count -gt 0) {
            Write-Host -NoNewline "Least common multiple of $lcm and $steps : $a|$b                    `r"
            $count = 0
        }
    }
    return $a
}

function LeastCommonMultiple($a, $b) {
    return (($a * $b) / (GreatestCommonDivisor $a $b))
}

Write-Host ''
$count = 0

$lcm = $stepsNeeded[0]
foreach ($steps in $stepsNeeded) {
    $lcm = (LeastCommonMultiple $lcm $steps)
}
Write-host ''
$lcm

Pop-Location
# Change working directory to this script location
# Previous one will be restored at the end of the script, or if an error occurs
Push-Location $PSScriptRoot
trap {
    Pop-Location
    break
}

function WordToChar($word) {
    switch ($word) {
        'one' { return '1' }
        'two' { return '2' }
        'three' { return '3' }
        'four' { return '4' }
        'five' { return '5' }
        'six' { return '6' }
        'seven' { return '7' }
        'eight' { return '8' }
        'nine' { return '9' }
    }
}

$allContent = Get-Content -ErrorAction Stop .\input.txt
$sum = 0
$arrayWords = @('one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine')

foreach ($line in $allContent) {
    # Left to right
    :leftToRight for ($i = 0; $i -lt $line.Length; $i++) {
        # Check digit
        if ($line[$i] -match '[0-9]') {
            $left = $line[$i]
            break leftToRight
        }

        # Check word by word
        $lineSub = $line.Substring($i)
        foreach ($word in $arrayWords) {
            if ($lineSub.StartsWith($word)) {
                $left = WordToChar($word)
                break leftToRight
            }
        }
    }

    # Right to left
    :rightToLeft for ($i = $line.Length; $i -ge 0; $i--) {
        # Check digit
        if ($line[$i] -match '[0-9]') {
            $right = $line[$i]
            break rightToLeft
        }


        # Check word by word
        $lineSub = $line.Substring(0, $i)
        foreach ($word in $arrayWords) {
            if ($lineSub.EndsWith(($word))) {
                $right = WordToChar($word)
                break rightToLeft
            }
        }
    }

    # Merging both sides
    $sum += [int] ($left + $right)
}
$sum

Pop-Location
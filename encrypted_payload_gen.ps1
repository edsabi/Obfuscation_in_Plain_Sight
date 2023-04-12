function Xor-Encryption ($InputText, $Key) {
    $inputBytes = [System.Text.Encoding]::UTF8.GetBytes($InputText)
    $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($Key)
    
    $outputBytes = New-Object 'byte[]' $inputBytes.Count
    for ($i = 0; $i -lt $inputBytes.Count; $i++) {
        $outputBytes[$i] = $inputBytes[$i] -bxor $keyBytes[$i % $keyBytes.Count]
    }

    return [System.Convert]::ToBase64String($outputBytes)
}

function Xor-Decryption ($EncryptedText, $Key) {
    $encryptedBytes = [System.Convert]::FromBase64String($EncryptedText)
    $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($Key)

    $decryptedBytes = New-Object 'byte[]' $encryptedBytes.Count
    for ($i = 0; $i -lt $encryptedBytes.Count; $i++) {
        $decryptedBytes[$i] = $encryptedBytes[$i] -bxor $keyBytes[$i % $keyBytes.Count]
    }

    return [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
}

function Hide-EncryptedStringInFakePEM ($EncryptedString) {
    $pemHeader = "-----BEGIN RSA PRIVATE KEY-----`n"
    $pemFooter = "`n-----END RSA PRIVATE KEY-----"
    $EncryptedStringLength = $EncryptedString.Length
    $numbytes=1600-$EncryptedStringLength
    # Generate a random base64 string
    $randomBytes = New-Object 'byte[]' $numbytes
    (New-Object System.Security.Cryptography.RNGCryptoServiceProvider).GetBytes($randomBytes)
    $randomBase64 = [System.Convert]::ToBase64String($randomBytes)
    $EncryptedString=$EncryptedString -replace '=',''
    # Combine the random base64 string with the encrypted string and delimiters
    $hiddenBase64 = $randomBase64 + "HaFfa" + $EncryptedString  + "Da7"

    # Break the hidden base64 string into lines of 64 characters
    $wrappedHiddenBase64 = $hiddenBase64 -replace "(.{64})", '${1}`n' -replace '=',''
    $wrappedHiddenBase64_lines = $wrappedHiddenBase64 -split '`n'
    
    foreach ($line in $wrappedHiddenBase64_lines) {
        
        $wrappedHiddenBase64_joined += $line + "`n"

    }

    # Create the fake PEM content
    $fakePEMContent = $pemHeader + $wrappedHiddenBase64_joined + $pemFooter

    return $fakePEMContent
}

function Parse-EncryptedString ($inputstring) {
    $fakePEM_string = $inputstring -replace "`n" -replace "`r"
    $pattern = "(?<=HaFfa).*?(?=Da7)"
    $match = [regex]::Match($fakePEM_string, $pattern)

    if ($match.Success) {
        return $match.Value
    } else {
        throw "The input string does not contain the expected delimiters (HaFfa and Da7)."
    }
}


$plaintext = "invoke-expression calc.exe"
$key = "us-east"

$encrypted = Xor-Encryption -InputText $plaintext -Key $key
$decrypted = Xor-Decryption -EncryptedText $encrypted -replace '=','' -Key $key

Write-Host "Encrypted text: $encrypted"
Write-Host "Decrypted text: $decrypted"

$fakePEM = Hide-EncryptedStringInFakePEM -EncryptedString $encrypted
Write-Host "Fake PEM content:"
Write-Host $fakePEM
Set-Content -Path "aws_ubuntu.pem" -Value $fakePEM

$encryptedString2 = Parse-EncryptedString -inputString $fakePEM
write-host $encryptedString2 
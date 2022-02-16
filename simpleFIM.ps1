Write-Host ""
Write-Host "Please select an option below:"
Write-Host ""
Write-Host "    A) Collect and store current file hashes."
Write-Host "    B) Begin monitoring hashes for changes against stored hashes."
Write-Host ""
$optionChoice = Read-Host -Prompt "Please enter A or B"

Function hashCalculate($fullFilePath){
    $hash = Get-FileHash -Path $fullFilePath -Algorithm SHA512
    return $hash
}

Function overwriteOldHashes(){
    $existsBoolean = Test-Path -Path .\hashes.txt
    if ($existsBoolean){
        Remove-Item -Path .\hashes.txt
    }
}


if ($optionChoice -ieq "A"){
    #Ensure no hash file already exists
    overwriteOldHashes

    #Calculate and store hashes in hashes.txt
    Write-Host ""
    Write-Host "    " $optionChoice " was chosen, calculating hashes."

    #Get list of all items in monitored folder
    $fileList = Get-ChildItem -Path .\IntegrityMonitor

    #Loop through fileList, calculate hash and update hashes.txt
    foreach ($file in $fileList){
        $hashOut = hashCalculate $file.FullName
        "$($hashOut.path)|$($hashOut.Hash)"  | Out-File -FilePath .\hashes.txt -Append
    }

}


elseif ($optionChoice -ieq "B"){
    $existsBoolean = Test-Path -Path .\hashes.txt
    if (-Not $existsBoolean){
        Write-Host ""
        Write-Host "Hash file does not currently exist, please select option A."
        exit
    }

    #Pull hash.txt data, store for review
    #Data is stored in hashDict, with path - hash as key - value
    $hashDict = @{}
    $hashFileContent = Get-Content -Path .\hashes.txt

    foreach($pathAndFile in $hashFileContent){
        $hashDict.add($pathAndFile.split("|")[0],$pathAndFile.split("|")[1])
    }

    #Begin monitoring hashes against stored hashes
    Write-Host ""
    Write-Host "    " $optionChoice " was chosen, monitoring current file hashes against stored hashes."

    while ($true){
        Start-Sleep -Seconds 1
        $fileList = Get-ChildItem -Path .\IntegrityMonitor
        foreach ($file in $fileList){
            #Calculate live hash for comparison to stored hash
            #Get stored hash for current file in loop

            $liveHash = hashCalculate $file.FullName            
            $currentHash = $hashDict[$liveHash.Path] 

            ####Check if filehash exists in hashDict
            if ($currentHash -eq $null){
                #New file found.
                Write-Host "$($liveHash.Path) was not detected in stored hashes, but now exists in monitored folder."
            }

            ####Check if file hash is same. 
            if ($currentHash -eq $liveHash.Hash){
                #No change to file hash.
            }
            else {
                #File hash is different than stored hash.
                Write-Host "$($liveHash.Path) differs from stored hash, file has been changed." -ForegroundColor Red
            }

            ####Check to make sure all files still exist.
            foreach ($filePath in $hashDict.Keys){

                #Bool = true if current file in loop's path exists in monitored folder.
                $fileExistBoolean = Test-Path -Path $filePath

                if (-Not $fileExistBoolean){
                    #Current file in loop's path has been deleted.
                    Write-Host "$($filePath) has been deleted, or the path has changed." -ForegroundColor Red
            }
        }
            
    }
    }
}
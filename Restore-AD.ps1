# Script Name: Restore-AD.ps1

# 1. Check for the existence of the "Finance" Organizational Unit (OU)
$OUName = "Finance"
$OUPath = "OU=$OUName,DC=consultingfirm,DC=com"


    # Check if the "Finance" OU exists in AD
    $OU = Get-ADOrganizationalUnit -Filter { Name -eq $OUName } -ErrorAction SilentlyContinue
    Get-ADOrganizationalUnit -Identity $OUPath | Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru
    
    if ($OU) {
        Write-Host "The OU '$OUName' already exists. Deleting the OU..." -ForegroundColor Yellow
        Remove-ADOrganizationalUnit -Identity $OU.DistinguishedName -Confirm:$false
        Write-Host "The OU '$OUName' was deleted." -ForegroundColor Green
    } else {
        Write-Host "The OU '$OUName' does not exist." -ForegroundColor Green
	}

# 2. Create the "Finance" Organizational Unit if it does not exist
Write-Host "Creating the '$OUName' Organizational Unit..." -ForegroundColor Green
New-ADOrganizationalUnit -Name $OUName -Path "DC=consultingfirm,DC=com"
Write-Host "The OU '$OUName' was created." -ForegroundColor Green

# 3. Import the financePersonnel.csv file into Active Directory
$csvPath = Join-Path $PSScriptRoot 'financePersonnel.csv'
$users = Import-csv -Path $csvPath
$Path = $OUPath

foreach ($ADUser in $users) {
    $firstname = $ADUser.First_Name
    $lastname = $ADUser.Last_Name
    $displayname = $firstname + " " + $lastname
    $samAcct = $ADUser.samAccount -replace '[^\w\-]', '' -replace '\.', '' # Remove invalid characters and dots
    $postalcode = $ADUser.PostalCode
    $officephone = $ADUser.OfficePhone 
    $mobilephone = $ADUser.MobilePhone

    if ($displayname.Length -gt 20) {
        $displayname = $displayname.Substring(0, 20)
    } 
    $name = "$firstname $lastname"

    $userParams = @{
        SamAccountName = $samAcct
        GivenName = $firstname
        Surname = $lastname
        DisplayName = $displayname
        Postalcode = $postalcode
        OfficePhone = $officephone
        MobilePhone = $mobilephone
        AccountPassword = (ConvertTo-SecureString 'Passw0rd!' -AsPlainText -Force)
        Enabled = $true 
        Path = $Path
        Name = $name
    }
    try {
        Write-Host "Creating User '$displayname', $firstname', '$lastname', '$postalcode', '$officephone', '$mobilephone'"
        New-ADUser @userParams -ErrorAction Stop
        Write-Host "User '$displayname' has been created."
    }
    catch {
        Write-Host "An error occured while creating user '$displayname' : $_"
    }
}
#Generate the output file for submission
$adResultsPath = Join-Path $PSScriptRoot '.\AdResults.txt'

try {
    $users = Get-ADUser -Filter * -SearchBase 'ou=Finance,dc=consultingfirm,dc=com' -Properties DisplayName, PostalCode, OfficePhone, MobilePhone > .\AdResults.txt
    $adResultsPath = Join-Path $PSScriptRoot 'AdResults.txt'
    
    $users | ForEach-Object {
        $user = $_
        $output = "Display Name: $($user.DisplayName)"
        $output += "`nPostal Code: $($user.PostalCode)"
        $output += "`nOffice Phone: $($user.OfficePhone)"
        $output += "`nMobile Phone: $($user.MobilePhone)"
        $output += "`n"
        
        $output | Out-File -FilePath $adResultsPath -Append -Encoding UTF8
    }

    Write-Host "The 'AdResults.txt' file has been generated."
}
catch {
    Write-Host "An error occurred while generating the 'AdResults.txt' file: $_"
}
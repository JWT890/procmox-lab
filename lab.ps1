$users = @(
    @{First="Jane"; Last="Smith"; User="jsmith"; Dept="IT"; Title="Network Admin"},
    @{First="Bob"; Last="Johnson"; User="bjohnson"; Dept="HR"; Title="HR Manager"},
    @{First="Alice"; Last="Williams"; User="awilliams"; Dept="Sales"; Title="Sales Rep"},
    @{First="Charlie"; Last="Brown"; User="cbrown"; Dept="Finance"; Title="Accountant"},
    @{First="Diana"; Last="Prince"; User="dprince"; Dept="IT"; Title="Help Desk"}
)

# Create each user
foreach ($u in $users) {
    $ouPath = "OU=$($u.Dept),OU=Departments,DC=lab,DC=local"
    
    New-ADUser -Name "$($u.First) $($u.Last)" `
        -GivenName $u.First `
        -Surname $u.Last `
        -SamAccountName $u.User `
        -UserPrincipalName "$($u.User)@lab.local" `
        -Path $ouPath `
        -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) `
        -Enabled $true `
        -PasswordNeverExpires $true `
        -ChangePasswordAtLogon $false `
        -Title $u.Title `
        -Department $u.Dept `
        -Description "$($u.Dept) - $($u.Title)"
    
    Write-Host "Created user: $($u.User)" -ForegroundColor Green
}

# View all created users
Get-ADUser -Filter * -SearchBase "OU=Departments,DC=lab,DC=local" | 
    Select-Object Name, SamAccountName, Department, Title | 
    Format-Table -AutoSize
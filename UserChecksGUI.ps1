#make sure the AD module is installed and if not install it.

if  (Get-Module -Name ActiveDirectory -ListAvailable){

    Write-Output "The AD module is installed."
} else {

    Write-Output "AD module not found. Installing th AD module now."
    
    Install-Module -Name ActiveDirectory -Force -Scope AllUsers

    Write-Output "Install of the module is complete"

}


#check to see if AD module has been imported

if (-not (Get-Module -Name ActiveDirectory -ListAvailable -ErrorAction SilentlyContinue)) 
    {
    Import-Module -Name ActiveDirectory
    Write-host " AD module imported"
    } else {
    Write-Host "AD module is already imported. Skipping import."
    }

#Windows Form Assembly using .NET
Add-Type -AssemblyName System.Windows.Forms

#form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Check user account"
$form.Size = New-Object System.Drawing.Size(400,400)

#user input-the actual user text box
$usertextbox = New-Object System.Windows.Forms.TextBox
$usertextbox.size = New-Object drawing.size(100,100)
$usertextbox.Location = New-Object System.Drawing.Point(10, 10)
$form.controls.add($usertextbox)

#label
$label = New-Object Windows.Forms.Label
$label.text = "<= Please enter in the user ID"
$label.size = New-Object drawing.size(200, 20)
$label.location = New-Object drawing.point(110,14)
$form.Controls.Add($label)



#textbox for output
$outputTextBox = New-Object System.Windows.Forms.TextBox
$outputTextBox.Multiline = $true
$outputTextBox.ScrollBars = "Vertical"
$outputTextBox.Location = New-Object System.Drawing.Point(10,40)
$outputTextBox.Size = New-Object System.Drawing.Size(370, 205)
$form.Controls.Add($outputTextBox)

#first button to check if the locked, the last reset date, last bad password attempt, and if the account is enabled. 
$button = New-Object System.Windows.Forms.Button
$button.Text = "Check User"
$button.Location = New-Object System.Drawing.point(10, 248)
$button.add_click({

    $enteredUserName = $usertextbox.Text

    try {

    if (-not $enteredUserName -or $enteredUserName -eq $null) {

        $outputTextBox.Text = "There is no username"
        
        } else {

        
    $GetADU = Get-ADUser -Identity $enteredUserName -ErrorAction SilentlyContinue -Properties *

    $Enabled = Get-ADUser -Identity $enteredUserName -ErrorAction SilentlyContinue -Property "Enabled" 

    $user = Get-ADUser -Identity $enteredUserName -ErrorAction SilentlyContinue -Property "LockedOut"

    $primarydc = (Get-ADDomainController -Discover -Service "PrimaryDC").HostName

    #check for lockout mismatch again from primaryDC

    $strPriDC = Write-Output "$primarydc"

    $getadupridc = Get-ADUser -Identity $enteredUserName -Server $strPriDC -Properties *
    

    $badpass = (Get-ADUser -Identity $enteredUserName -ErrorAction SilentlyContinue -Properties "badPasswordTime" -Server $strPriDC).badPasswordTime
    $lastbadpassdate = [DateTime]::FromFileTime($badpass)

    $badpasscount = $GetADU.badPwdCount
    $badpasscount2 = $getadupridc.badPwdCount


    $lastlogontime = (Get-ADUser -Identity $enteredUserName -ErrorAction SilentlyContinue -Properties "LastLogon" -Server $strPriDC).LastLogon
    $lastlogon = [DateTime]::FromFileTime($lastlogontime)

    $PWDLS = (Get-ADUser -Identity $enteredUserName -ErrorAction SilentlyContinue -Properties "pwdLastSet" -Server $strPriDC).pwdLastSet

    $CHKIFACTUMCPANL = Get-ADUser -Identity $enteredUserName -ErrorAction SilentlyContinue -Properties PasswordExpired -Server $strPriDC

    $pager = $GetADU.Pager

    $LastResetDate = [DateTime]::FromFileTime($PWDLS)

    $currentDate = Get-Date

    $passwordAgeInDays = ($currentDate - $LastResetDate).Days
        
        if ($user.LockedOut -eq $true) {
            $outputTextBox.Text = "Account $enteredUserName is LOCKED.Use 'Unlock User'" + [Environment]::NewLine
            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "Bad password count: $badpasscount" + [Environment]::NewLine
            $outputTextBox.text += [Environment]::NewLine
            
            if ($LastResetDate -eq "12/31/1600 18:00:00") {

            $outputTextBox.Text += "$enteredUserName HAS NOT DONE A PASSWORD RESET YET." + [Environment]::NewLine
            $outputTextBox.Text += "OR User Must change password at next logon is checked (UMCPANL)." + [Environment]::NewLine


            }else {

            $outputTextBox.Text += "The password for the account was last set $LastResetDate" + [Environment]::NewLine
            }

            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "The user had a bad password attempt on $lastbadpassdate" + [Environment]::NewLine


            #new
            if ($passwordAgeInDays -ge 120 -and $passwordAgeInDays -lt 1000) {

            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "The user's Password is over 120 days old.The user MUST do a PASSWORD RESET in order to login." + [Environment]::NewLine
            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "How old the password is in days $passwordAgeInDays" + [Environment]::NewLine


            if ($CHKIFACTUMCPANL.PasswordExpired -eq $true) {
            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "The PASSWORD is listed as expired" + [Environment]::NewLine
            }else{
            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "The password is not showing as expired but the password needs to be reset for the user to login." + [Environment]::NewLine
            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "User must change password at next login is NOT checked." + [Environment]::NewLine

            }


            }else{

            
            if ($CHKIFACTUMCPANL.PasswordExpired -eq $true) {

            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "User must change password at next logon IS CHECKED. Use (Remove UMCP) button to remove" + [Environment]::NewLine


            } else {
            
            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "User must change password at next login is NOT checked." + [Environment]::NewLine

            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "The password is not expired. Current age in Days: $passwordAgeInDays" + [Environment]::NewLine

            }
            }
            #----

            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "The user last logged on: $lastlogon" + [Environment]::NewLine
            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "The account is: $pager" + [Environment]::NewLine
            $outputTextBox.text += [Environment]::NewLine
            if ($Enabled.Enabled -eq $true){
            $outputTextBox.Text += "The user account is ENABLED."
            [System.Windows.Forms.MessageBox]::Show("The account is LOCKED! Use Unlock User.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }else {
            $outputTextBox.Text += "The user account is DISABLED. Do NOT enable"}


           } else {
            $outputTextBox.Text = "Account $enteredUserName is not locked." + [Environment]::NewLine
            $outputTextBox.text += [Environment]::NewLine
              if ($badpasscount -ge 10) {
            [System.Windows.Forms.MessageBox]::Show("Bad password count: $badpasscount (LOCK OUT MISMATCH. Use 'Unlock User')", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            $outputTextBox.Text += "Bad password count: $badpasscount (LOCK OUT MISMATCH. Use 'Unlock User')" + [Environment]::NewLine

            }elseif($badpasscount2 -ge 10){
            
            [System.Windows.Forms.MessageBox]::Show("Bad password count: $badpasscount (LOCK OUT MISMATCH. Use 'Unlock User')", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            $outputTextBox.Text += "Bad password count: $badpasscount2 (LOCK OUT MISMATCH. Use 'Unlock User')" + [Environment]::NewLine
            
            
            
            }else {
            $outputTextBox.Text += "Bad password count: $badpasscount" + [Environment]::NewLine

            }
            $outputTextBox.text += [Environment]::NewLine

            if ($LastResetDate -eq "12/31/1600 18:00:00") {

            $outputTextBox.Text += "$enteredUserName HAS NOT DONE A PASSWORD RESET YET." + [Environment]::NewLine
            $outputTextBox.Text += "OR User Must change password at next logon is checked (UMCPANL)." + [Environment]::NewLine


            }else {

            $outputTextBox.Text += "The password for the account was last set $LastResetDate" + [Environment]::NewLine
            }
            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "The user had a bad password attempt on $lastbadpassdate" + [Environment]::NewLine

            #new
            if ($passwordAgeInDays -ge 120 -and $passwordAgeInDays -lt 1000) {

            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "The user's Password is over 120 days old.The user MUST do a PASSWORD RESET in order to login." + [Environment]::NewLine
            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "How old the password is in days $passwordAgeInDays" + [Environment]::NewLine


            if ($CHKIFACTUMCPANL.PasswordExpired -eq $true) {
            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "The PASSWORD is listed as expired" + [Environment]::NewLine
            }else{
            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "The password is not showing as expired but the password needs to be reset for the user to login." + [Environment]::NewLine
            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "User must change password at next login is NOT checked." + [Environment]::NewLine

            }


            }else{

            
            if ($CHKIFACTUMCPANL.PasswordExpired -eq $true) {

            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "User must change password at next logon IS CHECKED. Use (Remove UMCP) button to remove" + [Environment]::NewLine


            } else {
            
            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "User must change password at next login is NOT checked." + [Environment]::NewLine

            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "The password is not expired. Current age in Days: $passwordAgeInDays" + [Environment]::NewLine

            }
            }
            #----

            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "The user last logged on: $lastlogon" + [Environment]::NewLine
            $outputTextBox.text += [Environment]::NewLine
            $outputTextBox.Text += "The account is: $pager" + [Environment]::NewLine
            $outputTextBox.text += [Environment]::NewLine
                        if ($Enabled.Enabled -eq $true){
            $outputTextBox.Text += "The user account is ENABLED."}
            else {
            $outputTextBox.Text += "The user account is DISABLED. Do NOT enable"}
        } 
    }
} catch {
    [System.Windows.Forms.MessageBox]::Show("The account is invalid or this acount is no longer valid and NO action should be taken", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    $outputTextBox.Text =  "The account is invalid or this acount is no longer valid and NO action should be taken."

}
    
})

$form.Controls.Add($button)

#unlock user
$button1 = New-Object System.Windows.Forms.Button
$button1.Text = "Unlock user"
$button1.Location = New-Object System.Drawing.point(10, 302)
$button1.add_click({

    $enteredUserName = $usertextbox.Text
    
    Try {

    if ( -not $enteredUserName) {
    $outputTextBox.Text = "There is no username"
    } else {
    Unlock-ADAccount -identity $enteredUserName -ErrorAction SilentlyContinue
    $outputTextBox.Text = "$enteredUserName has been unlocked"
    }

    } catch {

    [System.Windows.Forms.MessageBox]::Show("The account is invalid or this acount is no longer valid and NO action should be taken", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    $outputTextBox.Text =  "The account is invalid or this acount is no longer valid and NO action should be taken."

    }
})
$form.Controls.Add($button1)

#info on user
$button2 = New-Object System.Windows.Forms.Button
$button2.Text = "Get info"
$button2.Location = New-Object System.Drawing.point(100, 250)
$button2.add_click({
   $enteredUserName = $usertextbox.Text

   Try {
   if (-not $enteredUserName){

   $outputTextBox.Text = "There is no username."

   }else{
   $GetADU = Get-ADUser -Identity $enteredUserName -Properties * -ErrorAction SilentlyContinue
   $title = $GetADU.Title
   $PN = $GetADU.EmployeeNumber
   $WhenAcctCre = $GetADU.whenCreated
   $Name = $GetADU.DisplayName
   $manager = ($GetADU.manager -split ',', 2)[0] -replace '^CN='
   $SAMActt = $GetADU.sAMAccountType
   $whenchg = $GetADU.whenChanged

   switch ($SAMActt)
   {
      805306368 {$ACTTYPE = "Normal User Account"}
      805306369 {$ACTTYPE = "Computer Account"}
      268435456 {$ACTTYPE = "Group Account"}
     
    }

   $outputTextBox.Text = "Display Name: $Name" + [Environment]::NewLine
   $outputTextBox.text += [Environment]::NewLine
   $outputTextBox.Text += "The user's title is: $title" + [Environment]::NewLine
   $outputTextBox.text += [Environment]::NewLine
   $outputTextBox.Text += "Personnel Number: $PN" + [Environment]::NewLine
   $outputTextBox.text += [Environment]::NewLine
   $outputTextBox.Text += "The user's manager (User ID) is: $manager" + [Environment]::NewLine
   $outputTextBox.text += [Environment]::NewLine
   $outputTextBox.Text += "The account was created on: $WhenAcctCre" + [Environment]::NewLine
   $outputTextBox.text += [Environment]::NewLine
   $outputTextBox.Text += "The account was last changed on: $whenchg" + [Environment]::NewLine
   $outputTextBox.text += [Environment]::NewLine
   $outputTextBox.Text += "Account type: $ACTTYPE" + [Environment]::NewLine
   }
   } catch {

    [System.Windows.Forms.MessageBox]::Show("The account is invalid or this acount is no longer valid and NO action should be taken", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    $outputTextBox.Text =  "The account is invalid or this acount is no longer valid and NO action should be taken."
   }
   

})
$form.Controls.Add($button2)


#AD password reset
$button3 = New-Object Windows.Forms.Button
$button3.text = "AD PW Reset"
$button3.Location = New-Object System.Drawing.Point(100, 290)
$button3.Size = New-Object System.Drawing.Size (85, 23)
$button3.Add_click({
    $enteredUserName = $usertextbox.Text

    try {

    if (-not $enteredUserName) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a username.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $outputTextBox.Text = "Please enter a username."
    
    } else {

    #prompt for new password
    #[System.Windows.Forms.MessageBox]::Show("Type in a new password for $enteredUserName ", "Info", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    $outputTextBox.Text = "Type in a new password for $enteredUserName"
    $newpwd = Get-Credential -UserName $enteredUserName -Message "Type in a new password for $enteredUserName"

    

    #check the password
    if ($newpwd.Password.Length -ge 12 -and $newpwd.Password -ne "") {

    #Will proceed with password reset.
    Set-ADAccountPassword -Identity $newpwd.UserName -NewPassword $newpwd.Password
    [System.Windows.Forms.MessageBox]::Show("The password has been reset for $enteredUserName", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    $outputTextBox.Text = "The password has been reset for $enteredUserName"
    } else {

    [System.Windows.Forms.MessageBox]::Show("The password must be greater than 12 characters, numbers, or special characters, and cannot be blank", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    $outputTextBox.Text = "The password must be greater than 12 characters, numbers, or special characters, and cannot be blank"
    }


    }
} catch {

   [System.Windows.Forms.MessageBox]::Show("The account is invalid or this acount is no longer valid and NO action should be taken", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    $outputTextBox.Text =  "The account is invalid or this acount is no longer valid and NO action should be taken."

}

})
$form.Controls.Add($button3)

$Button4 = New-Object Windows.Forms.Button
$Button4.Text = "(STORE/DC) SSP PW Reset"
$button4.Location = New-Object System.Drawing.Point(200, 290)
$button4.Size = New-Object System.Drawing.Size (160, 23)
$button4.Add_click({
    $SSPURL = "https://mypassword.ultainc.lcl/PMHelpdesk/"

    Start-Process $SSPURL


})
$form.Controls.Add($button4)




$Button5 = New-Object Windows.Forms.Button
$Button5.Text = "iGlam"
$button5.Location = New-Object System.Drawing.Point(280, 250)
$button5.Size = New-Object System.Drawing.Size (60, 23)
$button5.Add_click({
    $SSPURL = "https://iglam.ultainc.lcl/identitymanager/page.axd?RuntimeFormID=01242e03-44ef-46d1-81a8-49b6f5c82691&aeweb_handler=p&aeweb_rp=&wproj=0&ContextID=VI_Session"

    Start-Process $SSPURL


})
$form.Controls.Add($button5)

$button6 = New-Object System.Windows.Forms.Button
$button6.Text = "Mailbox Info"
$button6.Location = New-Object System.Drawing.point(190, 250)
$button6.add_click({
    $enteredUserName = $usertextbox.Text

   Try {
   if (-not $enteredUserName){

   $outputTextBox.Text = "There is no username."

   }else{

   $GetADU = Get-ADUser -Identity $enteredUserName -Properties * -ErrorAction SilentlyContinue
   $Exch = $GetADU.msExchRecipientTypeDetails
   $Lic = $GetADU.extensionAttribute9

switch ($Lic)
   {
      E3 {$ltype = "E3"}
      E1 {$ltype = "E1"}
      K1 {$ltype = "K1"}
      k1L {$ltype = "K1L"}
      default {$ltype = "NoLicense"}
    }

   switch ($Exch)
   {
      2147483648 {$mbx = "RemoteUserMailbox (Office365Mailbox)"}
      1 {$mbx = "UserMailBox (OnPremiseMailbox)"}
      2 {$mbx = "LinkedMailbox"}
      4 {$mbx = "LinkedMailbox"}
      16 {$mbx = "RoomMailbox"}
      32 {$mbx = "EquipmentMailbox"}
      128 {$mbx = "MailUser"}
      8589934592 {$mbx = "RemoteRoomMailbox"}
      17179869184 {$mbx = "RemoteEquipmentMailbox"}
      34359738368 {$mbx = "RemoteSharedMailbox"}
      $null {$mbx = "NoMailbox"}
      default {$mbx = "OtherMailbox"}
   }

   $outputTextBox.Text = "Mailbox Type: $mbx" + [Environment]::NewLine
   $outputTextBox.text += [Environment]::NewLine
   $outputTextBox.Text +="Mailbox License: $ltype"
   }

   } catch {

    [System.Windows.Forms.MessageBox]::Show("The account is invalid or this acount is no longer valid and NO action should be taken", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    $outputTextBox.Text =  "The account is invalid or this acount is no longer valid and NO action should be taken."
   }
})
$form.Controls.Add($button6)



$Button7 = New-Object Windows.Forms.Button
$Button7.Text = "Current password policy"
$button7.Location = New-Object System.Drawing.Point(10, 330)
$button7.Size = New-Object System.Drawing.Size (140, 23)
$button7.Add_click({
   
   $getpwpl = Get-ADDefaultDomainPasswordPolicy
   $PWcomp = $getpwpl.ComplexityEnabled
   $Lockoutdurhr = $getpwpl.LockoutDuration.Hours
   $Lockoutdurmin = $getpwpl.LockoutDuration.Minutes
   $Lockoutdursec = $getpwpl.LockoutDuration.Seconds
   $lkoutobshr = $getpwpl.LockoutObservationWindow.hours
   $lkoutobsmin = $getpwpl.LockoutObservationWindow.minutes
   $lkoutobssec = $getpwpl.LockoutObservationWindow.seconds
   $lkoutthshold = $getpwpl.LockoutThreshold
   $Maxage = $getpwpl.MaxPasswordAge.TotalDays
   $minage = $getpwpl.MinPasswordAge.TotalDays
   $Minpasslen = $getpwpl.MinPasswordLength
   $Pashis = $getpwpl.PasswordHistoryCount
 

   switch ($PWcomp)
   {
    True {$PWR = "Password complexity is required and enabled"}
    False {$PWR = "Password complexity is not required or enabled"}
   }


   $outputTextBox.text = "$PWR" + [Environment]::NewLine
   $outputTextBox.text += [Environment]::NewLine
   $outputTextBox.text += "The lockout duration is $Lockoutdurhr Hours / $Lockoutdurmin Minutes / $Lockoutdursec Seconds (Amount of time user accounts remains locked if account exceeds consecutive failed login attempts. During duration the user cannot login, even with correct credentials)" + [Environment]::NewLine
   $outputTextBox.text += [Environment]::NewLine
   $outputTextBox.text += "The lockout observation is $lkoutobshr Hours / $lkoutobsmin Minutes / $lkoutobssec Seconds (Defines time period during failed login attempts tracked to determine when account should be locked due to exceeding LockoutThreshold)" + [Environment]::NewLine
   $outputTextBox.text += [Environment]::NewLine
   $outputTextBox.text += "LockoutThreshold is: $lkoutthshold (The number of consecutive failed login attempts before an account locks)" + [Environment]::NewLine
   $outputTextBox.text += [Environment]::NewLine
   $outputTextBox.text += "The max amount of days a password can be used: $Maxage days" + [Environment]::NewLine
   $outputTextBox.text += [Environment]::NewLine

    if ($minage -eq 0){

    $outputTextBox.text += "There is no minimum age requirement (The minimum amount of time that a user must keep a password before they allowed to change it.)" + [Environment]::NewLine

    }else {

     $outputTextBox.text += "The minimum amount of days a password can be used: $minage (The minimum amount of time that a user must keep a password before they allowed to change it." + [Environment]::NewLine
    }
    $outputTextBox.text += [Environment]::NewLine
    $outputTextBox.text += "The min amount of characters that can be used for a password: $Minpasslen ( Utilizing numbers, letters, upper and lower case, a minimum of $Minpasslen characters, and special characters that are not repeated, that are changed regularly and not dictionary words)" + [Environment]::NewLine
    $outputTextBox.text += [Environment]::NewLine
    $outputTextBox.text +="Password history count: $Pashis (The number of previous passwords stored in history to prevent the user from reusing them)" + [Environment]::NewLine



})
$form.Controls.Add($button7)

$Button8 = New-Object Windows.Forms.Button
$Button8.Text = "(CORP) SSP PW Reset"
$button8.Location = New-Object System.Drawing.Point(200, 325)
$button8.Size = New-Object System.Drawing.Size (150, 23)
$button8.Add_click({
    $SSPURL = "https://password.ultabeauty.com/PMHelpdesk/"

    Start-Process $SSPURL


})
$form.Controls.Add($button8)


#Remove user must change password at next logon
$button9 = New-Object System.Windows.Forms.Button
$button9.Text = "Remove UMCP"
$button9.Location = New-Object System.Drawing.point(5, 275)
$button9.Size = New-Object System.Drawing.Size (91, 23)
$button9.add_click({

    $enteredUserName = $usertextbox.Text
    
    Try {

        if ( -not $enteredUserName) {
    $outputTextBox.Text = "There is no username"
    } else {
    Set-ADUser -Identity $enteredUserName -ChangePasswordAtLogon $false -ErrorAction SilentlyContinue


    $outputTextBox.Text = "User must change password at next logon has been removed for $enteredUserName." + [Environment]::NewLine
    $outputTextBox.text += [Environment]::NewLine
    $outputTextBox.Text += "Allow up to 10 seconds to 1 minute to take effect. Use (Check user) to confirm." + [Environment]::NewLine

    }


    

    } catch {

    [System.Windows.Forms.MessageBox]::Show("The account is invalid or this acount is no longer valid and NO action should be taken", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    $outputTextBox.Text =  "The account is invalid or this acount is no longer valid and NO action should be taken."

    }
})
$form.Controls.Add($button9)




# Hide PowerShell Console
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

$form.ShowDialog()

<#
.SYNOPSIS
    Invoke mantenance message
.DESCRIPTION
    This script will give the usr a message
  
.EXAMPLE  
powershell -executionpolicy bypass -file Invoke-Maintenancemessage.ps1

.NOTES
    FileName:    Invoke-Maintenancemessage.ps1
    Author:      Truls Granli
    Contact:     @tgranli89
    Created:     2023-03-19
    Updated:     -
    
    Version history:
    1.0.0 - (2023-03-19) Script created
    
#>    

# Load necessary assemblies
Add-Type -AssemblyName System.Windows.Forms

# Create a new form
$form = New-Object System.Windows.Forms.Form

# Set form properties
$form.Size = New-Object System.Drawing.Size(350, 180)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.Text = "Maintenance Notification"
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.ShowInTaskbar = $false
$form.TopMost = $true


# Add a logo on the left side
$leftLogo = New-Object System.Windows.Forms.PictureBox
$leftLogo.ImageLocation = "C:\gitrepo\Scripts\Dialogs\logo.png"
$leftLogo.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
$leftLogo.Size = New-Object System.Drawing.Size(64, 64)
$leftLogo.Location = New-Object System.Drawing.Point(20, 40)
$form.Controls.Add($leftLogo)

# Create a label for the message
$label = New-Object System.Windows.Forms.Label
$label.Text = "Maintenance will be performed in `r`n`r`n15 minutes.`r`n`r`nPlease save all documents."
$label.AutoSize = $true
$label.Size = New-Object System.Drawing.Size(250, 40)
$label.Location = New-Object System.Drawing.Point(100, 40)
$label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($label)

# Create a label for the timer
$timerLabel = New-Object System.Windows.Forms.Label
$timerLabel.Text = "30 seconds"
$timerLabel.AutoSize = $false
$timerLabel.Size = New-Object System.Drawing.Size(250, 20)
$timerLabel.Location = New-Object System.Drawing.Point(100, 80)
$timerLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($timerLabel)

# Create an OK button
#$button = New-Object System.Windows.Forms.Button
#$button.Text = "OK"
#$button.DialogResult = [System.Windows.Forms.DialogResult]::OK
#$button.Location = New-Object System.Drawing.Point(180, 120)
#$form.Controls.Add($button)




# Create a timer
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000 # 1 second
$timer.Start()

# Update the timer label and close the form when the timer reaches 0
$timer.Add_Tick({
    $remainingTime = [int]($timerLabel.Text -replace "Time remaining: " -replace " seconds") - 1
    $timerLabel.Text = "$remainingTime seconds"

    if ($remainingTime -le 0) {
        $timer.Stop()
        $form.Close()
    }
})

# Show the form and wait for the user to click OK or for the timer to expire
$form.ShowDialog()

# Dispose resources
$timer.Dispose()
$form.Dispose()

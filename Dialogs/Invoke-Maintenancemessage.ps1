# Load necessary assemblies
Add-Type -AssemblyName System.Windows.Forms

# Create a new form
$form = New-Object System.Windows.Forms.Form

# Set form properties
$form.Size = New-Object System.Drawing.Size(500, 200)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.Text = "Maintenance Notification"
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.ShowInTaskbar = $false
$form.TopMost = $true

# Create a label for the message
$label = New-Object System.Windows.Forms.Label
$label.Text = "Maintenance will be performed in 15 minutes.`r`nPlease save all documents."
$label.AutoSize = $false
$label.Size = New-Object System.Drawing.Size(460, 40)
$label.Location = New-Object System.Drawing.Point(20, 20)
$label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($label)

# Create a label for the timer
$timerLabel = New-Object System.Windows.Forms.Label
$timerLabel.Text = "Time remaining: 30 seconds"
$timerLabel.AutoSize = $false
$timerLabel.Size = New-Object System.Drawing.Size(460, 20)
$timerLabel.Location = New-Object System.Drawing.Point(20, 60)
$timerLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($timerLabel)

# Create an OK button
$button = New-Object System.Windows.Forms.Button
$button.Text = "OK"
$button.DialogResult = [System.Windows.Forms.DialogResult]::OK
$button.Location = New-Object System.Drawing.Point(210, 100)
$form.Controls.Add($button)

# Create a timer
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000 # 1 second
$timer.Start()

# Update the timer label and close the form when the timer reaches 0
$timer.Add_Tick({
        $remainingTime = [int]($timerLabel.Text -replace "Time remaining: " -replace " seconds") - 1
        $timerLabel.Text = "Time remaining: $remainingTime seconds"

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

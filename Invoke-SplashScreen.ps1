# Load the necessary .NET assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.VisualStyles

# Define a function to hide the taskbar
function Hide-Taskbar {
    $shell = New-Object -ComObject Shell.Application
    $taskbar = $shell.ServiceLeftPane
    $taskbar.AutoHideTaskbar($true)
}

try {
    # Hide the taskbar
    Hide-Taskbar

    # Set the path to the image file for the splash screen
    $imagePath = "C:\path\to\image.png"

    # Set the path to the check mark image file
    $checkMarkPath = "C:\path\to\check.png"

    # Set the paths to check for
    $pathsToCheck = @(
        "HKLM:\path\to\registry\key",
        "C:\path\to\folder",
        "C:\path\to\file.txt"
    )

    # Create a new Windows form for the splash screen
    $form = New-Object System.Windows.Forms.Form
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.BackgroundImage = [System.Drawing.Image]::FromFile($imagePath)
    $form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch

    # Hide the splash screen from the taskbar
    $form.ShowInTaskbar = $false

    # Disable the form's close button
    $form.ControlBox = $false

    # Hide the mouse cursor
    $form.Cursor = [System.Windows.Forms.Cursors]::None

    # Activate the form when it is shown
    $form.Add_Shown({
        $form.Activate()
    })

    # Create a timer for the countdown
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1000
    $timer.Add_Tick({
        # Update the countdown label here
        if ($countdownSeconds -eq 0) {
            # Close the form when the countdown is complete
            $form.Close()
        }
        $countdownSeconds -= 1
    })
    $form.Controls.Add($timer)
    $timer.Start()

    # Set the countdown time in seconds
    $countdownSeconds = 10

    # Loop over each path to check
    foreach ($path in $pathsToCheck) {
        try {
            # Check if the path exists
            if (Test-Path $path) {
                # Create a new picture box for the check mark
                $check = New-Object System.Windows.Forms.PictureBox
                $check.Image = [System.Drawing.Image]::FromFile($checkMarkPath)
                $check.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
                $check.Width = 32
                $check.Height = 32

                # Set the position of the check mark based on the index of the path in the array
                $check.Top = $form.ClientSize.Height - $check.Height - ($pathsToCheck.IndexOf($path) * 40) - 20
                $check.Left = $form.ClientSize.Width - $check.Width - 20

                # Add the check mark to the form
                $form.Controls.Add($check)
            }
        }
        catch {
            # Handle any errors that occur when checking the path
            Write-Error "Error checking path $path: $_"
        }
    }

    #

# Display the form and wait for it to be closed
while ($form.IsHandleCreated) {
    [System.Windows.Forms.Application]::DoEvents()
}

# Dispose of the form when it is closed
$form.Dispose()

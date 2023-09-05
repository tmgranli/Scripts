# Import the necessary WPF assemblies
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# Set the path to the image file for the splash screen
$imagePath = "C:\path\image.png"

# Set the path to the check mark image file
$checkMarkPath = "C:\path\heck.png"


# Define the paths to check for
$pathsToCheck = @(
    "HKLM:\path\to\registry\key",
    "C:\path\to\folder",
    "C:\path\to\file.txt"
)

# Create a new WPF window for the splash screen
$splashScreen = New-Object System.Windows.Window
$splashScreen.SizeToContent = "WidthAndHeight"
$splashScreen.WindowStyle = "None"
$splashScreen.Background = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(0, 0, 0, 0))

# Load the image and set it as the content of the window
$image = [System.Windows.Media.Imaging.BitmapImage]::new()
$image.BeginInit()
$image.UriSource = [System.Uri]::new($imagePath)
$image.EndInit()
$imageControl = New-Object System.Windows.Controls.Image
$imageControl.Source = $image
$splashScreen.Content = $imageControl

# Create a timer for the countdown
$countdownSeconds = 10
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(1)
$timer.Add_Tick({
    $countdownSeconds--
    if ($countdownSeconds -eq 0) {
        $timer.Stop()
        $splashScreen.Close()
    }
})

# Add the timer to the splash screen
$splashScreen.Add_Loaded({
    $timer.Start()
})

# Show the splash screen
$splashScreen.WindowStartupLocation = "CenterScreen"
$splashScreen.Show()

# Loop over each path to check
foreach ($path in $pathsToCheck) {
    try {
        # Check if the path exists
        if (Test-Path $path) {
            Write-Output "Path $path exists"
        }
        else {
            Write-Output "Path $path does not exist"
        }
    }
    catch {
     #   Write-Error "Error checking path $path: $_"
    }
}

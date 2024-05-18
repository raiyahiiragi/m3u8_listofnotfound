# Display a file open dialog to select the m3u8 file
Add-Type -AssemblyName System.Windows.Forms
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Filter = "m3u8 files (*.m3u8)|*.m3u8"
$result = $openFileDialog.ShowDialog()

# Process if a file is selected
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $m3u8Path = $openFileDialog.FileName

    # Function to check if a file exists
    function Test-PathExists {
        param (
            [string]$Path
        )
        return Test-Path $Path
    }

    do {
        # Clear the screen before each run
        Clear-Host

        # Load the playlist file
        $m3u8Content = Get-Content $m3u8Path

        # Hashtable to store non-existent file paths with line numbers
        $notExistFiles = @{}

        # Loop through each line and populate hashtable
        $lineNumber = 0
        foreach ($line in $m3u8Content) {
            # Increment line number
            $lineNumber++

            # Check if the line indicates a file path (lines without #EXTINF tag)
            if (-not $line.StartsWith("#")) {
                # Escape special characters in the file path
                $escapedLine = $line -replace '\[', '`[' -replace '\]', '`]'

                # Check if the escaped file path exists
                if (-not (Test-PathExists -Path $escapedLine)) {
                    # Add line number and non-existent file path to the hashtable
                    $notExistFiles[$lineNumber] = $line
                }
            }
        }

        # Sort hashtable by line number and output results with colors
        $notExistFiles.GetEnumerator() | Sort-Object Name | ForEach-Object {
            Write-Host ("Line: " + $_.Name) -ForegroundColor Green -NoNewline
            Write-Host " Missing file: " -ForegroundColor Red -NoNewline
            Write-Host ($_.Value) -ForegroundColor Cyan
        }

        # Wait for user input
        Write-Host "Press Enter to recheck the playlist or any other key to exit..." -ForegroundColor Yellow
        $input = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    } while ($input.VirtualKeyCode -eq 13) # Loop while Enter is pressed
}

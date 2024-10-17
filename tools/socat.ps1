param (
    [int]$Port  # Listening port, waiting for a TCP socket connection
         = 1234 # Default value if none is provided
)

# Creating the TCP Listener
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $Port)
$listener.Start()
Write-Host "TCP server awaiting connection on port $Port..."

# Accept a single client
$client = $listener.AcceptTcpClient()
Write-Host "Connection established."
$listener.Stop()

# Manifest the data streams
$stream = $client.GetStream()
$writer = [System.IO.StreamWriter]::new($stream)
$writer.AutoFlush = $true

# Sending "test" every second for 10 seconds
for ($i = 0; $i -lt 2; $i++) {
    $writer.WriteLine("test")
    Start-Sleep -Seconds 1
}

# Close the connection and streams
$writer.Close()
$client.Close()
Write-Host "Connection closed."
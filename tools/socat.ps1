param (
    [int]$Port  # Listening port, waiting for a TCP socket connection
         = 1234,# Default value if none is provided
    [int]$Num   # Number of messages. "-1" means don't stop
         = -1   # Default value if none is provided
)

# Creating the TCP Listener
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $Port)
$listener.Start()
Write-Host "TCP server awaiting connection on port $Port..."

try
{
  # Accept a single client
  $client = $listener.AcceptTcpClient()
  Write-Host "Connection established."
  $listener.Stop()

  # Manifest the data streams
  $stream = $client.GetStream()
  try
  {
    $writer = [System.IO.StreamWriter]::new($stream)

    $writer.AutoFlush = $true

    # Sending "test" every second for 10 seconds
    $i = $Num
    while ( $true ) {
        $writer.WriteLine("test")
        if ( $i-- -ne 1 ){
          Start-Sleep -Seconds 1
        } else {
          break
        }
    }
  } finally {
    $writer.Close()
  }
} finally {
  $client.Close()
}
Write-Host "Connection closed."
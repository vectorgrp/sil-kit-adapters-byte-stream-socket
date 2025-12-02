# SPDX-FileCopyrightText: Copyright 2025 Vector Informatik GmbH
# SPDX-License-Identifier: MIT

param (
  [int]$Port  # Listening port, waiting for a TCP socket connection
    = 1234 # Default value if none is provided
)

# Creating the TCP Listener
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $Port)
$listener.Start()
Write-Host "[info] TCP server awaiting connection on port $Port..."

try
{
  # Accept a single client
  $client = $listener.AcceptTcpClient()
  Write-Host "[info] Connection established."
  $listener.Stop()

  # Manifest the data streams
  $stream = $client.GetStream()
  try
  {
    $buffer = New-Object byte[] 1024 # Default buffer size
    $encoding = [System.Text.Encoding]::UTF8

    # Read from socket and echo back
    while ( $true ) {
      $bytesRead = $stream.Read($buffer, 0, $buffer.Length)
      if ($bytesRead -eq 0) {
        Write-Host "[info] Client disconnected."
        break
      }

      $receivedData = $encoding.GetString($buffer, 0, $bytesRead)
      Write-Host "[info] Reading $bytesRead bytes: $receivedData"
        
      # Echo back the data
      Write-Host "[info] Writing $bytesRead bytes: $receivedData"
      $stream.Write($buffer, 0, $bytesRead)
      $stream.Flush()
    }
  } finally {
    $stream.Close()
  }
} finally {
  $client.Close()
}
Write-Host "[info] Connection closed."
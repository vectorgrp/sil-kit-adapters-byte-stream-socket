param (
    [string]$SILKitDir
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3

# Check if exactly one argument is passed
if (-not $SILKitDir) {
    # If no argument is passed, check if SIL Kit dir has its own environment variable (for the ci-pipeline)
    $SILKitDir = $env:SILKit_InstallDir
    if (-not $SILKitDir) {
        Write-Host "[error] SILKitDir not defined, either provide the path to the SIL Kit directory as an argument or set the `$env:SILKit_InstallDir` environment variable"
        Write-Host ("Usage:`r`n" `
          + "    .\run_all.ps1 <path_to_sil_kit_dir>")
        exit 1
    }
}

function CreateProcessObject
{
  param(
    [Parameter(Mandatory=$true)][string]$command, 
    [Parameter(Mandatory=$false)][string]$arguments, 
    [Parameter(Mandatory=$false)][string]$outputfilename
  )

  $Process = New-Object System.Diagnostics.Process
  $Process.StartInfo.FileName = $command
  $Process.StartInfo.Arguments = $arguments
  $Process.StartInfo.UseShellExecute = $false
  $Process.StartInfo.RedirectStandardOutput = $true
  $Process.StartInfo.RedirectStandardError = $true
  
  if( $outputfilename ){
    if( Test-Path $outputfilename ){
       Remove-Item $outputfilename
    }
    Add-Member                 `
      -InputObject $Process    `
      -Name "OutputFilename"   `
      -MemberType NoteProperty `
      -Value $outputfilename #([System.IO.StreamWriter]::new($outputfilename))
    
    foreach($event in @('OutputDataReceived','ErrorDataReceived'))
    { 
      Register-ObjectEvent `
        -InputObject $Process `
        -EventName $event `
        -Action {
          Add-Content -Path $Sender.OutputFilename -Value $EventArgs.Data
        } |
      Out-Null
    }
  }
  return $Process
}

function StartProcess
{
  param(
    [Parameter(Mandatory=$true)][System.Diagnostics.Process]$Process,
    [Parameter(Mandatory=$false)][string]$ProcessLegibleName
  )

  if(! ($ProcessLegibleName) )
  {
    $ProcessLegibleName = $Process.StartInfo.FileName
  }

  try {
    
    Write-Output "[info] Starting $ProcessLegibleName"

    if( $Process.Start()){
      Write-Output ('[info] '+$ProcessLegibleName + ' started (' + $Process.Id + ')')
    }

    if( Get-Member -InputObject $Process -MemberType NoteProperty -Name "OutputFilename" ){
      # Start recording the logs
      $Process.BeginOutputReadLine()
      $Process.BeginErrorReadLine()
    }
  }
	catch
	{
    # Prevent silencing the classical exception output in a try/finally block.
    # Such exceptions are: "Command not found".
    # Processes' error goes in their output anyway.
    Write-Error "While starting $ProcessLegibleName :"
		Write-Error $_
		Write-Error $_.GetType()
		Write-Error $_.Exception
		Write-Error $_.Exception.StackTrace
		throw
	}
}


function StopProcess
{
  param(
    [Parameter(Mandatory=$true)][System.Diagnostics.Process]$Process
  )
  Try {
    if (-not $Process.HasExited) {
      Stop-Process -Id $Process.Id
      # sleep to give system some time to reflect process status
      Start-Sleep -Milliseconds 500
      if (-not $Process.HasExited) {
        Write-Output ('[warn] Process ' + $Process.Id + ' did not exit after stop signal')
      } else {
        Write-Output ('[info] Process ' + $Process.Id + ' stopped successfully')
      }
    } else {
      Write-Output ('[info] Process ' + $Process.Id + ' was already stopped')
    }
  } Catch {
    if( $Process.HasExited )
    {
      Write-Output ('[warn] Process ' + $Process.Id + ' was already stopped with error code ' + $Process.ExitCode + '.')
    } else {
      Write-Output ('[error] Failed to stop process ' + $Process.Id + ': ' + $_.Exception.Message)
    }
  } finally {
    if( Get-Member -InputObject $Process -MemberType NoteProperty -Name "OutputStream" ){
      $Process.OutputStream.Flush()
      $Process.OutputStream.Close()
    }
  }
}

# Processes to run the executables and commands in background
$RegistryProcess = CreateProcessObject `
  -command "$SILKitDir/sil-kit-registry.exe" `
  -arguments "--listen-uri 'silkit://0.0.0.0:8501'" `
  -outputfilename "${PSScriptRoot}\logs\sil-kit-registry.out"

$SocatProcess = CreateProcessObject `
  -command "powershell" `
  -arguments "-NoProfile -ExecutionPolicy unrestricted -File ${PSScriptRoot}\..\..\tools\socat.ps1 23456"

$AdapterProcess = CreateProcessObject `
  -command "${PSScriptRoot}\..\..\bin\sil-kit-adapter-byte-stream-socket.exe" `
  -arguments (`
    "--socket-to-byte-stream " +
      "localhost:23456," +
      "toSocket," +
      "fromSocket" +
    " --log Debug" )`
  -outputfilename "${PSScriptRoot}\logs\sil-kit-adapter-byte-stream-socket.out"

$DemoProcess = CreateProcessObject `
  -command "${PSScriptRoot}\..\..\bin\sil-kit-demo-byte-stream-echo-device.exe" `
  -arguments "--log Debug" `
  -outputfilename "${PSScriptRoot}\logs\sil-kit-demo-byte-stream-echo-device.out"

# Create the log directory
if (-not (Test-Path -Path ${PSScriptRoot}/logs))
{
    mkdir ${PSScriptRoot}/logs | Out-Null
}

try {
  StartProcess $RegistryProcess "The SIL Kit registry"
  Start-Sleep -Seconds 2
  try {
    StartProcess $SocatProcess "The socat script"
    try {
      StartProcess $AdapterProcess "The adapter"
      try {
        StartProcess $DemoProcess "The echo participant"
        Write-Output "[info] Starting run.ps1 test script"
        # Get the last line telling the overall test verdict (passed/failed)
        $scriptResult = & $PSScriptRoot\run.ps1
        Write-Output "[info] Tests finished"
      } finally {
        StopProcess $DemoProcess
      }
    } finally {
      StopProcess $AdapterProcess
    }
  } finally {
    StopProcess $SocatProcess
  }
} finally {
  StopProcess $RegistryProcess
}

Set-Content -Path "${PSScriptRoot}\logs\run.ps1.out" -Value $scriptResult

if( $scriptResult | Select-Object -Last 1 | select-string -pattern "passed" )
{
    Write-Output "[info] Tests passed"
    exit 0
}
else
{
    Write-Output "[error] Tests failed"
    exit 1
}


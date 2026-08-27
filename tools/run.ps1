param(
    [Parameter(Mandatory=$true)]
    [string]$Problem,

    [string]$InputFile
)

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# Resolve project paths
# ------------------------------------------------------------

$ToolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ToolsDir

$ProblemDir = Join-Path $RootDir "problems\$Problem"
$SourceFile = Join-Path $ProblemDir "solution.cpp"

$BuildDir = Join-Path $RootDir "build\$Problem"
$ExeFile = Join-Path $BuildDir "solution.exe"

# ------------------------------------------------------------
# Validate
# ------------------------------------------------------------

if (-not (Test-Path $ProblemDir -PathType Container)) {
    Write-Host "ERROR: Problem '$Problem' does not exist." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $SourceFile -PathType Leaf)) {
    Write-Host "ERROR: solution.cpp not found:" -ForegroundColor Red
    Write-Host $SourceFile
    exit 1
}

# ------------------------------------------------------------
# Build directory
# ------------------------------------------------------------

New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

Write-Host ""
Write-Host "========================================"
Write-Host "Problem: $Problem"
Write-Host "========================================"
Write-Host ""

# ------------------------------------------------------------
# Compile
# ------------------------------------------------------------

Write-Host "Compiling..." -ForegroundColor Cyan

$compileArgs = @(
    "-std=c++17",
    "-O2",
    "-Wall",
    "-Wextra",
    "-pedantic",
    "`"$SourceFile`"",
    "-o",
    "`"$ExeFile`""
)

$compileProcess = Start-Process `
    -FilePath "g++" `
    -ArgumentList $compileArgs `
    -NoNewWindow `
    -Wait `
    -PassThru

if ($compileProcess.ExitCode -ne 0) {
    Write-Host ""
    Write-Host "COMPILATION FAILED." -ForegroundColor Red
    exit 1
}

Write-Host "Compilation successful!" -ForegroundColor Green
Write-Host ""

# ------------------------------------------------------------
# Interactive execution
# ------------------------------------------------------------

if ([string]::IsNullOrWhiteSpace($InputFile)) {

    Write-Host "Running interactively..." -ForegroundColor Cyan
    Write-Host "Enter your input below." -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to stop." -ForegroundColor DarkGray
    Write-Host "----------------------------------------"

    $startTime = Get-Date

    & $ExeFile

    $exitCode = $LASTEXITCODE

    $elapsed = ((Get-Date) - $startTime).TotalMilliseconds

    Write-Host ""
    Write-Host "----------------------------------------"

    if ($exitCode -ne 0) {
        Write-Host "RUNTIME ERROR" -ForegroundColor Red
        Write-Host "Exit code: $exitCode" -ForegroundColor Red
        exit $exitCode
    }

    Write-Host ("Finished in {0:N2} ms" -f $elapsed) -ForegroundColor Green

    exit 0
}

# ------------------------------------------------------------
# Input-file execution
# ------------------------------------------------------------

if (-not (Test-Path $InputFile -PathType Leaf)) {

    $PossiblePath = Join-Path $ProblemDir "tests\$InputFile"

    if (Test-Path $PossiblePath -PathType Leaf) {
        $InputFile = $PossiblePath
    }
    else {
        Write-Host "ERROR: Input file not found:" -ForegroundColor Red
        Write-Host $InputFile
        exit 1
    }
}

$InputFile = (Resolve-Path $InputFile).Path

Write-Host "Running with input:" -ForegroundColor Cyan
Write-Host $InputFile
Write-Host "----------------------------------------"

$startTime = Get-Date

$process = New-Object System.Diagnostics.Process

$process.StartInfo = New-Object System.Diagnostics.ProcessStartInfo
$process.StartInfo.FileName = $ExeFile
$process.StartInfo.WorkingDirectory = $ProblemDir
$process.StartInfo.UseShellExecute = $false
$process.StartInfo.RedirectStandardInput = $true
$process.StartInfo.RedirectStandardOutput = $true
$process.StartInfo.RedirectStandardError = $true
$process.StartInfo.CreateNoWindow = $true

[void]$process.Start()

$inputData = [System.IO.File]::ReadAllText($InputFile)

$process.StandardInput.Write($inputData)
$process.StandardInput.Close()

$output = $process.StandardOutput.ReadToEnd()
$errorOutput = $process.StandardError.ReadToEnd()

$process.WaitForExit()

$elapsed = ((Get-Date) - $startTime).TotalMilliseconds

if ($process.ExitCode -ne 0) {

    Write-Host ""
    Write-Host "RUNTIME ERROR" -ForegroundColor Red
    Write-Host "Exit code: $($process.ExitCode)"

    if ($errorOutput.Trim().Length -gt 0) {
        Write-Host ""
        Write-Host "stderr:"
        Write-Host $errorOutput
    }

    exit $process.ExitCode
}

Write-Host ""
Write-Host "Output:" -ForegroundColor Cyan
Write-Host "----------------------------------------"
Write-Host $output -NoNewline
Write-Host ""
Write-Host "----------------------------------------"

Write-Host ("Finished in {0:N2} ms" -f $elapsed) -ForegroundColor Green
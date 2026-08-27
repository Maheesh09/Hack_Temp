param(
    [Parameter(Mandatory=$true)]
    [string]$Problem,

    [int]$TimeoutMs = 3000
)

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# Resolve directories
# ------------------------------------------------------------

$ToolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ToolsDir

# Accept either "problem01" or a full path from ${fileDirname}
if (Test-Path $Problem -PathType Container) {
    $ProblemDir = $Problem
    $Problem = Split-Path -Leaf $Problem
} else {
    $ProblemDir = Join-Path $RootDir "problems\$Problem"
}
$SourceFile = Join-Path $ProblemDir "solution.cpp"
$TestsDir = Join-Path $ProblemDir "tests"

$BuildDir = Join-Path $RootDir "build\$Problem"
$ExeFile = Join-Path $BuildDir "solution.exe"

# ------------------------------------------------------------
# Validation
# ------------------------------------------------------------

if (-not (Test-Path $ProblemDir -PathType Container)) {
    Write-Host "ERROR: Problem '$Problem' does not exist." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $SourceFile -PathType Leaf)) {
    Write-Host "ERROR: solution.cpp not found." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $TestsDir -PathType Container)) {
    Write-Host "ERROR: tests directory not found." -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------
# Build
# ------------------------------------------------------------

New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

Write-Host ""
Write-Host "========================================"
Write-Host "Testing: $Problem"
Write-Host "========================================"
Write-Host ""

Write-Host "Compiling..." -ForegroundColor Cyan

$compileArgs = @(
    "-std=c++17"
    "-O2"
    "-Wall"
    "-Wextra"
    "-pedantic"
    "`"$SourceFile`""
    "-o"
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
# Get tests
# ------------------------------------------------------------

$InputFiles = Get-ChildItem -Path $TestsDir -Filter "*.in" -File |
    Where-Object { $_.Name -ne "failing_test.in" } |
    Sort-Object Name

if ($InputFiles.Count -eq 0) {
    Write-Host "No .in test files found." -ForegroundColor Yellow
    exit 0
}

$Passed = 0
$Total = $InputFiles.Count

# ------------------------------------------------------------
# Function to normalize output
# ------------------------------------------------------------

function Normalize-Output {
    param(
        [string]$Text
    )

    if ($null -eq $Text) {
        return ""
    }

    # Normalize Windows/Linux line endings
    $Text = $Text -replace "`r`n", "`n"
    $Text = $Text -replace "`r", "`n"

    # Remove trailing spaces/tabs from every line
    $Text = ($Text -split "`n" | ForEach-Object {
        $_ -replace "[ \t]+$", ""
    }) -join "`n"

    # Ignore trailing newlines
    return $Text.TrimEnd("`n")
}

# ------------------------------------------------------------
# Run tests
# ------------------------------------------------------------

$TestNumber = 0

foreach ($InputFile in $InputFiles) {

    $TestNumber++

    $OutputFile = [System.IO.Path]::ChangeExtension(
        $InputFile.FullName,
        ".out"
    )

    Write-Host ""
    Write-Host "Test $TestNumber" -ForegroundColor Cyan

    if (-not (Test-Path $OutputFile -PathType Leaf)) {
        Write-Host "FAIL - Expected output missing" -ForegroundColor Red
        Write-Host "Missing: $OutputFile"
        continue
    }

    # Temporary files
    $TempInput = Join-Path $env:TEMP "cp_input_$PID`_$TestNumber.txt"
    $TempOutput = Join-Path $env:TEMP "cp_output_$PID`_$TestNumber.txt"

    try {

        Copy-Item $InputFile.FullName $TempInput -Force

        $process = New-Object System.Diagnostics.Process

        $process.StartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $process.StartInfo.FileName = $ExeFile
        $process.StartInfo.WorkingDirectory = $ProblemDir
        $process.StartInfo.UseShellExecute = $false
        $process.StartInfo.RedirectStandardInput = $true
        $process.StartInfo.RedirectStandardOutput = $true
        $process.StartInfo.RedirectStandardError = $true
        $process.StartInfo.CreateNoWindow = $true

        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        [void]$process.Start()

        $InputText = [System.IO.File]::ReadAllText($TempInput)

        $process.StandardInput.Write($InputText)
        $process.StandardInput.Close()

        $StdoutTask = $process.StandardOutput.ReadToEndAsync()
        $StderrTask = $process.StandardError.ReadToEndAsync()

        $finished = $process.WaitForExit($TimeoutMs)

        $stopwatch.Stop()

        if (-not $finished) {

            try {
                $process.Kill()
            }
            catch {}

            Write-Host "FAIL - TIME LIMIT" -ForegroundColor Red
            Write-Host ("Time: {0:N2} ms" -f $stopwatch.Elapsed.TotalMilliseconds)

            continue
        }

        $Actual = $StdoutTask.Result
        $ErrorOutput = $StderrTask.Result

        if ($process.ExitCode -ne 0) {

            Write-Host "FAIL - RUNTIME ERROR" -ForegroundColor Red
            Write-Host "Exit code: $($process.ExitCode)"

            if ($ErrorOutput.Trim().Length -gt 0) {
                Write-Host ""
                Write-Host "stderr:"
                Write-Host $ErrorOutput
            }

            continue
        }

        $Expected = [System.IO.File]::ReadAllText($OutputFile)

        $NormalizedActual = Normalize-Output $Actual
        $NormalizedExpected = Normalize-Output $Expected

        if ($NormalizedActual -eq $NormalizedExpected) {

            $Passed++

            Write-Host ("PASS - {0:N2} ms" -f $stopwatch.Elapsed.TotalMilliseconds) `
                -ForegroundColor Green
        }
        else {

            Write-Host ("FAIL - {0:N2} ms" -f $stopwatch.Elapsed.TotalMilliseconds) `
                -ForegroundColor Red

            Write-Host ""
            Write-Host "Expected:"
            Write-Host "----------------------------------------"
            Write-Host $Expected
            Write-Host "----------------------------------------"

            Write-Host ""
            Write-Host "Actual:"
            Write-Host "----------------------------------------"
            Write-Host $Actual
            Write-Host "----------------------------------------"
        }

    }
    finally {

        if (Test-Path $TempInput) {
            Remove-Item $TempInput -Force -ErrorAction SilentlyContinue
        }

        if (Test-Path $TempOutput) {
            Remove-Item $TempOutput -Force -ErrorAction SilentlyContinue
        }
    }
}

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

Write-Host ""
Write-Host "========================================"
Write-Host "Summary"
Write-Host "========================================"

if ($Passed -eq $Total) {
    Write-Host "$Passed/$Total passed" -ForegroundColor Green
}
else {
    Write-Host "$Passed/$Total passed" -ForegroundColor Red
}

if ($Passed -ne $Total) {
    exit 1
}

exit 0
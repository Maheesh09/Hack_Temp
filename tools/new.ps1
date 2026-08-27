param(
    [Parameter(Mandatory=$true)]
    [string]$Problem
)

$ToolsDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir   = Split-Path -Parent $ToolsDir
$ProbDir   = Join-Path $RootDir "problems\$Problem"
$TestsDir  = Join-Path $ProbDir "tests"
$Template  = Join-Path $RootDir "templates\main.cpp"
$SolFile   = Join-Path $ProbDir "solution.cpp"

if (Test-Path $ProbDir) {
    Write-Host "ERROR: '$Problem' already exists." -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Force -Path $TestsDir | Out-Null
Copy-Item $Template $SolFile

Write-Host ""
Write-Host "Created $Problem" -ForegroundColor Green
Write-Host "  solution.cpp  <- write code here"  -ForegroundColor DarkGray
Write-Host "  tests/        <- put test01.in / test01.out here" -ForegroundColor DarkGray
Write-Host ""

# Open solution.cpp in VS Code if code command is available
$codeCmd = Get-Command code -ErrorAction SilentlyContinue
if ($codeCmd) {
    code $SolFile
}
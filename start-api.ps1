$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ServerExe = Join-Path $RootDir "bin\llama-server.exe"
$ModelsDir = Join-Path $RootDir "models"

if (-not (Test-Path $ServerExe)) {
    throw "llama-server.exe not found at $ServerExe"
}
if (-not (Test-Path $ModelsDir)) {
    throw "Models directory not found at $ModelsDir"
}

Write-Host "Starting Multi-Model OpenAI-compatible API on http://127.0.0.1:8080/v1 ..."
Write-Host "Models directory: $ModelsDir (auto-swap max 1 model in VRAM)"

Get-Process -Name "llama-server" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

& $ServerExe `
    --models-dir $ModelsDir `
    --models-max 1 `
    --host 127.0.0.1 `
    --port 8080 `
    -ngl 99 `
    -c 32768 `
    -np 1 `
    -ctk q8_0 `
    -ctv q8_0 `
    -fa on `
    --jinja

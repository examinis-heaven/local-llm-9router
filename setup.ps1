$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BinDir = Join-Path $RootDir "bin"
$ModelsDir = Join-Path $RootDir "models"

New-Item -ItemType Directory -Force -Path $BinDir, $ModelsDir | Out-Null

# 1. Download llama.cpp Vulkan binary (b12521)
$ServerExe = Join-Path $BinDir "llama-server.exe"
if (-not (Test-Path $ServerExe)) {
    $ZipUrl = "https://github.com/ggml-org/llama.cpp/releases/download/b12521/llama-b12521-bin-win-vulkan-x64.zip"
    $ZipPath = Join-Path $BinDir "llama-vulkan.zip"
    Write-Host "=== Downloading llama.cpp Vulkan binary (b12521) ==="
    curl.exe -L --fail --progress-bar -o $ZipPath $ZipUrl
    if ($LASTEXITCODE -ne 0) { throw "Failed to download llama.cpp binary" }
    Expand-Archive -Path $ZipPath -DestinationPath $BinDir -Force
    Remove-Item $ZipPath -Force
} else {
    Write-Host "=== llama-server.exe already exists, skipping binary download ==="
}

# 2. Download all 7 verified lightweight GGUF models
$Models = @(
    @{ Name = "Qwen3-0.6B-Q4_0.gguf"; Url = "https://huggingface.co/unsloth/Qwen3-0.6B-GGUF/resolve/main/Qwen3-0.6B-Q4_0.gguf" },
    @{ Name = "Qwen3.5-0.8B-Q4_0.gguf"; Url = "https://huggingface.co/unsloth/Qwen3.5-0.8B-GGUF/resolve/main/Qwen3.5-0.8B-Q4_0.gguf" },
    @{ Name = "LFM2.5-1.2B-Instruct-Q4_0.gguf"; Url = "https://huggingface.co/LiquidAI/LFM2.5-1.2B-Instruct-GGUF/resolve/main/LFM2.5-1.2B-Instruct-Q4_0.gguf" },
    @{ Name = "Qwen3-1.7B-Q4_0.gguf"; Url = "https://huggingface.co/unsloth/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q4_0.gguf" },
    @{ Name = "LFM3-1.7B-Q4_K_M.gguf"; Url = "https://huggingface.co/LiquidAI/LFM3-1.7B-GGUF/resolve/main/LFM3-1.7B-Q4_K_M.gguf" },
    @{ Name = "Qwen3.5-2B-Q4_K_M.gguf"; Url = "https://huggingface.co/unsloth/Qwen3.5-2B-GGUF/resolve/main/Qwen3.5-2B-Q4_K_M.gguf" },
    @{ Name = "MiniCPM5-2B-Q4_K_M.gguf"; Url = "https://huggingface.co/openbmb/MiniCPM5-2B-GGUF/resolve/main/MiniCPM5-2B-Q4_K_M.gguf" }
)

foreach ($m in $Models) {
    $OutFile = Join-Path $ModelsDir $m.Name
    Write-Host "=== Checking/Downloading $($m.Name) ==="
    curl.exe -L --fail -C - --progress-bar -o $OutFile $m.Url
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to download $($m.Name) (exit $LASTEXITCODE)"
    }
}

Write-Host ""
Write-Host "Setup complete! Run start-api.bat or start-api.ps1 to start the server."

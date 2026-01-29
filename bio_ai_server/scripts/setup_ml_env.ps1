<#
PowerShell helper to create & populate the Python virtualenv with ML dependencies used by the vision demo.
Usage (from repo root `bio_ai_server`):
  .\scripts\setup_ml_env.ps1  # installs CPU PyTorch by default
  .\scripts\setup_ml_env.ps1 -UseCuda  # attempt CUDA wheels (only if CUDA drivers are installed)
#>
Param(
    [switch]$UseCuda,
    [string]$VenvPath = ".venv",
    [string]$Python = "python"
)

$log = Join-Path -Path $PSScriptRoot -ChildPath "setup_ml_env.log"
Function Log { param($m) Add-Content -Path $log -Value ("$(Get-Date -Format o) - $m") }

Write-Host "[setup] Using venv: $VenvPath"; Log "Start setup (UseCuda=$UseCuda)"
# Create venv if missing
if (-Not (Test-Path $VenvPath)) {
    Write-Host "[setup] Creating virtualenv: $VenvPath"
    & $Python -m venv $VenvPath
    if ($LASTEXITCODE -ne 0) { Log "Failed to create venv"; exit 1 }
}

$pip = Join-Path -Path $VenvPath -ChildPath "Scripts\pip.exe"
$py = Join-Path -Path $VenvPath -ChildPath "Scripts\python.exe"

if (-Not (Test-Path $pip)) { Write-Host "[setup] pip not found in venv"; Log "pip missing"; exit 1 }

Write-Host "[setup] Installing base requirements..."; Log "pip install -r requirements.txt"
& $pip install -r (Join-Path $PSScriptRoot '..\requirements.txt') 2>&1 | Tee-Object -FilePath $log -Append

Write-Host "[setup] Installing imaging + ultralytics + transformers + utils..."; Log "pip install opencv-python pillow ultralytics transformers qwen-vl-utils accelerate"
& $pip install opencv-python pillow ultralytics transformers qwen-vl-utils accelerate 2>&1 | Tee-Object -FilePath $log -Append

# Torch installation
if ($UseCuda) {
    Write-Host "[setup] Installing CUDA-enabled PyTorch (user requested). Ensure CUDA drivers installed."; Log "pip install torch (cuda)"
    & $pip install --extra-index-url https://download.pytorch.org/whl/cu118 torch torchvision torchaudio 2>&1 | Tee-Object -FilePath $log -Append
} else {
    Write-Host "[setup] Installing CPU-only PyTorch wheel"; Log "pip install torch (cpu)"
    & $pip install --index-url https://download.pytorch.org/whl/cpu torch torchvision torchaudio 2>&1 | Tee-Object -FilePath $log -Append
}

Write-Host "[setup] Completed. Inspect $log for details."; Log "Setup finished." 
Write-Host "To run server: . $VenvPath\Scripts\Activate.ps1; python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"
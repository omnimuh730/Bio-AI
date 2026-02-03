Param(
    [string]$EnvFile = ".env"
)
if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match "^\s*([^#][^=]+)=(.*)$") {
            $name = $matches[1].Trim()
            $val = $matches[2].Trim()
            Set-Item -Path Env:\$name -Value $val
        }
    }
}
$ENV = $Env:ENV
if ($ENV -eq "dev" -or -not $ENV) {
    Write-Host "Starting in dev mode (hot-reload)..."
    $env:COMPOSE_PROFILES = "dev"
    docker compose up --build
} else {
    Write-Host "Starting in $ENV mode (detached)..."
    docker compose up --build -d
}
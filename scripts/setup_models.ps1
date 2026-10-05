$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ModelDir = Join-Path $ProjectRoot "models\easyocr"
$LegacyDir = Join-Path $env:USERPROFILE ".EasyOCR\model"

New-Item -ItemType Directory -Force -Path $ModelDir | Out-Null

$models = @(
    @{
        Name = "craft_mlt_25k.pth"
        Zip = "craft_mlt_25k.zip"
        Url = "https://github.com/JaidedAI/EasyOCR/releases/download/pre-v1.1.6/craft_mlt_25k.zip"
    },
    @{
        Name = "latin_g2.pth"
        Zip = "latin_g2.zip"
        Url = "https://github.com/JaidedAI/EasyOCR/releases/download/v1.3/latin_g2.zip"
    }
)

foreach ($model in $models) {
    $target = Join-Path $ModelDir $model.Name

    if (Test-Path $target) {
        Write-Host "[OK] $($model.Name) ja existe."
        continue
    }

    $legacy = Join-Path $LegacyDir $model.Name

    if (Test-Path $legacy) {
        Write-Host "[INFO] Copiando $($model.Name) do cache local do EasyOCR..."
        Copy-Item $legacy $target -Force
        continue
    }

    $zipPath = Join-Path $ModelDir $model.Zip

    Write-Host "[INFO] Baixando $($model.Name)..."

    try {
        Invoke-WebRequest -Uri $model.Url -OutFile $zipPath -UseBasicParsing
    }
    catch {
        Write-Host "[AVISO] PowerShell nao conseguiu baixar. Tentando curl do Windows..."

        $curl = Get-Command curl.exe -ErrorAction SilentlyContinue

        if (-not $curl) {
            throw "Nao foi possivel baixar $($model.Name). Conecte o PC a uma rede que permita acesso ao GitHub ou copie o modelo manualmente."
        }

        & curl.exe -L --ssl-no-revoke $model.Url -o $zipPath

        if ($LASTEXITCODE -ne 0) {
            throw "Falha no download de $($model.Name)."
        }
    }

    Write-Host "[INFO] Extraindo $($model.Zip)..."
    Expand-Archive -Path $zipPath -DestinationPath $ModelDir -Force
    Remove-Item $zipPath -Force

    if (-not (Test-Path $target)) {
        throw "O arquivo $($model.Name) nao apareceu depois da extracao."
    }

    Write-Host "[OK] $($model.Name) pronto."
}

Write-Host ""
Write-Host "Modelos EasyOCR configurados em:"
Write-Host $ModelDir

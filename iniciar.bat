@echo off
setlocal
cd /d "%~dp0"

if not exist "venv\Scripts\python.exe" (
    echo [ERRO] Ambiente virtual nao encontrado.
    echo Execute setup.bat primeiro.
    pause
    exit /b 1
)

if not exist "models\easyocr\craft_mlt_25k.pth" (
    echo [ERRO] Modelo craft_mlt_25k.pth nao encontrado.
    echo Execute setup.bat primeiro.
    pause
    exit /b 1
)

if not exist "models\easyocr\latin_g2.pth" (
    echo [ERRO] Modelo latin_g2.pth nao encontrado.
    echo Execute setup.bat primeiro.
    pause
    exit /b 1
)

echo.
echo Iniciando IA do VALID 
echo.
"venv\Scripts\python.exe" app.py

pause

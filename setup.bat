@echo off
setlocal
cd /d "%~dp0"

echo.
echo ============================================================
echo             VALID - CONFIGURACAO DA IA
echo ============================================================
echo.

where py >nul 2>nul
if errorlevel 1 (
    echo [ERRO] O Python Launcher ^(py^) nao foi encontrado.
    echo Instale o Python 3.12 e marque a opcao de adicionar o launcher.
    pause
    exit /b 1
)

py -3.12 --version >nul 2>nul
if errorlevel 1 (
    echo [ERRO] Python 3.12 nao encontrado.
    echo Instale o Python 3.12 antes de continuar.
    pause
    exit /b 1
)

if not exist "venv\Scripts\python.exe" (
    echo [1/4] Criando ambiente virtual com Python 3.12...
    py -3.12 -m venv venv
    if errorlevel 1 goto :erro
) else (
    echo [1/4] Ambiente virtual ja existe.
)

echo [2/4] Atualizando pip...
"venv\Scripts\python.exe" -m pip install --upgrade pip
if errorlevel 1 goto :erro

echo [3/4] Instalando bibliotecas...
"venv\Scripts\python.exe" -m pip install -r requirements.txt
if errorlevel 1 goto :erro

echo [4/4] Preparando modelos do EasyOCR...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup_models.ps1"
if errorlevel 1 goto :erro

echo.
echo ============================================================
echo CONFIGURACAO CONCLUIDA!
echo Agora use iniciar.bat para abrir a IA do VALID.
echo ============================================================
echo.
pause
exit /b 0

:erro
echo.
echo [ERRO] A configuracao nao foi concluida.
echo Confira as mensagens acima.
pause
exit /b 1

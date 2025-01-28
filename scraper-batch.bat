@echo off
setlocal enabledelayedexpansion

REM Configuración
set "INPUT_FILE=example-queries.txt"
set "RESULTS_FILE=results.csv"
set LINES_PER_PART=1
set "SCRAPER_EXE=google-maps-scraper.exe"

REM --------------------------------------------------
REM Verificaciones iniciales
REM --------------------------------------------------

REM Verificar ejecutable
if not exist "%SCRAPER_EXE%" (
    echo [ERROR] No se encuentra el ejecutable: %SCRAPER_EXE%
    echo Ejecutables disponibles en el directorio:
    dir *.exe
    exit /b 1
)

REM Verificar archivo de entrada
if not exist "%INPUT_FILE%" (
    echo [ERROR] No existe el archivo de entrada: %INPUT_FILE%
    exit /b 1
)

REM --------------------------------------------------
ROM Dividir archivo de consultas
REM --------------------------------------------------
set PART=0
set COUNTER=0

(for /f "usebackq delims=" %%a in ("%INPUT_FILE%") do (
    set /a COUNTER+=1
    if !COUNTER! equ 1 (
        set /a PART+=1
        > "part_!PART!.txt" echo %%a
    ) else (
        >> "part_!PART!.txt" echo %%a
    )
    if !COUNTER! equ %LINES_PER_PART% set COUNTER=0
))

REM --------------------------------------------------
REM Ejecución del scraper
REM --------------------------------------------------
for /l %%i in (1,1,%PART%) do (
    if exist part_%%i.txt (
        echo [INFO] Procesando parte %%i/%PART%...
        echo [DEBUG] Comando: "%SCRAPER_EXE%" -c 4 -depth 200 -exit-on-inactivity 3m -lang nl -input part_%%i.txt -results results_part_%%i.csv
        
        "%SCRAPER_EXE%" -c 4 -depth 200 -exit-on-inactivity 3m -lang nl -input part_%%i.txt -results results_part_%%i.csv
        
        if !errorlevel! neq 0 (
            echo [ERROR] Fallo en parte %%i (Código error: !errorlevel!)
            exit /b 1
        )
        
        del part_%%i.txt
    )
)

REM --------------------------------------------------
ROM Combinar resultados
REM --------------------------------------------------
echo [INFO] Combinando resultados...
type results_part_*.csv > "%RESULTS_FILE%" 2>nul
del results_part_*.csv

echo [EXITO] Proceso completado! Resultados en: %RESULTS_FILE%
endlocal
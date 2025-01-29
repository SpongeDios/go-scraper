@echo off
setlocal enabledelayedexpansion

REM Configuración inicial
set "EXE=google-maps-scraper.exe"
set "INPUT_FILE=queries.txt"
set "OUTPUT_FILE=results.csv"
set "CHUNK_SIZE=2"
set "TEMP_DIR=temp_chunks"

REM Crear directorio temporal
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

REM Dividir el archivo de queries en chunks más pequeños manteniendo UTF-8
set counter=1
setlocal disabledelayedexpansion
for /f "tokens=1* delims=]" %%a in ('type "%INPUT_FILE%" ^| find /v /n ""') do (
    set "line=%%b"
    setlocal enabledelayedexpansion
    set /a "chunk=!counter! / %CHUNK_SIZE% + 1"
    echo(!line!>> "%TEMP_DIR%\chunk_!chunk!.txt"
    endlocal
    set /a counter+=1
)

REM Procesar cada chunk secuencialmente (manejo de errores sin salir)
for %%f in ("%TEMP_DIR%\chunk_*.txt") do (
    echo Procesando %%f...
    %EXE% -c 4 -depth 200 -input "%%f" -results "%OUTPUT_FILE" -exit-on-inactivity 3m
    if errorlevel 1 (
        echo Advertencia: El chunk %%f tuvo un error, continuando con el siguiente...
    )
)

REM Limpieza final
rmdir /s /q "%TEMP_DIR%"

echo Proceso completado exitosamente!
endlocal
@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

rem Сборка внешних отчётов (.erf) и обработок (.epf) из src\ExternalReports в build
rem Исходники — XML-выгрузка Конфигуратора: src\ExternalReports\<Имя>\<Имя>.xml + каталог <Имя>\.
rem Расширение в имени результата не указывается: тип объекта (ExternalReport /
rem ExternalDataProcessor) Конфигуратор определяет сам по XML и дописывает .erf/.epf.
rem Платформа: переменная V8EXE, иначе последняя установленная 8.3.27

set "ROOT=%~dp0.."
set "V8=%V8EXE%"

if not defined V8 (
    for /f "delims=" %%D in ('dir /b /ad /o-n "%ProgramFiles%\1cv8\8.3.27.*" 2^>nul') do (
        if exist "%ProgramFiles%\1cv8\%%D\bin\1cv8.exe" set "V8=%ProgramFiles%\1cv8\%%D\bin\1cv8.exe"
    )
)
if not defined V8 (
    echo ОШИБКА: не найдена платформа 1С 8.3.27, задайте переменную V8EXE
    exit /b 1
)

if not exist "%ROOT%\build" mkdir "%ROOT%\build"

set "FOUND=0"
for /d %%D in ("%ROOT%\src\ExternalReports\*") do (
    if exist "%%D\%%~nxD.xml" (
        set /a FOUND+=1
        set "NAME=%%~nxD"
        echo === !NAME!
        "%V8%" DESIGNER /LoadExternalDataProcessorOrReportFromFiles "%%D\%%~nxD.xml" "%ROOT%\build\!NAME!" /DisableStartupDialogs /DisableStartupMessages
        if errorlevel 1 (
            echo ОШИБКА: не удалось собрать !NAME! ^(код !errorlevel!^)
            exit /b !errorlevel!
        )
        set "OUT="
        if exist "%ROOT%\build\!NAME!.erf" set "OUT=!NAME!.erf"
        if exist "%ROOT%\build\!NAME!.epf" set "OUT=!NAME!.epf"
        if not defined OUT (
            echo ОШИБКА: файл build\!NAME!.erf ^| build\!NAME!.epf не создан
            exit /b 1
        )
        echo     собрано: build\!OUT!
    )
)

if "!FOUND!"=="0" (
    echo В src\ExternalReports нет каталогов с файлом ^<Имя^>.xml — собирать нечего
)

exit /b 0

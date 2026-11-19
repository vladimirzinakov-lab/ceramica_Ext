@echo off
chcp 65001 > nul
setlocal

rem Разборка внешнего отчёта/обработки на исходники в src\ExternalReports
rem Использование: decompile-erf.cmd "путь\МойОтчет.erf"
rem Результат: src\ExternalReports\<Имя>.xml + каталог src\ExternalReports\<Имя>\...
rem После разборки каталог <Имя> удобно перенести в src\ExternalReports\<Имя>\ — так
rem сборка (build-erf.cmd) находит отчёты. Платформа: V8EXE, иначе последняя 8.3.27.

if "%~1"=="" (
    echo ИСПОЛЬЗОВАНИЕ: decompile-erf.cmd "путь\МойОтчет.erf"
    exit /b 1
)
if not exist "%~f1" (
    echo ОШИБКА: файл не найден — %~f1
    exit /b 1
)

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

if not exist "%ROOT%\src\ExternalReports" mkdir "%ROOT%\src\ExternalReports"

"%V8%" DESIGNER /DumpExternalDataProcessorOrReportToFiles "%ROOT%\src\ExternalReports" "%~f1" /DisableStartupDialogs /DisableStartupMessages
if errorlevel 1 (
    echo ОШИБКА: разборка завершилась с кодом %errorlevel%
    exit /b %errorlevel%
)

echo Готово: исходники в %ROOT%\src\ExternalReports
exit /b 0

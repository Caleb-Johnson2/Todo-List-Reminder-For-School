@echo off
setlocal

:: -------------------------------
:: 1. Detect Python Installation
:: -------------------------------
where py >nul 2>&1
if %errorlevel%==0 (
    set "PYTHON_COMMAND=py"
) else (
    where python >nul 2>&1
    if %errorlevel%==0 (
        set "PYTHON_COMMAND=python"
    ) else (
        where python3 >nul 2>&1
        if %errorlevel%==0 (
            set "PYTHON_COMMAND=python3"
        ) else (
            echo Python is not installed or not added to PATH.
            echo Please install it from: https://www.python.org/downloads/
            pause
            exit /b
        )
    )
)

:: -------------------------------
:: 2. Install Python Dependencies
:: -------------------------------
echo Installing required Python dependencies...
%PYTHON_COMMAND% -m pip install keyboard plyer

:: -------------------------------
:: 3. Download and Extract Repo
:: -------------------------------
set "ZIP_URL=https://github.com/Caleb-Johnson2/Todo-List-Reminder-For-School/archive/refs/heads/main.zip"
set "TEMP_DIR=%CD%\_temp_repo"
set "FINAL_DIR=%CD%\Todo_List"

:: Clean up previous temp folder if exists
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"

mkdir "%TEMP_DIR%"

echo Downloading Todo_List repository...
powershell -Command "Invoke-WebRequest -Uri '%ZIP_URL%' -OutFile '%TEMP_DIR%\repo.zip'"

echo Extracting repository...
powershell -Command "Expand-Archive -Path '%TEMP_DIR%\repo.zip' -DestinationPath '%TEMP_DIR%'"

:: -------------------------------
:: 4. Copy only Todo_List folder
:: -------------------------------
for /d %%D in ("%TEMP_DIR%\Todo-List-Reminder-For-School-*") do (
    xcopy "%%D\Todo_List" "%FINAL_DIR%\" /E /I /Y
)

:: -------------------------------
:: 5. Create todo.txt
:: -------------------------------
if not exist "%FINAL_DIR%\todo.txt" (
    echo # Your tasks go here > "%FINAL_DIR%\todo.txt"
)

:: -------------------------------
:: 6. Run reminder.py
:: -------------------------------
echo Launching reminder.py...
%PYTHON_COMMAND% "%FINAL_DIR%\reminder.py"

:: -------------------------------
:: 7. Clean up
:: -------------------------------
rmdir /s /q "%TEMP_DIR%"

echo All done!
pause

@echo off
setlocal

:: Detect Python installation
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

:: Set up paths
set "BASE_DIR=%CD%\Todo_List_Program"
set "EXTRACTED_DIR=%BASE_DIR%\Todo_List_Program-main"
set "REPO_ZIP_URL=https://github.com/Caleb-Johnson2/Todo_List_Program/archive/refs/heads/main.zip"
set "REPO_ZIP=%CD%\Todo_List.zip"

:: If reminder.py exists, skip installation
if exist "%EXTRACTED_DIR%\reminder.py" (
    echo Program already installed. Skipping installation...
    goto RunReminder
)

:: Install dependencies
echo Installing required Python dependencies...
%PYTHON_COMMAND% -m pip install keyboard plyer

:: Ensure Todo_List_Program folder exists
if not exist "%BASE_DIR%" mkdir "%BASE_DIR%"

:: Download the zip
echo Downloading Todo_List.zip...
powershell -Command "Invoke-WebRequest -Uri '%REPO_ZIP_URL%' -OutFile '%REPO_ZIP%'"

:: Verify the zip file was downloaded
if not exist "%REPO_ZIP%" (
    echo Error: Download failed! ZIP file not found.
    pause
    exit /b
)

:: Uncompress Todo_List.zip into Todo_List_Program
echo Unzipping Todo_List.zip...
powershell -Command "& {try { Expand-Archive -Path '%REPO_ZIP%' -DestinationPath '%BASE_DIR%' -Force -ErrorAction Stop; echo Success } catch { echo Unzip failed!; exit 1 }}"

:: Verify the extracted folder exists
if not exist "%EXTRACTED_DIR%\reminder.py" (
    echo Error: reminder.py not found in extracted folder!
    pause
    exit /b
)

:: Create todo.txt if it doesn't exist
if not exist "%EXTRACTED_DIR%\todo.txt" (
    echo Creating todo.txt...
    echo - [ ] New Task > "%EXTRACTED_DIR%\todo.txt"
)

:: Run reminder.py from Todo_List_Program-main
:RunReminder
echo Launching reminder.py...
%PYTHON_COMMAND% "%EXTRACTED_DIR%\reminder.py"

echo All done!
pause

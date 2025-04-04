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
set "TODO_LIST_DIR=%CD%\Todo_List"
set "REPO_ZIP_URL=https://github.com/Caleb-Johnson2/Todo_List_Program/archive/refs/heads/main.zip"
set "REPO_ZIP=%TODO_LIST_DIR%\Todo_List.zip"

:: Find the extracted folder dynamically
for /d %%D in ("%TODO_LIST_DIR%\Todo_List_Program*") do set "EXTRACTED_FOLDER=%%D"

:: Check if reminder.py exists (indicating installation is complete)
if exist "%EXTRACTED_FOLDER%\reminder.py" (
    echo Program already installed. Skipping installation...
    goto RunReminder
)

:: Install dependencies
echo Installing required Python dependencies...
%PYTHON_COMMAND% -m pip install keyboard plyer requests beautifulsoup4

:: Create the folder if it doesn't exist
if not exist "%TODO_LIST_DIR%" mkdir "%TODO_LIST_DIR%"

:: Download the zip
echo Downloading Todo_List.zip...
powershell -Command "Invoke-WebRequest -Uri '%REPO_ZIP_URL%' -OutFile '%REPO_ZIP%'"

:: Extract the zip
echo Extracting...
powershell -Command "Expand-Archive -Path '%REPO_ZIP%' -DestinationPath '%TODO_LIST_DIR%'"

:: Find the correct extracted folder again
for /d %%D in ("%TODO_LIST_DIR%\Todo_List_Program*") do set "EXTRACTED_FOLDER=%%D"

:: Verify extraction
if not exist "%EXTRACTED_FOLDER%\reminder.py" (
    echo Error: reminder.py not found after extraction!
    pause
    exit /b
)

:: Create todo.txt if it doesn't exist
if not exist "%EXTRACTED_FOLDER%\todo.txt" (
    echo Creating todo.txt...
    echo # Your tasks go here > "%EXTRACTED_FOLDER%\todo.txt"
)

:: Run reminder.py
:RunReminder
echo Launching reminder.py...
%PYTHON_COMMAND% "%EXTRACTED_FOLDER%\reminder.py"

echo All done!
pause

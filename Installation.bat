@echo off
setlocal

:: Check if Python is installed by checking common commands
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

:: Set up folder and file paths
set "TODO_LIST_DIR=%CD%\Todo_List"
set "TODO_LIST_ZIP_URL=https://github.com/Caleb-Johnson2/Todo-List-Reminder-For-School/archive/refs/heads/main.zip"
set "TODO_FILE=%TODO_LIST_DIR%\todo.txt"

:: Check if todo.txt already exists (i.e., the program is already installed)
if exist "%TODO_FILE%" (
    echo Program already installed, skipping installation steps...
    echo Launching reminder.py...
    %PYTHON_COMMAND% "%TODO_LIST_DIR%\reminder.py"
    goto :eof
)

:: Install Python dependencies
echo Installing required Python dependencies...
%PYTHON_COMMAND% -m pip install keyboard plyer

:: Create the folder if it doesn't exist
if not exist "%TODO_LIST_DIR%" mkdir "%TODO_LIST_DIR%"

:: Download the zip
echo Downloading Todo_List.zip...
powershell -Command "Invoke-WebRequest -Uri '%TODO_LIST_ZIP_URL%' -OutFile '%TODO_LIST_DIR%\Todo_List.zip'"

:: Extract the zip
echo Extracting...
powershell -Command "Expand-Archive -Path '%TODO_LIST_DIR%\Todo_List.zip' -DestinationPath '%TODO_LIST_DIR%'"

:: Clean up zip
del "%TODO_LIST_DIR%\Todo_List.zip"

:: Set path to extracted folder
set "EXTRACTED_FOLDER=%TODO_LIST_DIR%\Todo-List-Reminder-For-School-main"

:: Create todo.txt file if it doesn't exist
echo Creating todo.txt...
echo # Your tasks go here > "%EXTRACTED_FOLDER%\todo.txt"

:: Run the reminder script
echo Launching reminder.py...
%PYTHON_COMMAND% "%EXTRACTED_FOLDER%\reminder.py"

echo All done!
pause

@echo off

:: Check if Python is installed by checking for python, python3, and py
python --version >nul 2>&1
if %errorlevel% == 0 (
    set PYTHON_COMMAND=python
) else (
    python3 --version >nul 2>&1
    if %errorlevel% == 0 (
        set PYTHON_COMMAND=python3
    ) else (
        py --version >nul 2>&1
        if %errorlevel% == 0 (
            set PYTHON_COMMAND=py
        ) else (
            echo Python is not installed on your system.
            echo Please install Python from https://www.python.org/downloads/
            pause
            exit /b
        )
    )
)

:: Install dependencies using the detected Python command
echo Installing required Python dependencies...
%PYTHON_COMMAND% -m pip install keyboard plyer requests beautifulsoup4

:: Set the folder and download URL for Todo_List.zip
set TODO_LIST_DIR=%CD%\Todo_List
set TODO_LIST_ZIP_URL=https://github.com/Caleb-Johnson2/Todo-List-Reminder-For-School/archive/refs/heads/main.zip

:: Create the Todo_List folder if it doesn't exist
if not exist "%TODO_LIST_DIR%" (
    mkdir "%TODO_LIST_DIR%"
)

:: Download Todo_List.zip to the Todo_List folder
echo Downloading Todo_List.zip...
powershell -Command "Invoke-WebRequest -Uri %TODO_LIST_ZIP_URL% -OutFile \"%TODO_LIST_DIR%\Todo_List.zip\""

:: Extract Todo_List.zip into the Todo_List folder
echo Extracting Todo_List.zip...
powershell -Command "Expand-Archive -Path \"%TODO_LIST_DIR%\Todo_List.zip\" -DestinationPath \"%TODO_LIST_DIR%\""

:: Remove the .zip file after extraction
del "%TODO_LIST_DIR%\Todo_List.zip"

:: Set extracted folder path
set EXTRACTED_FOLDER=%TODO_LIST_DIR%\Todo-List-Reminder-For-School-main

:: Create the todo.txt file in the extracted Todo_List folder
echo Creating todo.txt...
echo # Your tasks go here > "%EXTRACTED_FOLDER%\todo.txt"

:: Run reminder.py
echo Running reminder.py...
%PYTHON_COMMAND% "%EXTRACTED_FOLDER%\reminder.py"

echo Installation complete!
pause

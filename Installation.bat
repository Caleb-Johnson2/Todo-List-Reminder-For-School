@echo off
setlocal

:: Assume py is available
set "PYTHON_COMMAND=py"

:: Install Python dependencies
echo Installing required Python dependencies...
%PYTHON_COMMAND% -m pip install keyboard plyer requests beautifulsoup4

:: Set up download path and folder
set "TODO_LIST_DIR=%CD%\Todo_List"
set "TODO_LIST_ZIP_URL=https://github.com/Caleb-Johnson2/Todo-List-Reminder-For-School/archive/refs/heads/main.zip"

:: Create the folder
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

:: Create todo.txt file
echo Creating todo.txt...
echo # Your tasks go here > "%EXTRACTED_FOLDER%\todo.txt"

:: Run the reminder script
echo Launching reminder.py...
%PYTHON_COMMAND% "%EXTRACTED_FOLDER%\reminder.py"

echo All done!
pause

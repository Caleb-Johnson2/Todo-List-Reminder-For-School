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
set "TODO_LIST_DIR=%CD%\Todo_List_Program"
set "REPO_ZIP_URL=https://github.com/Caleb-Johnson2/Todo_List_Program/archive/refs/heads/main.zip"
set "REPO_ZIP=%CD%\Todo_List.zip"

:: If reminder.py exists, skip installation
if exist "%TODO_LIST_DIR%\reminder.py" (
    echo Program already installed. Skipping installation...
    goto RunReminder
)

:: Install dependencies
echo Installing required Python dependencies...
%PYTHON_COMMAND% -m pip install keyboard plyer

:: Create the folder if it doesn't exist
if not exist "%CD%\Todo_List_Program" mkdir "%CD%\Todo_List_Program"

:: Download the zip
echo Downloading Todo_List.zip...
powershell -Command "Invoke-WebRequest -Uri '%REPO_ZIP_URL%' -OutFile '%REPO_ZIP%'"

:: Verify the zip file was downloaded
if not exist "%REPO_ZIP%" (
    echo Error: Download failed! ZIP file not found.
    pause
    exit /b
)

:: Uncompress Todo_List.zip
echo Unzipping Todo_List.zip...
powershell -Command "& {try { Expand-Archive -Path '%REPO_ZIP%' -DestinationPath '%CD%' -Force -ErrorAction Stop; echo Success } catch { echo Unzip failed!; exit 1 }}"

:: Find the correct extracted folder
for /d %%D in ("%CD%\Todo_List_Program*") do set "EXTRACTED_FOLDER=%%D"

:: Verify the extracted folder exists
if not exist "%EXTRACTED_FOLDER%\reminder.py" (
    echo Error: reminder.py not found after extraction!
    pause
    exit /b
)

:: Move extracted files into the correct folder
if not "%EXTRACTED_FOLDER%"=="%TODO_LIST_DIR%" (
    echo Moving extracted files to the correct location...
    move "%EXTRACTED_FOLDER%" "%TODO_LIST_DIR%"
)

:: Create todo.txt if it doesn't exist
if not exist "%TODO_LIST_DIR%\todo.txt" (
    echo Creating todo.txt...
    echo # Your tasks go here > "%TODO_LIST_DIR%\todo.txt"
)

:: Run reminder.py
:RunReminder
echo Launching reminder.py...
%PYTHON_COMMAND% "%TODO_LIST_DIR%\reminder.py"

echo All done!
pause

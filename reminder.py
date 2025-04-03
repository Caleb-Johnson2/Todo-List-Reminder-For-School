import time
import os
import platform
import datetime
import keyboard  # Detects keypress
from plyer import notification
import winsound  # Windows sound module (adjust for Mac/Linux)
import re  # For extracting dates
import requests
from bs4 import BeautifulSoup

TODO_FILE = "todo.txt"
REMINDER_INTERVAL = 1800  # 30 minutes (1800 seconds)
REPORT_TIME = "17:30"  # 5:30 PM in military time
LATE_POLICY_PENALTY = 10  # -10% per day late
BASE_URL = "https://hac.nisdtx.org/HomeAccess/Home/WeekView?startDate="  # Base URL
COOKIES = {"your_cookie_name": "your_cookie_value"}  # Replace with your actual cookie

def get_next_week_start_date():
    """Returns the start date for the next week."""
    today = datetime.date.today()
    # Calculate the days to add to reach the next Monday
    days_ahead = 7 - today.weekday()
    if days_ahead <= 0:
        days_ahead += 7

    next_monday = today + datetime.timedelta(days=days_ahead)
    next_monday_str = next_monday.strftime("%m%%2F%d%%2F%Y%%2000%%3A00%%3A00")  # Format for the URL
    return next_monday_str

def fetch_tasks_from_website():
    """Fetches tasks from the website and updates todo.txt."""
    try:
        next_week_start_date = get_next_week_start_date()
        url = BASE_URL + next_week_start_date
        
        response = requests.get(url, cookies=COOKIES)
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, "html.parser")
            assignments = soup.find_all("a", id="courseAssignmentDescription")
            updated_tasks = []

            for assignment in assignments:
                title = assignment.get_text(strip=True)
                grade_tag = assignment.find_next("span", class_="sg-right")
                
                if grade_tag:
                    grade = grade_tag.get_text(strip=True)
                else:
                    grade = None  # No grade available

                # Filter tasks with no grade, "M" (Missing), or "0" (Zero)
                if not grade or grade == "M" or grade == "0":
                    updated_tasks.append(f"- [ ] {title} (No grade/Incomplete)")

            # Update the todo.txt file
            with open(TODO_FILE, "a", encoding="utf-8") as file:
                for task in updated_tasks:
                    file.write(f"{task}\n")

            print("✅ Task list updated from website!")
        else:
            print("❌ Failed to fetch tasks!")
    except Exception as e:
        print(f"⚠️ Error fetching tasks: {e}")

def parse_due_date(task):
    """Extracts due date from a task and returns a datetime object."""
    match = re.search(r"\((\d{2})/(\d{2})/(\d{4})/(\d{2}):(\d{2})\)", task)
    if match:
        month, day, year, hour, minute = map(int, match.groups())
        return datetime.datetime(year, month, day, hour, minute)
    return None  # No due date found

def read_todo_list():
    """Reads the todo list and finds the most urgent task."""
    if not os.path.exists(TODO_FILE):
        return None, 0  # No file found
    
    with open(TODO_FILE, "r", encoding="utf-8") as file:
        lines = file.readlines()
    
    pending_tasks = [line.strip() for line in lines if line.startswith("- [ ]")]

    if not pending_tasks:
        return None, pending_tasks  # No tasks left

    # Sort tasks by closest due date (if they have one)
    pending_tasks.sort(key=lambda task: parse_due_date(task) or datetime.datetime.max)

    # Get the most urgent task (earliest due date)
    most_urgent_task = pending_tasks[0]

    return most_urgent_task, pending_tasks

def calculate_time_remaining(due_date):
    """Returns time left in a human-readable format or penalty if overdue."""
    now = datetime.datetime.now()
    time_diff = due_date - now

    if time_diff.total_seconds() > 0:
        hours, remainder = divmod(time_diff.seconds, 3600)
        minutes = remainder // 60
        return f"{time_diff.days} days, {hours} hours, {minutes} minutes left"
    else:
        days_late = abs(time_diff.days)
        penalty = min(days_late * LATE_POLICY_PENALTY, 100)  # Max penalty 100%
        return f"Late by {days_late} days (-{penalty}% penalty)"

def play_sound():
    """Plays a notification sound based on the OS."""
    if platform.system() == "Windows":
        winsound.MessageBeep(winsound.MB_ICONEXCLAMATION)
    elif platform.system() == "Darwin":  # macOS
        os.system("afplay /System/Library/Sounds/Glass.aiff")
    elif platform.system() == "Linux":
        os.system("paplay /usr/share/sounds/freedesktop/stereo/message.oga")

def remove_parentheses_content(text):
    """Removes content inside parentheses (including the parentheses)."""
    return re.sub(r"\(.*?\)", "", text)

def send_notification(title, message):
    """Sends a desktop notification with sound, excluding parentheses content."""
    # Remove content inside parentheses
    message = remove_parentheses_content(message)

    # Limit message length to 256 characters
    max_message_length = 256
    if len(message) > max_message_length:
        message = message[:max_message_length]  # Truncate the message

    notification.notify(
        title=title,
        message=message,
        timeout=10
    )
    play_sound()

def send_report():
    """Sends a report on remaining tasks, including due dates."""
    most_urgent_task, pending_tasks = read_todo_list()
    pending_count = len(pending_tasks)

    if pending_count > 0:
        report_lines = []
        for task in pending_tasks[:5]:  # Show up to 5 tasks
            due_date = parse_due_date(task)
            if due_date:
                time_info = calculate_time_remaining(due_date)
                report_lines.append(f"{task[6:]} - {time_info}")
            else:
                report_lines.append(task[6:])  # No due date

        report_text = "\n".join(report_lines)
        send_notification("📋 Todo Report", f"{pending_count} tasks left:\n{report_text}")
    else:
        send_notification("✅ Todo Report", "You have **0 tasks left!** Great job!")

def send_full_task_report():
    """Sends a detailed report of all tasks with due dates when Num * is pressed."""
    _, pending_tasks = read_todo_list()

    if not pending_tasks:
        send_notification("📋 Full Report", "No tasks left!")
        return

    report_lines = []
    for task in pending_tasks:
        due_date = parse_due_date(task)
        if due_date:
            time_info = calculate_time_remaining(due_date)
            report_lines.append(f"{task[6:]} - {time_info}")

    report_text = "\n".join(report_lines) if report_lines else "No tasks with due dates!"
    send_notification("📋 Full Task Report", report_text)

def main():
    """Main loop: sends reminders, reports, and checks tasks."""
    last_report_date = None  # Track last report date to prevent duplicate reports

    # Detect "Num -" to send an instant report
    keyboard.add_hotkey("num -", send_report)
    keyboard.add_hotkey("num *", send_full_task_report)

    while True:
        now = datetime.datetime.now()
        current_date = now.date()
        current_time = now.strftime("%H:%M")

        # Read todo list
        most_urgent_task, pending_tasks = read_todo_list()
        pending_count = len(pending_tasks)

        # Send a reminder every 30 minutes
        if most_urgent_task:
            due_date = parse_due_date(most_urgent_task)
            if due_date:
                time_info = calculate_time_remaining(due_date)
                # Remove any content inside parentheses from the task before displaying it
                reminder_message = f"Task: {remove_parentheses_content(most_urgent_task[6:])}\nTime left: {time_info}"
            else:
                # Remove parentheses content here as well
                reminder_message = f"Hey! You still have '{remove_parentheses_content(most_urgent_task[6:])}' to do. Get it done or you'll regret it!"

            send_notification("Todo Reminder", reminder_message)
        else:
            send_notification("Todo List Complete!", "🎉 Congrats! You finished your entire Todo list! 🎉")
            break  # Stop script when everything is done

        # Send daily report at 5:30 PM (17:30)
        if current_time == REPORT_TIME and last_report_date != current_date:
            last_report_date = current_date  # Prevent duplicate reports
            send_report()

        time.sleep(REMINDER_INTERVAL)  # Wait 30 minutes before the next reminder

        # Fetch tasks from the website to update the todo list
        fetch_tasks_from_website()

if __name__ == "__main__":
    main()

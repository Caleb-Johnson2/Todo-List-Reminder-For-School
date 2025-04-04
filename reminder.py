import time
import os
import platform
import datetime
import keyboard  # Detects keypress
from plyer import notification
import winsound  # Windows sound module (adjust for Mac/Linux)
import re  # For extracting dates
import threading

TODO_FILE = "todo.txt"
REMINDER_INTERVAL = 1800  # 30 minutes (1800 seconds)
REPORT_TIME = "15:50"  # 3:50 PM in military time
LATE_POLICY_PENALTY = 10  # -10% per day late

def remove_parentheses_content(text):
    """Removes content inside parentheses (including the parentheses)."""
    return re.sub(r"\(.*?\)", "", text)

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
        return None, []  # No file found, return an empty list instead of 0
    
    with open(TODO_FILE, "r", encoding="utf-8") as file:
        lines = file.readlines()
    
    pending_tasks = [line.strip() for line in lines if line.startswith("- [ ]")]

    if not pending_tasks:
        return None, []  # No tasks left, return an empty list instead of 0

    # Sort tasks by closest due date (if they have one)
    pending_tasks.sort(key=lambda task: parse_due_date(task) or datetime.datetime.max)

    # Get the most urgent task (earliest due date)
    most_urgent_task = pending_tasks[0]

    return most_urgent_task, pending_tasks  # Always return a list, never an integer

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
                report_lines.append(f"{remove_parentheses_content(task[6:])} - {time_info}")
            else:
                report_lines.append(remove_parentheses_content(task[6:]))  # No due date

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
            report_lines.append(f"{remove_parentheses_content(task[6:])} - {time_info}")

    report_text = "\n".join(report_lines) if report_lines else "No tasks with due dates!"
    send_notification("📋 Full Task Report", report_text)

def main():
    """Main loop: sends reminders, reports, and checks tasks."""
    last_report_date = None  # Track last report date to prevent duplicate reports

    def send_report_thread():
        threading.Thread(target=send_report, daemon=True).start()

    def send_full_task_report_thread():
        threading.Thread(target=send_full_task_report, daemon=True).start()

    # Use threads so hotkey functions don’t block the main loop
    keyboard.add_hotkey("num -", send_report_thread)
    keyboard.add_hotkey("num *", send_full_task_report_thread)

    while True:
        now = datetime.datetime.now()
        current_date = now.date()
        current_time = now.strftime("%H:%M")

        # Read todo list
        most_urgent_task, pending_tasks = read_todo_list()

        # Send a reminder every 30 minutes
        if most_urgent_task:
            due_date = parse_due_date(most_urgent_task)
            if due_date:
                time_info = calculate_time_remaining(due_date)
                reminder_message = f"Task: {remove_parentheses_content(most_urgent_task[6:])}\nTime left: {time_info}"
            else:
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

if __name__ == "__main__":
    main()

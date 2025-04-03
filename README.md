# Todo-List-Reminder-For-School
Guide to your Todo List

1. Hotkeys
The script includes specific hotkeys that allow you to interact with it while it's running. These hotkeys are set to trigger certain actions, such as generating reports or sending notifications. Below are the hotkeys available and what they do:

Hotkeys:
Num -
Action: Sends an instant summary report of the remaining tasks.
Description: When you press the "Num -" key, the script will immediately send a notification with a summary of the pending tasks, including their due dates and time remaining until they are due.

Num *
Action: Sends a detailed report of all tasks.
Description: Pressing the "Num *" key triggers the script to send a detailed report of all tasks, including those with due dates and the remaining time. It will list the tasks with their due dates and the time left until they are due. If a task does not have a due date, it will be listed without that information.

2. Editing the todo.txt File
The todo.txt file is the main file where your tasks are stored. The script reads from and updates this file, adding new tasks and keeping track of the ones you need to complete. Here’s how you should format and edit the todo.txt file.

Basic Format:
Tasks should be written in the following format:

*- [ ] Task description (MM/DD/YYYY/HH:MM)*

*- [ ]* indicates that the task is incomplete.
Task description is a brief summary of the task.
(MM/DD/YYYY/HH:MM) is the due date and time, in the format Month/Day/Year/Hour:Minute (24-hour format).
For example:

*- [ ] Complete homework (04/05/2025/14:00)*
*- [ ] Submit project report (04/06/2025/17:00)*

If a task does not have a due date or if it's not assigned yet, simply omit the date portion:

*- [ ] Buy groceries*

Important Points:
Tasks without due dates can be added without the parentheses and date.
Tasks that have a grade (e.g., from an assignment or homework) but are incomplete or missing should be written with "(No grade/Incomplete)" or similar tags, as handled by the script:

*- [ ] Read chapter 5 (No grade/Incomplete)*

Each task should be written on a new line, starting with *- [ ]*.
Example todo.txt File:

*- [ ] Complete homework (04/05/2025/14:00)*
*- [ ] Submit project report (04/06/2025/17:00)*
*- [ ] Buy groceries*
*- [ ] Call mom (No grade/Incomplete)*

The script will process the tasks from this file, determining which are due soon and which have penalties if overdue.

3. Notification Time Interval
The script sends reminders about tasks at regular intervals. You can adjust how often the script checks for pending tasks and sends reminders. This is controlled by the REMINDER_INTERVAL variable.

Default Notification Interval:
The REMINDER_INTERVAL is set to 1800 seconds, which is 30 minutes.
This means that the script will check for the most urgent task every 30 minutes and send a reminder notification if needed.

Customizing the Interval:
If you'd like to change the frequency of the reminders, you can adjust the REMINDER_INTERVAL in the script. For example, to change the interval to 1 hour (3600 seconds), simply modify the value like this:

REMINDER_INTERVAL = 3600  # 1 hour (3600 seconds)
This change will cause the script to send reminders every 60 minutes instead of every 30 minutes.

Summary of Key Features:
Hotkeys:

Num -: Instant summary report of tasks.

Num *: Detailed task report with due dates.

Editing todo.txt:

Tasks are written with *- [ ] Task description (MM/DD/YYYY/HH:MM)* for tasks with due dates.

Tasks without due dates should just have *- [ ] Task description*.

Notification Time Interval:

Default is 30 minutes (1800 seconds), adjustable by modifying REMINDER_INTERVAL.

With this manual, you should be able to effectively use the hotkeys, format your tasks in todo.txt, and customize the time interval for notifications.









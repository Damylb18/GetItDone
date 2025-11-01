# 🧠 Get It Done

**Get It Done** is a personal productivity app built for people who want to be organized, consistent, and truly *get things done*.  
It combines **habit tracking**, **daily task management**, and an **AI-powered planner** to help you optimize your day, all in one place.

---

## 🚀 Features

### 🗓️ Today Page
- Add, view, and manage your daily tasks.
- Track completion progress with a visual progress bar.
- Smart task validation prevents invalid or past-due tasks.
- Built-in reminders and notifications (via **UNUserNotificationCenter**).

### 📅 Upcoming Page
- View and organize future tasks beyond today.
- Automatically moves tasks based on their date.
- Edit or delete tasks easily through contextual menus.

### 🤖 AI Planner (Powered by OpenAI)
- Input your fixed commitments (e.g., “Uni 11–1, Meeting at 3PM”).
- Add your goals for the day (“gym, cook, study”).
- Let the AI create an *optimized day plan* balancing productivity and rest.
- The app uses the **OpenAI API** to generate realistic, structured daily schedules.

---

## 🧩 Tech Stack

| Technology | Purpose |
|-------------|----------|
| **SwiftUI** | UI design and reactive components |
| **Combine** | Reactive data flow between app components |
| **UserNotifications** | Scheduling reminders and AI nudges |
| **OpenAI API** | AI-generated daily planner |
| **Local Storage (UserDefaults)** | Task persistence between sessions |

---

## 🔔 AI Nudge System

Get It Done doesn’t just remind you *when* to start — it motivates you *to start*.  
If you don’t mark a task as begun within a few minutes, you’ll receive a cheeky motivational nudge like:

> “Come on, this task won’t do itself!”  
> “Less scrolling, more doing. Get to work!”

These nudges are dynamically generated using OpenAI’s API.

---

## 🎨 Design & Theme

The app follows a **modern, minimalist design** with a vibrant gradient header in indigo and purple hues.  
Each page uses consistent color accents and rounded elements to reflect productivity, clarity, and calm.

---

## 🔮 Future addition

Looking ahead, **Firebase integration** will be introduced to add user authentication and cloud syncing.  
This will allow users to:
- Create personal profiles  
- Save their tasks and AI plans securely online  
- **Follow friends** and share daily progress or motivational updates  

The vision is to turn *Get It Done* into a connected productivity hub — where personal growth meets community support.

---

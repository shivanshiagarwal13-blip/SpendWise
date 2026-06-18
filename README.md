# SpendWise 💸

A simple, fast expense tracker built with SwiftUI — log what you spend, set a monthly budget, and keep tabs on money others owe you, without any backend or sign-up.

> **Note:** This is a personal project built for my own day-to-day budget tracking, not a polished or published product. Feel free to poke around, fork it, or borrow ideas from it.

## Features

- **Home dashboard** — see what you've spent this month, your budget progress, and average daily/monthly spending at a glance.
- **Day Log** — quickly add an expense for any date with a description and amount.
- **Owe tracking** — if you paid for something on someone else's behalf (splitting a meal, covering a friend), mark it as owed. It still counts toward your spending until you tick it off as paid back, at which point it's added back to your remaining budget.
- **Calendar view** — a full year at a glance, with per-month totals and budget usage bars.
- **Month summary** — drill into any month for a complete, deletable transaction list.
- **Light & dark mode** — fully themed for both.
- **No account, no internet required** — everything is stored locally on-device.

## Tech Stack

- **SwiftUI** for the UI
- **Combine** (`ObservableObject` / `@Published`) for state management
- **UserDefaults + Codable** for local persistence (no backend, no database)

## Project Structure

```
SpendWise/
├── SpendWiseApp.swift        # App entry point
├── ContentView.swift         # Root tab view (Home / Day Log / Calendar)
├── Models.swift               # Expense model + BudgetStore (data layer)
├── HomeView.swift             # Dashboard: totals, budget, owed-to-you
├── DayLogView.swift           # Add/view expenses for a specific day
├── CalenderView.swift         # Year-at-a-glance calendar grid
├── MonthlySummaryView.swift   # Per-month transaction breakdown
└── Theme.swift                 # Colors, card styling, haptics, button styles
```

## Getting Started

1. Clone the repo:
   ```bash
   git clone https://github.com/your-username/spendwise.git
   ```
2. Open `SpendWise.xcodeproj` (or `.xcworkspace`) in Xcode.
3. Select a simulator or device and hit **Run** (`Cmd + R`).

**Requirements:** Xcode 15+, iOS 16+

## How It Works

- Add an expense from the **Day Log** tab with a description and amount.
- If someone owes you for part (or all) of that expense, toggle **"Someone owes you for this"** and enter the amount — it's still counted as spent for now.
- Once they pay you back, tap the checkmark in the **Owed to you** card on the Home screen. That amount is removed from your spent total and added back to your remaining budget.
- Set a monthly budget from the Home screen to track progress visually across Home, Calendar, and Month Summary.

## Roadmap Ideas

- [ ] Export expenses to CSV
- [ ] Custom categories/tags
- [ ] iCloud sync across devices
- [ ] Widgets for quick glance at spending

## About

Built solo as a way to actually stick to a budget, and to practice SwiftUI along the way. No license is attached — it's just up on GitHub for personal reference and tracking progress over time.

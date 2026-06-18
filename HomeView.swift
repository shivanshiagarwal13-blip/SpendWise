// HomeView.swift
import SwiftUI

struct HomeView: View {

    @EnvironmentObject var store: BudgetStore
    @Environment(\.colorScheme) var scheme
    @State private var budgetInput = ""
    @State private var displayedTotal: Double = 0
    @FocusState private var budgetFocused: Bool

    var monthKey: String { Date().monthKey() }

    var actualTotal: Double { store.total(forMonth: monthKey) }

    var averageDailySpending: Double {
        let monthExpenses = store.expenses.filter { $0.date.hasPrefix(monthKey) }
        let total = monthExpenses.reduce(0) { $0 + $1.netAmount }

        let dayOfMonth = Calendar.current.component(.day, from: Date())

        return total / Double(dayOfMonth)
    }

    var averageMonthlySpending: Double {
        let grouped = Dictionary(grouping: store.expenses) { String($0.date.prefix(7)) }
        guard !grouped.isEmpty else { return 0 }
        let totals = grouped.map { _, exps in exps.reduce(0) { $0 + $1.netAmount } }
        return totals.reduce(0, +) / Double(totals.count)
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 17 { return "Good afternoon" }
        return "Good evening"
    }

    var owedExpenses: [Expense] {
        store.pendingOwed()
    }

    var totalOwedAmount: Double {
        store.totalOwed()
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {

                    // Hero card
                    VStack(spacing: 10) {
                        HStack {
                            Text(greeting)
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text(monthLabel())
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.textSecondary)
                        }

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("₹")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.textSecondary)
                            Text("\(Int(displayedTotal))")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.textPrimary)
                                .contentTransition(.numericText())
                        }

                        Text("spent this month")
                            .font(.system(size: 13))
                            .foregroundColor(.textSecondary)

                        let budget = store.budget(forMonth: monthKey)
                        if budget > 0 {
                            let total    = actualTotal
                            let progress = min(total / budget, 1.0)
                            let over     = total > budget

                            VStack(spacing: 6) {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.appBackground)
                                            .frame(height: 6)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(over ? Color.accentTerracotta : Color.accentSage)
                                            .frame(width: geo.size.width * progress, height: 6)
                                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                                    }
                                }
                                .frame(height: 6)

                                HStack {
                                    Text(over
                                         ? "Over budget by ₹\(Int(total - budget))"
                                         : "₹\(Int(budget - total)) remaining")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(over ? .accentTerracotta : Color(red: 0.2, green: 0.65, blue: 0.4))
                                    Spacer()
                                    Text("of ₹\(budget, specifier: "%.0f")")
                                        .font(.system(size: 12))
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .cardStyle()
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.0)) {
                            displayedTotal = actualTotal
                        }
                    }
                    .onChange(of: actualTotal) { newVal in
                        withAnimation(.easeOut(duration: 0.4)) {
                            displayedTotal = newVal
                        }
                    }

                    // 4 stat cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        let budget = store.budget(forMonth: monthKey)
                        statCard("Budget",
                                 value: String(format: "₹%.0f", budget),
                                 icon: "target",
                                 color: .accentTerracotta)
                        statCard("Remaining",
                                 value: String(format: "₹%.0f", max(budget - actualTotal, 0)),
                                 icon: "checkmark.circle",
                                 color: .accentSage)
                        statCard("Avg Daily",
                                 value: String(format: "₹%.0f", averageDailySpending),
                                 icon: "sun.max",
                                 color: .accentAmber)
                        statCard("Avg Monthly",
                                 value: String(format: "₹%.0f", averageMonthlySpending),
                                 icon: "calendar",
                                 color: Color(red: 0.55, green: 0.5, blue: 0.8))
                    }

                    // Set budget
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Set monthly budget")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .textCase(.uppercase)
                            .kerning(0.8)

                        HStack(spacing: 10) {
                            TextField("e.g. 20000", text: $budgetInput)
                                .keyboardType(.decimalPad)
                                .focused($budgetFocused)
                                .padding(11)
                                .background(Color.appBackground)
                                .cornerRadius(10)
                                .foregroundColor(.textPrimary)

                            Button("Save") {
                                if let value = Double(budgetInput) {
                                    haptic(.medium)
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        store.setBudget(monthKey: monthKey, amount: value)
                                    }
                                    budgetInput = ""
                                    budgetFocused = false
                                }
                            }
                            .buttonStyle(PressScaleStyle())
                            .padding(.horizontal, 20)
                            .padding(.vertical, 11)
                            .background(Color.accentAmber)
                            .foregroundColor(.textPrimary)
                            .fontWeight(.semibold)
                            .cornerRadius(10)
                        }
                    }
                    .cardStyle()

                    // Owed to you
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Owed to you")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.textSecondary)
                                .textCase(.uppercase)
                                .kerning(0.8)
                            Spacer()
                            if totalOwedAmount > 0 {
                                Text("₹\(totalOwedAmount, specifier: "%.0f") pending")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textSecondary)
                            }
                        }

                        if owedExpenses.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "hand.thumbsup")
                                    .font(.system(size: 28))
                                    .foregroundColor(.textSecondary)
                                Text("No one owes you right now")
                                    .font(.system(size: 14))
                                    .foregroundColor(.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        } else {
                            ForEach(owedExpenses) { exp in
                                HStack(spacing: 12) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.accentAmber)
                                        .frame(width: 4, height: 36)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(displayName(exp.item))
                                            .font(.system(size: 15))
                                            .foregroundColor(.textPrimary)
                                        Text(exp.date)
                                            .font(.system(size: 12))
                                            .foregroundColor(.textSecondary)
                                    }
                                    Spacer()
                                    Text("₹\(exp.owedAmount, specifier: "%.0f")")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.textPrimary)

                                    Button {
                                        haptic(.medium)
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            store.settle(exp)
                                        }
                                    } label: {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.accentSage)
                                    }
                                    .buttonStyle(PressScaleStyle())
                                }
                                .padding(.vertical, 4)
                                .transition(.move(edge: .trailing).combined(with: .opacity))

                                if exp.id != owedExpenses.last?.id { Divider() }
                            }
                        }
                    }
                    .cardStyle()

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("SpendWise")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { budgetFocused = false }
                        .foregroundColor(.accentTerracotta)
                }
            }
        }
    }

    func monthLabel() -> String {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"
        return f.string(from: Date())
    }

    func displayName(_ item: String) -> String {
        if let r = item.range(of: ": ") { return String(item[r.upperBound...]) }
        return item
    }

    @ViewBuilder
    func statCard(_ title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.textPrimary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .contentTransition(.numericText())
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

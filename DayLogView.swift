// DayLogView.swift
import SwiftUI

struct DayLogView: View {
    @EnvironmentObject var store: BudgetStore
    @State private var selectedDate = Date()
    @State private var item = ""
    @State private var amount = ""
    @State private var owedToggle = false
    @State private var owedAmountInput = ""
    @State private var shakeAmount: CGFloat = 0
    @State private var showSuccessBanner = false
    @FocusState private var itemFocused: Bool
    @FocusState private var amountFocused: Bool
    @FocusState private var owedAmountFocused: Bool

    var dayExpenses: [Expense] {
        store.expenses(for: selectedDate.key()).sorted { $0.date > $1.date }
    }
    var dayTotal: Double { dayExpenses.reduce(0) { $0 + $1.netAmount } }

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {

                ScrollView {
                    VStack(spacing: 16) {

                        // Date picker
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Date")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.textSecondary)
                                .textCase(.uppercase)
                                .kerning(0.8)
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .tint(.accentTerracotta)
                                .labelsHidden()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardStyle()

                        // Daily total banner
                        if dayTotal > 0 {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Total for this day")
                                        .font(.system(size: 12))
                                        .foregroundColor(.textSecondary)
                                    Text("₹\(dayTotal, specifier: "%.0f")")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.textPrimary)
                                        .contentTransition(.numericText())
                                }
                                Spacer()
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color.accentTerracotta.opacity(0.5))
                            }
                            .padding()
                            .background(Color.accentTerracotta.opacity(0.1))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.accentTerracotta.opacity(0.2), lineWidth: 1))
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // Add expense
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add expense")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.textSecondary)
                                .textCase(.uppercase)
                                .kerning(0.8)

                            TextField("What did you spend on?", text: $item)
                                .focused($itemFocused)
                                .padding(12)
                                .background(Color.appBackground)
                                .cornerRadius(10)
                                .foregroundColor(.textPrimary)
                                .submitLabel(.next)
                                .onSubmit { amountFocused = true }

                            TextField("Amount (₹)", text: $amount)
                                .focused($amountFocused)
                                .keyboardType(.decimalPad)
                                .padding(12)
                                .background(Color.appBackground)
                                .cornerRadius(10)
                                .foregroundColor(.textPrimary)

                            VStack(alignment: .leading, spacing: 8) {
                                Toggle(isOn: $owedToggle) {
                                    Text("Someone owes you for this")
                                        .font(.system(size: 14))
                                        .foregroundColor(.textPrimary)
                                }
                                .tint(.accentTerracotta)

                                if owedToggle {
                                    TextField("How much do they owe you? (₹)", text: $owedAmountInput)
                                        .focused($owedAmountFocused)
                                        .keyboardType(.decimalPad)
                                        .padding(12)
                                        .background(Color.appBackground)
                                        .cornerRadius(10)
                                        .foregroundColor(.textPrimary)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .animation(.easeInOut(duration: 0.2), value: owedToggle)

                            Button(action: handleAddEntry) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add entry").fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(item.isEmpty || amount.isEmpty
                                    ? Color.appBackground
                                    : Color.accentTerracotta)
                                .foregroundColor(item.isEmpty || amount.isEmpty
                                    ? .textSecondary
                                    : .white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(item.isEmpty || amount.isEmpty
                                            ? Color.textSecondary.opacity(0.3)
                                            : Color.clear, lineWidth: 1)
                                )
                            }
                            .buttonStyle(PressScaleStyle())
                            .modifier(ShakeModifier(animatableData: shakeAmount))
                        }
                        .cardStyle()

                        // Entries
                        if !dayExpenses.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Entries")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.textSecondary)
                                        .textCase(.uppercase)
                                        .kerning(0.8)
                                    Spacer()
                                    Text("\(dayExpenses.count) item\(dayExpenses.count == 1 ? "" : "s")")
                                        .font(.system(size: 12))
                                        .foregroundColor(.textSecondary)
                                }

                                ForEach(dayExpenses) { exp in
                                    HStack(spacing: 12) {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(barColor(for: exp))
                                            .frame(width: 4, height: 36)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(displayName(exp.item))
                                                .font(.system(size: 15))
                                                .foregroundColor(.textPrimary)
                                            if exp.owedAmount > 0 {
                                                Text(exp.isSettled
                                                     ? "Owed ₹\(exp.owedAmount, specifier: "%.0f") · received"
                                                     : "Owed ₹\(exp.owedAmount, specifier: "%.0f") · pending")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(exp.isSettled ? .accentSage : .accentAmber)
                                            }
                                        }
                                        Spacer()
                                        Text("₹\(exp.amount, specifier: "%.0f")")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.textPrimary)
                                        Button(action: {
                                            haptic(.light)
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                store.deleteExpense(exp)
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.textSecondary)
                                                .font(.system(size: 20))
                                        }
                                        .buttonStyle(PressScaleStyle())
                                    }
                                    .padding(.vertical, 4)
                                    .transition(.move(edge: .leading).combined(with: .opacity))

                                    if exp.id != dayExpenses.last?.id { Divider() }
                                }
                            }
                            .cardStyle()
                        } else {
                            VStack(spacing: 10) {
                                Image(systemName: "tray")
                                    .font(.system(size: 30))
                                    .foregroundColor(.textSecondary)
                                Text("No entries yet")
                                    .font(.system(size: 14))
                                    .foregroundColor(.textSecondary)
                                Text("Add your first entry above")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding()
                }

                // Success banner overlay
                if showSuccessBanner {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentSage)
                        Text("Entry added")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.cardBackground)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
                    .zIndex(1)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle(navTitle())
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        itemFocused = false
                        amountFocused = false
                        owedAmountFocused = false
                    }
                    .foregroundColor(.accentTerracotta)
                }
            }
        }
    }

    func handleAddEntry() {
        guard !item.isEmpty, Double(amount) != nil else {
            // shake + haptic if fields empty
            haptic(.heavy)
            withAnimation(.default) { shakeAmount += 1 }
            return
        }
        haptic(.medium)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            addEntry()
        }
        // show success banner
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showSuccessBanner = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.3)) {
                showSuccessBanner = false
            }
        }
    }

    func addEntry() {
        guard let val = Double(amount), !item.isEmpty else { return }

        var owed: Double = 0
        if owedToggle {
            owed = Double(owedAmountInput) ?? val   // blank = assume the whole amount is owed back
            owed = min(max(owed, 0), val)             // can't owe more than what was actually spent
        }

        store.addExpense(date: selectedDate.key(),
                         item: item,
                         amount: val,
                         owedAmount: owed)
        item = ""; amount = ""
        owedToggle = false; owedAmountInput = ""
        itemFocused = false; amountFocused = false; owedAmountFocused = false
    }

    func navTitle() -> String {
        let f = DateFormatter(); f.dateFormat = "d MMM"
        return Calendar.current.isDateInToday(selectedDate) ? "Today" : f.string(from: selectedDate)
    }

    func displayName(_ item: String) -> String {
        if let r = item.range(of: ": ") { return String(item[r.upperBound...]) }
        return item
    }

    func barColor(for exp: Expense) -> Color {
        guard exp.owedAmount > 0 else { return .accentTerracotta }
        return exp.isSettled ? .accentSage : .accentAmber
    }
}

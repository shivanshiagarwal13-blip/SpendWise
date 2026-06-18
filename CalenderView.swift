import SwiftUI

struct CalendarView: View {

    @EnvironmentObject var store: BudgetStore
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var yearOffset: CGFloat = 0

    let months = ["Jan","Feb","Mar","Apr","May","Jun",
                  "Jul","Aug","Sep","Oct","Nov","Dec"]
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var yearlyTotal: Double {
        (0..<12).reduce(0) { sum, i in
            sum + store.total(forMonth: String(format: "%d-%02d", year, i + 1))
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // Year navigator
                    HStack {
                        Button {
                            haptic(.light)
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                year -= 1
                                yearOffset = 30
                            }
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.05)) {
                                yearOffset = 0
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.accentTerracotta)
                                .frame(width: 44, height: 44)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.06), radius: 4)
                        }
                        .buttonStyle(PressScaleStyle())

                        Spacer()

                        VStack(spacing: 3) {
                            Text(verbatim: "\(year)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.textPrimary)
                                .offset(x: yearOffset)
                            if yearlyTotal > 0 {
                                Text("₹\(yearlyTotal, specifier: "%.0f") total")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textSecondary)
                                    .contentTransition(.numericText())
                            }
                        }

                        Spacer()

                        Button {
                            haptic(.light)
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                year += 1
                                yearOffset = -30
                            }
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.05)) {
                                yearOffset = 0
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.accentTerracotta)
                                .frame(width: 44, height: 44)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.06), radius: 4)
                        }
                        .buttonStyle(PressScaleStyle())
                    }
                    .padding(.horizontal)

                    // Month grid
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(0..<12) { i in
                            let monthKey   = String(format: "%d-%02d", year, i + 1)
                            let total      = store.total(forMonth: monthKey)
                            let budget     = store.budget(forMonth: monthKey)
                            let overBudget = budget > 0 && total > budget
                            let hasData    = total > 0
                            let isCurrent  = monthKey == Date().monthKey()

                            NavigationLink {
                                MonthSummaryView(monthKey: monthKey, monthName: months[i])
                            } label: {
                                VStack(spacing: 6) {
                                    Text(months[i])
                                        .font(.system(size: 13, weight: isCurrent ? .bold : .medium))
                                        .foregroundColor(isCurrent ? .accentTerracotta : .textSecondary)

                                    Text(hasData ? "₹\(total, specifier: "%.0f")" : "—")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.textPrimary)
                                        .minimumScaleFactor(0.7)
                                        .lineLimit(1)
                                        .contentTransition(.numericText())

                                    if hasData {
                                        // budget usage bar
                                        let usageProgress = budget > 0 ? min(total / budget, 1.0) : 0
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(Color.appBackground)
                                                    .frame(height: 3)
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(overBudget ? Color.accentTerracotta : Color.accentSage)
                                                    .frame(width: budget > 0
                                                           ? geo.size.width * usageProgress
                                                           : geo.size.width, height: 3)
                                            }
                                        }
                                        .frame(height: 3)
                                        .padding(.horizontal, 10)

                                        Text("\(store.expenses.filter { $0.date.hasPrefix(monthKey) }.count) items")
                                            .font(.system(size: 10))
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 4)
                                .padding(.bottom, hasData ? 4 : 0)
                                .background(Color.cardBackground)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(isCurrent
                                            ? Color.accentTerracotta.opacity(0.5)
                                            : Color.cardStroke,
                                                lineWidth: isCurrent ? 1.5 : 0.5)
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                                .scaleEffect(isCurrent ? 1.02 : 1.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isCurrent)
                            }
                            .buttonStyle(PressScaleStyle())
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Calendar")
        }
    }
}

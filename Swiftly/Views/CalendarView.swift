import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date
    @State private var currentWeekIndex: Int = 0
    private let calendar: Calendar
    private let monthFormatter: DateFormatter
    private let weekdayFormatter: DateFormatter

    init(selectedDate: Binding<Date>) {
        _selectedDate = selectedDate

        // Configure the calendar to start the week on Sunday
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        self.calendar = calendar

        // Date formatter for displaying the month and year
        monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"

        // Date formatter for displaying weekdays
        weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale.current
        weekdayFormatter.dateFormat = "EEE"
    }

    private var displayMonth: String {
        guard let baseDate = calendar.date(byAdding: .weekOfYear, value: currentWeekIndex, to: Date()) else {
            return monthFormatter.string(from: Date())
        }
        return monthFormatter.string(from: baseDate)
    }

    private func resetToToday() {
        withAnimation(.spring(duration: 0.3, bounce: 0.2)) {
            currentWeekIndex = 0
            selectedDate = Date()
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            ZStack {
                // VStack(spacing: 4) {
                //     Text("History")
                //         .font(.headline)
                //         .foregroundColor(.primary)

                //     // Month
                //     Text(displayMonth)
                //         .font(.subheadline)
                //         .foregroundColor(.primary.opacity(0.8))
                // }

                // Month
                Text(displayMonth)
                    .font(.subheadline)
                    .foregroundColor(.primary.opacity(0.8))

                // Today Button
                HStack {
                    Spacer()
                    Button(action: resetToToday) {
                        Image(systemName: "calendar")
                            .foregroundColor(.primary.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal)

            // Calendar view
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Weekday Headers
                    HStack(spacing: 0) {
                        ForEach(0 ..< 7) { index in
                            Text(
                                weekdayFormatter.shortWeekdaySymbols[(index + calendar.firstWeekday - 1) % 7]
                                    .uppercased()
                            )
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary.opacity(0.8))
                            .frame(width: geometry.size.width / 7)
                        }
                    }
                    .padding(.vertical, 4)

                    // Paged Weeks
                    TabView(selection: $currentWeekIndex) {
                        // Limit the range to a reasonable number to optimize performance
                        ForEach(-52 ... 52, id: \.self) { weekOffset in
                            WeekView(
                                baseDate: Date(),
                                weekOffset: weekOffset,
                                selectedDate: selectedDate,
                                calendar: calendar,
                                geometry: geometry,
                                onDateSelected: { date in
                                    selectedDate = date
                                }
                            )
                            .tag(weekOffset)
                            .frame(width: geometry.size.width)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    // .animation(.easeInOut, value: currentWeekIndex)
                }
                .offset(y: 8)
            }
            .frame(height: 70) // Adjusted height to accommodate the week view
        }
        // .padding(.top)
    }
}

struct WeekView: View {
    let baseDate: Date
    let weekOffset: Int
    let selectedDate: Date
    let calendar: Calendar
    let geometry: GeometryProxy
    let onDateSelected: (Date) -> Void

    private var weekDates: [Date] {
        // Calculate the starting date of the week based on the offset
        guard let offsetDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: baseDate),
              let weekStart = calendar.date(from: calendar.dateComponents(
                  [.yearForWeekOfYear, .weekOfYear],
                  from: offsetDate
              ))
        else {
            return []
        }

        // Generate the dates for the week starting from Sunday
        return (0 ..< 7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: weekStart)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDates, id: \.self) { date in
                let isPastOrToday = date <= Calendar.current.startOfDay(for: Date())
                DateCell(
                    date: date,
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                    isPastOrToday: isPastOrToday
                )
                .frame(width: geometry.size.width / 7, height: 40)
                // Disable tap gestures for future dates
                .allowsHitTesting(isPastOrToday)
                .onTapGesture {
                    if isPastOrToday {
                        onDateSelected(date)
                    }
                }
            }
        }
    }
}

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    let isPastOrToday: Bool

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    var body: some View {
        Text(dayFormatter.string(from: date))
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? .black : (isPastOrToday ? .primary : .primary.opacity(0.5)))
            .frame(width: 32, height: 32)
            .background(
                isSelected ?
                    RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primary) :
                    nil
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    CalendarView(selectedDate: .constant(Date()))
}

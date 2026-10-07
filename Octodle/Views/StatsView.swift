import OctodleKit
import SwiftUI

struct StatsView: View {
    let api: OctordleAPI
    let uuid: String

    @State private var stat: FullStatResponse?
    @State private var error: String?

    var body: some View {
        List {
            if let error {
                Text(error).foregroundStyle(.red)
            }
            if let stat {
                Section("Сегодня") { dayRows(stat.today) }
                Section("Вчера") { dayRows(stat.yesterday) }
                Section("Мои игры") {
                    row("Обычный режим", "\(stat.personal.standart.count) игр, средний счет \(format(stat.personal.standart.average))")
                    row("Согра", "\(stat.personal.sogra.count) игр, средний счет \(format(stat.personal.sogra.average))")
                }
            } else if error == nil {
                ProgressView()
            }
        }
        .navigationTitle("Статистика")
        .task { await load() }
        .refreshable { await load() }
    }

    @ViewBuilder
    private func dayRows(_ day: DayStat) -> some View {
        row("Начали / закончили", "\(day.starts) / \(day.finish)")
        row("Средний счет", format(day.average))
        row("Медиана", format(day.median))
        row("Мин / макс", "\(day.min.map(String.init) ?? "—") / \(day.max.map(String.init) ?? "—")")
    }

    private func row(_ title: String, _ value: String) -> some View {
        LabeledContent(title, value: value)
    }

    private func format(_ value: Double?) -> String {
        value.map { String(format: "%.1f", $0) } ?? "—"
    }

    private func load() async {
        do {
            stat = try await api.fullStat(uuid: uuid)
            error = nil
        } catch {
            self.error = "Не удалось загрузить статистику"
        }
    }
}

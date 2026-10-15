import SwiftUI

/// You: a monogram, three numbers, the quotes you pinned, and a short More section.
struct ProfileScreen: View {
    @Environment(AppModel.self) private var model
    var preview = false
    @State private var editingName = false
    @State private var draftName = ""
    @State private var guide = false

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(left: "Profile", right: model.profile.name.isEmpty ? "" : model.profile.name)
            if preview {
                ProfileContent(preview: true, editName: beginEdit, showGuide: { guide = true }).padding(.horizontal, 28)
            } else {
                ScrollView {
                    ProfileContent(preview: false, editName: beginEdit, showGuide: { guide = true }).padding(.horizontal, 28)
                }
                .scrollIndicators(.hidden)
            }
        }
        .alert("Your name", isPresented: $editingName) {
            TextField("Name", text: $draftName)
            Button("Save") { model.setName(draftName) }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $guide) {
            WidgetGuideContent(close: { guide = false })
                .presentationDetents([.medium, .large])
                .presentationBackground(VirtusPalette.black)
        }
    }

    private func beginEdit() {
        draftName = model.profile.name
        editingName = true
    }
}

struct ProfileContent: View {
    @Environment(AppModel.self) private var model
    var preview: Bool
    var editName: () -> Void
    var showGuide: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Who
            VStack(spacing: 14) {
                Monogram(name: model.profile.name)
                Button(action: editName) {
                    Text(model.profile.name.isEmpty ? "Add your name" : model.profile.name)
                        .font(VirtusFont.body(18))
                        .foregroundStyle(model.profile.name.isEmpty ? VirtusPalette.inkFaint : VirtusPalette.ink)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 28)
            .padding(.bottom, 28)
            HStack {
                Stat(value: model.pinnedQuotes.count, label: "Pinned")
                Stat(value: model.daysOpened, label: "Days")
                Stat(value: model.streak, label: "Streak")
            }
            .padding(.bottom, 28)
            Hairline()

            // Pinned
            Caps("Pinned", size: 10, color: VirtusPalette.inkFaint, tracking: 3).padding(.top, 24)
            if model.pinnedQuotes.isEmpty {
                Text("Nothing pinned yet. Tap the pin under today’s quote.")
                    .font(VirtusFont.body(16)).foregroundStyle(VirtusPalette.inkSoft)
                    .padding(.vertical, 24)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                let quotes = preview ? Array(model.pinnedQuotes.prefix(2)) : model.pinnedQuotes
                ForEach(quotes) { quote in
                    let featured = model.featured?.id == quote.id
                    Button {
                        model.selected = quote
                    } label: {
                        QuoteRow(quote: quote, caption: featured ? "On your widget" : quote.source, pinned: false, featured: featured)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        if !featured { Button("Feature on widget", systemImage: "star") { model.feature(quote) } }
                        Button("Unpin", systemImage: "pin.slash", role: .destructive) { model.unpin(quote) }
                    }
                    Hairline()
                }
            }

            // More
            Caps("More", size: 10, color: VirtusPalette.inkFaint, tracking: 3).padding(.top, 28)
            ReminderRow().padding(.vertical, 12)
            Hairline()
            Button(action: showGuide) {
                HStack {
                    Text("Add a widget").font(VirtusFont.body(17)).foregroundStyle(VirtusPalette.ink)
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .light)).foregroundStyle(VirtusPalette.inkFaint)
                }
                .padding(.vertical, 18)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Hairline()
            Caps("\(QuoteLibrary.all.count) quotations", size: 9, color: VirtusPalette.inkFaint, tracking: 2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
        }
    }
}

/// Daily reminder on/off with its time.
struct ReminderRow: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let on = Binding(get: { model.profile.reminderOn },
                         set: { model.setReminder(on: $0, hour: model.profile.reminderHour, minute: model.profile.reminderMinute) })
        let time = Binding<Date>(
            get: { model.calendar.date(bySettingHour: model.profile.reminderHour, minute: model.profile.reminderMinute, second: 0, of: model.now) ?? model.now },
            set: {
                let c = model.calendar.dateComponents([.hour, .minute], from: $0)
                model.setReminder(on: model.profile.reminderOn, hour: c.hour ?? 7, minute: c.minute ?? 0)
            })
        VStack(spacing: 10) {
            Toggle(isOn: on) {
                Text("Daily reminder").font(VirtusFont.body(17)).foregroundStyle(VirtusPalette.ink)
            }
            .tint(VirtusPalette.gold)
            if model.profile.reminderOn {
                DatePicker("Time", selection: time, displayedComponents: .hourAndMinute)
                    .font(VirtusFont.body(15))
                    .foregroundStyle(VirtusPalette.inkSoft)
                    .tint(VirtusPalette.gold)
            }
        }
        .padding(.vertical, 6)
    }
}

import SwiftUI

struct LogbookListView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = LogbookViewModel()
    @State private var showNewDive   = false
    @State private var showExportShare = false
    @State private var exportData: Data?
    @State private var showFilters   = false
    @State private var diveToDelete: Dive?

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.dives.isEmpty {
                    LoadingView()
                } else if let err = vm.errorMessage, vm.dives.isEmpty {
                    ErrorView(message: err) { Task { await vm.loadInitial() } }
                } else {
                    mainContent
                }
            }
            .navigationTitle("nav.logbook")
            .searchable(text: $vm.searchText, prompt: "logbook.search")
            .toolbar { toolbarItems }
            .task { await vm.loadInitial() }
            .refreshable { await vm.refresh() }
            .sheet(isPresented: $showNewDive) {
                NewDiveView(isDiabetic: authVM.currentUser?.sdRole.isDiabetic == true) {
                    Task { await vm.loadInitial() }
                }
            }
            .sheet(isPresented: $showFilters) {
                DiveFiltersView(filters: $vm.filters) {
                    Task { await vm.loadInitial() }
                }
            }
            .confirmationDialog("logbook.delete_confirm", isPresented: Binding(
                get: { diveToDelete != nil },
                set: { if !$0 { diveToDelete = nil } }
            ), titleVisibility: .visible) {
                Button("delete", role: .destructive) {
                    if let d = diveToDelete {
                        Task { await vm.delete(dive: d) }
                    }
                    diveToDelete = nil
                }
                Button("cancel", role: .cancel) { diveToDelete = nil }
            }
        }
    }

    // ── Contenuto principale ──────────────────────────────────────────────

    private var mainContent: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {

                // ── Stats cards ──────────────────────────────────────────
                if let s = vm.stats?.summary {
                    statsCards(s)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                }

                // ── Lista immersioni ─────────────────────────────────────
                Section {
                    if vm.filteredDives.isEmpty {
                        emptyState
                    } else {
                        ForEach(vm.filteredDives) { dive in
                            NavigationLink(destination: DiveDetailView(diveID: dive.id)) {
                                DiveRowView(dive: dive)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    diveToDelete = dive
                                } label: {
                                    Label("delete", systemImage: "trash")
                                }
                            }
                        }

                        // Carica altri
                        if vm.isLoadingMore {
                            ProgressView().padding()
                        } else if vm.filteredDives.count >= 20 {
                            Color.clear
                                .onAppear { Task { await vm.loadMore() } }
                        }
                    }
                } header: {
                    HStack {
                        Text("logbook.dives_count \(vm.filteredDives.count)")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button { showFilters = true } label: {
                            Label("logbook.filters", systemImage: filtersActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                .font(.footnote)
                                .foregroundStyle(filtersActive ? Color("AccentColor") : .secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                }
            }
            .padding(.bottom, 32)
        }
    }

    // ── Stats cards ───────────────────────────────────────────────────────

    private func statsCards(_ s: DiveSummary) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatsCard(value: "\(s.totalDives)", label: "stats.total_dives",    icon: "figure.open.water.swim", color: .blue)
                StatsCard(value: "\(Int(s.maxDepthEver))m", label: "stats.max_depth", icon: "arrow.down.to.line",    color: .indigo)
                StatsCard(value: s.totalHours,     label: "stats.total_time",     icon: "clock.fill",             color: .teal)
                StatsCard(value: "\(s.uniqueSites)",label: "stats.unique_sites",  icon: "mappin.and.ellipse",     color: .orange)
            }
        }
    }

    // ── Stato vuoto ───────────────────────────────────────────────────────

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 52))
                .foregroundStyle(Color("AccentColor").opacity(0.4))
                .padding(.top, 48)
            Text("logbook.empty.title")
                .font(.headline)
            Text("logbook.empty.subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            SDButton(title: "logbook.add_first_dive") {
                showNewDive = true
            }
            .frame(maxWidth: 220)
        }
        .padding()
    }

    // ── Toolbar ───────────────────────────────────────────────────────────

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                Task {
                    if let data = await vm.exportCSV() {
                        exportData = data
                        showExportShare = true
                    }
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button { showNewDive = true } label: {
                Image(systemName: "plus")
            }
        }
    }

    private var filtersActive: Bool {
        vm.filters.dateFrom != nil || vm.filters.dateTo != nil || vm.filters.site != nil
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - DiveRowView
// ─────────────────────────────────────────────────────────────────────────────

struct DiveRowView: View {
    let dive: Dive

    var body: some View {
        HStack(spacing: 14) {
            // Numero immersione
            Text("#\(dive.diveNumber)")
                .font(.caption.monospacedDigit().bold())
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color("AccentColor"))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(dive.site)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let depth = dive.maxDepth {
                        Label("\(Int(depth))m", systemImage: "arrow.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let dur = dive.diveDuration {
                        Label(dur, systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Note immersione
                if let notes = dive.notes, !notes.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "note.text")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.top, 2)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let tin = dive.timeIn {
                    Text(String(tin.prefix(5)))
                        .font(.caption2)
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Design.cornerRadius))
    }

    private var formattedDate: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        guard let d = df.date(from: dive.diveDate) else { return dive.diveDate }
        df.dateStyle = .medium; df.dateFormat = nil
        return df.string(from: d)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - StatsCard
// ─────────────────────────────────────────────────────────────────────────────

struct StatsCard: View {
    let value: String
    let label: LocalizedStringKey
    let icon:  String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold().monospacedDigit())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(width: 120)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Design.cornerRadius))
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - DiveFiltersView
// ─────────────────────────────────────────────────────────────────────────────

struct DiveFiltersView: View {
    @Binding var filters: DiveFilters
    let onApply: () -> Void
    @Environment(\.dismiss) var dismiss

    @State private var dateFrom = Date()
    @State private var dateTo   = Date()
    @State private var site     = ""
    @State private var useDateFrom = false
    @State private var useDateTo   = false

    private let df: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()

    var body: some View {
        NavigationStack {
            Form {
                Section("logbook.filter.date") {
                    Toggle("logbook.filter.date_from", isOn: $useDateFrom)
                    if useDateFrom { DatePicker("", selection: $dateFrom, displayedComponents: .date).labelsHidden() }
                    Toggle("logbook.filter.date_to",   isOn: $useDateTo)
                    if useDateTo   { DatePicker("", selection: $dateTo,   displayedComponents: .date).labelsHidden() }
                }
                Section("logbook.filter.site") {
                    TextField("logbook.filter.site_placeholder", text: $site)
                }
            }
            .navigationTitle("logbook.filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("logbook.filter.apply") {
                        filters.dateFrom = useDateFrom ? df.string(from: dateFrom) : nil
                        filters.dateTo   = useDateTo   ? df.string(from: dateTo)   : nil
                        filters.site     = site.isEmpty ? nil : site
                        onApply()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("logbook.filter.reset") {
                        filters = DiveFilters()
                        useDateFrom = false; useDateTo = false; site = ""
                        onApply()
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
            }
            .onAppear {
                if let v = filters.dateFrom, let d = df.date(from: v) { dateFrom = d; useDateFrom = true }
                if let v = filters.dateTo,   let d = df.date(from: v) { dateTo   = d; useDateTo   = true }
                site = filters.site ?? ""
            }
        }
    }
}

import SwiftUI
import Combine

@MainActor
final class LogbookViewModel: ObservableObject {

    // ── Stato pubblico ────────────────────────────────────────────────────
    @Published var dives:        [Dive]      = []
    @Published var stats:        DiveStats?  = nil
    @Published var sessions:     [DiveSession] = []
    @Published var isLoading     = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var filters       = DiveFilters()
    @Published var searchText    = ""

    // Paginazione
    private var currentPage  = 1
    private var hasMore      = true
    private let perPage      = 20

    private let diveService    = DiveService()
    private let diabetesService = DiabetesService()

    // ── Carica logbook ────────────────────────────────────────────────────

    func loadInitial() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        hasMore = true
        defer { isLoading = false }

        async let divesResult  = diveService.list(page: 1, perPage: perPage, filters: filters)
        async let statsResult  = diveService.stats()

        do {
            let (d, s) = try await (divesResult, statsResult)
            dives  = d
            stats  = s
            hasMore = d.count == perPage
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMore() async {
        guard hasMore, !isLoadingMore, !isLoading else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextPage = currentPage + 1
        do {
            let more = try await diveService.list(page: nextPage, perPage: perPage, filters: filters)
            dives.append(contentsOf: more)
            currentPage = nextPage
            hasMore = more.count == perPage
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        await loadInitial()
    }

    // ── Elimina immersione ────────────────────────────────────────────────

    func delete(dive: Dive) async {
        do {
            try await diveService.delete(id: dive.id)
            dives.removeAll { $0.id == dive.id }
            // Aggiorna stats
            if stats != nil {
                // Reload stats silenziosamente
                if let newStats = try? await diveService.stats() {
                    stats = newStats
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // ── Export CSV ────────────────────────────────────────────────────────

    func exportCSV() async -> Data? {
        do {
            return try await diveService.exportCSV()
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    // ── Dives filtrati localmente per ricerca ─────────────────────────────

    var filteredDives: [Dive] {
        guard !searchText.isEmpty else { return dives }
        let q = searchText.lowercased()
        return dives.filter {
            $0.site.lowercased().contains(q) ||
            ($0.diveDate.contains(q)) ||
            ($0.notes?.lowercased().contains(q) == true)
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────

@MainActor
final class DiveDetailViewModel: ObservableObject {

    @Published var dive:         Dive?
    @Published var diabetesData: DiabetesData?
    @Published var nutrition:    [NutritionEntry] = []
    @Published var isLoading     = false
    @Published var errorMessage: String?

    private let diveService     = DiveService()
    private let diabetesService = DiabetesService()

    func load(diveID: Int) async {
        isLoading = true
        defer { isLoading = false }
        do {
            #if DEBUG
            print("🌊 DiveDetailVM.load(diveID: \(diveID))")
            #endif
            let detail   = try await diveService.detail(id: diveID)
            dive         = detail.dive
            diabetesData = detail.diabetesData
            nutrition    = detail.nutritionLog
            #if DEBUG
            print("✅ DiveDetailVM loaded: \(detail.dive.siteName) id=\(detail.dive.id)")
            #endif
        } catch {
            #if DEBUG
            print("❌ DiveDetailVM error: \(error)")
            #endif
            errorMessage = error.localizedDescription
        }
    }

    func saveDiabetesData(_ body: [String: Any]) async {
        guard let diveID = dive?.id else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            diabetesData = try await diabetesService.upsert(diveID: diveID, body: body)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────

@MainActor
final class NewDiveViewModel: ObservableObject {

    // Campi immersione
    @Published var diveDate      = Date()
    @Published var site          = ""
    @Published var timeIn        = Date()
    @Published var timeOut       = Date().addingTimeInterval(3600)
    @Published var maxDepth      = ""
    @Published var tankVolume    = "12"
    @Published var gasMix        = "Aria"
    @Published var ballast       = ""
    @Published var entryType     = "Riva"
    @Published var weather       = ""
    @Published var airTemp       = ""
    @Published var waterTemp     = ""
    @Published var visibility    = ""
    @Published var suit          = ""
    @Published var buddyName     = ""
    @Published var notes         = ""

    // Dati glicemici (mostrati solo se diabetico)
    @Published var showDiabetesSection = false
    @Published var glicPre60   = ""
    @Published var glicPre30   = ""
    @Published var glicPre10   = ""
    @Published var glicPost    = ""
    @Published var trendPre10  = "→"
    @Published var choRapidi   = ""
    @Published var choLenti    = ""
    @Published var diveDecision = "allowed"
    @Published var hypoDuringDive = false
    @Published var pumpDisconnected = false
    @Published var cgmUsed = false

    @Published var isLoading     = false
    @Published var errorMessage: String?
    @Published var savedDive:    Dive?

    private let diveService     = DiveService()
    private let diabetesService = DiabetesService()

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "HH:mm:ss"; return f
    }()
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()

    var isValid: Bool { !site.trimmingCharacters(in: .whitespaces).isEmpty }

    func save(isDiabetic: Bool) async {
        guard isValid else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var body: [String: Any] = [
            "dive_date":  dateFormatter.string(from: diveDate),
            "site":       site.trimmingCharacters(in: .whitespaces),
            "time_in":    timeFormatter.string(from: timeIn),
            "time_out":   timeFormatter.string(from: timeOut),
        ]
        if let d = Double(maxDepth)   { body["max_depth"]    = d }
        if let v = Int(tankVolume)    { body["tank_volume"]  = v }
        if !gasMix.isEmpty            { body["gas_mix"]      = gasMix }
        if let b = Double(ballast)    { body["ballast_kg"]   = b }
        if !entryType.isEmpty         { body["entry_type"]   = entryType }
        if !weather.isEmpty           { body["weather"]      = weather }
        if let t = Double(airTemp)    { body["air_temp"]     = t }
        if let t = Double(waterTemp)  { body["water_temp_surface"] = t }
        if let v = Int(visibility)    { body["visibility_m"] = v }
        if !suit.isEmpty              { body["suit_type"]    = suit }
        if !buddyName.isEmpty         { body["buddy_name"]   = buddyName }
        if !notes.isEmpty             { body["notes"]        = notes }

        do {
            let dive = try await diveService.create(body)
            savedDive = dive

            // Salva dati glicemici se diabetico
            if isDiabetic && showDiabetesSection {
                var db: [String: Any] = ["dive_decision": diveDecision]
                if let v = Double(glicPre60)  { db["glic_pre60"]  = v }
                if let v = Double(glicPre30)  { db["glic_pre30"]  = v }
                if let v = Double(glicPre10)  { db["glic_pre10"]  = v }
                if let v = Double(glicPost)   { db["glic_post"]   = v }
                if let v = Double(choRapidi)  { db["cho_rapidi_pre10"] = v }
                if let v = Double(choLenti)   { db["cho_lenti_pre10"]  = v }
                db["trend_pre10"]        = trendPre10
                db["hypo_during_dive"]   = hypoDuringDive
                db["pump_disconnected"]  = pumpDisconnected
                db["cgm_used"]           = cgmUsed
                _ = try? await diabetesService.upsert(diveID: dive.id, body: db)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

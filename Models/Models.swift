import Foundation
import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Auth Models
// ─────────────────────────────────────────────────────────────────────────────

struct LoginResponse: Decodable {
    let accessToken:  String
    let refreshToken: String
    let tokenType:    String
    let expiresIn:    Int
    let user:         SDUser
}

struct TokenPair: Decodable {
    let accessToken:  String
    let refreshToken: String
    let expiresIn:    Int
}

struct SDUser: Decodable, Identifiable {
    let id:          Int
    let email:       String
    let displayName: String?   // assente in /profile, presente in /auth/login
    let firstName:   String
    let lastName:    String
    let role:        String?   // assente in /profile
    let avatarUrl:   String?
    let profile:     HealthProfileSummary?

    var sdRole: AppConstants.Role { AppConstants.Role(rawValue: role ?? "") ?? .subscriber }
    var fullName: String { "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces) }
    var displayNameOrFull: String { displayName ?? fullName }
}

struct HealthProfileSummary: Decodable {
    let isDiabetic:           Bool?
    let diabetesType:         String?
    let certificationLevel:   String?
    let certificationAgency:  String?
}

struct MessageResponse: Decodable {
    let message: String
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Dive Models
// ─────────────────────────────────────────────────────────────────────────────

struct Dive: Decodable, Identifiable {

    var id:          Int
    var userId:      Int
    var diveNumber:  Int
    var sessionId:   Int?
    let diveDate:    String
    let siteName:    String
    let timeIn:      String?
    let timeOut:     String?
    var maxDepth:    Double?
    var avgDepth:    Double?
    var diveTime:    Int?
    var tankCapacity: Int?
    let gasMix:      String?
    var ballastKg:   Double?
    let entryType:   String?
    let weather:     String?
    var tempAir:     Double?
    var tempWater:   Double?
    let suitType:    String?
    let visibility:  String?
    let seaCondition: String?
    let sightings:   String?
    let notes:       String?
    let buddyName:   String?
    let guideName:   String?
    let createdAt:   String?

    // Alias per compatibilità View
    var site: String { siteName }
    var airTemp: Double? { tempAir }
    var waterTempSurface: Double? { tempWater }

    // Custom decode: tutti i numeri arrivano come String dal plugin PHP
    // CodingKeys espliciti + decodeIfPresent per campi opzionali assenti
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id           = Self.flexInt(c, .id)          ?? 0
        userId       = Self.flexInt(c, .userId)      ?? 0
        diveNumber   = Self.flexInt(c, .diveNumber)  ?? 0
        sessionId    = Self.flexIntOpt(c, .sessionId)
        diveDate     = (try? c.decodeIfPresent(String.self, forKey: .diveDate))   ?? ""
        siteName     = (try? c.decodeIfPresent(String.self, forKey: .siteName))   ?? ""
        timeIn       = try? c.decodeIfPresent(String.self, forKey: .timeIn)
        timeOut      = try? c.decodeIfPresent(String.self, forKey: .timeOut)
        maxDepth     = Self.flexDbl(c, .maxDepth)
        avgDepth     = Self.flexDbl(c, .avgDepth)
        diveTime     = Self.flexIntOpt(c, .diveTime)
        tankCapacity = Self.flexIntOpt(c, .tankCapacity)
        gasMix       = try? c.decodeIfPresent(String.self, forKey: .gasMix)
        ballastKg    = Self.flexDbl(c, .ballastKg)
        entryType    = try? c.decodeIfPresent(String.self, forKey: .entryType)
        weather      = try? c.decodeIfPresent(String.self, forKey: .weather)
        tempAir      = Self.flexDbl(c, .tempAir)
        tempWater    = Self.flexDbl(c, .tempWater)
        suitType     = try? c.decodeIfPresent(String.self, forKey: .suitType)
        visibility   = try? c.decodeIfPresent(String.self, forKey: .visibility)
        seaCondition = try? c.decodeIfPresent(String.self, forKey: .seaCondition)
        sightings    = try? c.decodeIfPresent(String.self, forKey: .sightings)
        notes        = try? c.decodeIfPresent(String.self, forKey: .notes)
        buddyName    = try? c.decodeIfPresent(String.self, forKey: .buddyName)
        guideName    = try? c.decodeIfPresent(String.self, forKey: .guideName)
        createdAt    = try? c.decodeIfPresent(String.self, forKey: .createdAt)
        #if DEBUG
        print("🔍 Dive decode: id=\(id) diveNumber=\(diveNumber) siteName=\(siteName)")
        #endif
    }

    private static func flexInt(_ c: KeyedDecodingContainer<CodingKeys>, _ k: CodingKeys) -> Int? {
        if let v = try? c.decode(Int.self,    forKey: k) { return v }
        if let s = try? c.decode(String.self, forKey: k) { return Int(s) }
        return nil
    }
    private static func flexIntOpt(_ c: KeyedDecodingContainer<CodingKeys>, _ k: CodingKeys) -> Int? {
        if (try? c.decodeNil(forKey: k)) == true { return nil }
        if let v = try? c.decode(Int.self,    forKey: k) { return v }
        if let s = try? c.decode(String.self, forKey: k) { return Int(s) }
        return nil
    }
    private static func flexDbl(_ c: KeyedDecodingContainer<CodingKeys>, _ k: CodingKeys) -> Double? {
        if (try? c.decodeNil(forKey: k)) == true { return nil }
        if let v = try? c.decode(Double.self, forKey: k) { return v }
        if let s = try? c.decode(String.self, forKey: k) { return Double(s) }
        return nil
    }

    // Con convertFromSnakeCase attivo, le chiavi JSON vengono convertite
    // PRIMA di essere messe nel container, anche in custom init.
    // Quindi "dive_number" → container key "diveNumber" → rawValue deve essere "diveNumber"
    enum CodingKeys: String, CodingKey {
        case id, weather, sightings, notes, visibility
        case userId       = "userId"        // user_id
        case diveNumber   = "diveNumber"    // dive_number
        case sessionId    = "sessionId"     // session_id
        case diveDate     = "diveDate"      // dive_date
        case siteName     = "siteName"      // site_name
        case timeIn       = "timeIn"        // time_in
        case timeOut      = "timeOut"       // time_out
        case maxDepth     = "maxDepth"      // max_depth
        case avgDepth     = "avgDepth"      // avg_depth
        case diveTime     = "diveTime"      // dive_time
        case tankCapacity = "tankCapacity"  // tank_capacity
        case gasMix       = "gasMix"        // gas_mix
        case ballastKg    = "ballastKg"     // ballast_kg
        case entryType    = "entryType"     // entry_type
        case tempAir      = "tempAir"       // temp_air
        case tempWater    = "tempWater"     // temp_water
        case suitType     = "suitType"      // suit_type
        case seaCondition = "seaCondition"  // sea_condition
        case buddyName    = "buddyName"     // buddy_name
        case guideName    = "guideName"     // guide_name
        case createdAt    = "createdAt"     // created_at
    }

    var diveDuration: String? {
        guard let tin = timeIn, let tout = timeOut,
              let inDate  = timeFormatter.date(from: tin),
              let outDate = timeFormatter.date(from: tout) else {
            if let m = diveTime {
                let h = m / 60, mm = m % 60
                return h > 0 ? "\(h)h \(mm)min" : "\(mm)min"
            }
            return nil
        }
        let mins = Int(outDate.timeIntervalSince(inDate) / 60)
        let h = mins / 60, m = mins % 60
        return h > 0 ? "\(h)h \(m)min" : "\(m)min"
    }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter(); f.dateFormat = "HH:mm:ss"; return f
    }
}


struct DiveDetail: Decodable {
    let dive:         Dive
    let diabetesData: DiabetesData?
    let nutritionLog: [NutritionEntry]

    // L'API ritorna dive + diabetes_data + nutrition_log nello stesso oggetto flat.
    // Con convertFromSnakeCase attivo: "diabetes_data" → chiave "diabetesData",
    // quindi il CodingKey deve usare il nome camelCase come raw value.
    private enum CodingKeys: String, CodingKey {
        case diabetesData = "diabetesData"
        case nutritionLog = "nutritionLog"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        diabetesData = try c.decodeIfPresent(DiabetesData.self, forKey: .diabetesData)
        nutritionLog = try c.decodeIfPresent([NutritionEntry].self, forKey: .nutritionLog) ?? []
        dive = try Dive(from: decoder) // decode flat usando i CodingKeys di Dive
    }
}

struct DiveSession: Decodable, Identifiable {
    let id:          Int
    let userId:      Int
    let sessionDate: String
    let notes:       String?
    let weather:     String?
    let diveCount:   Int?
    let createdAt:   String?
}

struct DiveStats: Decodable {
    let summary:   DiveSummary?   // null quando nessun dive registrato
    let byYear:    [YearCount]
    let topSites:  [SiteCount]
}

struct DiveSummary: Decodable {
    let totalDives:    Int
    let totalDepth:    Double
    let maxDepthEver:  Double
    let avgDepth:      Double
    let uniqueSites:   Int
    let diveDays:      Int
    let totalMinutes:  Int
    let firstDiveDate: String?
    let lastDiveDate:  String?

    var totalHours: String {
        let h = totalMinutes / 60, m = totalMinutes % 60
        return "\(h)h \(m)min"
    }
}

struct YearCount: Decodable, Identifiable {
    var id: String { year }
    let year:  String
    @FlexInt var count: Int
}

struct SiteCount: Decodable, Identifiable {
    var id: String { site }
    let site:  String
    let count: Int
}

struct DiveFilters {
    var dateFrom: String?
    var dateTo:   String?
    var site:     String?
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Diabetes Models
// ─────────────────────────────────────────────────────────────────────────────

struct DiabetesData: Decodable, Identifiable {
    // NOTA: il decoder usa .convertFromSnakeCase
    // quindi "glic_60_value" → CodingKey "glic60Value" (non "glic_60_value")
    var id:     Int
    var diveId: Int
    // Checkpoint -60
    var glicPre60:      Double?
    var methodPre60:    String?
    var trendPre60:     String?
    var choRapitiPre60: Double?
    var choLentiPre60:  Double?
    var insulinPre60:   Double?
    var notesPre60:     String?
    // Checkpoint -30
    var glicPre30:      Double?
    var methodPre30:    String?
    var trendPre30:     String?
    var choRapitiPre30: Double?
    var choLentiPre30:  Double?
    var insulinPre30:   Double?
    var notesPre30:     String?
    // Checkpoint -10
    var glicPre10:      Double?
    var methodPre10:    String?
    var trendPre10:     String?
    var choRapitiPre10: Double?
    var choLentiPre10:  Double?
    var insulinPre10:   Double?
    var notesPre10:     String?
    // Post
    var glicPost:       Double?
    var methodPost:     String?
    var trendPost:      String?
    var notesPost:      String?
    // Decisione
    var diveDecision:       String?
    var diveDecisionReason: String?
    // Flags
    var pumpDisconnected: Bool?
    var hypoDuringDive:   Bool?
    var hypoTreatment:    String?
    var diabetesNotes:    String?   // colonna: diabetes_notes

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id     = Self.fi(c, .id)     ?? 0
        diveId = Self.fi(c, .diveId) ?? 0

        glicPre60      = Self.fd(c, .glicPre60)
        methodPre60    = try? c.decodeIfPresent(String.self, forKey: .methodPre60)
        trendPre60     = try? c.decodeIfPresent(String.self, forKey: .trendPre60)
        choRapitiPre60 = Self.fd(c, .choRapitiPre60)
        choLentiPre60  = Self.fd(c, .choLentiPre60)
        insulinPre60   = Self.fd(c, .insulinPre60)
        notesPre60     = try? c.decodeIfPresent(String.self, forKey: .notesPre60)

        glicPre30      = Self.fd(c, .glicPre30)
        methodPre30    = try? c.decodeIfPresent(String.self, forKey: .methodPre30)
        trendPre30     = try? c.decodeIfPresent(String.self, forKey: .trendPre30)
        choRapitiPre30 = Self.fd(c, .choRapitiPre30)
        choLentiPre30  = Self.fd(c, .choLentiPre30)
        insulinPre30   = Self.fd(c, .insulinPre30)
        notesPre30     = try? c.decodeIfPresent(String.self, forKey: .notesPre30)

        glicPre10      = Self.fd(c, .glicPre10)
        methodPre10    = try? c.decodeIfPresent(String.self, forKey: .methodPre10)
        trendPre10     = try? c.decodeIfPresent(String.self, forKey: .trendPre10)
        choRapitiPre10 = Self.fd(c, .choRapitiPre10)
        choLentiPre10  = Self.fd(c, .choLentiPre10)
        insulinPre10   = Self.fd(c, .insulinPre10)
        notesPre10     = try? c.decodeIfPresent(String.self, forKey: .notesPre10)

        glicPost   = Self.fd(c, .glicPost)
        methodPost = try? c.decodeIfPresent(String.self, forKey: .methodPost)
        trendPost  = try? c.decodeIfPresent(String.self, forKey: .trendPost)
        notesPost  = try? c.decodeIfPresent(String.self, forKey: .notesPost)

        diveDecision       = try? c.decodeIfPresent(String.self, forKey: .diveDecision)
        diveDecisionReason = try? c.decodeIfPresent(String.self, forKey: .diveDecisionReason)

        pumpDisconnected = Self.fb(c, .pumpDisconnected)
        hypoDuringDive   = Self.fb(c, .hypoDuringDive)
        hypoTreatment    = try? c.decodeIfPresent(String.self, forKey: .hypoTreatment)
        diabetesNotes    = try? c.decodeIfPresent(String.self, forKey: .diabetesNotes)
    }

    // Flex helpers: accettano String o numero dal JSON
    private static func fi(_ c: KeyedDecodingContainer<CodingKeys>, _ k: CodingKeys) -> Int? {
        if let v = try? c.decode(Int.self,    forKey: k) { return v }
        if let s = try? c.decode(String.self, forKey: k) { return Int(s) }
        return nil
    }
    private static func fd(_ c: KeyedDecodingContainer<CodingKeys>, _ k: CodingKeys) -> Double? {
        if (try? c.decodeNil(forKey: k)) == true { return nil }
        if let v = try? c.decode(Double.self, forKey: k) { return v }
        if let s = try? c.decode(String.self, forKey: k) { return Double(s) }
        return nil
    }
    private static func fb(_ c: KeyedDecodingContainer<CodingKeys>, _ k: CodingKeys) -> Bool? {
        if (try? c.decodeNil(forKey: k)) == true { return nil }
        if let v = try? c.decode(Bool.self,   forKey: k) { return v }
        if let s = try? c.decode(String.self, forKey: k) { return s == "1" || s == "true" }
        if let i = try? c.decode(Int.self,    forKey: k) { return i == 1 }
        return nil
    }

    // CodingKeys nella forma camelCase prodotta da convertFromSnakeCase:
    // "glic_60_value" → "glic60Value"
    enum CodingKeys: String, CodingKey {
        case id
        case diveId             = "diveId"              // dive_id
        case glicPre60          = "glic60Value"          // glic_60_value
        case methodPre60        = "glic60Method"         // glic_60_method
        case trendPre60         = "glic60Trend"          // glic_60_trend
        case choRapitiPre60     = "glic60ChoRapidi"      // glic_60_cho_rapidi
        case choLentiPre60      = "glic60ChoLenti"       // glic_60_cho_lenti
        case insulinPre60       = "glic60Insulin"        // glic_60_insulin
        case notesPre60         = "glic60Notes"          // glic_60_notes
        case glicPre30          = "glic30Value"          // glic_30_value
        case methodPre30        = "glic30Method"         // glic_30_method
        case trendPre30         = "glic30Trend"          // glic_30_trend
        case choRapitiPre30     = "glic30ChoRapidi"      // glic_30_cho_rapidi
        case choLentiPre30      = "glic30ChoLenti"       // glic_30_cho_lenti
        case insulinPre30       = "glic30Insulin"        // glic_30_insulin
        case notesPre30         = "glic30Notes"          // glic_30_notes
        case glicPre10          = "glic10Value"          // glic_10_value
        case methodPre10        = "glic10Method"         // glic_10_method
        case trendPre10         = "glic10Trend"          // glic_10_trend
        case choRapitiPre10     = "glic10ChoRapidi"      // glic_10_cho_rapidi
        case choLentiPre10      = "glic10ChoLenti"       // glic_10_cho_lenti
        case insulinPre10       = "glic10Insulin"        // glic_10_insulin
        case notesPre10         = "glic10Notes"          // glic_10_notes
        case glicPost           = "glicPostValue"        // glic_post_value
        case methodPost         = "glicPostMethod"       // glic_post_method
        case trendPost          = "glicPostTrend"        // glic_post_trend
        case notesPost          = "glicPostNotes"        // glic_post_notes
        case diveDecision       = "diveDecision"         // dive_decision
        case diveDecisionReason = "diveDecisionReason"   // dive_decision_reason
        case pumpDisconnected   = "pumpDisconnected"     // pump_disconnected
        case hypoDuringDive     = "hypoDuringDive"       // hypo_during_dive
        case hypoTreatment      = "hypoTreatment"        // hypo_treatment
        case diabetesNotes      = "diabetesNotes"        // diabetes_notes
    }

    var decisionColor: Color {
        switch diveDecision {
        case "autorizzata": return .green
        case "posticipata": return .orange
        case "annullata":   return .red
        default:            return .gray
        }
    }
}

struct NutritionEntry: Decodable, Identifiable {
    let id:          Int
    let diveId:      Int
    let mealType:    String
    let description: String?
    let calories:    Int?
    let choGrams:    Double?
    let liquidsMl:   Int?
    let notes:       String?
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Profile Models
// ─────────────────────────────────────────────────────────────────────────────

struct DiverProfile: Decodable {
    let user:              SDUser
    let health:            HealthProfile?
    let certifications:    [Certification]
    let clearances:        [MedicalClearance]
    let emergencyContacts: [EmergencyContact]
}

struct HealthProfile: Decodable {
    let id:              Int?
    let userId:          Int?
    let isDiabetic:      Bool?
    let diabetesType:    String?
    let therapyType:     String?
    let hba1c:           Double?
    let cgmDevice:       String?
    let insulinPumpModel:String?
    let bloodType:       String?
    let allergies:       String?
    let medications:     String?
    let notes:           String?
}

struct Certification: Decodable, Identifiable {
    // id assente in /profile (lista), presente dopo add/update → default 0
    var id:     Int
    let level:  String
    let agency: String
    let date:   String
    let number: String?
    let notes:  String?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id     = (try? c.decodeIfPresent(Int.self, forKey: .id)) ?? 0
        level  = (try? c.decode(String.self, forKey: .level))  ?? ""
        agency = (try? c.decode(String.self, forKey: .agency)) ?? ""
        date   = (try? c.decode(String.self, forKey: .date))   ?? ""
        number = try? c.decodeIfPresent(String.self, forKey: .number)
        notes  = try? c.decodeIfPresent(String.self, forKey: .notes)
    }

    enum CodingKeys: String, CodingKey {
        case id, level, agency, date, number, notes
    }
}

struct MedicalClearance: Decodable, Identifiable {
    let id:           Int
    let year:         Int
    let validUntil:   String
    let doctor:       String?
    let outcome:      String?
    let notes:        String?
    let documentUrl:  String?
    let documentName: String?
    let approvedBy:   Int?
    let approvedAt:   String?
    let approvedNotes:String?
}

struct EmergencyContact: Decodable, Identifiable {
    let id:           Int
    let name:         String
    let phone:        String
    let relationship: String?
    let email:        String?
    let notes:        String?
}

struct UploadResult: Decodable {
    let url:      String
    let filename: String
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Medical Models
// ─────────────────────────────────────────────────────────────────────────────

struct DiverSummary: Decodable, Identifiable {
    let userId:        Int
    let displayName:   String
    let firstName:     String
    let lastName:      String
    let email:         String
    let role:          String
    let profile:       HealthProfileSummary?
    let diveCount:     Int
    let lastDiveDate:  String?
    let lastClearance: MedicalClearance?

    var id: Int { userId }
}

struct MedicalDiverDetail: Decodable {
    let user:               SDUser
    let health:             HealthProfile?
    let certifications:     [Certification]
    let clearances:         [MedicalClearance]
    let emergencyContacts:  [EmergencyContact]
    let diveStats:          DiveSummary?
    let recentSupervisions: [Supervision]
}

struct DiveWithGlycemia: Decodable, Identifiable {
    let id:            Int
    let diveDate:      String
    let site:          String
    let maxDepth:      Double?
    let glicPre10:     Double?
    let glicPost:      Double?
    let diveDecision:  String?
    let hypoDuringDive: Bool?
    let trendPre10:    String?
}

struct Supervision: Decodable, Identifiable {
    let id:              Int
    let diveId:          Int
    let diverUserId:     Int
    let supervisorUserId:Int
    let supervisionType: String
    let status:          String
    let notes:           String?
    let supervisorName:  String?
    let createdAt:       String?
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Members Models
// ─────────────────────────────────────────────────────────────────────────────

struct Membership: Decodable, Identifiable {
    let id:             Int
    let userId:         Int
    let membershipType: String
    let status:         String
    let startDate:      String?
    let endDate:        String?
    let autoRenew:      Bool?
    let notes:          String?

    var isActive: Bool { status == "active" }
    var typeLabel: String {
        switch membershipType {
        case "family":    return String(localized: "membership.family")
        case "supporter": return String(localized: "membership.supporter")
        default:          return String(localized: "membership.individual")
        }
    }
}

struct Payment: Decodable, Identifiable {
    let id:            Int
    let userId:        Int
    let membershipId:  Int?
    let amount:        Double
    let currency:      String
    let paymentMethod: String
    let transactionId: String?
    let status:        String
    let paymentDate:   String?
    let notes:         String?
}

struct FamilyMember: Decodable, Identifiable {
    let id:           Int
    let membershipId: Int
    let userId:       Int?
    let firstName:    String
    let lastName:     String
    let email:        String?
    let relationship: String?

    var fullName: String { "\(firstName) \(lastName)" }
}

struct MemberRow: Decodable, Identifiable {
    let id:             Int
    let userId:         Int
    let membershipType: String
    let status:         String
    let displayName:    String?
    let userEmail:      String?
    let startDate:      String?
    let endDate:        String?
}

struct MemberDetail: Decodable {
    let membership: Membership
    let payments:   [Payment]
    let family:     [FamilyMember]
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Research Models
// ─────────────────────────────────────────────────────────────────────────────

struct ResearchOverview: Decodable {
    let kpi:            ResearchKPI
    let availableYears: [String]
}

struct ResearchKPI: Decodable {
    let totalDives:     Int
    let totalDivers:    Int
    let avgGlicPre10:   Double?
    let avgGlicPost:    Double?
    let hypoEvents:     Int
    let cancelledDives: Int
    let postponedDives: Int
    let yearsCovered:   Int
}

struct GlycemicDistribution: Decodable {
    let hypo:       Int
    let lowNormal:  Int
    let normal:     Int
    let highNormal: Int
    let hyper:      Int
    let total:      Int
}

struct CheckpointAverages: Decodable {
    let avgPre60: Double?
    let avgPre30: Double?
    let avgPre10: Double?
    let avgPost:  Double?
    let sdPre60:  Double?
    let sdPre30:  Double?
    let sdPre10:  Double?
    let sdPost:   Double?
    let nPre60:   Int
    let nPre30:   Int
    let nPre10:   Int
    let nPost:    Int
}

struct DecisionCount: Decodable, Identifiable {
    var id: String { diveDecision ?? "unknown" }
    let diveDecision: String?
    let count:        Int
}

struct TimelinePoint: Decodable, Identifiable {
    var id: String { period }
    let period:    String
    let avgPre10:  Double?
    let avgPost:   Double?
    let n:         Int
}

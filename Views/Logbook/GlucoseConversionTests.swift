import Testing
@testable import ScubaDiabetes

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Glucose Unit Conversion Tests
// ─────────────────────────────────────────────────────────────────────────────

@Suite("Glucose Unit Conversions")
struct GlucoseConversionTests {
    
    @Test("Convert mg/dL to mmol/L - Normal Range")
    func testMgDlToMmolLNormalRange() {
        let mgDl: Double = 100
        let mmol = mgDl.mgDlToMmolL
        
        // 100 mg/dL = 5.55 mmol/L (approx)
        #expect(mmol >= 5.54 && mmol <= 5.56, "100 mg/dL should convert to ~5.55 mmol/L")
    }
    
    @Test("Convert mmol/L to mg/dL - Normal Range")
    func testMmolLToMgDlNormalRange() {
        let mmol: Double = 5.5
        let mgDl = mmol.mmolLToMgDl
        
        // 5.5 mmol/L = 99.1 mg/dL (approx)
        #expect(mgDl >= 99.0 && mgDl <= 100.0, "5.5 mmol/L should convert to ~99 mg/dL")
    }
    
    @Test("Round-trip conversion mg/dL → mmol/L → mg/dL")
    func testRoundTripMgDl() {
        let original: Double = 126
        let converted = original.mgDlToMmolL.mmolLToMgDl
        
        // Allow 0.01 tolerance for floating point
        #expect(abs(converted - original) < 0.01, "Round-trip should preserve value")
    }
    
    @Test("Round-trip conversion mmol/L → mg/dL → mmol/L")
    func testRoundTripMmolL() {
        let original: Double = 7.0
        let converted = original.mmolLToMgDl.mgDlToMmolL
        
        // Allow 0.001 tolerance for floating point
        #expect(abs(converted - original) < 0.001, "Round-trip should preserve value")
    }
    
    @Test("Hypoglycemia threshold - 70 mg/dL")
    func testHypoglycemiaThreshold() {
        let mgDl: Double = 70
        let mmol = mgDl.mgDlToMmolL
        
        // 70 mg/dL = 3.88 mmol/L (approx)
        #expect(mmol >= 3.88 && mmol <= 3.89, "70 mg/dL should convert to ~3.88 mmol/L")
    }
    
    @Test("Hyperglycemia threshold - 180 mg/dL")
    func testHyperglycemiaThreshold() {
        let mgDl: Double = 180
        let mmol = mgDl.mgDlToMmolL
        
        // 180 mg/dL = 9.99 mmol/L (approx)
        #expect(mmol >= 9.99 && mmol <= 10.01, "180 mg/dL should convert to ~10.0 mmol/L")
    }
    
    @Test("Format glucose value for display - mg/dL")
    func testFormatMgDl() {
        let value: Double = 126.7
        let formatted = value.formatGlucose(unit: .mgDl)
        
        #expect(formatted == "127", "mg/dL should be rounded to whole number")
    }
    
    @Test("Format glucose value for display - mmol/L")
    func testFormatMmolL() {
        let value: Double = 126.0 // in mg/dL
        let formatted = value.formatGlucose(unit: .mmolL)
        
        // 126 mg/dL = 6.99 mmol/L
        #expect(formatted == "7.0", "mmol/L should have 1 decimal place")
    }
    
    @Test("Format optional glucose - nil value")
    func testFormatOptionalNil() {
        let value: Double? = nil
        let formatted = value.formatGlucose(unit: .mgDl)
        
        #expect(formatted == nil, "Nil value should return nil")
    }
    
    @Test("Format optional glucose - with value")
    func testFormatOptionalValue() {
        let value: Double? = 100.0
        let formatted = value.formatGlucose(unit: .mmolL)
        
        #expect(formatted != nil, "Non-nil value should return formatted string")
        #expect(formatted == "5.6", "100 mg/dL should format to 5.6 mmol/L")
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Privacy Logic Tests
// ─────────────────────────────────────────────────────────────────────────────

@Suite("Privacy Settings Logic")
struct PrivacySettingsTests {
    
    @Test("Profile default share enabled - new dive inherits")
    func testProfileDefaultShareEnabled() {
        // Simula profilo con condivisione attiva
        let profileShareForResearch = true
        let diveShareForResearch: Bool? = nil // NULL = usa default
        
        let effectiveShare = diveShareForResearch ?? profileShareForResearch
        
        #expect(effectiveShare == true, "Dive should inherit profile's share setting")
    }
    
    @Test("Profile default share disabled - new dive inherits")
    func testProfileDefaultShareDisabled() {
        // Simula profilo con condivisione disattivata
        let profileShareForResearch = false
        let diveShareForResearch: Bool? = nil // NULL = usa default
        
        let effectiveShare = diveShareForResearch ?? profileShareForResearch
        
        #expect(effectiveShare == false, "Dive should inherit profile's private setting")
    }
    
    @Test("Dive override - share when profile is private")
    func testDiveOverrideShareWhenProfilePrivate() {
        // Profilo privato, ma immersione condivisa
        let profileShareForResearch = false
        let diveShareForResearch: Bool? = true // Override esplicito
        
        let effectiveShare = diveShareForResearch ?? profileShareForResearch
        
        #expect(effectiveShare == true, "Dive explicit share should override profile")
    }
    
    @Test("Dive override - private when profile shares")
    func testDiveOverridePrivateWhenProfileShares() {
        // Profilo condivide, ma immersione privata
        let profileShareForResearch = true
        let diveShareForResearch: Bool? = false // Override esplicito
        
        let effectiveShare = diveShareForResearch ?? profileShareForResearch
        
        #expect(effectiveShare == false, "Dive explicit private should override profile")
    }
    
    @Test("Legacy data - no preference set defaults to share")
    func testLegacyDataDefaultsToShare() {
        // Simula dati legacy senza preferenze
        let profileShareForResearch: Bool? = nil
        let diveShareForResearch: Bool? = nil
        
        let effectiveShare = diveShareForResearch ?? profileShareForResearch ?? true
        
        #expect(effectiveShare == true, "Legacy data should default to shared for research")
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Integration Tests
// ─────────────────────────────────────────────────────────────────────────────

@Suite("Glucose Conversion Integration")
struct GlucoseConversionIntegrationTests {
    
    @Test("User workflow - mmol/L input saves as mg/dL")
    func testMmolLInputSavesAsMgDl() {
        // Utente inserisce valore in mmol/L
        let userInput = "7.0"
        let glucoseUnit = GlucoseUnit.mmolL
        
        // Conversione come farebbe l'app
        guard let mmolValue = Double(userInput) else {
            Issue.record("Invalid input")
            return
        }
        
        let mgDlForDB = glucoseUnit == .mmolL ? mmolValue.mmolLToMgDl : mmolValue
        
        // Verifica valore salvato nel DB
        #expect(mgDlForDB >= 125.0 && mgDlForDB <= 127.0, "7.0 mmol/L should save as ~126 mg/dL")
    }
    
    @Test("User workflow - mg/dL input saves directly")
    func testMgDlInputSavesDirectly() {
        // Utente inserisce valore in mg/dL
        let userInput = "120"
        let glucoseUnit = GlucoseUnit.mgDl
        
        // Conversione come farebbe l'app
        guard let mgDlValue = Double(userInput) else {
            Issue.record("Invalid input")
            return
        }
        
        let mgDlForDB = glucoseUnit == .mmolL ? mgDlValue.mmolLToMgDl : mgDlValue
        
        // Verifica valore salvato nel DB
        #expect(mgDlForDB == 120.0, "120 mg/dL should save as 120 mg/dL")
    }
    
    @Test("User workflow - DB value displays in mmol/L")
    func testDbValueDisplaysInMmolL() {
        // Valore dal DB (sempre in mg/dL)
        let dbValue: Double = 140.0
        let glucoseUnit = GlucoseUnit.mmolL
        
        // Conversione per visualizzazione
        let displayValue = glucoseUnit == .mmolL ? dbValue.mgDlToMmolL : dbValue
        let formatted = String(format: "%.1f", displayValue)
        
        #expect(formatted == "7.8", "140 mg/dL should display as 7.8 mmol/L")
    }
    
    @Test("User workflow - DB value displays in mg/dL")
    func testDbValueDisplaysInMgDl() {
        // Valore dal DB (sempre in mg/dL)
        let dbValue: Double = 140.0
        let glucoseUnit = GlucoseUnit.mgDl
        
        // Conversione per visualizzazione
        let displayValue = glucoseUnit == .mmolL ? dbValue.mgDlToMmolL : dbValue
        let formatted = String(format: "%.0f", displayValue)
        
        #expect(formatted == "140", "140 mg/dL should display as 140 mg/dL")
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Edge Cases
// ─────────────────────────────────────────────────────────────────────────────

@Suite("Edge Cases and Validation")
struct EdgeCaseTests {
    
    @Test("Very low glucose - 40 mg/dL")
    func testVeryLowGlucose() {
        let mgDl: Double = 40
        let mmol = mgDl.mgDlToMmolL
        
        // 40 mg/dL = 2.22 mmol/L
        #expect(mmol >= 2.21 && mmol <= 2.23, "40 mg/dL should convert to ~2.22 mmol/L")
    }
    
    @Test("Very high glucose - 400 mg/dL")
    func testVeryHighGlucose() {
        let mgDl: Double = 400
        let mmol = mgDl.mgDlToMmolL
        
        // 400 mg/dL = 22.2 mmol/L
        #expect(mmol >= 22.1 && mmol <= 22.3, "400 mg/dL should convert to ~22.2 mmol/L")
    }
    
    @Test("Zero value")
    func testZeroValue() {
        let mgDl: Double = 0
        let mmol = mgDl.mgDlToMmolL
        
        #expect(mmol == 0.0, "0 mg/dL should convert to 0 mmol/L")
    }
    
    @Test("Negative value handling")
    func testNegativeValue() {
        // Anche se non dovrebbe accadere, test edge case
        let mgDl: Double = -50
        let mmol = mgDl.mgDlToMmolL
        
        #expect(mmol < 0, "Negative values should remain negative (invalid input)")
    }
}

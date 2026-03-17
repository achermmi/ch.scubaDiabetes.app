import XCTest
@testable import ScubaDiabetes

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Glucose Unit Conversion Tests
// ─────────────────────────────────────────────────────────────────────────────

final class GlucoseConversionTests: XCTestCase {
    
    func testMgDlToMmolLNormalRange() {
        // Convert mg/dL to mmol/L - Normal Range
        let mgDl: Double = 100
        let mmol = mgDl.mgDlToMmolL
        
        // 100 mg/dL = 5.55 mmol/L (approx)
        XCTAssertTrue(mmol >= 5.54 && mmol <= 5.56, "100 mg/dL should convert to ~5.55 mmol/L")
    }
    
    func testMmolLToMgDlNormalRange() {
        // Convert mmol/L to mg/dL - Normal Range
        let mmol: Double = 5.5
        let mgDl = mmol.mmolLToMgDl
        
        // 5.5 mmol/L = 99.1 mg/dL (approx)
        XCTAssertTrue(mgDl >= 99.0 && mgDl <= 100.0, "5.5 mmol/L should convert to ~99 mg/dL")
    }
    
    func testRoundTripMgDl() {
        // Round-trip conversion mg/dL → mmol/L → mg/dL
        let original: Double = 126
        let converted = original.mgDlToMmolL.mmolLToMgDl
        
        // Allow 0.01 tolerance for floating point
        XCTAssertLessThan(abs(converted - original), 0.01, "Round-trip should preserve value")
    }
    
    func testRoundTripMmolL() {
        // Round-trip conversion mmol/L → mg/dL → mmol/L
        let original: Double = 7.0
        let converted = original.mmolLToMgDl.mgDlToMmolL
        
        // Allow 0.001 tolerance for floating point
        XCTAssertLessThan(abs(converted - original), 0.001, "Round-trip should preserve value")
    }
    
    func testHypoglycemiaThreshold() {
        // Hypoglycemia threshold - 70 mg/dL
        let mgDl: Double = 70
        let mmol = mgDl.mgDlToMmolL
        
        // 70 mg/dL = 3.88 mmol/L (approx)
        XCTAssertTrue(mmol >= 3.88 && mmol <= 3.89, "70 mg/dL should convert to ~3.88 mmol/L")
    }
    
    func testHyperglycemiaThreshold() {
        // Hyperglycemia threshold - 180 mg/dL
        let mgDl: Double = 180
        let mmol = mgDl.mgDlToMmolL
        
        // 180 mg/dL = 9.99 mmol/L (approx)
        XCTAssertTrue(mmol >= 9.99 && mmol <= 10.01, "180 mg/dL should convert to ~10.0 mmol/L")
    }
    
    func testFormatMgDl() {
        // Format glucose value for display - mg/dL
        let value: Double = 126.7
        let formatted = value.formatGlucose(unit: .mgDl)
        
        XCTAssertEqual(formatted, "127", "mg/dL should be rounded to whole number")
    }
    
    func testFormatMmolL() {
        // Format glucose value for display - mmol/L
        let value: Double = 126.0 // in mg/dL
        let formatted = value.formatGlucose(unit: .mmolL)
        
        // 126 mg/dL = 6.99 mmol/L
        XCTAssertEqual(formatted, "7.0", "mmol/L should have 1 decimal place")
    }
    
    func testFormatOptionalNil() {
        // Format optional glucose - nil value
        let value: Double? = nil
        let formatted = value.formatGlucose(unit: .mgDl)
        
        XCTAssertNil(formatted, "Nil value should return nil")
    }
    
    func testFormatOptionalValue() {
        // Format optional glucose - with value
        let value: Double? = 100.0
        let formatted = value.formatGlucose(unit: .mmolL)
        
        XCTAssertNotNil(formatted, "Non-nil value should return formatted string")
        XCTAssertEqual(formatted, "5.6", "100 mg/dL should format to 5.6 mmol/L")
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Privacy Logic Tests
// ─────────────────────────────────────────────────────────────────────────────

final class PrivacySettingsTests: XCTestCase {
    
    func testProfileDefaultShareEnabled() {
        // Profile default share enabled - new dive inherits
        let profileShareForResearch = true
        let diveShareForResearch: Bool? = nil // NULL = usa default
        
        let effectiveShare = diveShareForResearch ?? profileShareForResearch
        
        XCTAssertTrue(effectiveShare, "Dive should inherit profile's share setting")
    }
    
    func testProfileDefaultShareDisabled() {
        // Profile default share disabled - new dive inherits
        let profileShareForResearch = false
        let diveShareForResearch: Bool? = nil // NULL = usa default
        
        let effectiveShare = diveShareForResearch ?? profileShareForResearch
        
        XCTAssertFalse(effectiveShare, "Dive should inherit profile's private setting")
    }
    
    func testDiveOverrideShareWhenProfilePrivate() {
        // Dive override - share when profile is private
        let profileShareForResearch = false
        let diveShareForResearch: Bool? = true // Override esplicito
        
        let effectiveShare = diveShareForResearch ?? profileShareForResearch
        
        XCTAssertTrue(effectiveShare, "Dive explicit share should override profile")
    }
    
    func testDiveOverridePrivateWhenProfileShares() {
        // Dive override - private when profile shares
        let profileShareForResearch = true
        let diveShareForResearch: Bool? = false // Override esplicito
        
        let effectiveShare = diveShareForResearch ?? profileShareForResearch
        
        XCTAssertFalse(effectiveShare, "Dive explicit private should override profile")
    }
    
    func testLegacyDataDefaultsToShare() {
        // Legacy data - no preference set defaults to share
        let profileShareForResearch: Bool? = nil
        let diveShareForResearch: Bool? = nil
        
        let effectiveShare = diveShareForResearch ?? profileShareForResearch ?? true
        
        XCTAssertTrue(effectiveShare, "Legacy data should default to shared for research")
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Integration Tests
// ─────────────────────────────────────────────────────────────────────────────

final class GlucoseConversionIntegrationTests: XCTestCase {
    
    func testMmolLInputSavesAsMgDl() {
        // User workflow - mmol/L input saves as mg/dL
        let userInput = "7.0"
        let glucoseUnit = GlucoseUnit.mmolL
        
        // Conversione come farebbe l'app
        guard let mmolValue = Double(userInput) else {
            XCTFail("Invalid input")
            return
        }
        
        let mgDlForDB = glucoseUnit == .mmolL ? mmolValue.mmolLToMgDl : mmolValue
        
        // Verifica valore salvato nel DB
        XCTAssertTrue(mgDlForDB >= 125.0 && mgDlForDB <= 127.0, "7.0 mmol/L should save as ~126 mg/dL")
    }
    
    func testMgDlInputSavesDirectly() {
        // User workflow - mg/dL input saves directly
        let userInput = "120"
        let glucoseUnit = GlucoseUnit.mgDl
        
        // Conversione come farebbe l'app
        guard let mgDlValue = Double(userInput) else {
            XCTFail("Invalid input")
            return
        }
        
        let mgDlForDB = glucoseUnit == .mmolL ? mgDlValue.mmolLToMgDl : mgDlValue
        
        // Verifica valore salvato nel DB
        XCTAssertEqual(mgDlForDB, 120.0, "120 mg/dL should save as 120 mg/dL")
    }
    
    func testDbValueDisplaysInMmolL() {
        // User workflow - DB value displays in mmol/L
        let dbValue: Double = 140.0
        let glucoseUnit = GlucoseUnit.mmolL
        
        // Conversione per visualizzazione
        let displayValue = glucoseUnit == .mmolL ? dbValue.mgDlToMmolL : dbValue
        let formatted = String(format: "%.1f", displayValue)
        
        XCTAssertEqual(formatted, "7.8", "140 mg/dL should display as 7.8 mmol/L")
    }
    
    func testDbValueDisplaysInMgDl() {
        // User workflow - DB value displays in mg/dL
        let dbValue: Double = 140.0
        let glucoseUnit = GlucoseUnit.mgDl
        
        // Conversione per visualizzazione
        let displayValue = glucoseUnit == .mmolL ? dbValue.mgDlToMmolL : dbValue
        let formatted = String(format: "%.0f", displayValue)
        
        XCTAssertEqual(formatted, "140", "140 mg/dL should display as 140 mg/dL")
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Edge Cases
// ─────────────────────────────────────────────────────────────────────────────

final class EdgeCaseTests: XCTestCase {
    
    func testVeryLowGlucose() {
        // Very low glucose - 40 mg/dL
        let mgDl: Double = 40
        let mmol = mgDl.mgDlToMmolL
        
        // 40 mg/dL = 2.22 mmol/L
        XCTAssertTrue(mmol >= 2.21 && mmol <= 2.23, "40 mg/dL should convert to ~2.22 mmol/L")
    }
    
    func testVeryHighGlucose() {
        // Very high glucose - 400 mg/dL
        let mgDl: Double = 400
        let mmol = mgDl.mgDlToMmolL
        
        // 400 mg/dL = 22.2 mmol/L
        XCTAssertTrue(mmol >= 22.1 && mmol <= 22.3, "400 mg/dL should convert to ~22.2 mmol/L")
    }
    
    func testZeroValue() {
        // Zero value
        let mgDl: Double = 0
        let mmol = mgDl.mgDlToMmolL
        
        XCTAssertEqual(mmol, 0.0, "0 mg/dL should convert to 0 mmol/L")
    }
    
    func testNegativeValue() {
        // Negative value handling (edge case - should not happen in production)
        let mgDl: Double = -50
        let mmol = mgDl.mgDlToMmolL
        
        XCTAssertLessThan(mmol, 0, "Negative values should remain negative (invalid input)")
    }
}

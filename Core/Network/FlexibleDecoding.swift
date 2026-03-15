import Foundation

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Flexible Int / Double decodable from String or Number
// Il plugin PHP/MySQL restituisce i campi numerici come stringhe JSON.
// Questi wrapper accettano sia "123" che 123.
// ─────────────────────────────────────────────────────────────────────────────

@propertyWrapper
struct FlexInt: Decodable {
    var wrappedValue: Int
    init(wrappedValue: Int) { self.wrappedValue = wrappedValue }
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let v = try? c.decode(Int.self)    { wrappedValue = v; return }
        if let s = try? c.decode(String.self), let v = Int(s) { wrappedValue = v; return }
        throw DecodingError.typeMismatch(Int.self,
            .init(codingPath: decoder.codingPath, debugDescription: "Cannot decode Int from value"))
    }
}

@propertyWrapper
struct FlexIntOpt: Decodable {
    var wrappedValue: Int?
    init(wrappedValue: Int?) { self.wrappedValue = wrappedValue }
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { wrappedValue = nil; return }
        if let v = try? c.decode(Int.self)    { wrappedValue = v; return }
        if let s = try? c.decode(String.self) {
            wrappedValue = s.isEmpty ? nil : Int(s); return
        }
        wrappedValue = nil
    }
}

@propertyWrapper
struct FlexDouble: Decodable {
    var wrappedValue: Double
    init(wrappedValue: Double) { self.wrappedValue = wrappedValue }
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let v = try? c.decode(Double.self)  { wrappedValue = v; return }
        if let s = try? c.decode(String.self), let v = Double(s) { wrappedValue = v; return }
        throw DecodingError.typeMismatch(Double.self,
            .init(codingPath: decoder.codingPath, debugDescription: "Cannot decode Double from value"))
    }
}

@propertyWrapper
struct FlexDoubleOpt: Decodable {
    var wrappedValue: Double?
    init(wrappedValue: Double?) { self.wrappedValue = wrappedValue }
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { wrappedValue = nil; return }
        if let v = try? c.decode(Double.self)  { wrappedValue = v; return }
        if let s = try? c.decode(String.self)  {
            wrappedValue = s.isEmpty ? nil : Double(s); return
        }
        wrappedValue = nil
    }
}

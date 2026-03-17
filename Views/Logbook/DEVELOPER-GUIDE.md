# 💡 Guida Sviluppatore - Conversione Glicemia e Privacy

## 📘 Come Usare la Conversione Glicemia

### Scenario 1: Mostrare un valore dal database

```swift
import SwiftUI

struct GlucoseDisplayView: View {
    let glucoseValueMgDl: Double  // Dal DB, sempre in mg/dL
    let userUnit: GlucoseUnit     // Dall'HealthProfile
    
    var body: some View {
        HStack {
            Text("Glicemia:")
            Text(glucoseValueMgDl.formatGlucose(unit: userUnit) ?? "—")
            Text(userUnit.displaySymbol)
                .foregroundStyle(.secondary)
        }
    }
}

// Esempio di utilizzo:
// GlucoseDisplayView(glucoseValueMgDl: 126.0, userUnit: .mmolL)
// Output: "Glicemia: 7.0 mmol/L"
```

### Scenario 2: Input utente e salvataggio

```swift
struct GlucoseInputView: View {
    @State private var inputText = ""
    let userUnit: GlucoseUnit
    
    func saveGlucose() async {
        guard let userValue = Double(inputText) else { return }
        
        // Converti in mg/dL per il database
        let mgDlForDB: Double
        switch userUnit {
        case .mgDl:
            mgDlForDB = userValue
        case .mmolL:
            mgDlForDB = userValue.mmolLToMgDl
        }
        
        // Salva mgDlForDB nel database
        await saveToDatabase(glucose: mgDlForDB)
    }
    
    var body: some View {
        HStack {
            TextField("Valore", text: $inputText)
                .keyboardType(.decimalPad)
            Text(userUnit.displaySymbol)
                .foregroundStyle(.secondary)
        }
    }
}
```

### Scenario 3: Conversione bidirezionale

```swift
extension DiabetesData {
    /// Converte il valore glicemico nell'unità dell'utente per la visualizzazione
    func displayGlucose(_ mgDlValue: Double?, in unit: GlucoseUnit) -> String {
        guard let value = mgDlValue else { return "—" }
        
        switch unit {
        case .mgDl:
            return String(format: "%.0f", value)
        case .mmolL:
            let mmol = value.mgDlToMmolL
            return String(format: "%.1f", mmol)
        }
    }
}

// Utilizzo:
let data: DiabetesData = ...
let displayValue = data.displayGlucose(data.glicPre10, in: userUnit)
```

---

## 🔐 Come Gestire la Privacy

### Scenario 1: Determinare se un'immersione è condivisa

```swift
extension Dive {
    /// Determina se questa immersione è condivisa per la ricerca
    /// considerando sia l'override specifico che il default del profilo
    func isSharedForResearch(profileDefault: Bool) -> Bool {
        return shareForResearch ?? profileDefault
    }
}

// Utilizzo:
let dive: Dive = ...
let profile: HealthProfile = ...
let isShared = dive.isSharedForResearch(profileDefault: profile.shareForResearch ?? true)

if isShared {
    print("Questa immersione sarà inclusa nella ricerca")
}
```

### Scenario 2: Badge visivo per privacy

```swift
struct DivePrivacyBadge: View {
    let dive: Dive
    let profileDefault: Bool
    
    var isShared: Bool {
        dive.shareForResearch ?? profileDefault
    }
    
    var body: some View {
        Label {
            Text(isShared ? "Condiviso" : "Privato")
                .font(.caption)
        } icon: {
            Image(systemName: isShared ? "lock.open.fill" : "lock.fill")
        }
        .foregroundStyle(isShared ? .green : .orange)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isShared ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        .clipShape(Capsule())
    }
}
```

### Scenario 3: Salvare preferenza privacy

```swift
func saveDive(shareOverride: Bool?) async {
    var body: [String: Any] = [
        "dive_date": "2026-03-15",
        "site": "Verzasca",
        // ... altri campi
    ]
    
    // Se l'utente ha impostato un override, salvalo
    if let share = shareOverride {
        body["share_for_research"] = share
    }
    // Altrimenti, non includere il campo (verrà salvato NULL nel DB)
    
    let dive = try await diveService.create(body)
}
```

---

## 🧪 Testing delle Conversioni

### Test Unitario - Conversione

```swift
@Test("User enters 7.2 mmol/L, saves as 129.73 mg/dL")
func testUserInputConversion() {
    let userInput: Double = 7.2
    let unit = GlucoseUnit.mmolL
    
    let savedValue = unit == .mmolL ? userInput.mmolLToMgDl : userInput
    
    #expect(savedValue >= 129.7 && savedValue <= 129.8)
}
```

### Test UI - Privacy Toggle

```swift
@Test("Privacy toggle initializes from profile default")
func testPrivacyToggleInitialization() {
    let profileDefault = false  // Profilo impostato su privato
    var diveShareForResearch = true  // Valore iniziale ignorato
    
    // Simula onAppear
    diveShareForResearch = profileDefault
    
    #expect(diveShareForResearch == false, "Toggle should match profile default")
}
```

---

## 🎨 Pattern UI Consigliati

### Indicatore Unità Glicemia nel Profilo

```swift
struct GlucoseUnitIndicator: View {
    let unit: GlucoseUnit
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "drop.fill")
                .foregroundStyle(.red)
            Text("Unità:")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(unit.displayName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.tertiarySystemBackground))
        .clipShape(Capsule())
    }
}
```

### Spiegazione Privacy con Icon

```swift
struct PrivacyExplanationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(.blue)
                Text("Condivisione per la Ricerca")
                    .font(.headline)
            }
            
            Text("I tuoi dati contribuiranno alla ricerca scientifica sul diabete e l'immersione subacquea.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Label("Tutti i dati sono completamente anonimi", systemImage: "checkmark.shield.fill")
                .font(.caption)
                .foregroundStyle(.green)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

---

## ⚡ Best Practices

### 1. **Sempre Validare Input Utente**

```swift
func parseGlucoseInput(_ text: String, unit: GlucoseUnit) -> Double? {
    guard let value = Double(text) else { return nil }
    
    // Validazione range realistici
    switch unit {
    case .mgDl:
        guard value >= 20 && value <= 600 else { return nil }
    case .mmolL:
        guard value >= 1.1 && value <= 33.3 else { return nil }
    }
    
    return value
}
```

### 2. **Gestire Valori nil con Grace**

```swift
struct GlucoseCell: View {
    let value: Double?
    let unit: GlucoseUnit
    
    var displayText: String {
        guard let v = value else { return "—" }
        return v.formatGlucose(unit: unit, decimals: unit == .mmolL ? 1 : 0)
    }
    
    var body: some View {
        Text(displayText)
            .foregroundStyle(value == nil ? .secondary : .primary)
    }
}
```

### 3. **Consistenza nelle Conversioni**

```swift
// ❌ EVITARE - conversione manuale inconsistente
let mmol = mgDl / 18  // Approssimativo

// ✅ PREFERIRE - usa extension standardizzata
let mmol = mgDl.mgDlToMmolL  // Preciso (18.0182)
```

### 4. **Logging per Debug**

```swift
#if DEBUG
func logGlucoseConversion(input: Double, from: GlucoseUnit, to: GlucoseUnit) {
    let converted: Double
    switch (from, to) {
    case (.mgDl, .mmolL):
        converted = input.mgDlToMmolL
    case (.mmolL, .mgDl):
        converted = input.mmolLToMgDl
    default:
        converted = input
    }
    
    print("🔄 Glucose: \(input) \(from.displaySymbol) → \(converted) \(to.displaySymbol)")
}
#endif
```

---

## 🗺️ Flusso Dati Completo

```
┌─────────────────────────────────────────────────────────────┐
│                    UTENTE INSERISCE DATI                    │
│                  (nell'unità preferita)                     │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
         ┌─────────────────────────┐
         │  TextField con unità    │
         │  dinamica visualizzata  │
         └───────────┬─────────────┘
                     │
                     ▼
         ┌─────────────────────────┐
         │  Conversione a mg/dL    │
         │  (se necessario)        │
         └───────────┬─────────────┘
                     │
                     ▼
         ┌─────────────────────────┐
         │  Salvataggio nel DB     │
         │  (sempre in mg/dL)      │
         └───────────┬─────────────┘
                     │
                     ▼
         ┌─────────────────────────┐
         │  Recupero dal DB        │
         │  (sempre in mg/dL)      │
         └───────────┬─────────────┘
                     │
                     ▼
         ┌─────────────────────────┐
         │  Conversione per UI     │
         │  (se necessario)        │
         └───────────┬─────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────────────────┐
│                    UTENTE VISUALIZZA                       │
│                  (nell'unità preferita)                    │
└────────────────────────────────────────────────────────────┘
```

---

## 📊 Tabella Valori di Riferimento

| Condizione        | mg/dL    | mmol/L  |
|-------------------|----------|---------|
| Ipoglicemia       | < 70     | < 3.9   |
| Range normale     | 70-140   | 3.9-7.8 |
| Pre-prandiale     | 80-130   | 4.4-7.2 |
| Post-prandiale    | < 180    | < 10.0  |
| Iperglicemia      | > 180    | > 10.0  |

---

## 🆘 Troubleshooting Comune

### Problema: "Valori non corrispondono dopo conversione"
**Soluzione**: Verifica di usare `18.0182` e non `18` come fattore di conversione.

### Problema: "Privacy non funziona come previsto"
**Soluzione**: Controlla la logica `shareForResearch ?? profileDefault ?? true` con coalescenza nil.

### Problema: "Arrotondamenti strani in mmol/L"
**Soluzione**: Usa sempre 1 decimale per mmol/L: `String(format: "%.1f", mmol)`

---

## 📞 Supporto

Per domande tecniche:
- Consulta `Models.swift` per le funzioni di conversione
- Vedi `GlucoseConversionTests.swift` per esempi pratici
- Leggi `IMPLEMENTATION-SUMMARY.md` per panoramica completa

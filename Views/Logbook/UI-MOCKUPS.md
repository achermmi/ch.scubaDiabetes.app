# 🎨 Mockup UI - Nuove Funzionalità

## 1. Profilo Salute - Sezione Diabete

```
┌─────────────────────────────────────────────────────┐
│  ❤️  Diabete                                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Ho il diabete                           [✓]       │
│                                                     │
│  Tipo di diabete                                   │
│  ┌─────────────────────────────────────┐           │
│  │ Tipo 1                        ⌄     │           │
│  └─────────────────────────────────────┘           │
│                                                     │
│  Terapia                                           │
│  ┌─────────────────────────────────────┐           │
│  │ MDI                           ⌄     │           │
│  └─────────────────────────────────────┘           │
│                                                     │
│  HbA1c                              5.5 %          │
│                                                     │
│  🆕 Unità glicemia                                  │
│  ┌───────────┬───────────┐                        │
│  │  mg/dL    │  mmol/L   │                        │
│  │           │    ✓      │                        │
│  └───────────┴───────────┘                        │
│                                                     │
│  CGM                         es. Dexcom G7         │
│  Microinfusore               es. Omnipod 5         │
│                                                     │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  🔒  Privacy e Ricerca                              │
├─────────────────────────────────────────────────────┤
│                                                     │
│  [✓] Condividi dati per la ricerca                 │
│      I tuoi dati potranno essere utilizzati        │
│      in forma anonima per studi scientifici        │
│                                                     │
│  ℹ️  Questa impostazione definisce il              │
│     comportamento predefinito per tutte le tue     │
│     immersioni. Potrai comunque modificare la      │
│     privacy di ogni singola immersione.            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 2. Nuova Immersione - Dati Glicemici

### Con unità mmol/L selezionata:

```
┌─────────────────────────────────────────────────────┐
│  💧 Checkpoint Glicemici                            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  -60 min                                           │
│  Glicemia                          6.5  mmol/L     │
│                                                     │
│  -30 min                                           │
│  Glicemia                          7.0  mmol/L     │
│                                                     │
│  -10 min                                           │
│  Glicemia                          7.2  mmol/L     │
│                                                     │
│  Post                                              │
│  Glicemia                          6.8  mmol/L     │
│                                                     │
│  Trend                                             │
│  ┌──┬──┬──┬──┬──┐                                  │
│  │↑↑│↑ │→ │↓ │↓↓│                                  │
│  └──┴──┴──┴──┴──┘                                  │
│        (→ selezionato)                             │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Con unità mg/dL selezionata:

```
┌─────────────────────────────────────────────────────┐
│  💧 Checkpoint Glicemici                            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  -60 min                                           │
│  Glicemia                          117  mg/dL      │
│                                                     │
│  -30 min                                           │
│  Glicemia                          126  mg/dL      │
│                                                     │
│  -10 min                                           │
│  Glicemia                          130  mg/dL      │
│                                                     │
│  Post                                              │
│  Glicemia                          122  mg/dL      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 3. Nuova Immersione - Privacy

```
┌─────────────────────────────────────────────────────┐
│  Note                                               │
├─────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────┐       │
│  │ Bellissima immersione con visibilità   │       │
│  │ eccellente. Temperature stabili.        │       │
│  │                                          │       │
│  └─────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  🔒  Privacy                                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  [✓] Condividi questa immersione per la ricerca    │
│      Permetti l'uso anonimo di questi dati         │
│      per studi scientifici                         │
│                                                     │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│                                                     │
│          [Annulla]           [Salva]               │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 4. Dettaglio Immersione - Card Glicemia

### Visualizzazione con mmol/L:

```
┌─────────────────────────────────────────────────────┐
│  💧 Dati Glicemici                                  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Checkpoint Pre-Immersione                         │
│  ┌─────────────────────────────────────────┐       │
│  │ -60 min     6.5 mmol/L    →            │       │
│  │ -30 min     7.0 mmol/L    →            │       │
│  │ -10 min     7.2 mmol/L    →            │       │
│  └─────────────────────────────────────────┘       │
│                                                     │
│  Checkpoint Post-Immersione                        │
│  ┌─────────────────────────────────────────┐       │
│  │ Post        6.8 mmol/L    ↓            │       │
│  └─────────────────────────────────────────┘       │
│                                                     │
│  Decisione                                         │
│  ✅ Autorizzata                                     │
│                                                     │
│  Privacy                                           │
│  🔓 Condiviso per ricerca                          │
│                                                     │
│            [Modifica dati glicemici]               │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Visualizzazione con mg/dL:

```
┌─────────────────────────────────────────────────────┐
│  💧 Dati Glicemici                                  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Checkpoint Pre-Immersione                         │
│  ┌─────────────────────────────────────────┐       │
│  │ -60 min    117 mg/dL     →             │       │
│  │ -30 min    126 mg/dL     →             │       │
│  │ -10 min    130 mg/dL     →             │       │
│  └─────────────────────────────────────────┘       │
│                                                     │
│  Checkpoint Post-Immersione                        │
│  ┌─────────────────────────────────────────┐       │
│  │ Post       122 mg/dL     ↓             │       │
│  └─────────────────────────────────────────┘       │
│                                                     │
│  Decisione                                         │
│  ✅ Autorizzata                                     │
│                                                     │
│  Privacy                                           │
│  🔒 Privato                                        │
│                                                     │
│            [Modifica dati glicemici]               │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 5. Lista Immersioni - Badge Privacy

```
┌─────────────────────────────────────────────────────┐
│  🌊 Logbook                                    [+]  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │ #42  Verzasca                              │   │
│  │                                             │   │
│  │ 15 marzo 2026                               │   │
│  │ Max depth: 18m  •  Duration: 42min         │   │
│  │                                             │   │
│  │ 🔓 Condiviso   7.2 mmol/L → 6.8 mmol/L    │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │ #41  Lago di Lugano                        │   │
│  │                                             │   │
│  │ 10 marzo 2026                               │   │
│  │ Max depth: 12m  •  Duration: 35min         │   │
│  │                                             │   │
│  │ 🔒 Privato     130 mg/dL → 122 mg/dL       │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 6. Picker Unità nel Form

```
┌─────────────────────────────────────────────────────┐
│  Unità glicemia                                     │
│                                                     │
│  ┌──────────────────────┬──────────────────────┐   │
│  │                      │                      │   │
│  │      mg/dL           │      mmol/L          │   │
│  │                      │         ✓            │   │
│  │                      │                      │   │
│  └──────────────────────┴──────────────────────┘   │
│                                                     │
│  Style: Segmented Picker                           │
│  iOS Native Component                              │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 7. Toggle Privacy con Spiegazione

```
┌─────────────────────────────────────────────────────┐
│  🔒 Privacy e Ricerca                               │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │                                             │   │
│  │  Condividi dati per la ricerca       [✓]   │   │
│  │  I tuoi dati potranno essere utilizzati    │   │
│  │  in forma anonima per studi scientifici    │   │
│  │                                             │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ℹ️  Questa impostazione definisce il              │
│     comportamento predefinito per tutte le tue     │
│     immersioni. Potrai comunque modificare la      │
│     privacy di ogni singola immersione.            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 8. Indicatore Unità nel Dettaglio

```
┌─────────────────────────────────────────────────────┐
│  Verzasca                                     #42   │
│  15 marzo 2026                                      │
│                                                     │
│  ┌────────────────────────┐                        │
│  │ 💧 Unità: mmol/L       │  ← Badge informativo   │
│  └────────────────────────┘                        │
│                                                     │
│  Glicemie                                          │
│  -10 min:  7.2 mmol/L                              │
│  Post:     6.8 mmol/L                              │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 9. Alert Conferma Cambio Unità

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  ⚠️  Cambio Unità di Misura                        │
│                                                     │
│  Stai cambiando l'unità di misura della glicemia   │
│  da mg/dL a mmol/L.                                │
│                                                     │
│  I valori nelle immersioni esistenti verranno      │
│  automaticamente convertiti per la                 │
│  visualizzazione.                                  │
│                                                     │
│  I dati nel database rimangono in mg/dL.           │
│                                                     │
│          [Annulla]           [Conferma]            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 10. Colori e Stili

### Stati Privacy

- **Condiviso**: 
  - Icona: 🔓 `lock.open.fill`
  - Colore: Verde `.green`
  - Badge: background verde chiaro

- **Privato**: 
  - Icona: 🔒 `lock.fill`
  - Colore: Arancione `.orange`
  - Badge: background arancione chiaro

### Unità Glicemia

- **Segmented Picker**: 
  - Style: `.segmented`
  - Colori: Accent color per selezione
  - Font: System regular

- **Badge Unità**: 
  - Background: `.tertiarySystemBackground`
  - Shape: `Capsule()`
  - Padding: horizontal 10, vertical 6

### Range Glicemici (colori indicativi)

- **Ipoglicemia (< 70 mg/dL / < 3.9 mmol/L)**: Rosso
- **Normale (70-140 mg/dL / 3.9-7.8 mmol/L)**: Verde
- **Elevata (> 180 mg/dL / > 10.0 mmol/L)**: Arancione

---

## 11. Animazioni

### Toggle Privacy
```swift
Toggle("Condividi", isOn: $shareForResearch)
    .animation(.easeInOut(duration: 0.2), value: shareForResearch)
```

### Cambio Unità
```swift
.onChange(of: glucoseUnit) { oldValue, newValue in
    withAnimation(.spring()) {
        // Update UI
    }
}
```

### Espansione Sezioni
```swift
.animation(.easeInOut(duration: 0.3), value: isExpanded)
```

---

## 12. Accessibilità

### VoiceOver Labels

```swift
// Picker unità
.accessibilityLabel("Unità di misura glicemia")
.accessibilityValue(glucoseUnit.displayName)

// Toggle privacy
.accessibilityLabel("Condividi dati per la ricerca scientifica")
.accessibilityHint("Attiva per condividere in forma anonima")

// Badge privacy
.accessibilityLabel(isShared ? "Immersione condivisa" : "Immersione privata")
```

### Dynamic Type Support

```swift
Text("Glicemia")
    .font(.subheadline) // Si adatta automaticamente
    
Text(value)
    .font(.title3.monospacedDigit()) // Numeri sempre leggibili
```

---

## 📱 Compatibilità

- iOS 17.0+
- iPadOS 17.0+
- Supporto orientamento portrait e landscape
- Dark mode supportato
- Dimensioni testo dinamiche (Accessibility)
- VoiceOver completo

---

## 🎨 Design System

Tutti i componenti seguono:
- **Apple Human Interface Guidelines**
- **Design system app esistente**
- **Colori:** AccentColor, OceanMid, OceanDeep
- **Corner Radius:** `AppConstants.Design.cornerRadius` (12pt)
- **Spacing:** Multipli di 4pt (8, 12, 16, 24)
- **Typography:** San Francisco (system font)

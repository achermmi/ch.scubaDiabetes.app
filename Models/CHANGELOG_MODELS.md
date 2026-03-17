# Changelog - Allineamento Models.swift con Database WordPress

## Data: 15 Marzo 2026

### Modifiche apportate per allineare i modelli Swift con il plugin WordPress

---

## 1. HealthProfile - Allineamento con `wp_sd_diver_profiles`

### Campi aggiunti:
- `certificationLevel` → `certification_level` (VARCHAR 50)
- `certificationAgency` → `certification_agency` (VARCHAR 50)
- `certificationDate` → `certification_date` (DATE)
- `emergencyContactName` → `emergency_contact_name` (VARCHAR 100)
- `emergencyContactPhone` → `emergency_contact_phone` (VARCHAR 30)
- `medicalClearanceDate` → `medical_clearance_date` (DATE)
- `medicalClearanceExpiry` → `medical_clearance_expiry` (DATE)
- `hba1cDate` → `hba1c_date` (DATE)
- `usesCgm` → `uses_cgm` (TINYINT)
- `createdAt` → `created_at` (DATETIME)
- `updatedAt` → `updated_at` (DATETIME)

### Campi rinominati:
- `hba1c` ora mappa a `hba1c_last` nel DB (non `hba1c`)
- `glucoseUnit` ora mappa a `glycemia_unit` nel DB
- `shareForResearch` ora mappa a `default_shared_for_research` nel DB

### Custom Decoder aggiornato:
- Aggiunta gestione per `usesCgm` (Bool o String "1"/"0")
- Gestione di tutti i nuovi campi stringa e date

---

## 2. Dive - Allineamento con `wp_sd_dives`

### Campi aggiunti:
- `siteLatitude` → `site_latitude` (DECIMAL 10,7)
- `siteLongitude` → `site_longitude` (DECIMAL 10,7)
- `pressureStart` → `pressure_start` (SMALLINT)
- `pressureEnd` → `pressure_end` (SMALLINT)
- `tankCount` → `tank_count` (TINYINT)
- `nitroxPercentage` → `nitrox_percentage` (DECIMAL 4,1)
- `safetyStopDepth` → `safety_stop_depth` (DECIMAL 4,1)
- `safetyStopTime` → `safety_stop_time` (SMALLINT)
- `decoStopDepth` → `deco_stop_depth` (DECIMAL 4,1)
- `decoStopTime` → `deco_stop_time` (SMALLINT)
- `deepStopDepth` → `deep_stop_depth` (DECIMAL 4,1)
- `deepStopTime` → `deep_stop_time` (SMALLINT)
- `diveType` → `dive_type` (VARCHAR 15)
- `currentStrength` → `current_strength` (VARCHAR 10)
- `otherEquipment` → `other_equipment` (TEXT)
- `updatedAt` → `updated_at` (DATETIME)

### Campi modificati:
- `tankCapacity` ora è `Double?` invece di `Int?` (DECIMAL 4,1 nel DB)
- `shareForResearch` ora mappa a `sharedForResearch` (non `shareForResearch`)

### CodingKeys aggiornati:
- Aggiunti tutti i nuovi mapping snake_case → camelCase

---

## 3. NutritionEntry - Allineamento con `wp_sd_nutrition_log`

### Campi aggiunti/modificati:
- `diveId` ora è opzionale (`Int?`) - può essere NULL nel DB
- `userId` aggiunto - campo obbligatorio nel DB
- `logDate` aggiunto - `log_date` nel DB (DATE)
- `createdAt` aggiunto - `created_at` nel DB (DATETIME)

### Mapping corretti:
- `calories` → `calories_estimated` nel DB
- `choGrams` → `cho_grams` nel DB
- `liquidsMl` → `liquids_ml` nel DB

### Custom Decoder aggiunto:
- Gestione conversione String → Int/Double per compatibilità backend PHP

---

## 4. DiveSession - Allineamento con `wp_sd_dive_sessions`

### Campi rinominati:
- `notes` → `sessionNotes` (mappa a `session_notes`)
- `weather` → `weatherGeneral` (mappa a `weather_general`)
- `updatedAt` aggiunto

### Backward compatibility:
- Aggiunte computed properties `notes` e `weather` per compatibilità con codice esistente
- `diveCount` ora opzionale, non presente direttamente nel DB (calcolato dinamicamente)

---

## 5. MedicalClearance - Campi mancanti aggiunti

### Fix applicato per allineamento con il form web:
- ✅ Aggiunto campo **`date`** - Data di rilascio dell'idoneità (non solo `year`)
- ✅ Aggiunto campo **`type`** - Tipo di visita medica
  - Valori possibili: `"iperbarica"`, `"sportiva"`, `"non_agonistica"`, `"altro"`
  - Mappato dal campo `type` nel JSON dell'API
- ✅ Campo **`doctor`** già presente - Nome del medico certificatore
- ✅ Campo **`outcome`** già presente - Esito della visita
  - Valori: `"fit"` (idoneo), `"fit_limited"` (idoneo con limitazioni), `"unfit"` (non idoneo)
- ✅ Documento PDF/immagine già gestito tramite `documentUrl` e `documentName`

### Computed properties aggiunte per il display:
- `typeDisplayName` - Nome leggibile del tipo di visita
- `outcomeDisplayName` - Nome leggibile dell'esito
- `outcomeIcon` - Icona SF Symbol appropriata per l'esito
- `outcomeColor` - Colore SwiftUI per l'esito (verde/arancione/rosso)

### Note sul formato date:
- `date` contiene la data di rilascio in formato `"yyyy-MM-dd"` (es: `"2026-03-12"`)
- `validUntil` contiene la data di scadenza (mappato da `"expiry"` nel JSON)
- `year` viene estratto automaticamente da `date` se non presente nel JSON

---

## 6. EmergencyContact - Gestione ID mancante

### Fix applicato:
- Custom decoder che genera un hash-based ID quando mancante nella risposta API
- ID generato da `abs((name + phone).hashValue)` per garantire unicità
- Gestione robusta di tutti i campi opzionali

---

## Note sulla conversione Snake_case → CamelCase

Il backend WordPress usa il formato snake_case per i nomi delle colonne del database, mentre l'app iOS usa camelCase. Con il `JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase` attivo:

- `dive_number` → viene decodificato come `diveNumber`
- Le CodingKeys devono avere rawValue in camelCase (es: `case diveNumber = "diveNumber"`)
- Il JSON ricevuto usa ancora snake_case ma viene automaticamente convertito

---

## Validazione dei Tipi

Tutti i numeric fields dal backend PHP arrivano come String o Number:
- Custom decoders con `flexInt`, `flexDbl`, `flexBool` gestiscono entrambi i casi
- Bool fields: accettano `true/false`, `1/0`, `"1"/"0"`, `"true"/"false"`
- Gestione robusta di valori NULL/assenti

---

## Nuovi file creati per UI completa

### 1. **MedicalClearanceFormView.swift**
Form completo per aggiungere/modificare idoneità medica con:
- ✅ Tutti i campi richiesti (anno, date, tipo visita, medico, esito)
- ✅ Upload documenti (PDF, JPG, PNG, ZIP fino a 5 MB)
- ✅ Validazione dimensione file
- ✅ Compatibilità con formato web (stepper anno + date picker)

### 2. **MedicalClearanceCardView.swift**
Card per visualizzare idoneità nella lista con:
- ✅ Status badge colorato (VALIDA/IN SCADENZA/SCADUTA)
- ✅ Calcolo giorni rimanenti automatico
- ✅ Icone ed esito colorati
- ✅ Link al documento allegato
- ✅ Bordo e sfondo colorati in base allo status

---

## Prossimi passi consigliati

1. ✅ **COMPLETATO** - Allineamento modello `MedicalClearance` con backend
2. ✅ **COMPLETATO** - Aggiunta campi `date` e `type`
3. ✅ **COMPLETATO** - UI form completa con upload documenti
4. ⚠️ Verificare i valori di default per `glycemia_unit` ("mg/dl" vs "mg_dl")
5. ⚠️ Confermare che `shared_for_research` nel JSON usa lo stesso nome
6. 📝 Integrare `MedicalClearanceFormView` nella schermata Profilo
7. 📝 Implementare upload multipart/form-data per i documenti
8. 📝 Gestire visualizzazione PDF/immagini in-app

---

## Riferimenti Database

- **Tabelle**: `wp_sd_diver_profiles`, `wp_sd_dives`, `wp_sd_dive_diabetes`, `wp_sd_nutrition_log`, `wp_sd_dive_sessions`
- **Database**: `qi57sq_scuba`
- **Charset**: `utf8mb4_unicode_520_ci`
- **Engine**: InnoDB


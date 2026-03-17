# Modifiche Backend WordPress Richieste

Per supportare le nuove funzionalità implementate nell'app iOS, il plugin WordPress deve essere aggiornato.

## 1. Database - Tabella `health_profiles`

Aggiungere due nuove colonne:

```sql
ALTER TABLE wp_sd_health_profiles 
ADD COLUMN glucose_unit VARCHAR(10) DEFAULT 'mg_dl' COMMENT 'Unità misura glicemia: mg_dl o mmol_l',
ADD COLUMN share_for_research TINYINT(1) DEFAULT 1 COMMENT 'Default condivisione dati per ricerca';
```

## 2. Database - Tabella `dives`

Aggiungere una nuova colonna:

```sql
ALTER TABLE wp_sd_dives 
ADD COLUMN share_for_research TINYINT(1) DEFAULT NULL COMMENT 'Privacy specifica immersione (NULL = usa default profilo)';
```

### Logica di Privacy

- Se `dives.share_for_research` è `NULL`, usare il valore da `health_profiles.share_for_research`
- Se `dives.share_for_research` è `0` o `1`, sovrascrive il default del profilo

## 3. API Endpoint `/profile` (GET)

Risposta JSON deve includere i nuovi campi:

```json
{
  "user": { ... },
  "health": {
    "id": 1,
    "user_id": 123,
    "is_diabetic": true,
    "diabetes_type": "T1",
    "glucose_unit": "mg_dl",
    "share_for_research": true,
    ...
  },
  "certifications": [ ... ],
  "clearances": [ ... ],
  "emergency_contacts": [ ... ]
}
```

## 4. API Endpoint `/profile` (PUT)

Accettare i nuovi campi nel body della richiesta:

```json
{
  "is_diabetic": true,
  "diabetes_type": "T1",
  "glucose_unit": "mmol_l",
  "share_for_research": false,
  ...
}
```

**NOTA:** Non deve fare alcuna conversione delle glicemie esistenti, solo salvare la preferenza.

## 5. API Endpoint `/dives` (POST/PUT)

Accettare il nuovo campo:

```json
{
  "dive_date": "2026-03-15",
  "site": "Verzasca",
  "share_for_research": true,
  ...
}
```

## 6. API Endpoint `/dives/:id/diabetes` (POST)

**IMPORTANTE:** I valori di glicemia ricevuti dall'app iOS sono **SEMPRE in mg/dL**.

L'app fa già la conversione prima di inviare i dati. Il backend deve:
- Salvare i valori così come arrivano (già in mg/dL)
- Non fare nessuna conversione

```json
{
  "glic_pre60": 120,
  "glic_pre30": 130,
  "glic_pre10": 140,
  "glic_post": 110,
  ...
}
```

Tutti questi valori sono in **mg/dL**, indipendentemente dall'unità preferita dall'utente.

## 7. API Endpoint `/dives/:id` (GET)

Risposta deve includere il campo privacy:

```json
{
  "dive": {
    "id": 456,
    "user_id": 123,
    "dive_date": "2026-03-15",
    "share_for_research": true,
    ...
  },
  "diabetes_data": {
    "glic_pre60": 120,
    ...
  },
  "nutrition_log": [ ... ]
}
```

**NOTA:** I valori glicemici nel database sono in mg/dL. L'app iOS si occuperà di convertirli in mmol/L se necessario per la visualizzazione.

## 8. Query per Ricerca Scientifica

Quando si estraggono dati per la ricerca, rispettare la privacy:

```sql
-- Solo immersioni condivise
SELECT d.*, dd.* 
FROM wp_sd_dives d
LEFT JOIN wp_sd_health_profiles hp ON d.user_id = hp.user_id
LEFT JOIN wp_sd_diabetes_data dd ON d.id = dd.dive_id
WHERE 
  COALESCE(d.share_for_research, hp.share_for_research, 1) = 1
  AND dd.id IS NOT NULL;
```

## Riepilogo Comportamento

### Scenario 1: Utente con profilo "Condividi = SI"
- Nuove immersioni: default `share_for_research = NULL` → eredita `true` dal profilo
- Utente può disabilitare singole immersioni

### Scenario 2: Utente con profilo "Condividi = NO"
- Nuove immersioni: default `share_for_research = NULL` → eredita `false` dal profilo
- Utente può abilitare singole immersioni

### Scenario 3: Dati legacy (senza campo)
- `share_for_research = NULL` → eredita dal profilo
- Se profilo non ha il campo → default `true` (retrocompatibilità)

## Testing

Per testare con l'utente fornito:
- **Username:** test.dia
- **Password:** Scuba2026Diabetes!
- **URL profilo:** https://scubadiabetes.m-achermann.com/profilo-subacqueo/
- **URL logbook:** https://scubadiabetes.m-achermann.com/log-book-scubadiabetes/

Verificare che:
1. Il profilo mostri il toggle "Condividi dati per ricerca"
2. Il form nuova immersione mostri il toggle privacy
3. I valori salvati rispettino la logica di default/override
4. Le glicemie siano sempre in mg/dL nel database

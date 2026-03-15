# 🚀 Configurazione GitHub Actions per ScubaDiabetes

## ✅ Checklist Pre-Push

Prima di attivare il workflow, segui questi passaggi:

### 1. Condividi lo Scheme in Xcode

1. Apri il progetto in Xcode
2. Vai su **Product → Scheme → Manage Schemes**
3. Seleziona lo scheme **ScubaDiabetes**
4. Assicurati che la checkbox **Shared** sia selezionata
5. Chiudi il pannello

Questo creerà il file:
```
ScubaDiabetes.xcodeproj/xcshareddata/xcschemes/ScubaDiabetes.xcscheme
```

### 2. Configura i Permessi su GitHub

1. Vai su: `https://github.com/tuoUsername/ch..scubadiabetes.app`
2. Clicca su **Settings** (tab del repository)
3. Nel menu laterale: **Actions → General**
4. Scorri fino a **Workflow permissions**
5. Seleziona: **Read and write permissions** ✅
6. Abilita: **Allow GitHub Actions to create and approve pull requests** ✅
7. Clicca **Save**

### 3. Committa e Pusha

```bash
# Verifica i file che saranno committati
git status

# Aggiungi il workflow
git add .github/workflows/ios-build-tag.yml

# Aggiungi lo scheme condiviso
git add ScubaDiabetes.xcodeproj/xcshareddata/

# Committa
git commit -m "Add GitHub Actions workflow for CI/CD"

# Pusha sul branch main
git push origin main
```

---

## 🔍 Come Funziona il Workflow

### Trigger
Il workflow si attiva automaticamente quando:
- Fai **push** sul branch **main**

### Steps del Workflow

1. **Checkout** - Scarica il codice dal repository
2. **Setup Xcode 15.3** - Configura l'ambiente di build
3. **Install xcpretty** - Tool per formattare i log di build
4. **Cache SPM** - Velocizza le build successive (cache delle dipendenze)
5. **Build iOS** - Compila per iPhone Simulator
6. **Build iPadOS** - Compila per iPad Simulator  
7. **Run Tests** - Esegue i test con code coverage
8. **Upload Test Results** - Salva i risultati dei test (30 giorni)
9. **Generate Build Info** - Crea un file con info sulla build
10. **Upload Build Info** - Salva le info (90 giorni)
11. **Create Tag** - Crea un tag Git (es: `build-success-20260315-143022`)
12. **Create Release** - Crea una GitHub Release con dettagli

---

## 📊 Monitorare le Build

### Su GitHub

1. Vai sul tuo repository
2. Clicca sulla tab **Actions**
3. Vedrai la lista di tutti i workflow eseguiti
4. Clicca su uno specifico workflow per vedere:
   - Log dettagliati di ogni step
   - Artefatti scaricabili
   - Tempo di esecuzione

### Releases

1. Vai sulla tab **Releases** del repository
2. Vedrai tutte le build riuscite con:
   - Numero build
   - Commit SHA
   - Data e ora
   - File scaricabili

---

## 🐛 Troubleshooting

### Errore: "Scheme not found"

**Soluzione**: Lo scheme non è condiviso
```bash
# Verifica che esista il file
ls ScubaDiabetes.xcodeproj/xcshareddata/xcschemes/

# Se non esiste, torna al punto 1 della checklist
```

### Errore: "Permission denied" durante push

**Soluzione**: Permessi del workflow non configurati
- Vai su Settings → Actions → General
- Abilita "Read and write permissions"

### Errore: "Simulator not available"

**Soluzione**: Il simulatore specificato non esiste
- Il workflow usa `iPhone 15 Pro` e `iPad Pro 13-inch (M4)`
- Questi sono disponibili su macOS 14 con Xcode 15.3

### Build fallisce ma localmente funziona

**Possibili cause**:
1. **Dipendenze mancanti**: Verifica che tutte le dipendenze SPM siano committate
2. **Secrets/API Keys**: Se usi API keys, devi aggiungerle come Secrets GitHub
3. **File mancanti**: Verifica con `git status` che tutti i file siano tracciati

---

## 🎯 Personalizzazioni Utili

### Cambiare il Branch di Trigger

Modifica il file `.github/workflows/ios-build-tag.yml`:

```yaml
on:
  push:
    branches: [ main, develop, feature/* ]  # Aggiungi altri branch
```

### Aggiungere Build per macOS

Aggiungi questo step dopo "Build for iPadOS":

```yaml
- name: Build for macOS
  run: |
    xcodebuild build \
      -scheme ScubaDiabetes \
      -destination 'platform=macOS,arch=arm64' \
      -configuration Debug \
      CODE_SIGN_IDENTITY="" \
      CODE_SIGNING_REQUIRED=NO \
      | xcpretty && exit ${PIPESTATUS[0]}
```

### Disabilitare Temporaneamente il Workflow

Aggiungi all'inizio del file:

```yaml
on:
  workflow_dispatch:  # Esegui solo manualmente
```

---

## 📈 Badge per il README

Aggiungi questo al tuo `README.md` per mostrare lo stato della build:

```markdown
![iOS Build](https://github.com/tuoUsername/ch..scubadiabetes.app/workflows/iOS%20Build%20with%20Auto-Tag/badge.svg)
```

Sostituisci `tuoUsername` con il tuo username GitHub.

---

## 🔐 Gestione Secrets (Opzionale)

Se devi usare API keys o certificati:

1. Vai su **Settings → Secrets and variables → Actions**
2. Clicca **New repository secret**
3. Nome: `API_KEY` (esempio)
4. Valore: la tua chiave
5. Nel workflow, accedi con: `${{ secrets.API_KEY }}`

---

## 📞 Supporto

Se hai problemi:
1. Controlla i log nella tab Actions
2. Verifica questa checklist
3. Controlla la documentazione GitHub Actions: https://docs.github.com/actions

---

**Happy Building! 🎉**

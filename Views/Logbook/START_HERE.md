# 🚀 GitHub Actions CI/CD - Setup Completo per ScubaDiabetes

## ✨ Cosa hai a disposizione

Ho creato un **sistema completo di CI/CD** per il tuo progetto ScubaDiabetes che:

✅ Compila automaticamente l'app per iOS e iPadOS  
✅ Esegue i test automaticamente  
✅ Crea release su GitHub quando la build ha successo  
✅ Genera tag cronologici per ogni build  
✅ Salva i risultati dei test  
✅ Ti avvisa se qualcosa va storto  

---

## 🎯 Cosa Devi Fare ORA (3 Step!)

### Step 1: Condividi lo Scheme in Xcode (IMPORTANTE!)

1. Apri il progetto in **Xcode**
2. Vai su menu: **Product → Scheme → Manage Schemes...**
3. Trova lo scheme **ScubaDiabetes**
4. Seleziona la checkbox **"Shared"** ✅
5. Chiudi la finestra

### Step 2: Esegui lo Script di Setup

Apri il **Terminale**, vai nella cartella del progetto e digita:

```bash
chmod +x setup-ci-complete.sh
./setup-ci-complete.sh
```

Lo script ti guiderà passo-passo e farà tutto automaticamente!

### Step 3: Configura i Permessi su GitHub

**IMPORTANTE**: Prima del primo push, vai su:

```
https://github.com/TUO_USERNAME/ch..scubadiabetes.app/settings/actions
```

Poi:
1. Scorri fino a **"Workflow permissions"**
2. Seleziona: **"Read and write permissions"** ✅
3. Abilita: **"Allow GitHub Actions to create and approve pull requests"** ✅
4. Clicca **Save**

---

## 📁 File Creati

### Script Eseguibili
- **`setup-ci-complete.sh`** - Setup guidato COMPLETO (usa questo!)
- **`verify-ci-setup.sh`** - Verifica che tutto sia OK
- **`organize-workflow-files.sh`** - Organizza i file nella struttura corretta

### Documentazione
- **`QUICKSTART.md`** - Guida rapida
- **`INDEX.md`** - Indice di tutti i file
- **`README_CI.md`** - README completo
- **`GITHUB_ACTIONS_SETUP.md`** - Guida dettagliata e troubleshooting
- **`START_HERE.md`** - Questo file!

### Workflow Files
- **`.github/workflows/ios-build-tag.yml`** - Workflow principale (build + release)
- **`.github/workflows/pr-check.yml`** - Verifica Pull Request

---

## 🎬 Workflow Passo-Passo

```
1. Tu:    Modifichi il codice
         ↓
2. Tu:    git add . && git commit -m "Fix bug"
         ↓
3. Tu:    git push origin main
         ↓
4. GitHub: 🤖 Avvia GitHub Actions (automatico!)
         ↓
5. GitHub: 🔨 Compila per iOS + iPadOS
         ↓
6. GitHub: 🧪 Esegue i test
         ↓
         ├─ ✅ SUCCESSO → Crea Release + Tag
         │
         └─ ❌ FALLITO → Ti avvisa via email
```

---

## 📊 Cosa Succede Dopo il Push

Quando fai `git push origin main`, GitHub Actions:

1. **Scarica** il codice
2. **Installa** Xcode 15.3 su macOS 14
3. **Compila** per iPhone 15 Pro (Simulator)
4. **Compila** per iPad Pro (Simulator)
5. **Esegue** tutti i test con code coverage
6. **Salva** i risultati dei test (disponibili per 30 giorni)
7. **Crea** un tag Git (es: `build-success-20260315-143022`)
8. **Crea** una GitHub Release con:
   - Numero build
   - Commit SHA
   - Data e ora
   - Info su piattaforme e target
   - File scaricabili

**Tempo totale**: ~5-8 minuti

---

## 🔍 Dove Vedere i Risultati

### Su GitHub - Tab "Actions"
```
https://github.com/TUO_USERNAME/ch..scubadiabetes.app/actions
```
Qui vedi:
- Tutti i workflow eseguiti
- Log dettagliati di ogni step
- Eventuali errori
- Tempo di esecuzione

### Su GitHub - Tab "Releases"
```
https://github.com/TUO_USERNAME/ch..scubadiabetes.app/releases
```
Qui vedi:
- Tutte le build riuscite
- Info dettagliate su ogni build
- File scaricabili (test results, build info)

### Su GitHub - Tab "Tags"
```
https://github.com/TUO_USERNAME/ch..scubadiabetes.app/tags
```
Qui vedi:
- Tag cronologici di ogni build
- Formato: `build-success-YYYYMMDD-HHMMSS`

---

## 🎨 Badge per il README

Aggiungi questo al tuo `README.md` principale per mostrare lo stato della build:

```markdown
![Build Status](https://github.com/TUO_USERNAME/ch..scubadiabetes.app/workflows/iOS%20Build%20with%20Auto-Tag/badge.svg)
```

Cambia `TUO_USERNAME` con il tuo username GitHub.

---

## 🐛 Problemi Comuni e Soluzioni

### ❌ Il workflow non parte dopo il push

**Soluzione**: Hai configurato i permessi?
- Vai su: Settings → Actions → General
- Seleziona: "Read and write permissions"
- Salva

### ❌ Errore: "Scheme 'ScubaDiabetes' not found"

**Soluzione**: Lo scheme non è condiviso
1. Xcode → Product → Scheme → Manage Schemes
2. Seleziona "Shared" per ScubaDiabetes ✅
3. Committa il file: `git add ScubaDiabetes.xcodeproj/xcshareddata/`

### ❌ Errore: "Permission denied" durante push tag

**Soluzione**: Permessi non configurati
- GitHub → Settings → Actions → "Read and write permissions" ✅

### ⚠️ Build locale funziona, ma CI fallisce

**Possibili cause**:
1. Dipendenze SPM non committate
2. File mancanti nel repository
3. Secrets/API keys non configurati come GitHub Secrets

**Verifica**:
```bash
./verify-ci-setup.sh
git status
```

---

## 🔧 Comandi Utili

### Verifica Prima del Push
```bash
./verify-ci-setup.sh
```

### Riorganizza File (se necessario)
```bash
./organize-workflow-files.sh
```

### Verifica Scheme Condiviso
```bash
ls ScubaDiabetes.xcodeproj/xcshareddata/xcschemes/
# Deve mostrare: ScubaDiabetes.xcscheme
```

### Verifica Workflow Files
```bash
ls .github/workflows/
# Deve mostrare: ios-build-tag.yml e pr-check.yml
```

---

## 📚 Documentazione Completa

| Hai Bisogno Di... | Leggi Questo |
|-------------------|--------------|
| Setup veloce | `QUICKSTART.md` |
| Indice di tutti i file | `INDEX.md` |
| Guida completa | `README_CI.md` |
| Troubleshooting dettagliato | `GITHUB_ACTIONS_SETUP.md` |
| Questa panoramica | `START_HERE.md` |

---

## ✅ Checklist Finale

Prima di fare il primo push:

- [ ] Scheme condiviso in Xcode (Product → Scheme → Manage Schemes → Shared ✅)
- [ ] Eseguito `./setup-ci-complete.sh` senza errori
- [ ] Permessi configurati su GitHub (Settings → Actions → Read and write ✅)
- [ ] Eseguito `./verify-ci-setup.sh` → tutto OK
- [ ] File committati: `git status` mostra i file giusti
- [ ] Remote configurato: `git remote -v` mostra il repository corretto

Se tutto è ✅, sei pronto!

```bash
git push origin main
```

---

## 🎉 Prossimi Passi

Dopo il primo push riuscito:

1. ✅ Vai su GitHub → Actions e guarda il workflow in esecuzione
2. ✅ Dopo 5-8 minuti, controlla la tab Releases
3. ✅ Aggiungi il badge al README principale
4. ✅ Celebra! 🎊

### Miglioramenti Futuri (Opzionali)

- 🔜 Aggiungere test UI automatici
- 🔜 Deploy automatico su TestFlight
- 🔜 Code coverage reports
- 🔜 Notifiche Slack/Discord
- 🔜 Danger per PR automation

---

## 📞 Serve Aiuto?

### 1. Esegui il Check
```bash
./verify-ci-setup.sh
```

### 2. Leggi il Troubleshooting
Apri: `GITHUB_ACTIONS_SETUP.md` sezione "Risoluzione Problemi Comuni"

### 3. Controlla i Log
Vai su: GitHub → Actions → Seleziona il workflow → Guarda i log

---

## 🚀 Sei Pronto!

Ora hai un sistema di CI/CD professionale che:

✅ Verifica automaticamente ogni push  
✅ Esegue i test  
✅ Crea release automatiche  
✅ Ti tiene aggiornato sullo stato del progetto  
✅ Risparmia tempo e previene errori  

**Buon coding! 🎊**

---

*Creato il 15 Marzo 2026*  
*Per il progetto: ScubaDiabetes (ch.scubadiabetes.app)*

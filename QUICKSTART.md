# 🎯 Quick Start - GitHub Actions per ScubaDiabetes

## ⚡ Setup in 5 Minuti

```bash
# 1. Organizza i file nella struttura corretta
chmod +x organize-workflow-files.sh
./organize-workflow-files.sh

# 2. Verifica che tutto sia OK
./verify-ci-setup.sh

# 3. Committa
git add .github/ *.md *.sh .gitignore
git commit -m "🚀 Add GitHub Actions CI/CD"

# 4. Configura i permessi su GitHub (vedi sotto)

# 5. Pusha!
git push origin main
```

---

## 🔧 Configurazione Permessi GitHub (IMPORTANTE!)

**DEVI fare questo PRIMA del primo push!**

### Percorso:
```
GitHub.com → Il tuo repository → Settings → Actions → General
```

### Impostazioni da modificare:

1. Scorri fino a **"Workflow permissions"**

2. Seleziona:
   ```
   ⚪ Read repository contents and packages permissions
   ✅ Read and write permissions  ← SELEZIONA QUESTO
   ```

3. Abilita:
   ```
   ✅ Allow GitHub Actions to create and approve pull requests
   ```

4. Clicca **Save**

---

## 📁 Struttura File che Verrà Creata

```
ScubaDiabetes/
├── .github/
│   └── workflows/
│       ├── ios-build-tag.yml    ← Workflow principale
│       └── pr-check.yml          ← Workflow per PR
│
├── ScubaDiabetes.xcodeproj/
│   └── xcshareddata/
│       └── xcschemes/
│           └── ScubaDiabetes.xcscheme  ← IMPORTANTE: deve esistere!
│
├── .gitignore                    ← Ignora file non necessari
├── README_CI.md                  ← Questa guida
├── GITHUB_ACTIONS_SETUP.md       ← Guida completa
├── verify-ci-setup.sh            ← Script di verifica
└── organize-workflow-files.sh    ← Script organizzazione
```

---

## ✅ Checklist Pre-Push

Usa questa checklist prima di fare `git push`:

### In Xcode:
- [ ] Apri **Product → Scheme → Manage Schemes**
- [ ] Verifica che **ScubaDiabetes** abbia la checkbox **"Shared"** selezionata ✅
- [ ] Se non era selezionata, selezionala e chiudi

### Nel Terminale:
```bash
# Verifica che il file dello scheme esista
ls ScubaDiabetes.xcodeproj/xcshareddata/xcschemes/ScubaDiabetes.xcscheme
# ✅ Se vedi il percorso del file → OK
# ❌ Se vedi "No such file" → Torna in Xcode e condividi lo scheme
```

### Su GitHub:
- [ ] Vai su Settings → Actions → General
- [ ] Abilita "Read and write permissions"
- [ ] Abilita "Allow GitHub Actions to create and approve pull requests"
- [ ] Clicca Save

### Final Check:
```bash
# Esegui questo comando
./verify-ci-setup.sh

# ✅ Se vedi "TUTTO OK! Sei pronto per il push!" → Vai!
# ❌ Se vedi errori → Risolvili prima di continuare
```

---

## 🚀 Primo Push

Quando sei pronto:

```bash
git push origin main
```

Poi:
1. Vai su **GitHub.com → tuo repository**
2. Clicca sulla tab **Actions**
3. Vedrai il workflow in esecuzione in tempo reale!

---

## 📊 Cosa Succede Dopo il Push

### 1. GitHub Actions si Attiva (automatico)
```
⏱️  Tempo stimato: 5-8 minuti
```

### 2. Steps Eseguiti:
```
✅ Checkout del codice
✅ Setup Xcode 15.3
✅ Install xcpretty
✅ Cache dipendenze
✅ Build iOS (iPhone)
✅ Build iPadOS (iPad)
✅ Run Tests con coverage
✅ Upload test results
✅ Crea tag (es: build-success-20260315-143022)
✅ Crea GitHub Release
```

### 3. Risultati Disponibili:

#### Tab "Actions"
- Log dettagliati di ogni step
- Tempo di esecuzione
- Eventuali errori

#### Tab "Releases"
- Lista di tutte le build riuscite
- Info su commit, branch, data
- File scaricabili

#### Tab "Tags"
- Tag cronologici
- Uno per ogni build riuscita

---

## 🎨 Badge per il README

Dopo il primo workflow riuscito, aggiungi questo al tuo `README.md`:

```markdown
![Build Status](https://github.com/TUO_USERNAME/ch..scubadiabetes.app/workflows/iOS%20Build%20with%20Auto-Tag/badge.svg)
```

Sostituisci `TUO_USERNAME` con il tuo username GitHub.

---

## 🐛 Problemi? Soluzioni Rapide

### Il workflow non parte
➡️ Hai configurato i permessi? (Vedi sezione "Configurazione Permessi")

### Errore "Scheme not found"
➡️ Lo scheme non è condiviso:
```bash
# In Xcode: Product → Scheme → Manage Schemes → Shared ✅
# Poi committa: git add . && git commit -m "Share scheme"
```

### Errore "Permission denied"
➡️ Permessi workflow non configurati:
```bash
# GitHub → Settings → Actions → General
# Read and write permissions ✅
```

### Build locale funziona, CI no
➡️ Dipendenze mancanti:
```bash
# Verifica che tutti i file necessari siano committati
git status
git add .
```

---

## 📞 Hai Bisogno di Aiuto?

### 📚 Documentazione:
- **Quick Start**: `README_CI.md` (questo file)
- **Guida Completa**: `GITHUB_ACTIONS_SETUP.md`
- **Script Verifica**: `./verify-ci-setup.sh`

### 🔍 Check Rapido:
```bash
# File workflow esistono?
ls .github/workflows/

# Scheme condiviso?
ls ScubaDiabetes.xcodeproj/xcshareddata/xcschemes/

# Git configurato?
git remote -v

# Tutto ok?
./verify-ci-setup.sh
```

---

## 🎯 Workflow Completo Riassunto

```
┌─────────────────────────────────────────┐
│  1. Fai modifiche al codice            │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  2. git add . && git commit -m "..."   │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  3. git push origin main               │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  4. GitHub Actions si attiva (auto)    │
│     ⏱️  ~5-8 minuti                     │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  5. Build + Test su macOS 14           │
│     • iPhone 15 Pro Simulator          │
│     • iPad Pro Simulator               │
│     • Unit Tests                       │
└──────────────┬──────────────────────────┘
               │
               ▼
      ┌────────┴────────┐
      │                 │
      ▼                 ▼
┌──────────┐      ┌──────────┐
│ SUCCESS  │      │  FAILED  │
│    ✅    │      │    ❌    │
└────┬─────┘      └────┬─────┘
     │                 │
     ▼                 ▼
┌──────────┐      ┌──────────┐
│ Crea Tag │      │ Check    │
│ Crea     │      │ Logs in  │
│ Release  │      │ Actions  │
└──────────┘      └──────────┘
```

---

## 🎉 Sei Pronto!

Se hai seguito tutti gli step, ora puoi:

1. ✅ Pushare su `main` e vedere il workflow attivarsi
2. ✅ Creare Pull Request e vedere i check automatici
3. ✅ Avere release automatiche ad ogni build riuscita
4. ✅ Tenere traccia di tutte le build con tag cronologici

**Buon coding e buon CI/CD! 🚀**

---

*Ultima modifica: 15 Marzo 2026*

# 📖 Indice Documentazione GitHub Actions

Questa cartella contiene tutti i file necessari per configurare e utilizzare GitHub Actions per il progetto ScubaDiabetes.

## 🚀 Inizio Rapido

### Per iniziare SUBITO:

```bash
# 1. Rendi eseguibili gli script
chmod +x setup-ci-complete.sh
chmod +x verify-ci-setup.sh
chmod +x organize-workflow-files.sh

# 2. Esegui il setup completo (guidato)
./setup-ci-complete.sh
```

Lo script `setup-ci-complete.sh` ti guiderà passo-passo attraverso TUTTA la configurazione.

---

## 📁 File Disponibili

### 🎯 Script Eseguibili

| File | Cosa fa | Quando usarlo |
|------|---------|---------------|
| **`setup-ci-complete.sh`** | Setup COMPLETO guidato | Prima volta - fa tutto! |
| **`verify-ci-setup.sh`** | Verifica configurazione | Prima di ogni push |
| **`organize-workflow-files.sh`** | Organizza file .github/ | Se i file sono nella posizione sbagliata |

### 📚 Documentazione

| File | Contenuto | Quando leggerlo |
|------|-----------|-----------------|
| **`QUICKSTART.md`** | Guida rapida con checklist | Per setup veloce |
| **`README_CI.md`** | README completo del CI | Per capire il sistema |
| **`GITHUB_ACTIONS_SETUP.md`** | Guida dettagliata e troubleshooting | Quando hai problemi |
| **`INDEX.md`** | Questo file - indice | Per navigare |

### ⚙️ File Workflow

| File | Cosa fa | Trigger |
|------|---------|---------|
| **`.github/workflows/ios-build-tag.yml`** | Build completa + Release | Push su `main` |
| **`.github/workflows/pr-check.yml`** | Verifica Pull Request | Apertura PR |

### 🛠️ Altri File

| File | Descrizione |
|------|-------------|
| **`.gitignore`** | File da ignorare in Git |

---

## 🎓 Percorsi di Apprendimento

### 👶 Sono Nuovo a GitHub Actions

1. Leggi: **`QUICKSTART.md`** (5 minuti)
2. Esegui: **`./setup-ci-complete.sh`** (10 minuti)
3. Guarda il workflow in azione su GitHub
4. Leggi: **`README_CI.md`** per capire meglio

### 🔧 Voglio Solo Configurare e Basta

```bash
./setup-ci-complete.sh
```

Fatto! Lo script fa tutto.

### 🚨 Ho un Problema

1. Esegui: **`./verify-ci-setup.sh`** per diagnosticare
2. Leggi: **`GITHUB_ACTIONS_SETUP.md`** sezione "Troubleshooting"
3. Controlla i log su GitHub → Actions

### 🎨 Voglio Personalizzare il Workflow

1. Leggi: **`GITHUB_ACTIONS_SETUP.md`** sezione "Personalizzazioni"
2. Modifica: **`.github/workflows/ios-build-tag.yml`**
3. Testa: Fai push e controlla su GitHub Actions

---

## 📊 Workflow Completo

```
┌─────────────────────┐
│  1. SETUP INIZIALE  │  ← Usa: setup-ci-complete.sh
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  2. VERIFICA        │  ← Usa: verify-ci-setup.sh
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  3. COMMITTA        │  ← git commit -m "..."
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  4. PUSH            │  ← git push origin main
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  5. GITHUB ACTIONS  │  ← Automatico!
│     In esecuzione   │
└─────────────────────┘
```

---

## 🎯 Comandi Essenziali

### Setup Iniziale (Una Volta)

```bash
# Setup completo guidato
./setup-ci-complete.sh
```

### Prima di Ogni Push

```bash
# Verifica veloce
./verify-ci-setup.sh

# Se OK, pusha
git push origin main
```

### Troubleshooting

```bash
# Riorganizza i file se necessario
./organize-workflow-files.sh

# Verifica di nuovo
./verify-ci-setup.sh

# Controlla lo scheme
ls ScubaDiabetes.xcodeproj/xcshareddata/xcschemes/

# Verifica workflow files
ls .github/workflows/
```

---

## 📋 Checklist Veloce

Prima del primo push:

- [ ] Eseguito `./setup-ci-complete.sh`
- [ ] Scheme condiviso in Xcode (Product → Scheme → Manage Schemes → Shared ✅)
- [ ] Permessi configurati su GitHub (Settings → Actions → Read and write ✅)
- [ ] `./verify-ci-setup.sh` passa senza errori
- [ ] File committati: `git add .github/ *.md *.sh`

Sei pronto! 🚀

---

## 🆘 Aiuto Rapido

### Il workflow non parte dopo il push
➡️ Hai configurato i permessi su GitHub? (Settings → Actions → General → Read and write permissions)

### Errore: "Scheme not found"
➡️ In Xcode: Product → Scheme → Manage Schemes → Seleziona "Shared" ✅

### Errore: "Permission denied"
➡️ GitHub → Settings → Actions → Read and write permissions ✅

### Non so da dove iniziare
➡️ Esegui: `./setup-ci-complete.sh` e segui le istruzioni

---

## 📞 Supporto

### Per problemi tecnici:
1. Esegui `./verify-ci-setup.sh` per diagnostica
2. Leggi `GITHUB_ACTIONS_SETUP.md` sezione Troubleshooting
3. Controlla i log su GitHub → Actions

### Per capire meglio:
1. `QUICKSTART.md` - Setup veloce
2. `README_CI.md` - Guida completa
3. `GITHUB_ACTIONS_SETUP.md` - Dettagli e personalizzazioni

---

## 🎉 Quick Tips

### Badge nel README
Aggiungi al tuo README.md principale:
```markdown
![Build Status](https://github.com/USERNAME/ch..scubadiabetes.app/workflows/iOS%20Build%20with%20Auto-Tag/badge.svg)
```

### Vedere i risultati
- **Logs**: GitHub → Actions → Seleziona workflow
- **Releases**: GitHub → Releases
- **Tags**: GitHub → Tags

### Modificare il workflow
1. Edita `.github/workflows/ios-build-tag.yml`
2. Committa e pusha
3. GitHub Actions userà la nuova versione

---

## 📚 Link Utili

- [GitHub Actions Docs](https://docs.github.com/actions)
- [Xcode Build Settings](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [GitHub Actions for iOS](https://github.com/actions/runner-images/blob/main/images/macos/macos-14-Readme.md)

---

## 🗺️ Roadmap

Dopo il setup iniziale, considera:

1. ✅ Setup CI/CD completato
2. 🔜 Aggiungere test di UI
3. 🔜 Configurare deploy automatico su TestFlight
4. 🔜 Aggiungere code coverage reports
5. 🔜 Integrare Danger per PR automation

---

**Buon coding! 🚀**

*Ultima modifica: 15 Marzo 2026*

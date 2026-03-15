# ScubaDiabetes - GitHub Actions Setup

## 🚀 Setup Rapido

### Prerequisiti

Prima di iniziare, assicurati di avere:
- ✅ Xcode installato (versione 15.3 o superiore)
- ✅ Account GitHub
- ✅ Repository GitHub creato: `ch..scubadiabetes.app`
- ✅ Git configurato localmente

---

## 📋 Step-by-Step

### 1. Condividi lo Scheme in Xcode

**IMPORTANTE**: Questo è il passaggio più critico!

1. Apri `ScubaDiabetes.xcodeproj` in Xcode
2. Vai su menu: **Product → Scheme → Manage Schemes...**
3. Nella finestra che si apre, trova lo scheme **ScubaDiabetes**
4. Assicurati che la checkbox **"Shared"** sia **SELEZIONATA** ✅
5. Clicca su **Close**

Questo creerà automaticamente:
```
ScubaDiabetes.xcodeproj/
  └── xcshareddata/
      └── xcschemes/
          └── ScubaDiabetes.xcscheme
```

### 2. Esegui lo Script di Verifica

Nel terminale, dalla directory root del progetto:

```bash
# Rendi lo script eseguibile
chmod +x verify-ci-setup.sh

# Esegui la verifica
./verify-ci-setup.sh
```

Lo script controllerà:
- ✅ Presenza del workflow
- ✅ Scheme condiviso
- ✅ Configurazione Git
- ✅ Branch corrente
- ✅ File importanti

### 3. Configura i Permessi su GitHub

1. Vai su: https://github.com/TUO_USERNAME/ch..scubadiabetes.app
2. Clicca su **Settings** (tab in alto del repository)
3. Nel menu laterale sinistro: **Actions → General**
4. Scorri in basso fino a **"Workflow permissions"**
5. Seleziona: **"Read and write permissions"** ⚪→✅
6. Abilita: **"Allow GitHub Actions to create and approve pull requests"** ⚪→✅
7. Clicca **Save**

### 4. Committa e Pusha

```bash
# Verifica lo stato
git status

# Aggiungi tutti i file necessari
git add .github/workflows/ios-build-tag.yml
git add .github/workflows/pr-check.yml
git add ScubaDiabetes.xcodeproj/xcshareddata/
git add GITHUB_ACTIONS_SETUP.md
git add verify-ci-setup.sh
git add README_CI.md

# Committa
git commit -m "🚀 Add GitHub Actions CI/CD workflow"

# Pusha
git push origin main
```

### 5. Verifica il Workflow

1. Vai su: https://github.com/TUO_USERNAME/ch..scubadiabetes.app
2. Clicca sulla tab **Actions**
3. Dovresti vedere il workflow "iOS Build with Auto-Tag" in esecuzione
4. Clicca sul workflow per vedere i dettagli in tempo reale

---

## 🎯 Cosa Fa il Workflow

Quando fai `push` sul branch `main`, il workflow:

1. ✅ **Scarica il codice** dal repository
2. ✅ **Configura Xcode 15.3** su macOS 14
3. ✅ **Installa xcpretty** per log più leggibili
4. ✅ **Cacha le dipendenze SPM** per build più veloci
5. ✅ **Compila per iOS** (iPhone 15 Pro Simulator)
6. ✅ **Compila per iPadOS** (iPad Pro Simulator)
7. ✅ **Esegue i test** con code coverage
8. ✅ **Carica i risultati dei test** come artifacts
9. ✅ **Genera info sulla build**
10. ✅ **Crea un tag Git** (es: `build-success-20260315-143022`)
11. ✅ **Crea una GitHub Release** con tutti i dettagli

---

## 📊 Dove Trovare i Risultati

### Actions Tab
- **Percorso**: GitHub → Actions
- **Cosa trovi**: 
  - Log dettagliati di ogni step
  - Tempo di esecuzione
  - Errori (se ci sono)
  - Artifacts scaricabili

### Releases Tab
- **Percorso**: GitHub → Releases
- **Cosa trovi**:
  - Lista di tutte le build riuscite
  - Numero build, commit, data
  - File scaricabili (build info, test results)

### Tags
- **Percorso**: GitHub → Tags
- **Cosa trovi**:
  - Tag cronologici di ogni build riuscita
  - Es: `build-success-20260315-143022`

---

## 🐛 Problemi Comuni

### ❌ Errore: "Scheme 'ScubaDiabetes' not found"

**Causa**: Lo scheme non è condiviso  
**Soluzione**: 
1. Torna allo Step 1
2. Assicurati di aver selezionato "Shared"
3. Committa il file `xcshareddata/xcschemes/ScubaDiabetes.xcscheme`

### ❌ Errore: "Permission denied" durante push del tag

**Causa**: Workflow non ha permessi di scrittura  
**Soluzione**: 
1. Vai su Settings → Actions → General
2. Abilita "Read and write permissions"

### ❌ Build fallisce ma localmente funziona

**Possibili cause**:
1. **Dipendenze mancanti**: Verifica che tutte le dipendenze siano committate
2. **Secrets non configurati**: Se usi API keys, aggiungile come GitHub Secrets
3. **File .gitignore troppo aggressivo**: Verifica che i file necessari non siano ignorati

### ⚠️ Warning: "Simulator not available"

**Causa**: Il simulatore specificato non è disponibile  
**Soluzione**: 
- Il workflow usa iPhone 15 Pro e iPad Pro 13-inch (M4)
- Questi sono disponibili su macOS 14 con Xcode 15.3
- Se usi Xcode più vecchio, modifica il workflow

---

## 🎨 Personalizzazioni

### Badge nel README

Aggiungi questo al tuo `README.md`:

```markdown
![Build Status](https://github.com/TUO_USERNAME/ch..scubadiabetes.app/workflows/iOS%20Build%20with%20Auto-Tag/badge.svg)
```

### Trigger su Altri Branch

Modifica `.github/workflows/ios-build-tag.yml`:

```yaml
on:
  push:
    branches: [ main, develop, staging ]  # Aggiungi altri branch
```

### Notifiche Slack (Opzionale)

Aggiungi al workflow:

```yaml
- name: Notify Slack
  if: success()
  uses: 8398a7/action-slack@v3
  with:
    status: success
    text: '✅ Build iOS completata!'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

Poi aggiungi il webhook come Secret:
1. Settings → Secrets and variables → Actions
2. New repository secret → Nome: `SLACK_WEBHOOK`

---

## 📚 File Creati

| File | Descrizione |
|------|-------------|
| `.github/workflows/ios-build-tag.yml` | Workflow principale per build su main |
| `.github/workflows/pr-check.yml` | Workflow per verificare le Pull Request |
| `GITHUB_ACTIONS_SETUP.md` | Guida completa e troubleshooting |
| `README_CI.md` | Questo file - quick start |
| `verify-ci-setup.sh` | Script di verifica pre-push |
| `.gitignore` | File da ignorare in Git |

---

## ✅ Checklist Finale

Prima di fare push, verifica:

- [ ] Scheme condiviso in Xcode
- [ ] Script `verify-ci-setup.sh` eseguito senza errori
- [ ] Permessi workflow configurati su GitHub
- [ ] File workflow committati
- [ ] File `.gitignore` aggiornato
- [ ] Scheme file presente in `xcshareddata/`

Se tutto è ✅, sei pronto!

```bash
git push origin main
```

Poi vai su **GitHub → Actions** e guarda la magia! 🎉

---

## 📞 Supporto

- 📖 Guida completa: `GITHUB_ACTIONS_SETUP.md`
- 🔧 Script verifica: `./verify-ci-setup.sh`
- 📚 Documentazione GitHub Actions: https://docs.github.com/actions

**Buon coding! 🚀**

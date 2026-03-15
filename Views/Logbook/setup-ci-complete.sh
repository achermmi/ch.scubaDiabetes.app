#!/bin/bash
# 
# SCRIPT COMPLETO DI SETUP - ESEGUI QUESTO!
# ==========================================
#
# Questo script esegue TUTTI i passaggi necessari per configurare GitHub Actions
# 

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║     🚀 Setup Completo GitHub Actions per ScubaDiabetes 🚀     ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colori
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

step_number=1

print_step() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Step $step_number: $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    step_number=$((step_number + 1))
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

info() {
    echo -e "ℹ️  $1"
}

# ══════════════════════════════════════════════════════════════
# STEP 1: Organizza i file
# ══════════════════════════════════════════════════════════════
print_step "Organizzazione file nella struttura corretta"

mkdir -p .github/workflows

if [ -f ".githubworkflowsios-build-tag.yml" ]; then
    mv .githubworkflowsios-build-tag.yml .github/workflows/ios-build-tag.yml
    success "Workflow principale spostato"
fi

if [ -f ".githubworkflowspr-check.yml" ]; then
    mv .githubworkflowspr-check.yml .github/workflows/pr-check.yml
    success "Workflow PR spostato"
fi

if [ -f ".githubworkflowsios-build.yml" ]; then
    mv .githubworkflowsios-build.yml .github/workflows/ios-build.yml
    success "Workflow build alternativo spostato"
fi

success "Struttura directory creata: .github/workflows/"

# ══════════════════════════════════════════════════════════════
# STEP 2: Verifica scheme condiviso
# ══════════════════════════════════════════════════════════════
print_step "Verifica scheme Xcode condiviso"

# Cerca QUALSIASI file .xcscheme in xcshareddata
SCHEME_FILE=$(find . -path "*/xcshareddata/xcschemes/*.xcscheme" -type f 2>/dev/null | head -n 1)

if [ -n "$SCHEME_FILE" ]; then
    success "Scheme condiviso trovato: $SCHEME_FILE"
    
    # Mostra tutti gli scheme condivisi trovati
    ALL_SCHEMES=$(find . -path "*/xcshareddata/xcschemes/*.xcscheme" -type f 2>/dev/null)
    if [ -n "$ALL_SCHEMES" ]; then
        info "Scheme condivisi disponibili:"
        echo "$ALL_SCHEMES" | while read -r scheme; do
            SCHEME_NAME=$(basename "$scheme" .xcscheme)
            echo "    • $SCHEME_NAME"
        done
    fi
else
    error "ATTENZIONE: Nessuno scheme condiviso trovato!"
    echo ""
    echo "  📋 Debug: cerchiamo tutti i file .xcscheme..."
    ALL_XCSCHEMES=$(find . -name "*.xcscheme" -type f 2>/dev/null)
    
    if [ -z "$ALL_XCSCHEMES" ]; then
        warning "Nessun file .xcscheme trovato nel progetto!"
    else
        echo ""
        info "File .xcscheme trovati:"
        echo "$ALL_XCSCHEMES"
        echo ""
    fi
    
    echo "  📋 DEVI fare questo MANUALMENTE in Xcode:"
    echo "  1. Apri il progetto in Xcode"
    echo "  2. Vai su: Product → Scheme → Manage Schemes..."
    echo "  3. Seleziona lo scheme 'ScubaDiabetes'"
    echo "  4. Abilita la checkbox 'Shared' ✅"
    echo "  5. Clicca 'Close' (importante!)"
    echo "  6. In Xcode, premi Cmd+S per salvare il progetto"
    echo ""
    read -p "  Premi INVIO dopo aver condiviso lo scheme in Xcode..." 
    
    # Ricontrolla con il nuovo metodo
    SCHEME_FILE=$(find . -path "*/xcshareddata/xcschemes/*.xcscheme" -type f 2>/dev/null | head -n 1)
    if [ -n "$SCHEME_FILE" ]; then
        success "Perfetto! Scheme ora condiviso: $SCHEME_FILE"
    else
        warning "Scheme ancora non trovato automaticamente."
        echo ""
        echo "  Proviamo comunque a continuare..."
        echo "  Se la build su GitHub fallisce, torna a questo passaggio."
        echo ""
        read -p "  Vuoi continuare comunque? (s/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            error "Setup interrotto. Verifica lo scheme e ri-esegui lo script."
            exit 1
        fi
    fi
fi

# ══════════════════════════════════════════════════════════════
# STEP 3: Verifica Git
# ══════════════════════════════════════════════════════════════
print_step "Verifica configurazione Git"

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Non è un repository Git!"
    echo "  Inizializza con: git init"
    exit 1
fi

success "Repository Git trovato"

REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
if [ -z "$REMOTE" ]; then
    warning "Remote 'origin' non configurato"
    echo ""
    echo "  Configura il remote con:"
    echo "  git remote add origin https://github.com/TUO_USERNAME/ch..scubadiabetes.app.git"
    echo ""
    read -p "  Vuoi configurarlo ora? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        read -p "  Inserisci l'URL del repository: " REPO_URL
        git remote add origin "$REPO_URL"
        success "Remote configurato!"
    fi
else
    success "Remote configurato: $REMOTE"
fi

# ══════════════════════════════════════════════════════════════
# STEP 4: Lista file da committare
# ══════════════════════════════════════════════════════════════
print_step "Preparazione file per commit"

# Aggiungi i file al git staging
git add .github/workflows/ 2>/dev/null || true
git add ScubaDiabetes.xcodeproj/xcshareddata/ 2>/dev/null || true
git add *.md 2>/dev/null || true
git add *.sh 2>/dev/null || true
git add .gitignore 2>/dev/null || true

# Mostra lo status
echo ""
info "File pronti per essere committati:"
git status --short

# ══════════════════════════════════════════════════════════════
# STEP 5: Commit
# ══════════════════════════════════════════════════════════════
print_step "Commit dei file"

echo ""
read -p "Vuoi committare ora? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    git commit -m "🚀 Add GitHub Actions CI/CD workflow

- Add iOS build workflow with auto-tagging
- Add PR check workflow
- Add verification and setup scripts
- Share Xcode scheme for CI
- Add comprehensive documentation" || true
    success "Commit eseguito!"
else
    warning "Commit saltato. Puoi farlo manualmente con:"
    echo "  git commit -m '🚀 Add GitHub Actions CI/CD workflow'"
fi

# ══════════════════════════════════════════════════════════════
# STEP 6: Istruzioni finali
# ══════════════════════════════════════════════════════════════
print_step "Configurazione GitHub (IMPORTANTE!)"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ⚠️  PRIMA DI FARE PUSH DEVI CONFIGURARE I PERMESSI SU GITHUB  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "1. Vai su: https://github.com/TUO_USERNAME/ch..scubadiabetes.app"
echo "2. Clicca: Settings → Actions → General"
echo "3. Scorri fino a 'Workflow permissions'"
echo "4. Seleziona: 'Read and write permissions' ✅"
echo "5. Abilita: 'Allow GitHub Actions to create and approve pull requests' ✅"
echo "6. Clicca: Save"
echo ""
read -p "Premi INVIO quando hai finito la configurazione su GitHub..." 

# ══════════════════════════════════════════════════════════════
# STEP 7: Push finale
# ══════════════════════════════════════════════════════════════
print_step "Push su GitHub"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")

echo ""
info "Branch corrente: $CURRENT_BRANCH"
echo ""
read -p "Vuoi pushare su GitHub ora? (s/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo ""
    info "Pushing to origin $CURRENT_BRANCH..."
    
    if git push origin "$CURRENT_BRANCH"; then
        success "Push completato con successo!"
        
        echo ""
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                    🎉 TUTTO FATTO! 🎉                          ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "  Prossimi passi:"
        echo ""
        echo "  1. Vai su GitHub: https://github.com/TUO_USERNAME/ch..scubadiabetes.app"
        echo "  2. Clicca sulla tab 'Actions'"
        echo "  3. Guarda il workflow in esecuzione in tempo reale!"
        echo "  4. Dopo ~5-8 minuti, controlla la tab 'Releases'"
        echo ""
        success "Setup GitHub Actions completato!"
        echo ""
    else
        error "Push fallito!"
        echo ""
        echo "  Possibili cause:"
        echo "  • Remote non configurato correttamente"
        echo "  • Credenziali Git non configurate"
        echo "  • Problemi di rete"
        echo ""
        echo "  Prova manualmente:"
        echo "  git push origin $CURRENT_BRANCH"
        echo ""
    fi
else
    warning "Push saltato."
    echo ""
    echo "  Quando sei pronto, esegui:"
    echo "  git push origin $CURRENT_BRANCH"
    echo ""
fi

# ══════════════════════════════════════════════════════════════
# RIEPILOGO FINALE
# ══════════════════════════════════════════════════════════════

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                      📚 DOCUMENTAZIONE                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "  • Quick Start:       QUICKSTART.md"
echo "  • Guida Completa:    GITHUB_ACTIONS_SETUP.md"
echo "  • README CI:         README_CI.md"
echo "  • Script Verifica:   ./verify-ci-setup.sh"
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                         🔍 CHECK                               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "  Verifica tutto con:"
echo "  ./verify-ci-setup.sh"
echo ""

success "Setup completato! 🚀"
echo ""

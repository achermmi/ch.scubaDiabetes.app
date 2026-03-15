#!/bin/bash

# Script di verifica pre-push per GitHub Actions
# Esegui questo script prima di fare push per verificare che tutto sia configurato correttamente

set -e

echo "🔍 Verifica Configurazione GitHub Actions per ScubaDiabetes"
echo "============================================================"
echo ""

# Colori per l'output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funzione per stampare successo
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Funzione per stampare errore
error() {
    echo -e "${RED}❌ $1${NC}"
}

# Funzione per stampare warning
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Variabile per tracciare errori
ERRORS=0

# 1. Verifica che il workflow esista
echo "1️⃣  Verifica file workflow..."
if [ -f ".github/workflows/ios-build-tag.yml" ] || [ -f ".githubworkflowsios-build-tag.yml" ]; then
    success "File workflow trovato"
else
    error "File workflow non trovato"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 2. Verifica che lo scheme sia condiviso
echo "2️⃣  Verifica scheme condiviso..."
SCHEME_FILE=$(find . -path "*/xcshareddata/xcschemes/*.xcscheme" -type f 2>/dev/null | head -n 1)
if [ -n "$SCHEME_FILE" ]; then
    success "Scheme condiviso trovato: $SCHEME_FILE"
else
    error "Scheme non condiviso!"
    echo "   👉 Vai su Product → Scheme → Manage Schemes in Xcode"
    echo "   👉 Seleziona 'Shared' per uno scheme"
    echo "   👉 Clicca 'Close' e salva il progetto (Cmd+S)"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 3. Verifica file progetto
echo "3️⃣  Verifica file progetto Xcode..."
if [ -d "ScubaDiabetes.xcodeproj" ] || [ -d "*.xcodeproj" ]; then
    success "File progetto trovato"
else
    warning "File .xcodeproj non trovato nella directory corrente"
    echo "   👉 Assicurati di essere nella directory root del progetto"
fi
echo ""

# 4. Verifica Git
echo "4️⃣  Verifica configurazione Git..."
if git rev-parse --git-dir > /dev/null 2>&1; then
    success "Repository Git inizializzato"
    
    # Verifica remote
    REMOTE=$(git remote -v | grep origin | head -n 1)
    if [ -n "$REMOTE" ]; then
        success "Remote configurato: $(echo $REMOTE | awk '{print $2}')"
    else
        warning "Nessun remote configurato"
        echo "   👉 Configura con: git remote add origin <url>"
    fi
else
    error "Non è un repository Git"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 5. Verifica branch
echo "5️⃣  Verifica branch corrente..."
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    success "Branch: $CURRENT_BRANCH"
else
    warning "Branch corrente: $CURRENT_BRANCH"
    echo "   👉 Il workflow si attiva solo su push a 'main'"
    echo "   👉 Considera di fare merge su main per attivare il workflow"
fi
echo ""

# 6. Verifica modifiche non committate
echo "6️⃣  Verifica modifiche non committate..."
if [ -z "$(git status --porcelain)" ]; then
    success "Nessuna modifica non committata"
else
    warning "Ci sono modifiche non committate:"
    git status --short
    echo "   👉 Ricorda di committare prima di pushare"
fi
echo ""

# 7. Verifica file importanti
echo "7️⃣  Verifica file importanti..."
IMPORTANT_FILES=(
    ".gitignore"
    "README.md"
)

for file in "${IMPORTANT_FILES[@]}"; do
    if [ -f "$file" ]; then
        success "$file presente"
    else
        warning "$file non trovato (opzionale)"
    fi
done
echo ""

# 8. Test build locale (opzionale)
echo "8️⃣  Test build locale..."
echo "   Vuoi eseguire un test build locale? (y/n)"
read -r -p "   " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "   🔨 Esecuzione build..."
    if xcodebuild -list &>/dev/null; then
        xcodebuild clean build \
            -scheme ScubaDiabetes \
            -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
            -configuration Debug \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            2>&1 | grep -E "BUILD (SUCCEEDED|FAILED)" || true
    else
        warning "xcodebuild non disponibile"
    fi
else
    warning "Build locale saltata"
fi
echo ""

# Riepilogo
echo "============================================================"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ TUTTO OK! Sei pronto per il push!${NC}"
    echo ""
    echo "Prossimi passi:"
    echo "1. Committa eventuali modifiche: git add . && git commit -m 'messaggio'"
    echo "2. Pusha su GitHub: git push origin main"
    echo "3. Vai su GitHub → Actions per vedere il workflow in esecuzione"
    echo "4. Configura i permessi del workflow (vedi GITHUB_ACTIONS_SETUP.md)"
else
    echo -e "${RED}❌ Trovati $ERRORS errori. Risolvili prima di procedere.${NC}"
    exit 1
fi
echo ""

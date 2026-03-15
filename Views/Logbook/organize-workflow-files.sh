#!/bin/bash

# Script per organizzare correttamente i file GitHub Actions
# Sposta i file nella struttura corretta .github/workflows/

set -e

echo "📁 Organizzazione File GitHub Actions"
echo "======================================"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# 1. Crea la struttura di directory corretta
info "Creazione struttura .github/workflows/"
mkdir -p .github/workflows

# 2. Sposta i file workflow se necessario
if [ -f ".githubworkflowsios-build-tag.yml" ]; then
    info "Spostamento ios-build-tag.yml..."
    mv .githubworkflowsios-build-tag.yml .github/workflows/ios-build-tag.yml
    success "ios-build-tag.yml spostato"
fi

if [ -f ".githubworkflowspr-check.yml" ]; then
    info "Spostamento pr-check.yml..."
    mv .githubworkflowspr-check.yml .github/workflows/pr-check.yml
    success "pr-check.yml spostato"
fi

if [ -f ".githubworkflowsios-build.yml" ]; then
    info "Spostamento ios-build.yml..."
    mv .githubworkflowsios-build.yml .github/workflows/ios-build.yml
    success "ios-build.yml spostato"
fi

# 3. Verifica che i file siano nella posizione corretta
echo ""
info "Verifica file nella posizione corretta..."
if [ -f ".github/workflows/ios-build-tag.yml" ]; then
    success ".github/workflows/ios-build-tag.yml ✓"
else
    echo "❌ ios-build-tag.yml non trovato!"
fi

if [ -f ".github/workflows/pr-check.yml" ]; then
    success ".github/workflows/pr-check.yml ✓"
else
    echo "⚠️  pr-check.yml non trovato (opzionale)"
fi

# 4. Rendi eseguibile lo script di verifica
if [ -f "verify-ci-setup.sh" ]; then
    chmod +x verify-ci-setup.sh
    success "verify-ci-setup.sh reso eseguibile"
fi

echo ""
echo "======================================"
success "Organizzazione completata!"
echo ""
echo "Prossimi passi:"
echo "1. Verifica la configurazione: ./verify-ci-setup.sh"
echo "2. Committa i file:"
echo "   git add .github/"
echo "   git add *.md"
echo "   git add *.sh"
echo "   git commit -m '🚀 Add GitHub Actions CI/CD'"
echo "3. Pusha su GitHub:"
echo "   git push origin main"
echo ""

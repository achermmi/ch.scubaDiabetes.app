#!/bin/bash

# Script di Debug per verificare lo stato dello scheme Xcode

echo "🔍 Debug Scheme Xcode"
echo "===================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "1️⃣  Cerca TUTTI i file .xcscheme nel progetto:"
echo "------------------------------------------------"
ALL_SCHEMES=$(find . -name "*.xcscheme" -type f 2>/dev/null)

if [ -z "$ALL_SCHEMES" ]; then
    echo -e "${RED}❌ Nessun file .xcscheme trovato!${NC}"
else
    echo "$ALL_SCHEMES" | while read -r scheme; do
        if echo "$scheme" | grep -q "xcshareddata"; then
            echo -e "${GREEN}✅ CONDIVISO: $scheme${NC}"
        else
            echo -e "${YELLOW}⚠️  PRIVATO:   $scheme${NC}"
        fi
    done
fi

echo ""
echo "2️⃣  Cerca solo scheme CONDIVISI (xcshareddata):"
echo "------------------------------------------------"
SHARED_SCHEMES=$(find . -path "*/xcshareddata/xcschemes/*.xcscheme" -type f 2>/dev/null)

if [ -z "$SHARED_SCHEMES" ]; then
    echo -e "${RED}❌ Nessuno scheme condiviso trovato!${NC}"
    echo ""
    echo "Questo significa che lo scheme NON è stato condiviso correttamente."
    echo ""
    echo "Cosa fare:"
    echo "1. In Xcode, vai su: Product → Scheme → Manage Schemes"
    echo "2. Verifica che la checkbox 'Shared' sia selezionata"
    echo "3. Clicca 'Close'"
    echo "4. Salva il progetto: Cmd+S"
    echo "5. Ri-esegui questo script: ./debug-scheme.sh"
else
    echo -e "${GREEN}✅ Scheme condivisi trovati:${NC}"
    echo "$SHARED_SCHEMES" | while read -r scheme; do
        SCHEME_NAME=$(basename "$scheme" .xcscheme)
        echo "   • $SCHEME_NAME"
        echo "     Percorso: $scheme"
    done
fi

echo ""
echo "3️⃣  Struttura directory xcshareddata:"
echo "--------------------------------------"
if [ -d "ScubaDiabetes.xcodeproj/xcshareddata" ]; then
    echo -e "${GREEN}✅ Directory xcshareddata esiste${NC}"
    
    if [ -d "ScubaDiabetes.xcodeproj/xcshareddata/xcschemes" ]; then
        echo -e "${GREEN}✅ Directory xcschemes esiste${NC}"
        
        SCHEME_COUNT=$(find ScubaDiabetes.xcodeproj/xcshareddata/xcschemes -name "*.xcscheme" 2>/dev/null | wc -l)
        echo "   Scheme trovati: $SCHEME_COUNT"
        
        if [ "$SCHEME_COUNT" -gt 0 ]; then
            ls -la ScubaDiabetes.xcodeproj/xcshareddata/xcschemes/
        fi
    else
        echo -e "${YELLOW}⚠️  Directory xcschemes NON esiste${NC}"
    fi
else
    echo -e "${RED}❌ Directory xcshareddata NON esiste${NC}"
    echo "   Questo conferma che lo scheme NON è condiviso."
fi

echo ""
echo "4️⃣  Cerca file di progetto Xcode:"
echo "----------------------------------"
XCODE_PROJECTS=$(find . -name "*.xcodeproj" -maxdepth 2 -type d 2>/dev/null)

if [ -z "$XCODE_PROJECTS" ]; then
    echo -e "${RED}❌ Nessun progetto Xcode trovato!${NC}"
else
    echo "$XCODE_PROJECTS" | while read -r proj; do
        echo -e "${GREEN}✅ $proj${NC}"
    done
fi

echo ""
echo "5️⃣  Verifica Git status:"
echo "------------------------"
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Repository Git attivo${NC}"
    
    # Verifica se ci sono modifiche non committate per xcshareddata
    if git status --porcelain | grep -q "xcshareddata"; then
        echo -e "${YELLOW}⚠️  Modifiche non committate in xcshareddata:${NC}"
        git status --short | grep xcshareddata
    else
        echo "   Nessuna modifica pending per xcshareddata"
    fi
else
    echo -e "${RED}❌ Non è un repository Git${NC}"
fi

echo ""
echo "═══════════════════════════════════════════════"
echo "📋 RIEPILOGO"
echo "═══════════════════════════════════════════════"

SHARED_COUNT=$(find . -path "*/xcshareddata/xcschemes/*.xcscheme" -type f 2>/dev/null | wc -l)

if [ "$SHARED_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ TUTTO OK! Hai $SHARED_COUNT scheme condivisi.${NC}"
    echo ""
    echo "Puoi procedere con:"
    echo "  ./setup-ci-complete.sh"
else
    echo -e "${RED}❌ PROBLEMA: Nessuno scheme condiviso trovato!${NC}"
    echo ""
    echo "AZIONE RICHIESTA:"
    echo "1. Apri il progetto in Xcode"
    echo "2. Product → Scheme → Manage Schemes"
    echo "3. Seleziona la checkbox 'Shared' per il tuo scheme principale"
    echo "4. Clicca 'Close'"
    echo "5. Salva il progetto: Cmd+S"
    echo "6. Ri-esegui: ./debug-scheme.sh"
fi

echo ""

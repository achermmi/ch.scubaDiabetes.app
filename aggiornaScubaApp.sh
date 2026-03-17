#!/bin/bash

echo "──────────────────────────────────────"
echo "  Aggiorna ScubaDiabetes su GitHub"
echo "──────────────────────────────────────"
echo ""

# Mostra le modifiche in sospeso
echo "📝 File modificati:"
git status --short
echo ""

# Chiede il messaggio di commit
read -p "✏️  Descrizione delle modifiche: " messaggio

if [ -z "$messaggio" ]; then
    echo "❌ Messaggio vuoto. Operazione annullata."
    exit 1
fi

echo ""
echo "🔄 Aggiunta file..."
git add -A

echo "💾 Commit in corso..."
git commit -m "$messaggio"

if [ $? -ne 0 ]; then
    echo "❌ Commit fallito (nessuna modifica da committare?)."
    exit 1
fi

echo "🚀 Push su GitHub..."
git pull origin main --rebase --no-edit 2>/dev/null
git push origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Fatto! Le modifiche sono su GitHub."
else
    echo ""
    echo "❌ Push fallito. Controlla la connessione o i permessi."
fi

#!/bin/bash
echo "🎯 מפעיל מערכת MTSS..."

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

VENV_PY="$SCRIPT_DIR/mtss_env/bin/python"

if [ ! -x "$VENV_PY" ]; then
  echo "❌ סביבה וירטואלית לא נמצאה."
  echo "ℹ️  להרצה ידנית: python3 mtss_app.py"
else
  echo "✅ הפעלת Python מהסביבה הוירטואלית"
fi

if grep -q "your_anthropic_api_key_here" .env; then
    echo "⚠️  זכור לעדכן את ה-API Key בקובץ .env!"
fi

${VENV_PY:-python3} mtss_app.py


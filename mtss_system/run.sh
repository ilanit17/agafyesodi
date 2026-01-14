#!/bin/bash
echo "🎯 מפעיל מערכת MTSS..."

# הפעלת סביבה וירטואלית
source mtss_env/bin/activate

# בדיקת API Key
if grep -q "your_anthropic_api_key_here" .env; then
    echo "⚠️  זכור לעדכן את ה-API Key בקובץ .env!"
fi

# הפעלת המערכת
python3 mtss_app.py

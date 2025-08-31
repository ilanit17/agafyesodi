#!/bin/bash
# סקריפט התקנה מהירה למערכת MTSS אוניברסלית

echo "🎯 מתחיל התקנה מהירה של מערכת MTSS..."
echo "=================================================="

# בדיקת Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 לא מותקן. אנא התקן Python 3.8+ תחילה."
    exit 1
fi

echo "✅ Python זוהה: $(python3 --version)"

# יצירת תיקיית פרויקט
read -p "📁 שם תיקיית הפרויקט (ברירת מחדל: mtss_system): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-mtss_system}

if [ -d "$PROJECT_NAME" ]; then
    echo "⚠️  התיקייה כבר קיימת. ממשיך..."
else
    mkdir "$PROJECT_NAME"
    echo "✅ נוצרה תיקייה: $PROJECT_NAME"
fi

cd "$PROJECT_NAME"

# יצירת סביבה וירטואלית
echo "🔧 יוצר סביבה וירטואלית..."

# נקה venv קודם אם קיים חלקית
if [ -d "mtss_env" ]; then
    rm -rf mtss_env
fi

if python3 -m venv mtss_env 2>/dev/null; then
    :
else
    echo "⚠️ ensurepip לא זמין. יוצר venv ללא pip ומבצע bootstrap..."
    python3 -m venv --without-pip mtss_env || { echo "❌ יצירת venv נכשלה"; exit 1; }
    curl -fsSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py || { echo "❌ הורדת get-pip נכשלה"; exit 1; }
    ./mtss_env/bin/python get-pip.py || { echo "❌ התקנת pip לvenv נכשלה"; exit 1; }
fi

source mtss_env/bin/activate

echo "✅ סביבה וירטואלית הופעלה"

# בחירת דרישות לפי גרסת Python להתאמה ל-3.13
PY_MAJOR=$(python3 -c 'import sys; print(sys.version_info.major)')
PY_MINOR=$(python3 -c 'import sys; print(sys.version_info.minor)')
if [ "$PY_MAJOR" -gt 3 ] || { [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -ge 13 ]; }; then
cat > requirements.txt << EOF
flask
flask-cors
pandas
numpy
anthropic
plotly
openpyxl
xlsxwriter
scikit-learn
seaborn
python-dotenv
EOF
else
cat > requirements.txt << EOF
flask==2.3.3
flask-cors==4.0.0
pandas==2.0.3
numpy==1.24.3
anthropic==0.3.11
plotly==5.15.0
openpyxl==3.1.2
xlsxwriter==3.1.2
scikit-learn==1.3.0
seaborn==0.12.2
python-dotenv==1.0.0
EOF
fi

echo "✅ נוצר requirements.txt"

# התקנת חבילות
echo "📦 מתקין חבילות Python..."
pip install --upgrade pip
pip install -r requirements.txt

if [ $? -eq 0 ]; then
    echo "✅ כל החבילות הותקנו בהצלחה"
else
    echo "❌ שגיאה בהתקנת חבילות"
    exit 1
fi

# יצירת מבנה תיקיות
mkdir -p templates static/{css,js,images} uploads reports logs

# יצירת קובץ .env
cat > .env << EOF
# הגדרות מערכת MTSS
ANTHROPIC_API_KEY=your_anthropic_api_key_here
FLASK_ENV=development
FLASK_DEBUG=True
SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_hex(32))')
MAX_CONTENT_LENGTH=52428800
UPLOAD_FOLDER=uploads
REPORTS_FOLDER=reports

# הגדרות לוגים
LOG_LEVEL=INFO
LOG_FILE=logs/mtss.log

# הגדרות אבטחה
ALLOWED_EXTENSIONS=xlsx,xls,csv
CORS_ORIGINS=*
EOF

echo "✅ נוצר קובץ .env עם הגדרות בסיסיות"

# הורדת הקבצים המוכנים (סימולציה - בפועל תצטרכי להעתיק אותם)
cat > mtss_app.py << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
מערכת MTSS אוניברסלית - קובץ ראשי
"""

import os
import sys
from pathlib import Path
from flask import Flask, render_template_string
from flask_cors import CORS
from dotenv import load_dotenv

# טעינת משתני סביבה
load_dotenv()

# יצירת אפליקציית Flask
app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')
app.config['MAX_CONTENT_LENGTH'] = int(os.getenv('MAX_CONTENT_LENGTH', 52428800))

# הגדרת CORS
CORS(app)

# HTML בסיסי למערכת
HTML_TEMPLATE = """
<!DOCTYPE html>
<html dir="rtl" lang="he">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>מערכת MTSS אוניברסלית</title>
    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            direction: rtl;
        }
        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 600px;
            width: 90%;
        }
        h1 {
            color: #2E7D32;
            margin-bottom: 20px;
            font-size: 2.5em;
        }
        .status {
            background: #e8f5e9;
            border: 2px solid #4caf50;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        .status.error {
            background: #ffebee;
            border-color: #f44336;
        }
        .next-steps {
            background: #f3e5f5;
            border: 2px solid #9c27b0;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
            text-align: right;
        }
        .next-steps h3 {
            margin-top: 0;
            color: #7b1fa2;
        }
        .button {
            display: inline-block;
            background: linear-gradient(45deg, #4CAF50, #66BB6A);
            color: white;
            padding: 15px 30px;
            text-decoration: none;
            border-radius: 25px;
            margin: 10px;
            font-weight: bold;
            border: none;
            cursor: pointer;
            font-size: 16px;
        }
        .button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(76, 175, 80, 0.3);
        }
    </style>
    
</head>
<body>
    <div class="container">
        <h1>🎯 מערכת MTSS אוניברסלית</h1>
        <p>מערכת מתקדמת לניתוח נתוני בתי ספר עם בינה מלאכותית</p>
        
        {% if api_key_missing %}
        <div class="status error">
            <h3>❌ נדרש הגדרת API Key</h3>
            <p>כדי להשתמש במערכת, יש להגדיר את מפתח ה-API של Anthropic</p>
        </div>
        {% else %}
        <div class="status">
            <h3>✅ המערכת מוכנה לשימוש!</h3>
            <p>כל הרכיבים הותקנו והוגדרו בהצלחה</p>
        </div>
        {% endif %}
        
        <div class="next-steps">
            <h3>📋 צעדים הבאים:</h3>
            <ol>
                <li><strong>הגדר API Key:</strong> עדכן את ANTHROPIC_API_KEY בקובץ .env</li>
                <li><strong>העלה נתונים:</strong> הכן קובץ Excel/CSV עם נתוני בתי ספר</li>
                <li><strong>התחל ניתוח:</strong> המערכת תזהה תחומים אוטומטית</li>
                <li><strong>קבל תובנות:</strong> ניתוח מתקדם עם Claude AI</li>
            </ol>
        </div>
        
        <div>
            <button class="button" onclick="location.reload()">🔄 רענן דף</button>
            <button class="button" onclick="window.open('https://console.anthropic.com/')">🔑 קבל API Key</button>
        </div>
        
        <hr style="margin: 30px 0;">
        <p><small>גרסה 1.0 | פותח עבור מערכת החינוך הישראלית</small></p>
    </div>
    
</body>
</html>
"""

@app.route('/')
def index():
    """עמוד הבית"""
    api_key = os.getenv('ANTHROPIC_API_KEY')
    api_key_missing = not api_key or api_key == 'your_anthropic_api_key_here'
    
    return render_template_string(HTML_TEMPLATE, api_key_missing=api_key_missing)

@app.route('/health')
def health_check():
    """בדיקת תקינות"""
    return {'status': 'healthy', 'version': '1.0'}

if __name__ == '__main__':
    print("🎯 מתחיל מערכת MTSS אוניברסלית...")
    print("🌐 השרת זמין בכתובת: http://localhost:5000")
    
    # בדיקת API Key
    api_key = os.getenv('ANTHROPIC_API_KEY')
    if not api_key or api_key == 'your_anthropic_api_key_here':
        print("⚠️  שים לב: ANTHROPIC_API_KEY טרם הוגדר!")
    
    app.run(
        host='0.0.0.0',
        port=int(os.getenv('PORT', 5000)),
        debug=True
    )
EOF

chmod +x mtss_app.py

# יצירת סקריפט הפעלה
cat > run.sh << 'EOF'
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
EOF

chmod +x run.sh

# יצירת מדריך מהיר
cat > QUICK_START.md << 'EOF'
# 🚀 מדריך התחלה מהיר

## 1. הפעלת המערכת
```bash
./run.sh
```

## 2. עדכון API Key
ערוך את קובץ `.env` ועדכן:
```
ANTHROPIC_API_KEY=your_actual_api_key_here
```

## 3. גישה למערכת
פתח דפדפן: http://localhost:5000

## 4. העלאת נתונים
- גרור קובץ Excel/CSV
- המערכת תזהה תחומים אוטומטית
- תקבל ניתוח מיידי

## 5. תכונות מתקדמות
- ניתוח AI עם Claude
- ויזואליזציות אינטראקטיביות  
- דוחות HTML מקצועיים
- פרופילי בתי ספר מותאמים

## 🆘 עזרה
- בדוק את logs/mtss.log לשגיאות
- ודא שכל החבילות מותקנות
- בדוק חיבור אינטרנט לAPI
EOF

echo "✅ המערכת הותקנה בהצלחה!"
echo ""
echo "📋 סיכום:"
echo "✓ Python packages הותקנו"
echo "✓ מבנה תיקיות נוצר"  
echo "✓ קבצי הגדרות נוצרו"
echo "✓ מערכת בסיסית מוכנה"
echo ""
echo "🔑 צעד חשוב: עדכן את ANTHROPIC_API_KEY בקובץ .env"
echo ""
echo "🚀 להפעלה:"
echo "   ./run.sh"
echo ""
echo "🌐 לאחר הפעלה גש ל: http://localhost:5000"
echo ""
echo "=================================================="
echo "🎉 התקנה הושלמה בהצלחה!"


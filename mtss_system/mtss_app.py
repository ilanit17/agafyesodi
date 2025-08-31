#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
מערכת MTSS אוניברסלית - קובץ ראשי
"""

import os
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
    <script>
      function openConsole() {
        window.open('https://console.anthropic.com/', '_blank');
      }
    </script>
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
            <button class="button" onclick="openConsole()">🔑 קבל API Key</button>
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
        debug=True,
    )


import os
import random
import json
import boto3
from botocore.exceptions import ClientError
from datetime import datetime

SENDER = os.environ.get("SENDER_EMAIL")
RECIPIENT = os.environ.get("RECIPIENT_EMAIL")
REGION = os.environ.get("AWS_REGION", "us-east-1")

ses = boto3.client('ses', region_name=REGION)

def load_commentary():
    path = '/var/task/commentary_data.json'
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception:
        return {
            "verses": [
                {"verse": "John 3:16", "text": "For God so loved the world...", "commentary_en": "God's love is unending.", "commentary_zh": "神的爱是无尽的。"},
                {"verse": "Psalm 23:1", "text": "The Lord is my shepherd...", "commentary_en": "Trust in the Shepherd.", "commentary_zh": "信靠我们的牧者。"}
            ]
        }

def pick_random(data):
    verses = data.get('verses', [])
    if not verses:
        return None
    return random.choice(verses)

def build_html(verse_obj):
    now = datetime.utcnow().strftime('%Y-%m-%d %H:%M UTC')
    html = f"""<html>
    <body>
      <h2>Daily Bible Devotional — {now}</h2>
      <h3>{verse_obj.get('verse')}</h3>
      <p>{verse_obj.get('text')}</p>
      <h4>English Commentary</h4>
      <p>{verse_obj.get('commentary_en')}</p>
      <h4>中文批注</h4>
      <p>{verse_obj.get('commentary_zh')}</p>
      <h4>Prayer Prompts</h4>
      <ul>
        <li>Pray for guidance to apply this verse.</li>
        <li>Pray for loved ones.</li>
      </ul>
      <h4>Learning Questions</h4>
      <ol>
        <li>What does this verse mean to me today?</li>
        <li>What practical step will I take based on it?</li>
      </ol>
    </body>
    </html>"""
    return html

def send_email(subject, html_body):
    if not SENDER or not RECIPIENT:
        print('SENDER or RECIPIENT not set; skipping email send.')
        return {"status": "skipped", "reason": "env_missing"}

    try:
        response = ses.send_email(
            Source=SENDER,
            Destination={'ToAddresses': [RECIPIENT]},
            Message={
                'Subject': {'Data': subject, 'Charset': 'UTF-8'},
                'Body': {
                    'Html': {'Data': html_body, 'Charset': 'UTF-8'},
                    'Text': {'Data': 'Daily devotional email', 'Charset': 'UTF-8'}
                }
            }
        )
        return {"status": "sent", "message_id": response.get('MessageId')}
    except ClientError as e:
        print('SES send error:', e)
        return {"status": "error", "error": str(e)}

def lambda_handler(event, context):
    data = load_commentary()
    verse = pick_random(data)
    if not verse:
        return {"status": "no_verse"}
    html = build_html(verse)
    subject = f"Daily Devotional — {verse.get('verse')}"
    result = send_email(subject, html)
    return {"result": result, "picked": verse}

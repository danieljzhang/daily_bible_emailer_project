import json
import random

VERSES = [
    {"verse":"John 3:16","text":"For God so loved the world..."},
    {"verse":"Psalm 23:1","text":"The Lord is my shepherd..."},
    {"verse":"Philippians 4:13","text":"I can do all things through Christ..."}
]

def lambda_handler(event, context):
    v = random.choice(VERSES)
    subject = f"Daily Verse: {v['verse']}"
    body = f"{v['text']}\n\nA short prayer for today."
    # Placeholder: send via boto3 SES
    print("Subject:", subject)
    print("Body:", body)
    return {
        "statusCode": 200,
        "body": json.dumps({"subject": subject, "body": body})
    }

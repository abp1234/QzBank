import json
import os
import requests
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
TABLE_NAME = os.getenv("TABLE_NAME")

HEADERS = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json"
}

def upload_to_supabase(json_path: str):
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    success, fail = 0, 0
    for item in data:
        payload = {
            "question": item.get("question"),
            "answer": item.get("answer"),
            "category": item.get("category")
        }

        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/{TABLE_NAME}",
            headers=HEADERS,
            json=payload
        )

        if response.status_code == 201 or response.status_code == 200:
            success += 1
        else:
            fail += 1
            print(f"❌ 실패: {response.status_code} | {response.text}")

    print(f"✅ 업로드 완료: 성공 {success}개, 실패 {fail}개")

if __name__ == "__main__":
    upload_to_supabase("quiz.json")

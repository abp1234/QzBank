import argparse
import json
import os
from pathlib import Path
from typing import List
from dotenv import load_dotenv
import requests
import re
load_dotenv()
# ✅ Gemini 설정
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

def read_markdown(file_path: str) -> str:
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()

def call_gemini_for_questions(text: str) -> List[dict]:
    prompt = f"""
다음은 교육 자료입니다. 이 내용을 기반으로 빈칸 채우기 문제를 JSON 형식으로 만들어주세요.
- 문제는 반드시 원문의 문장을 수정하지 않고, 일부 단어를 빈칸으로 바꾸는 형태로 작성해주세요.
- 각 문제는 다음 형식을 따릅니다:

{{
  "question": "___은 FTP 보안 강화를 위해 사용하는 프로토콜 중 하나이다.",
  "answer": "FTPS",
  "category": "네트워크"
}}

다음 원문:
{text}
"""

    headers = {
        "Content-Type": "application/json",
        "x-goog-api-key": GEMINI_API_KEY
    }

    data = {
        "contents": [
            {
                "parts": [
                    {"text": prompt}
                ]
            }
        ]
    }

    response = requests.post(GEMINI_ENDPOINT, headers=headers, json=data)

    try:
        res_json = response.json()
        content = res_json['candidates'][0]['content']['parts'][0]['text']
    
        cleaned = re.sub(r"^```json\s*|\s*```$", "", content.strip(), flags=re.DOTALL)

        return json.loads(cleaned)
    except Exception as e:
        print(f"❌ JSON 변환 실패: {e}")
        print(f"원본 응답:\n{response.text}")
        return []

def write_output(problems: List[dict], output_path: str):
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(problems, f, indent=2, ensure_ascii=False)
    print(f"✅ 문제 {len(problems)}개를 {output_path}에 저장했습니다.")

def main():
    parser = argparse.ArgumentParser(description="Markdown 기반 문제 자동 생성기 (Gemini 버전)")
    parser.add_argument("--input", required=True, help="입력 Markdown 파일 경로")
    parser.add_argument("--output", required=True, help="출력 JSON 파일 경로")
    args = parser.parse_args()

    md_text = read_markdown(args.input)
    problems = call_gemini_for_questions(md_text)
    write_output(problems, args.output)

if __name__ == "__main__":
    main()

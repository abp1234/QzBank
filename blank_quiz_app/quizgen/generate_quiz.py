import argparse
import json
import os
from pathlib import Path
from typing import List

import openai  # 또는 gemini 사용할 수 있음

# ✅ OpenAI 설정 (또는 Gemini 설정을 넣으세요)
openai.api_key = os.getenv("OPENAI_API_KEY")

def read_markdown(file_path: str) -> str:
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()

def call_openai_for_questions(text: str) -> List[dict]:
    prompt = f"""
다음은 교육 자료입니다. 이 내용을 기반으로 빈칸 채우기 문제를 JSON 형식으로 만들어주세요.
- 문제는 반드시 원문의 문장을 수정하지 않고, 일부 단어를 빈칸으로 바꾸는 형태로 작성해주세요.
- 각 문제는 다음 형식을 따릅니다:

{{
  "question": "___은 FTP 보안 강화를 위해 사용하는 프로토콜 중 하나이다.",
  "answer": "FTPS",
  "explanation": "FTPS는 SSL/TLS 기반으로 명령과 데이터를 암호화한다."
}}

다음 원문:
{text}
"""

    response = openai.ChatCompletion.create(
        model="gpt-4",  # 또는 "gpt-3.5-turbo"
        messages=[
            {"role": "system", "content": "너는 교육 문제를 잘 만드는 AI입니다."},
            {"role": "user", "content": prompt}
        ],
        temperature=0.3
    )

    try:
        content = response['choices'][0]['message']['content']
        return json.loads(content)
    except Exception as e:
        print(f"❌ JSON 변환 실패: {e}")
        print(f"원본 응답:\n{response}")
        return []

def write_output(problems: List[dict], output_path: str):
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(problems, f, indent=2, ensure_ascii=False)
    print(f"✅ 문제 {len(problems)}개를 {output_path}에 저장했습니다.")

def main():
    parser = argparse.ArgumentParser(description="Markdown 기반 문제 자동 생성기")
    parser.add_argument("--input", required=True, help="입력 Markdown 파일 경로")
    parser.add_argument("--output", required=True, help="출력 JSON 파일 경로")
    args = parser.parse_args()

    md_text = read_markdown(args.input)
    problems = call_openai_for_questions(md_text)
    write_output(problems, args.output)

if __name__ == "__main__":
    main()

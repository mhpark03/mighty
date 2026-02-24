import subprocess
import os

os.chdir(r"C:\sudoku\mighty_app")

BOLD = "C\\:/Windows/Fonts/malgunbd.ttf"
REG = "C\\:/Windows/Fonts/malgun.ttf"

filter_text = (
    # === 인트로 제목 (0~2s) - 검은 화면 위에 ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='e01.txt':fontsize=64:fontcolor=white:borderw=5:bordercolor=black"
    ":shadowcolor=black@0.8:shadowx=3:shadowy=3"
    ":box=1:boxcolor=black@0.5:boxborderw=15"
    ":x=(w-text_w)/2:y=(h-text_h)/2-50:enable='between(t,0,2)',"

    f"drawtext=fontfile='{REG}'"
    ":textfile='e02.txt':fontsize=26:fontcolor=#CCDDFF:borderw=3:bordercolor=black"
    ":shadowcolor=black@0.8:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.5:boxborderw=10"
    ":x=(w-text_w)/2:y=(h-text_h)/2+30:enable='between(t,0.3,2)',"

    # === 배팅 단계 (2~8s) ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='e03.txt':fontsize=38:fontcolor=yellow:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.6:boxborderw=12"
    ":x=(w-text_w)/2:y=50:enable='between(t,2,8)',"

    f"drawtext=fontfile='{REG}'"
    ":textfile='e04.txt':fontsize=22:fontcolor=white:borderw=3:bordercolor=black"
    ":shadowcolor=black@0.8:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.5:boxborderw=8"
    ":x=(w-text_w)/2:y=105:enable='between(t,2,8)',"

    # === 키티 교환 (8~15s) ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='e05.txt':fontsize=38:fontcolor=#00FF88:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.6:boxborderw=12"
    ":x=(w-text_w)/2:y=50:enable='between(t,8,15)',"

    f"drawtext=fontfile='{REG}'"
    ":textfile='e06.txt':fontsize=22:fontcolor=white:borderw=3:bordercolor=black"
    ":shadowcolor=black@0.8:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.5:boxborderw=8"
    ":x=(w-text_w)/2:y=105:enable='between(t,8,15)',"

    # === 전략 수립 (15~21s) ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='e07.txt':fontsize=38:fontcolor=#FF88FF:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.6:boxborderw=12"
    ":x=(w-text_w)/2:y=50:enable='between(t,15,21)',"

    f"drawtext=fontfile='{REG}'"
    ":textfile='e08.txt':fontsize=22:fontcolor=white:borderw=3:bordercolor=black"
    ":shadowcolor=black@0.8:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.5:boxborderw=8"
    ":x=(w-text_w)/2:y=105:enable='between(t,15,21)',"

    # === 카드 플레이 (21~39s) ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='e09.txt':fontsize=38:fontcolor=#00CCFF:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.6:boxborderw=12"
    ":x=(w-text_w)/2:y=50:enable='between(t,21,39)',"

    # 공격팀 승리 (21~24s)
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='e10.txt':fontsize=36:fontcolor=#FFD700:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=3:shadowy=3"
    ":box=1:boxcolor=black@0.6:boxborderw=10"
    ":x=(w-text_w)/2:y=105:enable='between(t,21,24)',"

    # 방어팀 반격 (30~33s)
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='e11.txt':fontsize=36:fontcolor=#FF6666:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=3:shadowy=3"
    ":box=1:boxcolor=black@0.6:boxborderw=10"
    ":x=(w-text_w)/2:y=105:enable='between(t,30,33)',"

    # === 결과 화면 + 엔딩 (39~43s) ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='e12.txt':fontsize=30:fontcolor=white:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=3:shadowy=3"
    ":box=1:boxcolor=black@0.65:boxborderw=15"
    ":x=(w-text_w)/2:y=h-220:enable='between(t,39,43)',"

    f"drawtext=fontfile='{BOLD}'"
    ":textfile='e13.txt':fontsize=26:fontcolor=#34A853:borderw=3:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.65:boxborderw=12"
    ":x=(w-text_w)/2:y=h-155:enable='between(t,39,43)',"

    f"drawtext=fontfile='{BOLD}'"
    ":textfile='e14.txt':fontsize=28:fontcolor=#FFD700:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=3:shadowy=3"
    ":box=1:boxcolor=black@0.65:boxborderw=12"
    ":x=(w-text_w)/2:y=h-105:enable='between(t,39,43)'"
)

texts = {
    "e01.txt": "마이티 AI 대전",
    "e02.txt": "5명의 AI가 펼치는 카드 대결",
    "e03.txt": "배팅 단계",
    "e04.txt": "AI가 손패를 분석하고 배팅합니다",
    "e05.txt": "키티 교환",
    "e06.txt": "바닥패 3장을 교환하고 전략을 세웁니다",
    "e07.txt": "프렌드 선언",
    "e08.txt": "함께 싸울 프렌드를 선택합니다",
    "e09.txt": "카드 플레이",
    "e10.txt": "공격팀 승리!",
    "e11.txt": "방어팀 반격!",
    "e12.txt": "마이티 - AI와 함께 배우는 카드 게임",
    "e13.txt": "Google Play에서 다운로드",
    "e14.txt": "com.mhpark.mighty",
}

for fname, text in texts.items():
    with open(fname, "w", encoding="utf-8") as f:
        f.write(text)

with open("filter2.txt", "w", encoding="utf-8") as f:
    f.write(filter_text)

result = subprocess.run(
    ["ffmpeg", "-y", "-i", "mighty_shorts_edited.mp4",
     "-filter_script:v", "filter2.txt",
     "-c:a", "copy", "mighty_shorts_edited_v2.mp4"],
    capture_output=True, text=True, encoding="utf-8"
)

print("STDERR:", result.stderr[-300:] if result.stderr else "")
print("Return code:", result.returncode)

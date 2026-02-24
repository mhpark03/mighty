import subprocess
import os

os.chdir(r"C:\sudoku\mighty_app")

BOLD = "C\\:/Windows/Fonts/malgunbd.ttf"
REG = "C\\:/Windows/Fonts/malgun.ttf"

# box=1 adds semi-transparent background behind text
# borderw=4~5 for thick outline, shadowx/shadowy for drop shadow
filter_text = (
    # === 인트로 제목 (0~2.5s) - 화면 중앙, 큰 글씨 + 검정 반투명 박스 ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='t01.txt':fontsize=64:fontcolor=white:borderw=5:bordercolor=black"
    ":shadowcolor=black@0.8:shadowx=3:shadowy=3"
    ":box=1:boxcolor=black@0.5:boxborderw=15"
    ":x=(w-text_w)/2:y=(h-text_h)/2-50:enable='between(t,0,2.5)',"

    f"drawtext=fontfile='{REG}'"
    ":textfile='t02.txt':fontsize=26:fontcolor=#CCDDFF:borderw=3:bordercolor=black"
    ":shadowcolor=black@0.8:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.5:boxborderw=10"
    ":x=(w-text_w)/2:y=(h-text_h)/2+30:enable='between(t,0.5,2.5)',"

    # === 배팅 단계 (2.5~7s) - 상단 배너 ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='t03.txt':fontsize=38:fontcolor=yellow:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.6:boxborderw=12"
    ":x=(w-text_w)/2:y=50:enable='between(t,2.5,7)',"

    f"drawtext=fontfile='{REG}'"
    ":textfile='t04.txt':fontsize=22:fontcolor=white:borderw=3:bordercolor=black"
    ":shadowcolor=black@0.8:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.5:boxborderw=8"
    ":x=(w-text_w)/2:y=105:enable='between(t,2.5,7)',"

    # === 전략 수립 (7~12s) - 상단 배너 ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='t05.txt':fontsize=38:fontcolor=#00FF88:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.6:boxborderw=12"
    ":x=(w-text_w)/2:y=50:enable='between(t,7,12)',"

    f"drawtext=fontfile='{REG}'"
    ":textfile='t06.txt':fontsize=22:fontcolor=white:borderw=3:bordercolor=black"
    ":shadowcolor=black@0.8:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.5:boxborderw=8"
    ":x=(w-text_w)/2:y=105:enable='between(t,7,12)',"

    # === 카드 플레이 (12~28s) - 상단 배너 ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='t07.txt':fontsize=38:fontcolor=#00CCFF:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.6:boxborderw=12"
    ":x=(w-text_w)/2:y=50:enable='between(t,12,28)',"

    # === 서브 텍스트 - 카드 플레이 시작 (12~15s) ===
    f"drawtext=fontfile='{REG}'"
    ":textfile='t08.txt':fontsize=24:fontcolor=white:borderw=3:bordercolor=black"
    ":shadowcolor=black@0.8:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.5:boxborderw=8"
    ":x=(w-text_w)/2:y=105:enable='between(t,12,15)',"

    # === 공격팀 승리 (17~20s) ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='t09.txt':fontsize=36:fontcolor=#FFD700:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=3:shadowy=3"
    ":box=1:boxcolor=black@0.6:boxborderw=10"
    ":x=(w-text_w)/2:y=105:enable='between(t,17,20)',"

    # === 방어팀 반격 (23~26s) ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='t10.txt':fontsize=36:fontcolor=#FF6666:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=3:shadowy=3"
    ":box=1:boxcolor=black@0.6:boxborderw=10"
    ":x=(w-text_w)/2:y=105:enable='between(t,23,26)',"

    # === 기루다 컷 역전 (26~29s) ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='t11.txt':fontsize=36:fontcolor=#FFD700:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=3:shadowy=3"
    ":box=1:boxcolor=black@0.6:boxborderw=10"
    ":x=(w-text_w)/2:y=105:enable='between(t,26,29)',"

    # === 엔딩 (30~33s) - 하단 영역 ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='t12.txt':fontsize=30:fontcolor=white:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=3:shadowy=3"
    ":box=1:boxcolor=black@0.65:boxborderw=15"
    ":x=(w-text_w)/2:y=h-220:enable='between(t,30,33)',"

    # === Google Play 다운로드 안내 (30~33s) ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='t13.txt':fontsize=26:fontcolor=#34A853:borderw=3:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=2:shadowy=2"
    ":box=1:boxcolor=black@0.65:boxborderw=12"
    ":x=(w-text_w)/2:y=h-155:enable='between(t,30,33)',"

    # === 앱 ID 강조 (30~33s) ===
    f"drawtext=fontfile='{BOLD}'"
    ":textfile='t14.txt':fontsize=28:fontcolor=#FFD700:borderw=4:bordercolor=black"
    ":shadowcolor=black@0.9:shadowx=3:shadowy=3"
    ":box=1:boxcolor=black@0.65:boxborderw=12"
    ":x=(w-text_w)/2:y=h-105:enable='between(t,30,33)'"
)

# Write each text file (UTF-8 no BOM)
texts = {
    "t01.txt": "마이티 AI 대전",
    "t02.txt": "5명의 AI가 펼치는 카드 대결",
    "t03.txt": "배팅 단계",
    "t04.txt": "AI가 손패를 분석하고 배팅합니다",
    "t05.txt": "전략 수립",
    "t06.txt": "키티 교환 & 프렌드 선언",
    "t07.txt": "카드 플레이",
    "t08.txt": "10트릭의 치열한 승부!",
    "t09.txt": "공격팀 승리!",
    "t10.txt": "방어팀 반격!",
    "t11.txt": "기루다 컷으로 역전!",
    "t12.txt": "마이티 - AI와 함께 배우는 카드 게임",
    "t13.txt": "Google Play에서 다운로드",
    "t14.txt": "com.mhpark.mighty",
}

for fname, text in texts.items():
    with open(fname, "w", encoding="utf-8") as f:
        f.write(text)

# Write filter script (UTF-8 no BOM)
with open("filter.txt", "w", encoding="utf-8") as f:
    f.write(filter_text)

# Run ffmpeg
result = subprocess.run(
    ["ffmpeg", "-y", "-i", "mighty_shorts_final2.mp4",
     "-filter_script:v", "filter.txt",
     "-c:a", "copy", "mighty_shorts_v3.mp4"],
    capture_output=True, text=True, encoding="utf-8"
)

print("STDOUT:", result.stdout[-500:] if result.stdout else "")
print("STDERR:", result.stderr[-500:] if result.stderr else "")
print("Return code:", result.returncode)

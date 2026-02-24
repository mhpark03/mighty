import edge_tts, asyncio, subprocess, os, sys

sys.stdout.reconfigure(encoding='utf-8')
os.chdir(r"C:\sudoku\mighty_app")

FONT_B = "C\\:/Windows/Fonts/malgunbd.ttf"
FONT_R = "C\\:/Windows/Fonts/malgun.ttf"
VOICE = "ko-KR-SunHiNeural"
INPUT = "ko1.mp4"
OUTPUT_FINAL = "ko1_shorts.mp4"

# ko1: 주공=수빈, 기루다=♣클로버, 목표=16, 프렌드=♠A소유자(민준)
# 결과: 수비팀 승리! 공격팀 15점 (1점 차 패배)
# 배속 없음 - 초보자 가이드용

PHASES = [
    (0,   26,  '배팅 단계',     '누가 주공이 될까?'),
    (26,  30,  '키티 교환',     '패 보강'),
    (30,  36,  '프렌드 선언',   '동맹 선택'),
    (36,  70,  '트릭 대결',     '10번의 승부'),
    (70,  None, '결과 발표',    '수비팀 승리!'),
]

def run_ffmpeg(cmd):
    result = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
    if result.returncode != 0:
        print(f'  ERROR: {result.stderr[-800:]}')
    return result.returncode == 0

def get_duration(f):
    r = subprocess.run(
        ['ffprobe', '-v', 'quiet', '-show_entries', 'format=duration', '-of', 'csv=p=0', f],
        capture_output=True, text=True
    )
    return float(r.stdout.strip())

def write_text(idx, content):
    fname = f"txt_ko1_{idx:02d}.txt"
    with open(fname, 'w', encoding='utf-8') as f:
        f.write(content)
    return fname

async def generate_tts(text, output_file, rate="+0%"):
    communicate = edge_tts.Communicate(text, VOICE, rate=rate)
    await communicate.save(output_file)
    dur = get_duration(output_file)
    print(f'  TTS: ({dur:.1f}s) {text}')
    return dur

async def main():
    orig_dur = get_duration(INPUT)
    print(f'\n=== ko1 Shorts - 초보자 가이드 (orig {orig_dur:.1f}s) ===')

    # Step 1: Text overlays (no speed change, use original)
    print('\n[1] Adding text overlays...')
    idx = [0]
    def txt(c):
        idx[0] += 1
        return write_text(idx[0], c)
    filters = []

    # Intro
    t_end = 5.0
    tf = txt("Mighty")
    filters.append(f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=105:fontcolor=#FFD700"
        f":borderw=7:bordercolor=black:shadowcolor=black@0.9:shadowx=5:shadowy=5"
        f":box=1:boxcolor=black@0.6:boxborderw=26:x=(w-text_w)/2:y=(h-text_h)/2-110:enable='between(t,0,{t_end:.2f})'")
    tf = txt("마이티 기본 규칙")
    filters.append(f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=44:fontcolor=white"
        f":borderw=4:bordercolor=black:shadowcolor=black@0.9:shadowx=4:shadowy=4"
        f":box=1:boxcolor=black@0.6:boxborderw=16:x=(w-text_w)/2:y=(h-text_h)/2+15:enable='between(t,0.5,{t_end:.2f})'")
    tf = txt("5명의 AI 대전으로 배워보세요!")
    filters.append(f"drawtext=fontfile='{FONT_R}':textfile='{tf}':fontsize=32:fontcolor=#AADDFF"
        f":borderw=4:bordercolor=black:shadowcolor=black@0.9:shadowx=3:shadowy=3"
        f":box=1:boxcolor=black@0.6:boxborderw=14:x=(w-text_w)/2:y=(h-text_h)/2+80:enable='between(t,1,{t_end:.2f})'")

    # Phase labels
    for (start, end, label, sublabel) in PHASES:
        ne = end if end is not None else orig_dur
        tf = txt(label)
        filters.append(f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=56:fontcolor=#FFD700"
            f":borderw=5:bordercolor=black:shadowcolor=black@0.9:shadowx=4:shadowy=4"
            f":box=1:boxcolor=black@0.7:boxborderw=18:x=(w-text_w)/2:y=8:enable='between(t,{start:.2f},{ne:.2f})'")
        if sublabel:
            tf = txt(sublabel)
            filters.append(f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=32:fontcolor=white"
                f":borderw=4:bordercolor=black:shadowcolor=black@0.9:shadowx=3:shadowy=3"
                f":box=1:boxcolor=black@0.6:boxborderw=11:x=(w-text_w)/2:y=78:enable='between(t,{start:.2f},{ne:.2f})'")

    # CTA
    cta_start = orig_dur - 5
    tf = txt("Mighty 카드게임")
    filters.append(f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=44:fontcolor=white"
        f":borderw=5:bordercolor=black:shadowcolor=black@0.9:shadowx=4:shadowy=4"
        f":box=1:boxcolor=black@0.7:boxborderw=18:x=(w-text_w)/2:y=h-260:enable='between(t,{cta_start:.2f},{orig_dur:.2f})'")
    tf = txt("Google Play 다운로드")
    filters.append(f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=35:fontcolor=#34A853"
        f":borderw=4:bordercolor=black:shadowcolor=black@0.9:shadowx=4:shadowy=4"
        f":box=1:boxcolor=black@0.7:boxborderw=16:x=(w-text_w)/2:y=h-195:enable='between(t,{cta_start:.2f},{orig_dur:.2f})'")

    filter_script = ",\n".join(filters)
    with open("filter_ko1.txt", 'w', encoding='utf-8') as f:
        f.write(filter_script)
    print(f'  Filters: {len(filters)} layers')
    text_out = "tmp_ko1_text.mp4"
    cmd = ['ffmpeg', '-y', '-i', INPUT, '-filter_script:v', 'filter_ko1.txt',
           '-c:v', 'libx264', '-preset', 'medium', '-crf', '20', '-c:a', 'copy', text_out]
    if not run_ffmpeg(cmd): return

    # Step 2: TTS narrations (초보자 설명)
    print('\n[2] Generating TTS narrations...')
    os.makedirs("narration", exist_ok=True)
    narrations = [
        (0,   "마이티! 다섯 명이 즐기는 한국 대표 카드게임입니다!", "+10%"),
        (6,   "지금은 배팅 단계! 자기 패를 보고, 목표 점수를 경매합니다", "+15%"),
        (14,  "가장 높은 점수를 부르면 주공이 됩니다. 으뜸 무늬도 함께 정해요", "+15%"),
        (22,  "수빈이 16 클로버 낙찰! 클로버가 이 판의 으뜸패, 기루다입니다", "+15%"),
        (27,  "키티 교환! 주공이 바닥패 세 장을 가져오고, 약한 카드를 버립니다", "+15%"),
        (33,  "프렌드 선언! 특정 카드를 가진 사람을 동맹으로 지정합니다", "+15%"),
        (38,  "트릭 대결 시작! 선공이 카드를 내면, 같은 무늬로 따라내야 해요", "+15%"),
        (46,  "에이스, 킹, 퀸, 잭, 텐이 점수 카드! 각 1점, 총 20점입니다", "+15%"),
        (55,  "기루다는 다른 무늬를 이기는 강력한 으뜸패! 마이티와 조커는 최강 카드!", "+15%"),
        (70,  "15점! 목표에 1점 부족! 주공팀이 목표를 못 채우면, 수비팀 승리!", "+10%"),
    ]
    narr_files = []
    prev_end_ms = 0
    for i, (sec, text, rate) in enumerate(narrations):
        nf = f"narration/ko1_{i}.mp3"
        tts_dur = await generate_tts(text, nf, rate)
        new_ms = int(sec * 1000)
        new_ms = max(new_ms, prev_end_ms + 300)
        narr_files.append((new_ms, nf))
        prev_end_ms = new_ms + int(tts_dur * 1000)
        print(f'    {sec}s -> {new_ms}ms (end {prev_end_ms}ms)')

    # Step 3: Mix
    print('\n[3] Mixing audio...')
    inputs = ["-i", text_out]
    for _, nf in narr_files:
        inputs.extend(["-i", nf])
    filter_parts = ["[0:a]volume=0.3[bg]"]
    mix_labels = "[bg]"
    for i, (delay_ms, _) in enumerate(narr_files):
        filter_parts.append(f"[{i+1}:a]adelay={delay_ms}|{delay_ms},volume=1.5[n{i}]")
        mix_labels += f"[n{i}]"
    filter_parts.append(f"{mix_labels}amix=inputs={len(narr_files)+1}:duration=first:normalize=0[aout]")
    cmd = ["ffmpeg", "-y"] + inputs + ["-filter_complex", ";".join(filter_parts),
           "-map", "0:v", "-map", "[aout]", "-c:v", "copy", "-c:a", "aac", "-b:a", "128k", OUTPUT_FINAL]
    if run_ffmpeg(cmd):
        final_dur = get_duration(OUTPUT_FINAL)
        sz = os.path.getsize(OUTPUT_FINAL) / (1024*1024)
        print(f'\n=== Done! {OUTPUT_FINAL} ===')
        print(f'  Duration: {final_dur:.1f}s\n  Size: {sz:.1f}MB')
    else:
        print('  Audio mix FAILED!')

    if os.path.exists(text_out): os.remove(text_out)
    print('  Cleaned up.')

asyncio.run(main())

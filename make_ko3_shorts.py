import edge_tts, asyncio, subprocess, os, sys

sys.stdout.reconfigure(encoding='utf-8')
os.chdir(r"C:\sudoku\mighty_app")

FONT_B = "C\\:/Windows/Fonts/malgunbd.ttf"
FONT_R = "C\\:/Windows/Fonts/malgun.ttf"
VOICE = "ko-KR-SunHiNeural"
INPUT = "ko3.mp4"
OUTPUT_FINAL = "ko3_shorts.mp4"

# ko3: 주공=수빈, 기루다=♥하트, 목표=13, 프렌드=♠A소유자(서연)
# 수빈 하트 7장 보유! 결과: 공격팀 대승! 16점 (목표 3점 초과)
# 배속 없음 - 초보자 가이드용

PHASES = [
    (0,   4,   '배팅 단계',     '최고 입찰자가 주공!'),
    (4,   8,   '키티 교환',     '3장 교환으로 패 보강'),
    (8,   15,  '프렌드 선언',   '숨겨진 동맹'),
    (15,  48,  '트릭 대결',     '기루다의 위력!'),
    (48,  None, '결과 발표',    '공격팀 대승!'),
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
    fname = f"txt_ko3_{idx:02d}.txt"
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
    print(f'\n=== ko3 Shorts - 초보자 가이드 (orig {orig_dur:.1f}s) ===')

    # Step 1: Text overlays (no speed change, use original)
    print('\n[1] Adding text overlays...')
    idx = [0]
    def txt(c):
        idx[0] += 1
        return write_text(idx[0], c)
    filters = []

    # Intro
    t_end = 4.0
    tf = txt("Mighty")
    filters.append(f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=105:fontcolor=#FFD700"
        f":borderw=7:bordercolor=black:shadowcolor=black@0.9:shadowx=5:shadowy=5"
        f":box=1:boxcolor=black@0.6:boxborderw=26:x=(w-text_w)/2:y=(h-text_h)/2-110:enable='between(t,0,{t_end:.2f})'")
    tf = txt("기루다의 힘을 보여드립니다!")
    filters.append(f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=44:fontcolor=white"
        f":borderw=4:bordercolor=black:shadowcolor=black@0.9:shadowx=4:shadowy=4"
        f":box=1:boxcolor=black@0.6:boxborderw=16:x=(w-text_w)/2:y=(h-text_h)/2+15:enable='between(t,0.5,{t_end:.2f})'")
    tf = txt("하트 7장! 압도적 기루다 플레이")
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
    with open("filter_ko3.txt", 'w', encoding='utf-8') as f:
        f.write(filter_script)
    print(f'  Filters: {len(filters)} layers')
    text_out = "tmp_ko3_text.mp4"
    cmd = ['ffmpeg', '-y', '-i', INPUT, '-filter_script:v', 'filter_ko3.txt',
           '-c:v', 'libx264', '-preset', 'medium', '-crf', '20', '-c:a', 'copy', text_out]
    if not run_ffmpeg(cmd): return

    # Step 2: TTS narrations (초보자 설명)
    print('\n[2] Generating TTS narrations...')
    os.makedirs("narration", exist_ok=True)
    narrations = [
        (0,   "이번엔 기루다의 강력한 힘을 직접 확인해보세요!", "+10%"),
        (2,   "수빈이 하트를 기루다로 선택! 하트가 무려 일곱 장이에요!", "+15%"),
        (5,   "키티 교환으로 다이아 에이스도 확보! 패가 더 강해졌어요", "+15%"),
        (9,   "프렌드는 스페이드 에이스 소유자! 누가 동맹인지는 카드가 나올 때 공개돼요", "+15%"),
        (16,  "트릭 시작! 기루다가 많으면 언제든 다른 무늬를 이길 수 있어요", "+15%"),
        (24,  "기루다 하트로 연속 승리! 으뜸패가 많으면 이렇게 강력합니다", "+15%"),
        (32,  "점수 카드는 에이스부터 텐까지! 각 1점, 무늬당 5장, 총 20점이에요", "+15%"),
        (40,  "공격팀이 점수를 쓸어담고 있어요! 기루다 일색의 위력!", "+15%"),
        (48,  "16점 대승! 목표 13점을 3점 초과! 기루다가 많으면 이렇게 압도적이에요!", "+10%"),
    ]
    narr_files = []
    prev_end_ms = 0
    for i, (sec, text, rate) in enumerate(narrations):
        nf = f"narration/ko3_{i}.mp3"
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

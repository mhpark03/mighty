import edge_tts, asyncio, subprocess, os, sys

sys.stdout.reconfigure(encoding='utf-8')
os.chdir(r"C:\sudoku\mighty_app")

FONT_B = "C\\:/Windows/Fonts/YuGothB.ttc"
FONT_R = "C\\:/Windows/Fonts/YuGothR.ttc"
VOICE = "ja-JP-NanamiNeural"
INPUT = "ja2.mp4"
OUTPUT_FINAL = "ja2_shorts.mp4"

# Speed segments: (original_start, original_end, speed_multiplier)
SEGMENTS = [
    (0,    5,    2.0),   # Bidding - 2x
    (5,    9,    1.5),   # Kitty exchange - 1.5x
    (9,    16,   1.5),   # Friend declaration - 1.5x
    (16,   48,   2.0),   # Trick play - 2x
    (48,   None, 1.0),   # Result - 1x
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

def map_time(orig_t, orig_dur):
    """Map original timestamp to new timestamp after speed changes."""
    new_t = 0.0
    for (start, end, speed) in SEGMENTS:
        seg_end = end if end is not None else orig_dur
        if orig_t <= start:
            return new_t
        elif orig_t < seg_end:
            return new_t + (orig_t - start) / speed
        else:
            new_t += (seg_end - start) / speed
    return new_t

def write_text(idx, content):
    fname = f"txt_ja2_{idx:02d}.txt"
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
    print(f'\n=== ja2 Shorts 1080x1920 (orig {orig_dur:.1f}s) ===')

    # Calculate new total duration
    total_dur = map_time(orig_dur, orig_dur)
    print(f'  Speed segments: {" / ".join(f"{s}-{e or "end"}s @{sp}x" for s,e,sp in SEGMENTS)}')
    print(f'  New duration: {total_dur:.1f}s')

    # ── Step 1: Speed adjustment ──
    print('\n[1] Applying speed changes...')

    v_filters = []
    a_filters = []
    v_labels = []
    a_labels = []

    for i, (start, end, speed) in enumerate(SEGMENTS):
        seg_end = end if end is not None else orig_dur
        pts = 1.0 / speed
        v_filters.append(
            f"[0:v]trim={start}:{seg_end:.2f},setpts={pts:.4f}*(PTS-STARTPTS)[v{i}]"
        )
        a_filters.append(
            f"[0:a]atrim={start}:{seg_end:.2f},asetpts=PTS-STARTPTS,atempo={speed}[a{i}]"
        )
        v_labels.append(f"[v{i}]")
        a_labels.append(f"[a{i}]")

    n = len(SEGMENTS)
    concat_v = "".join(v_labels) + f"concat=n={n}:v=1:a=0[vspeed]"
    concat_a = "".join(a_labels) + f"concat=n={n}:v=0:a=1[aspeed]"

    speed_filter = ";".join(v_filters + a_filters + [concat_v, concat_a])

    speed_out = "tmp_ja2_speed.mp4"
    cmd = [
        'ffmpeg', '-y', '-i', INPUT,
        '-filter_complex', speed_filter,
        '-map', '[vspeed]', '-map', '[aspeed]',
        '-c:v', 'libx264', '-preset', 'medium', '-crf', '20',
        '-c:a', 'aac', '-b:a', '128k',
        speed_out
    ]
    if not run_ffmpeg(cmd):
        print('  Speed adjustment FAILED!')
        return

    speed_dur = get_duration(speed_out)
    print(f'  Speed adjusted: {speed_dur:.1f}s')

    # ── Step 2: 1080x1920 with blur filler ──
    print('\n[2] Scaling to 1080x1920 with blur filler...')

    # 720x1640 → fit height 1920: w=844, h=1920
    # Blurred bg: scale to fill 1080x1920, crop, blur, darken
    blur_filter = (
        "split[bg][fg];"
        "[bg]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,"
        "boxblur=12:12[bg2];"
        "[fg]scale=-2:1920[fg2];"
        "[bg2][fg2]overlay=(W-w)/2:0,format=yuv420p[vout]"
    )

    scaled_out = "tmp_ja2_1080.mp4"
    cmd = [
        'ffmpeg', '-y', '-i', speed_out,
        '-filter_complex', blur_filter,
        '-map', '[vout]', '-map', '0:a',
        '-c:v', 'libx264', '-preset', 'medium', '-crf', '20',
        '-c:a', 'copy',
        scaled_out
    ]
    if not run_ffmpeg(cmd):
        print('  Scaling FAILED!')
        return
    print(f'  Scaled to 1080x1920')

    # ── Step 3: Text overlays (timestamps mapped) ──
    print('\n[3] Adding text overlays...')

    idx = [0]
    def txt(content):
        idx[0] += 1
        return write_text(idx[0], content)

    def mt(t):
        """Shortcut for map_time."""
        return map_time(t, orig_dur)

    filters = []

    # Intro title (orig 0~3s)
    t_end = mt(3)
    tf = txt("マイティ")
    filters.append(
        f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=105:fontcolor=#FFD700"
        f":borderw=7:bordercolor=black:shadowcolor=black@0.9:shadowx=5:shadowy=5"
        f":box=1:boxcolor=black@0.6:boxborderw=26"
        f":x=(w-text_w)/2:y=(h-text_h)/2-110:enable='between(t,0,{t_end:.2f})'"
    )
    tf = txt("韓国カードゲーム - AIデモ")
    t_sub = mt(0.5)
    filters.append(
        f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=40:fontcolor=white"
        f":borderw=4:bordercolor=black:shadowcolor=black@0.9:shadowx=4:shadowy=4"
        f":box=1:boxcolor=black@0.6:boxborderw=16"
        f":x=(w-text_w)/2:y=(h-text_h)/2+15:enable='between(t,{t_sub:.2f},{t_end:.2f})'"
    )
    tf = txt("健太 / 13クラブ / フレンド: ♠A所有者")
    t_info_s = mt(1)
    t_info_e = mt(4)
    filters.append(
        f"drawtext=fontfile='{FONT_R}':textfile='{tf}':fontsize=32:fontcolor=#AADDFF"
        f":borderw=4:bordercolor=black:shadowcolor=black@0.9:shadowx=3:shadowy=3"
        f":box=1:boxcolor=black@0.6:boxborderw=14"
        f":x=(w-text_w)/2:y=(h-text_h)/2+80:enable='between(t,{t_info_s:.2f},{t_info_e:.2f})'"
    )

    # Phase labels (mapped timestamps)
    phases = [
        (0,   5,   'ビッディング',     '5人AI対戦 | 2倍速'),
        (5,   9,   'キティ交換',       '手札入れ替え | 1.5倍速'),
        (9,   16,  'フレンド宣言',     '味方を選択 | 1.5倍速'),
        (16,  48,  'トリックプレイ',    None),
        (48,  None, '結果発表',        '守備チーム勝利!'),
    ]
    for (start, end, label, sublabel) in phases:
        ns = mt(start)
        ne = mt(end if end is not None else orig_dur)
        tf = txt(label)
        filters.append(
            f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=56:fontcolor=#FFD700"
            f":borderw=5:bordercolor=black:shadowcolor=black@0.9:shadowx=4:shadowy=4"
            f":box=1:boxcolor=black@0.7:boxborderw=18"
            f":x=(w-text_w)/2:y=8:enable='between(t,{ns:.2f},{ne:.2f})'"
        )
        if sublabel:
            tf = txt(sublabel)
            filters.append(
                f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=32:fontcolor=white"
                f":borderw=4:bordercolor=black:shadowcolor=black@0.9:shadowx=3:shadowy=3"
                f":box=1:boxcolor=black@0.6:boxborderw=11"
                f":x=(w-text_w)/2:y=78:enable='between(t,{ns:.2f},{ne:.2f})'"
            )

    # Ending CTA (last 5s)
    cta_start = total_dur - 5
    tf = txt("マイティ カードゲーム")
    filters.append(
        f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=44:fontcolor=white"
        f":borderw=5:bordercolor=black:shadowcolor=black@0.9:shadowx=4:shadowy=4"
        f":box=1:boxcolor=black@0.7:boxborderw=18"
        f":x=(w-text_w)/2:y=h-260:enable='between(t,{cta_start:.2f},{total_dur:.2f})'"
    )
    tf = txt("Google Playでダウンロード")
    filters.append(
        f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=35:fontcolor=#34A853"
        f":borderw=4:bordercolor=black:shadowcolor=black@0.9:shadowx=4:shadowy=4"
        f":box=1:boxcolor=black@0.7:boxborderw=16"
        f":x=(w-text_w)/2:y=h-195:enable='between(t,{cta_start:.2f},{total_dur:.2f})'"
    )

    # Write filter script & render
    filter_script = ",\n".join(filters)
    with open("filter_ja2.txt", 'w', encoding='utf-8') as f:
        f.write(filter_script)
    print(f'  Filters: {len(filters)} layers')

    text_out = "tmp_ja2_text.mp4"
    cmd = [
        'ffmpeg', '-y', '-i', scaled_out,
        '-filter_script:v', 'filter_ja2.txt',
        '-c:v', 'libx264', '-preset', 'medium', '-crf', '20',
        '-c:a', 'copy',
        text_out
    ]
    if not run_ffmpeg(cmd):
        print('  Text overlay FAILED!')
        return

    # ── Step 4: TTS narration (timestamps mapped) ──
    print('\n[4] Generating TTS narrations...')
    os.makedirs("narration", exist_ok=True)

    # (original_seconds, text, rate) - rates increased for compressed timeline
    narrations_orig = [
        (0,   "マイティ！同盟が勝敗を決める！", "+20%"),
        (4,   "健太が13クラブ宣言、秘密のフレンドを選ぶ", "+30%"),
        (10,  "フレンドはスペードA所有者、バトル開始！", "+25%"),
        (17,  "序盤からポイントカードを大量獲得！", "+25%"),
        (24,  "ジョーカー発動！守備チームの逆襲だ！", "+25%"),
        (32,  "切り札リードで攻撃チームが押し返す！", "+25%"),
        (40,  "宣言者が連勝で得点を積む！", "+25%"),
        (48,  "あと1点足りず守備チームの勝利！", "+15%"),
    ]

    narr_files = []
    prev_end_ms = 0
    for i, (orig_sec, text, rate) in enumerate(narrations_orig):
        nf = f"narration/ja2_{i}.mp3"
        tts_dur = await generate_tts(text, nf, rate)
        new_ms = int(mt(orig_sec) * 1000)
        # Prevent overlap: ensure 300ms gap after previous narration
        new_ms = max(new_ms, prev_end_ms + 300)
        narr_files.append((new_ms, nf))
        prev_end_ms = new_ms + int(tts_dur * 1000)
        print(f'    {orig_sec}s -> {new_ms}ms (end {prev_end_ms}ms)')

    # ── Step 5: Mix audio ──
    print('\n[5] Mixing audio...')
    inputs = ["-i", text_out]
    for _, nf in narr_files:
        inputs.extend(["-i", nf])

    filter_parts = ["[0:a]volume=0.3[bg]"]
    mix_labels = "[bg]"
    for i, (delay_ms, _) in enumerate(narr_files):
        filter_parts.append(f"[{i+1}:a]adelay={delay_ms}|{delay_ms},volume=1.5[n{i}]")
        mix_labels += f"[n{i}]"

    n = len(narr_files) + 1
    filter_parts.append(f"{mix_labels}amix=inputs={n}:duration=first:normalize=0[aout]")

    cmd = ["ffmpeg", "-y"] + inputs + [
        "-filter_complex", ";".join(filter_parts),
        "-map", "0:v", "-map", "[aout]",
        "-c:v", "copy", "-c:a", "aac", "-b:a", "128k",
        OUTPUT_FINAL
    ]

    if run_ffmpeg(cmd):
        final_dur = get_duration(OUTPUT_FINAL)
        sz = os.path.getsize(OUTPUT_FINAL) / (1024 * 1024)
        r = subprocess.run(
            ['ffprobe', '-v', 'quiet', '-show_entries', 'stream=width,height',
             '-of', 'csv=p=0', OUTPUT_FINAL],
            capture_output=True, text=True
        )
        print(f'\n=== Done! {OUTPUT_FINAL} ===')
        print(f'  Resolution: {r.stdout.strip()}')
        print(f'  Duration: {final_dur:.1f}s')
        print(f'  Size: {sz:.1f}MB')
    else:
        print('  Audio mix FAILED!')

    # Cleanup intermediate files
    for f in [speed_out, scaled_out, text_out]:
        if os.path.exists(f):
            os.remove(f)
    print('  Intermediate files cleaned up.')

asyncio.run(main())

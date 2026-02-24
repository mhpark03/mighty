import edge_tts, asyncio, subprocess, os, sys

sys.stdout.reconfigure(encoding='utf-8')
os.chdir(r"C:\sudoku\mighty_app")

FONT_B = "C\\:/Windows/Fonts/YuGothB.ttc"
VOICE = "ja-JP-NanamiNeural"
INPUT = "bidja1.mp4"
OUTPUT = "bidja1_shorts.mp4"

# (source_frame_sec, subtitle_text, tts_text, min_hold_sec)
SEGMENTS = [
    (0,
     "マイティのビッド\nどう計算する？",
     "マイティのビッド、どう計算する？", 4),
    (0,
     "ビッドの基準：予想得点\n13点以上ならビッド！",
     "ビッドの基準は、予想得点が13点以上ならビッドです！", 5),
    (3,
     "計算法①：一番多いスート\n＝ 切り札候補",
     "計算法その1、一番多いスートが切り札候補になります", 5),
    (3,
     "花子：♦4枚が切り札候補\n核心カード ♦Q·J",
     "花子はダイヤ4枚が切り札候補、核心カードはダイヤのクイーンとジャックです", 5),
    (3,
     "計算法②：切り札トリック＋\n非切り札Aで得点計算",
     "計算法その2、切り札のトリック数に非切り札のエースを加えて得点を計算します", 5),
    (3,
     "花子：適正7点 < 最低13点\n→ パス！",
     "花子は適正7点、最低13点に届かないのでパスです！", 4),
    (15,
     "健太：♣4枚 A·Q·J保有\n適正10点、まだ足りない！",
     "健太はクラブ4枚でエース、クイーン、ジャック保有。でも適正10点、まだ足りません！", 6),
    (15,
     "適正10点 < 最低13点\n→ パス！",
     "適正10点は最低13点未満なのでパスです！", 4),
    (42,
     "プレイヤー：♠4枚 K·Q保有\n初手 ♥A",
     "プレイヤーはスペード4枚でキングとクイーン保有、初手はハートのエース！", 5),
    (42,
     "♠切り札K·Q＋♥A＋場札\n→ 適正13点！",
     "スペードの切り札キングクイーンにハートのエースを加えて、適正13点です！", 5),
    (42,
     "適正13点 ≧ 最低13点\n→ 13スペード宣言！",
     "適正13点は最低ラインに達しました！13スペードを宣言！", 5),
    (51,
     "太郎：♠A·J保有だが適正8点\n→ パス",
     "太郎はスペードのエースとジャックがありますが、適正8点でパスです", 5),
    (62,
     "主公確定！\nキティから♦Aを獲得！",
     "プレイヤーが主公確定！キティからダイヤのエースを獲得しました！", 5),
]

def run(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True, encoding='utf-8')
    if r.returncode != 0:
        print(f'  ERR: {r.stderr[-600:]}')
    return r.returncode == 0

def get_dur(f):
    r = subprocess.run(['ffprobe','-v','quiet','-show_entries','format=duration','-of','csv=p=0',f],
                       capture_output=True, text=True)
    return float(r.stdout.strip())

def write_txt(idx, text):
    f = f"tmp_parts/txt_b1_{idx:02d}.txt"
    with open(f, 'w', encoding='utf-8') as fh:
        fh.write(text)
    return f

async def gen_tts(text, outfile, rate="+10%"):
    c = edge_tts.Communicate(text, VOICE, rate=rate)
    await c.save(outfile)
    d = get_dur(outfile)
    print(f'  TTS ({d:.1f}s): {text[:40]}')
    return d

async def main():
    os.makedirs("narration", exist_ok=True)
    os.makedirs("tmp_parts", exist_ok=True)

    print(f'\n=== bidja1 Japanese Shorts ===')

    # Step 1: TTS
    print('\n[1] Generating TTS...')
    seg_data = []
    for i, (src_t, sub, tts_txt, min_s) in enumerate(SEGMENTS):
        nf = f"narration/bidja1_{i}.mp3"
        td = await gen_tts(tts_txt, nf)
        hold = max(min_s, td + 1.5)
        seg_data.append((src_t, sub, nf, hold, td))
        print(f'    Seg{i}: frame@{src_t}s, hold={hold:.1f}s')

    total = sum(d[3] for d in seg_data)
    print(f'  Total: {total:.1f}s')

    # Step 2: Extract unique frames
    print('\n[2] Extracting frames...')
    frames = {}
    for src_t, *_ in seg_data:
        if src_t not in frames:
            fn = f"tmp_parts/frame_b1_{src_t}.jpg"
            run(['ffmpeg','-y','-ss',str(src_t),'-i',INPUT,'-frames:v','1','-q:v','2',fn])
            frames[src_t] = fn
            print(f'    Frame @{src_t}s')

    # Step 3: Create still clips
    print('\n[3] Creating clips...')
    clip_files = []
    for i, (src_t, sub, nf, hold, td) in enumerate(seg_data):
        clip = f"tmp_parts/clip_b1_{i:02d}.mp4"
        run(['ffmpeg','-y','-loop','1','-i', frames[src_t],
             '-f','lavfi','-i','anullsrc=r=44100:cl=stereo',
             '-t', f'{hold:.2f}',
             '-c:v','libx264','-preset','fast','-crf','22','-pix_fmt','yuv420p',
             '-c:a','aac','-b:a','128k','-shortest', clip])
        clip_files.append(clip)
        print(f'    Clip{i}: {hold:.1f}s')

    # Step 4: Concatenate
    print('\n[4] Concatenating...')
    lf = "tmp_parts/concat_b1.txt"
    with open(lf, 'w') as f:
        for cf in clip_files:
            f.write(f"file '{os.path.basename(cf)}'\n")
    concat_out = "tmp_parts/concat_b1.mp4"
    run(['ffmpeg','-y','-f','concat','-safe','0','-i',lf,
         '-c:v','libx264','-preset','medium','-crf','20',
         '-c:a','aac','-b:a','128k', concat_out])
    print(f'    Concat: {get_dur(concat_out):.1f}s')

    # Step 5: Text overlays
    print('\n[5] Adding subtitles...')
    filters = []
    t_off = 0.0
    for i, (src_t, sub, nf, hold, td) in enumerate(seg_data):
        ts, te = t_off + 0.2, t_off + hold - 0.2
        tf = write_txt(i, sub)
        filters.append(
            f"drawtext=fontfile='{FONT_B}':textfile='{tf}'"
            f":fontsize=44:fontcolor=white"
            f":borderw=5:bordercolor=black"
            f":shadowcolor=black@0.9:shadowx=4:shadowy=4"
            f":box=1:boxcolor=black@0.65:boxborderw=22"
            f":x=(w-text_w)/2:y=h-text_h-110"
            f":enable='between(t,{ts:.2f},{te:.2f})'"
        )
        t_off += hold

    fscript = "filter_bidja1.txt"
    with open(fscript, 'w', encoding='utf-8') as f:
        f.write(",\n".join(filters))
    print(f'    {len(filters)} subtitle layers')

    text_out = "tmp_parts/text_b1.mp4"
    run(['ffmpeg','-y','-i',concat_out,'-filter_script:v',fscript,
         '-c:v','libx264','-preset','medium','-crf','20','-c:a','copy', text_out])

    # Step 6: Mix TTS
    print('\n[6] Mixing TTS...')
    inputs = ["-i", text_out]
    for _, _, nf, _, _ in seg_data:
        inputs.extend(["-i", nf])

    fp = ["[0:a]volume=0.0[bg]"]
    ml = "[bg]"
    t_off = 0.0
    for i, (_, _, _, hold, _) in enumerate(seg_data):
        ms = int(t_off * 1000) + 300
        fp.append(f"[{i+1}:a]adelay={ms}|{ms},volume=1.3[n{i}]")
        ml += f"[n{i}]"
        t_off += hold
    fp.append(f"{ml}amix=inputs={len(seg_data)+1}:duration=first:normalize=0[aout]")

    ok = run(["ffmpeg","-y"] + inputs + [
        "-filter_complex", ";".join(fp),
        "-map","0:v","-map","[aout]",
        "-c:v","copy","-c:a","aac","-b:a","128k", OUTPUT])

    if ok:
        fd = get_dur(OUTPUT)
        sz = os.path.getsize(OUTPUT)/(1024*1024)
        print(f'\n=== Done! {OUTPUT} ===')
        print(f'  Duration: {fd:.1f}s, Size: {sz:.1f}MB')

    # Cleanup temp
    for f in [concat_out, text_out]:
        if os.path.exists(f): os.remove(f)
    print('  Cleaned up.')

asyncio.run(main())

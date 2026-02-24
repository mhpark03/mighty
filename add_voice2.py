import edge_tts, asyncio, subprocess, os

os.chdir(r"C:\sudoku\mighty_app")
VOICE = "en-US-AnaNeural"

def run_ffmpeg(cmd):
    result = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
    if result.returncode != 0:
        print(f'  ERROR: {result.stderr[-500:]}')
    return result.returncode == 0

def get_duration(f):
    r = subprocess.run(
        ['ffprobe', '-v', 'quiet', '-show_entries', 'format=duration', '-of', 'csv=p=0', f],
        capture_output=True, text=True
    )
    return float(r.stdout.strip())

async def generate_tts(text, output_file, rate="+0%"):
    communicate = edge_tts.Communicate(text, VOICE, rate=rate)
    await communicate.save(output_file)
    dur = get_duration(output_file)
    print(f'  TTS: ({dur:.1f}s) {text}')
    return dur

async def main():
    print("=== shorts_eng2 with AnaNeural (cute girl voice) ===")

    narrations = [
        (0,     "Mighty! Where hidden alliances decide everything.", "+5%"),
        (5000,  "Alex bids fourteen clubs and picks a secret friend.", "+15%"),
        (10000, "The battle begins!", "+5%"),
        (16000, "Three point cards captured! A huge early swing!", "+10%"),
        (22000, "The Player counters with the Joker! What a play!", "+10%"),
        (29000, "Alex fires back with a trump cut! Attack won't stop!", "+10%"),
        (37000, "The declarer dominates! Almost all points taken!", "+10%"),
        (44000, "Declarer wins! Minus eighteen for the defense.", "+10%"),
    ]

    narr_files = []
    for i, (delay_ms, text, rate) in enumerate(narrations):
        nf = f"narration/eng2_{i}.mp3"
        await generate_tts(text, nf, rate)
        narr_files.append((delay_ms, nf))

    inputs = ["-i", "shorts_eng2.mp4"]
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
        "shorts_eng2_voice.mp4"
    ]

    print("  Mixing audio...")
    if run_ffmpeg(cmd):
        dur = get_duration("shorts_eng2_voice.mp4")
        print(f"  => shorts_eng2_voice.mp4: {dur:.1f}s")

asyncio.run(main())

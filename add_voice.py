import edge_tts
import asyncio
import subprocess
import os

os.chdir(r"C:\sudoku\mighty_app")
os.makedirs('narration', exist_ok=True)

VOICE = "en-US-GuyNeural"

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
    print(f'  TTS: {output_file} ({dur:.1f}s) - "{text}"')
    return dur

async def process_video(input_file, output_file, tag, narrations):
    vid_dur = get_duration(input_file)
    print(f'\n=== {input_file} ({vid_dur:.1f}s) => {output_file} ===')

    # 1. Generate narration audio files
    narr_files = []
    for i, (delay_ms, text, rate) in enumerate(narrations):
        narr_file = f'narration/{tag}_{i}.mp3'
        await generate_tts(text, narr_file, rate)
        narr_files.append((delay_ms, narr_file))

    # 2. Build ffmpeg filter to mix audio
    # Original audio at 30% volume, narration overlaid
    inputs = ['-i', input_file]
    for _, nf in narr_files:
        inputs.extend(['-i', nf])

    filter_parts = ["[0:a]volume=0.3[bg]"]
    mix_labels = "[bg]"
    for i, (delay_ms, _) in enumerate(narr_files):
        filter_parts.append(f"[{i+1}:a]adelay={delay_ms}|{delay_ms},volume=1.5[n{i}]")
        mix_labels += f"[n{i}]"

    n_inputs = len(narr_files) + 1
    filter_parts.append(f"{mix_labels}amix=inputs={n_inputs}:duration=first:normalize=0[aout]")

    filter_complex = ";".join(filter_parts)

    cmd = ['ffmpeg', '-y'] + inputs + [
        '-filter_complex', filter_complex,
        '-map', '0:v', '-map', '[aout]',
        '-c:v', 'copy', '-c:a', 'aac', '-b:a', '128k',
        output_file
    ]

    print('  Mixing audio...')
    if run_ffmpeg(cmd):
        out_dur = get_duration(output_file)
        print(f'  => {output_file}: {out_dur:.1f}s')
    else:
        print(f'  FAILED!')

async def main():
    # Video 1 (46.3s): Sophia, 14 Club, Friend: James(Joker), no result screen
    # Tricks: t=12 start, t=20 friend revealed, t=28 Sophia trump, t=36 Alex defense, t=40 Sophia back
    await process_video('shorts_eng1.mp4', 'shorts_eng1_voice.mp4', 'eng1', [
        (0,     "Mighty! Five players battle in this Korean card game.", "+5%"),
        (5000,  "The declarer exchanges cards and picks a secret ally.", "+15%"),
        (10000, "Ten tricks to play. Let the battle begin!", "+5%"),
        (17000, "The friend is revealed with a Joker! Attack team strikes!", "+10%"),
        (24000, "Defense tries to fight back, but attack holds strong.", "+10%"),
        (31000, "Sophia leads with trump! Nine points already!", "+10%"),
        (37000, "Defense steals a trick, but it may be too late!", "+10%"),
        (42000, "Try Mighty on Google Play!", "+0%"),
    ])

    # Video 2 (48.4s): Alex, 14 Club, Friend: Emma(Spade A), Defeat -18pts
    # Tricks: t=12 first, t=16 Emma 3pts, t=20 Alex 3pts, t=24 Player Joker!, t=28 Alex trump cut
    await process_video('shorts_eng2.mp4', 'shorts_eng2_voice.mp4', 'eng2', [
        (0,     "Mighty! Where hidden alliances decide everything.", "+5%"),
        (5000,  "Alex bids fourteen clubs and picks a secret friend.", "+15%"),
        (10000, "The battle begins!", "+5%"),
        (16000, "Three point cards captured! A huge early swing!", "+10%"),
        (22000, "The Player counters with the Joker! What a play!", "+10%"),
        (29000, "Alex fires back with a trump cut! Attack won't stop!", "+10%"),
        (37000, "The declarer dominates! Almost all points taken!", "+10%"),
        (44000, "Declarer wins! Minus eighteen for the defense.", "+10%"),
    ])

    # Video 3 (51.2s): Sophia, 15 Spade, Friend: James(Joker), Full Run -40pts
    # Tricks: t=18 Spade A, t=22 friend revealed 6pts, t=26 9pts, t=34 all 13pts!, t=38 sweep
    await process_video('shorts_eng3.mp4', 'shorts_eng3_voice.mp4', 'eng3', [
        (0,     "Can Sophia pull off fifteen spades?", "+0%"),
        (5000,  "She strengthens her hand and calls on the Joker owner.", "+15%"),
        (12000, "High stakes! Every trick matters.", "+5%"),
        (19000, "Sophia plays the Spade Ace! Taking control early!", "+10%"),
        (26000, "Nine points in just four tricks! She's unstoppable!", "+10%"),
        (34000, "All thirteen points collected! Full run incoming!", "+10%"),
        (41000, "No one can stop the declarer team!", "+10%"),
        (47000, "A devastating full run! Forty points lost!", "+5%"),
    ])

    print('\nAll done!')

asyncio.run(main())

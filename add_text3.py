import subprocess
import os

os.chdir(r"C:\sudoku\mighty_app")

FONT_B = "C\\:/Windows/Fonts/arialbd.ttf"
FONT_R = "C\\:/Windows/Fonts/arial.ttf"

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

def write_text(tag, idx, content):
    fname = f"txt_{tag}_{idx:02d}.txt"
    with open(fname, 'w', encoding='utf-8') as f:
        f.write(content)
    return fname

def process_video(input_file, output_file, tag, game_info, phases):
    dur = get_duration(input_file)
    print(f'\n=== {input_file} ({dur:.1f}s) => {output_file} ===')

    idx = [0]
    def txt(content):
        idx[0] += 1
        return write_text(tag, idx[0], content)

    filters = []

    # --- Intro title (0~3s) - centered on screen, large & bold ---
    tf = txt("MIGHTY")
    filters.append(
        f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=80:fontcolor=#FFD700"
        f":borderw=5:bordercolor=black:shadowcolor=black@0.9:shadowx=4:shadowy=4"
        f":box=1:boxcolor=black@0.6:boxborderw=20"
        f":x=(w-text_w)/2:y=(h-text_h)/2-80:enable='between(t,0,3)'"
    )
    tf = txt("Korean Card Game - AI Demo")
    filters.append(
        f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=30:fontcolor=white"
        f":borderw=3:bordercolor=black:shadowcolor=black@0.9:shadowx=3:shadowy=3"
        f":box=1:boxcolor=black@0.6:boxborderw=12"
        f":x=(w-text_w)/2:y=(h-text_h)/2+10:enable='between(t,0.5,3)'"
    )
    tf = txt(game_info)
    filters.append(
        f"drawtext=fontfile='{FONT_R}':textfile='{tf}':fontsize=26:fontcolor=#AADDFF"
        f":borderw=3:bordercolor=black:shadowcolor=black@0.9:shadowx=2:shadowy=2"
        f":box=1:boxcolor=black@0.6:boxborderw=10"
        f":x=(w-text_w)/2:y=(h-text_h)/2+60:enable='between(t,1,4)'"
    )

    # --- Phase labels (top banner area, large & visible) ---
    for (start, end, label, sublabel) in phases:
        e = end if end is not None else dur
        tf = txt(label)
        filters.append(
            f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=44:fontcolor=#FFD700"
            f":borderw=4:bordercolor=black:shadowcolor=black@0.9:shadowx=3:shadowy=3"
            f":box=1:boxcolor=black@0.7:boxborderw=14"
            f":x=(w-text_w)/2:y=6:enable='between(t,{start},{e:.1f})'"
        )
        if sublabel:
            tf = txt(sublabel)
            filters.append(
                f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=26:fontcolor=white"
                f":borderw=3:bordercolor=black:shadowcolor=black@0.9:shadowx=2:shadowy=2"
                f":box=1:boxcolor=black@0.6:boxborderw=8"
                f":x=(w-text_w)/2:y=62:enable='between(t,{start},{e:.1f})'"
            )

    # --- Ending CTA (last 5s) ---
    cta_start = dur - 5
    tf = txt("Mighty Card Game")
    filters.append(
        f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=34:fontcolor=white"
        f":borderw=4:bordercolor=black:shadowcolor=black@0.9:shadowx=3:shadowy=3"
        f":box=1:boxcolor=black@0.7:boxborderw=14"
        f":x=(w-text_w)/2:y=h-200:enable='between(t,{cta_start:.1f},{dur:.1f})'"
    )
    tf = txt("Download on Google Play")
    filters.append(
        f"drawtext=fontfile='{FONT_B}':textfile='{tf}':fontsize=28:fontcolor=#34A853"
        f":borderw=3:bordercolor=black:shadowcolor=black@0.9:shadowx=3:shadowy=3"
        f":box=1:boxcolor=black@0.7:boxborderw=12"
        f":x=(w-text_w)/2:y=h-140:enable='between(t,{cta_start:.1f},{dur:.1f})'"
    )

    # Write filter script
    filter_script = ",\n".join(filters)
    script_name = f"filter_{tag}.txt"
    with open(script_name, 'w', encoding='utf-8') as f:
        f.write(filter_script)
    print(f'  Filter: {script_name} ({len(filters)} drawtext layers)')

    # Run ffmpeg
    cmd = [
        'ffmpeg', '-y', '-i', input_file,
        '-filter_script:v', script_name,
        '-c:v', 'libx264', '-preset', 'medium', '-crf', '20',
        '-c:a', 'copy',
        output_file
    ]
    if run_ffmpeg(cmd):
        out_dur = get_duration(output_file)
        print(f'  Done! {out_dur:.1f}s')
    else:
        print(f'  FAILED!')


# Video 1: Sophia, 14 Club, Friend: Joker (46.8s, no result screen)
process_video('shorts_eng11.mp4', 'shorts_eng1.mp4', 'eng1',
    'Sophia / 14 Club / Friend: Joker Owner',
    [
        (0,  4,  'Bidding Phase',  '5 AI Players | 2x Speed'),
        (4,  9,  'Strategy Setup', 'Kitty Exchange & Friend | 1.5x Speed'),
        (9,  None, 'Trick Play',   None),
    ])

# Video 2: Alex, 14 Club, Friend: Spade A (51.7s, Defeat -18pts)
process_video('shorts_eng22.mp4', 'shorts_eng2.mp4', 'eng2',
    'Alex / 14 Club / Friend: Spade A Owner',
    [
        (0,  4,  'Bidding Phase',      '5 AI Players | 2x Speed'),
        (4,  9,  'Friend Declaration', 'Choosing an Ally | 1.5x Speed'),
        (9,  48, 'Trick Play',         None),
        (48, None, 'Game Result',      'Defeat! -18 pts'),
    ])

# Video 3: Sophia, 15 Spade, Friend: Joker (51.2s, Full Run -40pts)
process_video('shorts_eng33.mp4', 'shorts_eng3.mp4', 'eng3',
    'Sophia / 15 Spade / Friend: Joker Owner',
    [
        (0,  4,  'Bidding Phase',  '5 AI Players | 1.5x Speed'),
        (4,  11, 'Strategy Setup', 'Kitty & Friend | 1.5x Speed'),
        (11, 47, 'Trick Play',     None),
        (47, None, 'Game Result',  'Full Run! -40 pts'),
    ])

print('\nAll done!')

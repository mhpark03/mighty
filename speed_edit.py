import subprocess
import os

os.chdir(r"C:\sudoku\mighty_app")

def run_ffmpeg(cmd):
    result = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
    if result.returncode != 0:
        print(f'  ERROR: {result.stderr[-300:]}')
    return result.returncode == 0

def make_segment(input_file, start, end, speed, output_file):
    duration = end - start
    vf = f'setpts=PTS/{speed}' if speed != 1.0 else 'copy'

    af_parts = []
    s = speed
    while s > 2.0:
        af_parts.append('atempo=2.0')
        s /= 2.0
    if abs(s - 1.0) > 0.01:
        af_parts.append(f'atempo={s:.4f}')
    af = ','.join(af_parts) if af_parts else 'acopy'

    cmd = [
        'ffmpeg', '-y',
        '-ss', f'{start:.3f}', '-t', f'{duration:.3f}',
        '-i', input_file,
        '-filter_complex', f'[0:v]{vf}[v];[0:a]{af}[a]',
        '-map', '[v]', '-map', '[a]',
        '-c:v', 'libx264', '-preset', 'fast', '-crf', '20',
        '-c:a', 'aac', '-b:a', '128k',
        output_file
    ]
    return run_ffmpeg(cmd)

def concat_files(part_files, output_file):
    list_file = output_file + '.txt'
    with open(list_file, 'w') as f:
        for pf in part_files:
            abs_path = os.path.abspath(pf).replace('\\', '/')
            f.write(f"file '{abs_path}'\n")

    cmd = ['ffmpeg', '-y', '-f', 'concat', '-safe', '0', '-i', list_file, '-c', 'copy', output_file]
    result = run_ffmpeg(cmd)
    os.remove(list_file)
    return result

def blur_bg(input_file, output_file):
    cmd = [
        'ffmpeg', '-y', '-i', input_file,
        '-filter_complex',
        '[0:v]scale=1080:1920,boxblur=20:20[bg];[0:v]scale=-2:1920[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2',
        '-c:v', 'libx264', '-preset', 'medium', '-crf', '20',
        '-c:a', 'aac', '-b:a', '128k', '-movflags', '+faststart',
        output_file
    ]
    return run_ffmpeg(cmd)

def get_duration(f):
    r = subprocess.run(
        ['ffprobe', '-v', 'quiet', '-show_entries', 'format=duration', '-of', 'csv=p=0', f],
        capture_output=True, text=True
    )
    return float(r.stdout.strip())

# eng1: 73.7s -> ~56s
# eng2: 68.7s -> ~56s
# eng3: 57.2s -> ~51s
videos = {
    'eng1.mp4': [
        (0, 2, 4.0),       # black screen
        (2, 28, 2.0),      # bidding
        (28, 38, 1.5),     # kitty + friend
        (38, 73.7, 1.0),   # tricks
    ],
    'eng2.mp4': [
        (0, 2, 4.0),       # black screen
        (2, 18, 2.0),      # bidding
        (18, 27, 1.5),     # kitty + friend
        (27, 68.7, 1.0),   # tricks + result
    ],
    'eng3.mp4': [
        (0, 8, 1.5),       # bidding
        (8, 18, 1.5),      # kitty + friend
        (18, 57.2, 1.0),   # tricks + result
    ],
}

os.makedirs('tmp_speed', exist_ok=True)

for video, segments in videos.items():
    base = video.replace('.mp4', '')
    print(f'\n=== {video} ===')

    parts = []
    for i, (s, e, spd) in enumerate(segments):
        pf = f'tmp_speed/{base}_p{i}.mp4'
        parts.append(pf)
        print(f'  [{i}] {s}-{e}s @ {spd}x ...')
        make_segment(video, s, e, spd, pf)

    concat_out = f'tmp_speed/{base}_concat.mp4'
    print('  Concatenating...')
    concat_files(parts, concat_out)

    out = f'shorts_{base}.mp4'
    print('  Blur background...')
    blur_bg(concat_out, out)

    dur = get_duration(out)
    print(f'  => {out}: {dur:.1f}s')

print('\nAll done!')

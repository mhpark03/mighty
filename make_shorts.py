"""
마이티 배팅 전략 숏츠 영상 제작 스크립트
- TTS 자연 속도에 맞춰 영상 길이를 자동 확장 (정지 화면 복제)
- 자막과 음성을 합성
"""
import subprocess
import asyncio
import edge_tts
import json
import os

VOICE = "ko-KR-SunHiNeural"  # 여성 한국어 음성
OUTPUT_DIR = "C:/sudoku/mighty_app"

# ============================================================
# Shorts 1: bid1.mp4 (56초) - 서연의 13 클로버 선언
# ============================================================
shorts1_segments = [
    # (시작, 끝, 자막텍스트, 음성텍스트)
    (0.0, 3.0,
     "마이티 배팅, 어떻게 계산할까?",
     "마이티 배팅, 어떻게 점수를 계산하는지 알아봅시다!"),
    (3.0, 6.0,
     "배팅 기준: 예상 득점 13점 이상이면 배팅!",
     "배팅 기준은 간단합니다. 예상 득점이 13점 이상이면 배팅하세요!"),
    (6.0, 10.0,
     "계산법 ①: 가장 많은 무늬 = 기루다 후보",
     "계산 첫번째 단계. 가장 많은 무늬가 기루다 후보입니다."),
    (10.0, 15.0,
     "민준: ♥ 5장이 기루다 후보\n핵심카드: ♥A·Q·J 보유",
     "민준은 하트가 5장으로 기루다 후보. 핵심카드 에이스, 퀸, 잭을 보유하고 있습니다."),
    (15.0, 20.0,
     "계산법 ②: 기루다 트릭 + 비기루다 A로\n예상 득점 계산 → 적정 10점",
     "기루다로 이길 트릭과 비기루다 에이스를 합쳐 예상 득점을 계산하면, 적정 10점입니다."),
    (20.0, 23.0,
     "적정 10점 < 최소 13점 → 패스!",
     "적정 10점은 최소 13점에 미달이므로 패스입니다!"),
    (23.0, 28.0,
     "서연: ♣ 4장 + 조커 + ♠K 보유\n계산법 ③: 조커 = 확정 1트릭 추가",
     "서연은 클로버 4장에 조커를 보유. 조커는 확정 1트릭을 추가합니다."),
    (28.0, 33.0,
     "기루다 ♣ 핵심카드(K·10·8)\n+ 조커 1트릭 → 예상 2~15점",
     "기루다 핵심카드 킹, 10, 8에 조커를 더하면, 예상 2에서 15점."),
    (33.0, 36.0,
     "적정 13점 ≥ 최소 13점 → 배팅!",
     "적정 13점은 최소 기준을 충족. 배팅합니다!"),
    (36.0, 41.0,
     "지호: ♣ A·K 보유, 적정 12점\n마이티 없고 조커 없음 → 패스",
     "지호는 클로버 에이스, 킹 보유에 적정 12점이지만, 마이티와 조커 없이 패스."),
    (41.0, 47.0,
     "수빈: 마이티(♠A) 보유!\n하지만 기루다 ♥ 5장 적정 12점 → 패스",
     "수빈은 마이티를 가지고 있지만! 기루다 하트 5장으로 적정 12점, 아쉽게 패스."),
    (47.0, 52.0,
     "핵심 정리: 마이티가 있어도\n점수카드가 부족하면 패스가 정답!",
     "핵심 정리! 마이티가 있어도 점수카드가 부족하면 패스가 정답입니다!"),
    (52.0, 56.0,
     "서연이 주공 확정! 키티에서 추가 점수 획득",
     "서연이 주공 확정! 키티에서 추가 점수를 획득합니다."),
]
# 각 자막에 맞는 원본 영상 프레임 추출 시간 (bid1.mp4 절대 시간)
shorts1_frame_times = [
    2,   # 0: 인트로 → 배팅 화면 (민준 분석 중)
    2,   # 1: 배팅 규칙 → 배팅 화면
    2,   # 2: 계산법① → 민준 카드 보이는 화면
    2,   # 3: 민준 분석 → 민준 카드 펼침 + 설명
    4,   # 4: 민준 계산 → 민준 패스 결과
    4,   # 5: 민준 패스 → 민준 패스 결과
    6,   # 6: 서연 분석 → 서연 카드 펼침 + 13 클로버
    8,   # 7: 서연 계산 → 서연 설명 상세
    8,   # 8: 서연 배팅 → 서연 13 클로버 선언
    20,  # 9: 지호 분석 → 지호 카드 펼침 + 패스 설명
    32,  # 10: 수빈 분석 → 수빈 카드 펼침 + 패스 설명
    40,  # 11: 핵심 정리 → 전체 결과 요약 화면
    52,  # 12: 서연 주공 → 키티 선택 결과
]

# ============================================================
# Shorts 2: bid2.mp4 58초~ (60초) - 수빈의 13 클로버 선언
# ============================================================
shorts2_segments = [
    (0.0, 3.0,
     "이번 판, 누가 배팅할까?\n계산 과정을 따라가 봅시다!",
     "이번 판, 누가 배팅할까요? 계산 과정을 따라가 봅시다!"),
    (3.0, 8.0,
     "서연: 조커 보유! 하지만...\n기루다 후보 무늬가 없다 (최대 2장)",
     "서연은 조커를 가지고 있지만, 기루다 후보 무늬가 최대 2장뿐입니다."),
    (8.0, 13.0,
     "계산: 조커 1트릭 + 기루다 부족\n= 적정 0점 → 패스!",
     "조커 1트릭에 기루다가 부족하면 적정 0점. 조커만으로는 배팅할 수 없습니다!"),
    (13.0, 18.0,
     "지호: ♦ 4장이 기루다 후보\n하지만 ♦10이 최고카드, A·K 없음",
     "지호는 다이아 4장이 기루다 후보지만, 10이 최고카드. 에이스도 킹도 없습니다."),
    (18.0, 22.0,
     "계산: 핵심카드(A·K) 없으면\n트릭 승률 급감 → 적정 4점 패스!",
     "핵심카드인 에이스, 킹이 없으면 트릭 승률이 급감합니다. 적정 4점으로 패스!"),
    (22.0, 27.0,
     "수빈의 손패를 봅시다!\n♣ 5장 + A·Q·J 보유",
     "수빈의 손패를 봅시다! 클로버 5장에 에이스, 퀸, 잭을 보유!"),
    (27.0, 33.0,
     "계산법 정리:\n① 기루다 5장 = 강한 기반\n② A·Q·J = 높은 트릭 승률",
     "계산법 정리. 첫째 기루다 5장은 강한 기반. 둘째 에이스, 퀸, 잭은 높은 트릭 승률."),
    (33.0, 38.0,
     "③ ♥A = 초구 확정 트릭\n④ 프렌드 마이티 예상 → +α점",
     "셋째 하트 에이스로 초구 확정 트릭. 넷째 프렌드로 마이티를 부르면 추가 점수!"),
    (38.0, 43.0,
     "최종: 예상 1~19점 (적정 16점)\n→ 13 클로버 선언!",
     "최종 계산! 예상 1에서 19점, 적정 16점. 13 클로버 선언!"),
    (43.0, 48.0,
     "플레이어: ♦ 5장, K·Q 보유\n적정 11점 → 13점 미달 패스",
     "플레이어는 다이아 5장에 킹, 퀸 보유. 적정 11점으로 13점에 미달, 패스."),
    (48.0, 53.0,
     "민준: ♥ 4장, K·Q·J 보유\n적정 9점 → 13점 미달 패스",
     "민준은 하트 4장에 킹, 퀸, 잭 보유. 적정 9점으로 패스입니다."),
    (53.0, 60.0,
     "핵심 정리: 기루다 5장 이상\n+ A 보유 = 강한 배팅 근거!",
     "핵심 정리! 기루다 5장 이상에 에이스를 보유하면 강한 배팅 근거가 됩니다!"),
]
# 각 자막에 맞는 원본 영상 프레임 추출 시간 (bid2.mp4 절대 시간)
shorts2_frame_times = [
    60,   # 0: 인트로 → 새 게임, 카드 배분 화면
    62,   # 1: 서연 분석 → 서연 카드 펼침 + 조커
    62,   # 2: 서연 패스 → 서연 패스 결과 (적정 0점)
    74,   # 3: 지호 분석 → 지호 카드 펼침 + ♦4장
    78,   # 4: 지호 패스 → 지호 패스 결과 (적정 4점)
    86,   # 5: 수빈 손패 → 수빈 카드 펼침 + 13 클로버
    88,   # 6: 수빈 계산법 → 수빈 설명 상세
    90,   # 7: 수빈 계산 계속 → 수빈 설명 상세
    90,   # 8: 수빈 배팅 → 수빈 13 클로버 선언
    98,   # 9: 플레이어 분석 → 플레이어 패스 (적정 11점)
    110,  # 10: 민준 분석 → 민준 패스 (적정 9점)
    114,  # 11: 핵심 정리 → 전체 결과 요약 화면
]


def generate_srt(segments, filename):
    """SRT 자막 파일 생성"""
    lines = []
    for i, (start, end, subtitle, _) in enumerate(segments, 1):
        sh, sm, ss = int(start // 3600), int((start % 3600) // 60), start % 60
        eh, em, es = int(end // 3600), int((end % 3600) // 60), end % 60
        lines.append(str(i))
        lines.append(f"{sh:02d}:{sm:02d}:{ss:06.3f} --> {eh:02d}:{em:02d}:{es:06.3f}".replace('.', ','))
        lines.append(subtitle)
        lines.append("")
    with open(filename, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"Generated: {filename}")


async def generate_tts_segments(segments, prefix):
    """각 세그먼트별 TTS 음성 파일 생성 (자연 속도)"""
    files = []
    for i, (start, end, _, voice_text) in enumerate(segments):
        outfile = f"{OUTPUT_DIR}/{prefix}_voice_{i:03d}.mp3"
        communicate = edge_tts.Communicate(voice_text, VOICE, rate="+0%")
        await communicate.save(outfile)
        files.append((start, outfile))
        print(f"  TTS {i}: {outfile}")
    return files


def get_duration(filepath):
    """ffprobe로 파일 길이 조회"""
    result = subprocess.run(
        ["ffprobe", "-v", "quiet", "-print_format", "json", "-show_format", filepath],
        capture_output=True, text=True
    )
    data = json.loads(result.stdout)
    return float(data["format"]["duration"])


def adjust_timings(segments, tts_files):
    """TTS 길이에 맞춰 세그먼트 타이밍 조정 (영상을 늘려서 맞춤)"""
    adjusted = []
    current_time = 0.0
    for i, (orig_start, orig_end, subtitle, voice_text) in enumerate(segments):
        orig_window = orig_end - orig_start
        tts_dur = get_duration(tts_files[i][1])
        # TTS 길이 + 여유 0.5초, 최소한 원래 길이 유지
        new_window = max(orig_window, tts_dur + 0.5)
        new_end = current_time + new_window
        adjusted.append((current_time, new_end, subtitle, voice_text))
        if new_window > orig_window:
            print(f"  Segment {i}: {orig_window:.1f}s -> {new_window:.1f}s (TTS: {tts_dur:.1f}s, +{new_window - orig_window:.1f}s)")
        else:
            print(f"  Segment {i}: {orig_window:.1f}s (TTS: {tts_dur:.1f}s, OK)")
        current_time = new_end
    return adjusted


def create_extended_video(input_video, adjusted_segments, frame_times, output_path):
    """원본 영상에서 지정된 시점의 프레임을 추출하고 TTS 길이에 맞춰 확장"""
    temp_files = []

    for i in range(len(adjusted_segments)):
        adj_dur = adjusted_segments[i][1] - adjusted_segments[i][0]

        # 지정된 시점에서 프레임 추출
        frame_time = frame_times[i]
        frame_file = f"{OUTPUT_DIR}/tmp_frame_{i:03d}.png"
        subprocess.run([
            "ffmpeg", "-y", "-ss", str(frame_time),
            "-i", input_video, "-vframes", "1", frame_file
        ], capture_output=True, text=True)

        # 프레임을 adj_dur 길이의 영상 클립으로 생성
        clip_file = f"{OUTPUT_DIR}/tmp_clip_{i:03d}.mp4"
        subprocess.run([
            "ffmpeg", "-y", "-loop", "1", "-i", frame_file,
            "-t", str(adj_dur),
            "-c:v", "libx264", "-preset", "fast",
            "-pix_fmt", "yuv420p", "-r", "24",
            clip_file
        ], capture_output=True, text=True)
        temp_files.append(clip_file)
        os.remove(frame_file)
        print(f"  Clip {i}: {adj_dur:.1f}s from frame @{frame_time:.1f}s")

    # 모든 클립 연결
    list_file = f"{OUTPUT_DIR}/tmp_clips.txt"
    with open(list_file, "w") as f:
        for clip in temp_files:
            f.write(f"file '{clip.replace(chr(92), '/')}'\n")

    result = subprocess.run([
        "ffmpeg", "-y", "-f", "concat", "-safe", "0",
        "-i", list_file, "-c", "copy", output_path
    ], capture_output=True, text=True)
    if result.returncode != 0:
        print(f"  Video concat ERROR: {result.stderr[-500:]}")
    else:
        dur = get_duration(output_path)
        print(f"  Extended video: {dur:.1f}s")

    # 임시 파일 정리
    for clip in temp_files:
        if os.path.exists(clip):
            os.remove(clip)
    if os.path.exists(list_file):
        os.remove(list_file)


def merge_tts_to_audio(tts_files, adjusted_segments, total_duration, output_audio):
    """TTS 파일들을 조정된 타이밍에 맞춰 합성 (속도 변경 없음, 겹침 없음)"""
    inputs = []
    delays = []
    for i, (_, filepath) in enumerate(tts_files):
        inputs.extend(["-i", filepath])
        # 조정된 시작 시간 사용
        adj_start = adjusted_segments[i][0]
        delay_ms = int(adj_start * 1000)
        delays.append(f"[{i}]adelay={delay_ms}|{delay_ms}[d{i}]")

    mix_inputs = "".join(f"[d{i}]" for i in range(len(tts_files)))
    n = len(tts_files)
    filter_complex = (
        ";".join(delays) +
        f";{mix_inputs}amix=inputs={n}:duration=longest:dropout_transition=0,"
        f"dynaudnorm=p=0.95:s=5[out]"
    )

    cmd = ["ffmpeg", "-y"] + inputs + [
        "-filter_complex", filter_complex,
        "-map", "[out]",
        "-t", str(total_duration),
        "-c:a", "aac", "-b:a", "128k",
        output_audio
    ]
    print(f"Merging TTS to: {output_audio}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"  Audio merge ERROR: {result.stderr[-500:]}")


def create_final_video(input_video, srt_file, tts_audio, output_video):
    """자막 + TTS 음성을 합성한 최종 영상 생성"""
    cmd = [
        "ffmpeg", "-y",
        "-i", input_video,
        "-i", tts_audio,
        "-filter_complex",
        f"[0:v]subtitles={srt_file}:force_style='FontName=Malgun Gothic,FontSize=10,PrimaryColour=&H00FFFFFF,OutlineColour=&H00000000,BackColour=&H80000000,Outline=1,Shadow=0,BorderStyle=4,Alignment=2,MarginV=50,Bold=1'[v]",
        "-map", "[v]",
        "-map", "1:a",
        "-c:v", "libx264", "-preset", "fast", "-crf", "23",
        "-c:a", "aac", "-b:a", "128k",
        "-shortest",
        output_video
    ]
    print(f"Creating final video: {output_video}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"  ERROR: {result.stderr[-500:]}")
    else:
        print(f"  Success: {output_video}")


async def main():
    # === Shorts 1 ===
    print("=== Shorts 1 ===")

    print("Generating TTS (natural speed)...")
    tts1_files = await generate_tts_segments(shorts1_segments, "s1")

    print("Adjusting timings to fit TTS...")
    adjusted1 = adjust_timings(shorts1_segments, tts1_files)
    total1 = adjusted1[-1][1]
    print(f"  Total: {total1:.1f}s (original: 56s)")

    srt1 = f"{OUTPUT_DIR}/bid1.srt"
    generate_srt(adjusted1, srt1)

    print("Creating extended video (frame duplication)...")
    ext1 = f"{OUTPUT_DIR}/bid1_ext.mp4"
    create_extended_video(f"{OUTPUT_DIR}/bid1.mp4", adjusted1, shorts1_frame_times, ext1)

    audio1 = f"{OUTPUT_DIR}/s1_voice.m4a"
    merge_tts_to_audio(tts1_files, adjusted1, total1, audio1)

    create_final_video(ext1, "bid1.srt", audio1, f"{OUTPUT_DIR}/shorts1.mp4")

    # === Shorts 2 ===
    print("\n=== Shorts 2 ===")

    print("Generating TTS (natural speed)...")
    tts2_files = await generate_tts_segments(shorts2_segments, "s2")

    print("Adjusting timings to fit TTS...")
    adjusted2 = adjust_timings(shorts2_segments, tts2_files)
    total2 = adjusted2[-1][1]
    print(f"  Total: {total2:.1f}s (original: 60s)")

    srt2 = f"{OUTPUT_DIR}/bid2.srt"
    generate_srt(adjusted2, srt2)

    print("Creating extended video (frame duplication)...")
    ext2 = f"{OUTPUT_DIR}/bid2_ext.mp4"
    create_extended_video(f"{OUTPUT_DIR}/bid2.mp4", adjusted2, shorts2_frame_times, ext2)

    audio2 = f"{OUTPUT_DIR}/s2_voice.m4a"
    merge_tts_to_audio(tts2_files, adjusted2, total2, audio2)

    create_final_video(ext2, "bid2.srt", audio2, f"{OUTPUT_DIR}/shorts2.mp4")

    # 임시 파일 정리
    print("\nCleaning up temp files...")
    for f in os.listdir(OUTPUT_DIR):
        if f.startswith("s1_voice_") or f.startswith("s2_voice_"):
            os.remove(f"{OUTPUT_DIR}/{f}")
    for tmp in [audio1, audio2, ext1, ext2]:
        if os.path.exists(tmp):
            os.remove(tmp)

    print("\n=== 완료! ===")
    for name in ["shorts1.mp4", "shorts2.mp4"]:
        path = f"{OUTPUT_DIR}/{name}"
        if os.path.exists(path):
            dur = get_duration(path)
            size_mb = os.path.getsize(path) / (1024 * 1024)
            print(f"  {name}: {dur:.1f}초, {size_mb:.1f}MB")


if __name__ == "__main__":
    asyncio.run(main())

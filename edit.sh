#!/bin/bash
SRC="C:/sudoku/mighty_app/mighty_shorts.mp4"
OUT="C:/sudoku/mighty_app/mighty_shorts_edited.mp4"
TMP="C:/sudoku/mighty_app/tmp_parts"
mkdir -p "$TMP"

# 한글 폰트 찾기
FONT=$(fc-list :lang=ko -f "%{file}\n" 2>/dev/null | head -1)
if [ -z "$FONT" ]; then
  FONT="C\:/Windows/Fonts/malgun.ttf"
else
  FONT=$(echo "$FONT" | sed 's/:/\:/g; s/ /\ /g')
fi
echo "Using font: $FONT"

# Part 1: 인트로 제목 (첫 프레임에서 2초 정지 + 텍스트)
ffmpeg -y -ss 0 -i "$SRC" -vframes 1 -vf "scale=720:1280" "$TMP/intro_frame.png" 2>/dev/null
ffmpeg -y -loop 1 -i "$TMP/intro_frame.png" -t 2.0 \
  -vf "drawbox=x=0:y=440:w=720:h=400:color=black@0.7:t=fill,\
drawtext=fontfile='$FONT':text='마이티 AI 대전':fontsize=52:fontcolor=gold:x=(w-text_w)/2:y=500:borderw=2:bordercolor=black,\
drawtext=fontfile='$FONT':text='5인 AI가 펼치는 전략 카드 게임':fontsize=24:fontcolor=white:x=(w-text_w)/2:y=580:borderw=1:bordercolor=black,\
drawtext=fontfile='$FONT':text='배팅 → 키티 교환 → 카드 플레이':fontsize=20:fontcolor=white@0.8:x=(w-text_w)/2:y=640:borderw=1:bordercolor=black,\
fade=t=in:st=0:d=0.5" \
  -c:v libx264 -pix_fmt yuv420p -r 30 "$TMP/part1_intro.mp4" 2>/dev/null
echo "Part 1 done (intro)"

# Part 2: 배팅 (5~20s) 4배속
ffmpeg -y -ss 5 -t 15 -i "$SRC" \
  -vf "setpts=0.25*PTS,drawtext=fontfile='$FONT':text='배팅 단계 (4x)':fontsize=28:fontcolor=yellow:x=20:y=1220:borderw=2:bordercolor=black:enable='lt(t,2)'" \
  -an -c:v libx264 -pix_fmt yuv420p -r 30 "$TMP/part2_bid.mp4" 2>/dev/null
echo "Part 2 done (bidding)"

# Part 3: 키티 선택 + 프렌드 (20~40s) 2배속
ffmpeg -y -ss 20 -t 20 -i "$SRC" \
  -vf "setpts=0.5*PTS,drawtext=fontfile='$FONT':text='키티 교환 (2x)':fontsize=28:fontcolor=cyan:x=20:y=1220:borderw=2:bordercolor=black:enable='lt(t,2)'" \
  -an -c:v libx264 -pix_fmt yuv420p -r 30 "$TMP/part3_kitty.mp4" 2>/dev/null
echo "Part 3 done (kitty)"

# Part 4: Bid Summary (40~60s) 원속
ffmpeg -y -ss 40 -t 20 -i "$SRC" \
  -vf "drawtext=fontfile='$FONT':text='게임 요약':fontsize=28:fontcolor=lime:x=20:y=1220:borderw=2:bordercolor=black:enable='lt(t,2)'" \
  -an -c:v libx264 -pix_fmt yuv420p -r 30 "$TMP/part4_summary.mp4" 2>/dev/null
echo "Part 4 done (summary)"

# Part 5: 카드 플레이 (60~90s) 4배속
ffmpeg -y -ss 60 -t 30 -i "$SRC" \
  -vf "setpts=0.25*PTS,drawtext=fontfile='$FONT':text='카드 플레이 (4x)':fontsize=28:fontcolor=yellow:x=20:y=1220:borderw=2:bordercolor=black:enable='lt(t,2)'" \
  -an -c:v libx264 -pix_fmt yuv420p -r 30 "$TMP/part5_play.mp4" 2>/dev/null
echo "Part 5 done (play)"

# Part 6: 게임 결과 (90~110s) 원속 + 아웃로 fade
ffmpeg -y -ss 88 -t 20 -i "$SRC" \
  -vf "drawtext=fontfile='$FONT':text='게임 결과':fontsize=28:fontcolor=gold:x=20:y=1220:borderw=2:bordercolor=black:enable='lt(t,2)',fade=t=out:st=17:d=3" \
  -an -c:v libx264 -pix_fmt yuv420p -r 30 "$TMP/part6_result.mp4" 2>/dev/null
echo "Part 6 done (result)"

# Concat
cat > "$TMP/concat.txt" << EOF
file 'part1_intro.mp4'
file 'part2_bid.mp4'
file 'part3_kitty.mp4'
file 'part4_summary.mp4'
file 'part5_play.mp4'
file 'part6_result.mp4'
EOF

ffmpeg -y -f concat -safe 0 -i "$TMP/concat.txt" \
  -c:v libx264 -pix_fmt yuv420p -r 30 -movflags +faststart \
  "$OUT" 2>/dev/null

echo ""
echo "=== DONE ==="
ffprobe -v quiet -print_format json -show_format "$OUT" 2>/dev/null | python -c "import sys,json; f=json.load(sys.stdin)['format']; print(f'Output: {f[\"filename\"]}'); print(f'Duration: {float(f[\"duration\"]):.1f}s'); print(f'Size: {int(f[\"size\"])/1024/1024:.1f}MB')"

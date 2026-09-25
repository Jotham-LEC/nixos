geom=$(slurp) || exit 0

text=$(grim -g "$geom" - | tesseract stdin stdout -l eng+chi_sim 2>/dev/null) || {
  notify-send -u critical "screen-ocr" "tesseract failed"
  exit 1
}

if [ -z "${text//[[:space:]]/}" ]; then
  notify-send -t 2000 "screen-ocr" "No text found"
  exit 0
fi

printf '%s' "$text" | wl-copy

notify-send -t 2000 "screen-ocr" "Copied $(printf '%s' "$text" | wc -c) characters"

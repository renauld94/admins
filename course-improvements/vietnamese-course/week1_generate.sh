#!/usr/bin/env bash
# Simple generator: calls Ollama or OpenWebUI to produce Week1 expansions.
# Edit ENDPOINT, MODEL and PROVIDER as needed before running.
set -euo pipefail
WORKDIR="$(dirname "$0")"
PROVIDER=${PROVIDER:-ollama} # 'ollama' or 'openwebui' or 'cli'
MODEL=${MODEL:-llama2}
OLLAMA_URL=${OLLAMA_URL:-https://ollama.simondatalab.de/api/generate}
OPENWEBUI_URL=${OPENWEBUI_URL:-https://openwebui.simondatalab.de/api/generate}
PROMPTS_FILE="$WORKDIR/week1_prompts.txt"
OUTDIR="$WORKDIR/generated"
mkdir -p "$OUTDIR"

prompt_to_file(){
  local prompt="$1"
  local outpath="$2"
  if [ "$PROVIDER" = "ollama" ]; then
    curl -sS -X POST "$OLLAMA_URL" -H "Content-Type: application/json" \
      -d '{"model":"'$MODEL'","prompt":"'$prompt'","max_tokens":800}' -o "$outpath"
  elif [ "$PROVIDER" = "openwebui" ]; then
    curl -sS -X POST "$OPENWEBUI_URL" -H "Content-Type: application/json" \
      -d '{"prompt":"'$prompt'","length":800}' -o "$outpath"
  else
    # local CLI (ollama) fallback
    ollama generate -m "$MODEL" "$prompt" > "$outpath"
  fi
}

# Example: generate dialogues (prompt 1)
read -r -d '' P1 <<'EOF'
Generate 10 short dialogue pairs. Each pair should include: 1) a Vietnamese line with polite/formal and informal variants; 2) an English translation on the next line. Keep each dialogue under 3 lines. Mark lines with 'VN:' and 'EN:'.
EOF

echo "Generating dialogues..."
prompt_to_file "$P1" "$OUTDIR/dialogues.json"

# Example: generate fill-in-the-blanks (prompt 2)
read -r -d '' P2 <<'EOF'
Produce 20 short Vietnamese sentences with one blank each (____) for students to fill in with core Week1 words (Chào, tên, đến từ, ở, ...). Provide an answer key after the list.
EOF

echo "Generating fill-in-the-blanks..."
prompt_to_file "$P2" "$OUTDIR/fill_blanks.json"

# Example: flashcards CSV (prompt 3)
read -r -d '' P3 <<'EOF'
Return CSV format with headers Front,Back. Create 50 high-value vocabulary items for beginner learners relevant to introductions and daily survival language.
EOF

echo "Generating flashcards CSV..."
prompt_to_file "$P3" "$OUTDIR/flashcards.csv"

# Example: 30-second script (prompt 4)
read -r -d '' P4 <<'EOF'
Write a 30-second self-introduction in Vietnamese with an English translation and simple pronunciation hints (one short phrase per line). Keep vocabulary limited to Week 1 words.
EOF

echo "Generating 30-second script..."
prompt_to_file "$P4" "$OUTDIR/intro_script.json"

echo "Done. Generated files are in $OUTDIR"
exit 0

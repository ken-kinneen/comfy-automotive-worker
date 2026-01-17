#!/bin/bash
# Custom start script with detailed timing logs

set -e

BOOT_START=$(date +%s.%N)

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     🏎️  COMFYUI AUTOMOTIVE WORKER - STARTING                 ║"
echo "║     $(date '+%Y-%m-%d %H:%M:%S')                                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check environment
echo "🔧 Environment:"
echo "   HF_TOKEN: ${HF_TOKEN:+SET (${#HF_TOKEN} chars)}${HF_TOKEN:-NOT SET}"
echo "   RUNPOD_POD_ID: ${RUNPOD_POD_ID:-not set}"
echo "   GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo 'unknown')"
echo ""

# Check network volume
echo "💾 Network Volume:"
if [ -d "/runpod-volume" ]; then
    VOLUME_USED=$(df -h /runpod-volume 2>/dev/null | tail -1 | awk '{print $3}')
    VOLUME_AVAIL=$(df -h /runpod-volume 2>/dev/null | tail -1 | awk '{print $4}')
    echo "   Status: MOUNTED"
    echo "   Used: $VOLUME_USED / Available: $VOLUME_AVAIL"
else
    echo "   Status: NOT MOUNTED ⚠️"
fi
echo ""

# ============================================
# STEP 1: Download Models
# ============================================
MODEL_START=$(date +%s.%N)
echo "┌──────────────────────────────────────────────────────────────┐"
echo "│  STEP 1: MODEL SETUP                                        │"
echo "└──────────────────────────────────────────────────────────────┘"

/download-models.sh

MODEL_END=$(date +%s.%N)
MODEL_DURATION=$(echo "$MODEL_END - $MODEL_START" | bc)
echo "⏱️  Model setup completed in ${MODEL_DURATION}s"
echo ""

# ============================================
# STEP 2: Start ComfyUI Worker
# ============================================
WORKER_START=$(date +%s.%N)
echo "┌──────────────────────────────────────────────────────────────┐"
echo "│  STEP 2: STARTING COMFYUI WORKER                            │"
echo "└──────────────────────────────────────────────────────────────┘"
echo ""

BOOT_END=$(date +%s.%N)
BOOT_DURATION=$(echo "$BOOT_END - $BOOT_START" | bc)

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🚀 BOOT COMPLETE - WORKER READY                            ║"
echo "║  ⏱️  Total boot time: ${BOOT_DURATION}s                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Run the original handler
exec python -u /handler.py

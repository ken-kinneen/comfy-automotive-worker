#!/bin/bash
# Download models to network volume if not already present
# This runs at container startup

set -e

MODELS_DIR="/runpod-volume/models"
TOTAL_START=$(date +%s.%N)

echo "══════════════════════════════════════════════════════════════"
echo "  🚀 MODEL DOWNLOAD SCRIPT - $(date '+%Y-%m-%d %H:%M:%S')"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Create directories
echo "📁 Creating model directories..."
mkdir -p "$MODELS_DIR/checkpoints"
mkdir -p "$MODELS_DIR/vae"
mkdir -p "$MODELS_DIR/clip"
mkdir -p "$MODELS_DIR/loras"
mkdir -p "$MODELS_DIR/controlnet"
mkdir -p "$MODELS_DIR/ipadapter"
mkdir -p "$MODELS_DIR/clip_vision"

DOWNLOADED=0
SKIPPED=0
FAILED=0

download_model() {
    local name="$1"
    local path="$2"
    local url="$3"
    local use_hf="$4"
    local hf_repo="$5"
    local hf_file="$6"
    
    if [ -f "$path" ]; then
        local size=$(du -h "$path" 2>/dev/null | cut -f1)
        echo "✅ SKIP: $name ($size) - already exists"
        ((SKIPPED++))
        return 0
    fi
    
    local start=$(date +%s.%N)
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📥 DOWNLOADING: $name"
    echo "   Path: $path"
    
    if [ "$use_hf" = "true" ]; then
        echo "   Source: HuggingFace ($hf_repo)"
        if [ -z "$HF_TOKEN" ]; then
            echo "❌ ERROR: HF_TOKEN not set for gated model"
            ((FAILED++))
            return 1
        fi
        local dir=$(dirname "$path")
        huggingface-cli download "$hf_repo" "$hf_file" --token "$HF_TOKEN" --local-dir "$dir" --local-dir-use-symlinks False 2>&1
    else
        echo "   Source: $url"
        wget -q --show-progress -O "$path" "$url" 2>&1
    fi
    
    local end=$(date +%s.%N)
    local duration=$(echo "$end - $start" | bc)
    
    if [ -f "$path" ]; then
        local size=$(du -h "$path" | cut -f1)
        echo "✅ DONE: $name ($size) in ${duration}s"
        ((DOWNLOADED++))
    else
        echo "❌ FAILED: $name"
        ((FAILED++))
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

echo ""
echo "🔍 Checking models on network volume..."
echo ""

# --- ControlNet ---
download_model \
    "Shakker-Labs-ControlNet-Union-Pro-2.0" \
    "$MODELS_DIR/controlnet/diffusion_pytorch_model.safetensors" \
    "https://huggingface.co/Shakker-Labs/FLUX.1-dev-ControlNet-Union-Pro/resolve/main/diffusion_pytorch_model.safetensors" \
    "false"

# --- CLIP L ---
download_model \
    "clip_l.safetensors" \
    "$MODELS_DIR/clip/clip_l.safetensors" \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" \
    "false"

# --- T5 XXL FP16 ---
download_model \
    "t5xxl_fp16.safetensors (9.3GB)" \
    "$MODELS_DIR/clip/t5xxl_fp16.safetensors" \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors" \
    "false"

# --- Flux Dev (Gated) ---
download_model \
    "flux1-dev.safetensors (23GB - GATED)" \
    "$MODELS_DIR/checkpoints/flux1-dev.safetensors" \
    "" \
    "true" \
    "black-forest-labs/FLUX.1-dev" \
    "flux1-dev.safetensors"

# --- Flux VAE (Gated) ---
download_model \
    "ae.safetensors (VAE - GATED)" \
    "$MODELS_DIR/vae/ae.safetensors" \
    "" \
    "true" \
    "black-forest-labs/FLUX.1-dev" \
    "ae.safetensors"

# --- Custom LoRA 1 ---
download_model \
    "MM008_LyCORIS_DS02A_v1-000024.safetensors (LoRA)" \
    "$MODELS_DIR/loras/MM008_LyCORIS_DS02A_v1-000024.safetensors" \
    "" \
    "true" \
    "dvhouw/CLOUD_SYNC" \
    "MM008_LyCORIS_DS02A_v1-000024.safetensors"

# --- Custom LoRA 2 ---
download_model \
    "PNF001_LyCORIS_PNFB3TT4S_DS02_v1-000024.safetensors (LoRA)" \
    "$MODELS_DIR/loras/PNF001_LyCORIS_PNFB3TT4S_DS02_v1-000024.safetensors" \
    "" \
    "true" \
    "dvhouw/CLOUD_SYNC" \
    "PNF001_LyCORIS_PNFB3TT4S_DS02_v1-000024.safetensors"

TOTAL_END=$(date +%s.%N)
TOTAL_DURATION=$(echo "$TOTAL_END - $TOTAL_START" | bc)

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  📊 MODEL DOWNLOAD SUMMARY"
echo "══════════════════════════════════════════════════════════════"
echo "  ✅ Downloaded: $DOWNLOADED"
echo "  ⏭️  Skipped:    $SKIPPED (already present)"
echo "  ❌ Failed:     $FAILED"
echo "  ⏱️  Total time: ${TOTAL_DURATION}s"
echo "══════════════════════════════════════════════════════════════"
echo ""

# List what's on the volume
echo "📂 Models on network volume:"
echo ""
find "$MODELS_DIR" -name "*.safetensors" -exec ls -lh {} \; 2>/dev/null | awk '{print "   " $5 " " $9}'
echo ""

if [ $FAILED -gt 0 ]; then
    echo "⚠️  Some models failed to download. Worker may not function correctly."
    exit 1
fi

echo "✅ All models ready!"
echo ""

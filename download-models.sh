#!/bin/bash
# Download models to network volume if not already present
# This runs at container startup

set -e

MODELS_DIR="/runpod-volume/models"

echo "🔍 Checking for models on network volume..."

# Create directories
mkdir -p "$MODELS_DIR/checkpoints"
mkdir -p "$MODELS_DIR/vae"
mkdir -p "$MODELS_DIR/clip"
mkdir -p "$MODELS_DIR/loras"
mkdir -p "$MODELS_DIR/controlnet"
mkdir -p "$MODELS_DIR/ipadapter"
mkdir -p "$MODELS_DIR/clip_vision"

# --- Shakker-Labs-ControlNet-Union-Pro-2.0 (controlnet) ---
if [ ! -f "$MODELS_DIR/controlnet/Shakker-Labs-ControlNet-Union-Pro-2.0" ]; then
    echo "📥 Downloading Shakker-Labs-ControlNet-Union-Pro-2.0..."
    wget -q --show-progress -O "$MODELS_DIR/controlnet/Shakker-Labs-ControlNet-Union-Pro-2.0" "https://huggingface.co/Shakker-Labs/FLUX.1-dev-ControlNet-Union-Pro/resolve/main/diffusion_pytorch_model.safetensors"
else
    echo "✅ Shakker-Labs-ControlNet-Union-Pro-2.0 already exists"
fi

# --- clip_l.safetensors (clip) ---
if [ ! -f "$MODELS_DIR/clip/clip_l.safetensors" ]; then
    echo "📥 Downloading clip_l.safetensors..."
    wget -q --show-progress -O "$MODELS_DIR/clip/clip_l.safetensors" "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"
else
    echo "✅ clip_l.safetensors already exists"
fi

# --- t5xxl_fp16.safetensors (clip) ---
if [ ! -f "$MODELS_DIR/clip/t5xxl_fp16.safetensors" ]; then
    echo "📥 Downloading t5xxl_fp16.safetensors..."
    wget -q --show-progress -O "$MODELS_DIR/clip/t5xxl_fp16.safetensors" "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"
else
    echo "✅ t5xxl_fp16.safetensors already exists"
fi

# --- flux1-dev.safetensors (checkpoint) ---
if [ ! -f "$MODELS_DIR/checkpoints/flux1-dev.safetensors" ]; then
    echo "📥 Downloading flux1-dev.safetensors..."
    huggingface-cli download "black-forest-labs/FLUX.1-dev" "flux1-dev.safetensors" --token "$HF_TOKEN" --local-dir "$MODELS_DIR/checkpoints" --local-dir-use-symlinks False
else
    echo "✅ flux1-dev.safetensors already exists"
fi

# --- ae.safetensors (vae) ---
if [ ! -f "$MODELS_DIR/vae/ae.safetensors" ]; then
    echo "📥 Downloading ae.safetensors..."
    huggingface-cli download "black-forest-labs/FLUX.1-dev" "ae.safetensors" --token "$HF_TOKEN" --local-dir "$MODELS_DIR/vae" --local-dir-use-symlinks False
else
    echo "✅ ae.safetensors already exists"
fi

# --- MM008_LyCORIS_DS02A_v1-000024.safetensors (lora) ---
if [ ! -f "$MODELS_DIR/loras/MM008_LyCORIS_DS02A_v1-000024.safetensors" ]; then
    echo "📥 Downloading MM008_LyCORIS_DS02A_v1-000024.safetensors..."
    huggingface-cli download "dvhouw/CLOUD_SYNC" "MM008_LyCORIS_DS02A_v1-000024.safetensors" --token "$HF_TOKEN" --local-dir "$MODELS_DIR/loras" --local-dir-use-symlinks False
else
    echo "✅ MM008_LyCORIS_DS02A_v1-000024.safetensors already exists"
fi

# --- PNF001_LyCORIS_PNFB3TT4S_DS02_v1-000024.safetensors (lora) ---
if [ ! -f "$MODELS_DIR/loras/PNF001_LyCORIS_PNFB3TT4S_DS02_v1-000024.safetensors" ]; then
    echo "📥 Downloading PNF001_LyCORIS_PNFB3TT4S_DS02_v1-000024.safetensors..."
    huggingface-cli download "dvhouw/CLOUD_SYNC" "PNF001_LyCORIS_PNFB3TT4S_DS02_v1-000024.safetensors" --token "$HF_TOKEN" --local-dir "$MODELS_DIR/loras" --local-dir-use-symlinks False
else
    echo "✅ PNF001_LyCORIS_PNFB3TT4S_DS02_v1-000024.safetensors already exists"
fi

echo ""
echo "✅ All models ready!"
echo ""

#!/bin/bash
# Custom start script that downloads models before starting ComfyUI

set -e

echo "=========================================="
echo "  ComfyUI Worker - Model Setup"
echo "=========================================="

# Run the model download script
/download-models.sh

echo ""
echo "=========================================="
echo "  Starting ComfyUI Worker"
echo "=========================================="

# Run the original handler
exec python -u /handler.py

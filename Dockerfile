# RunPod ComfyUI Worker - Automotive Workflow
# Auto-downloads models to network volume on first startup
# Generated from workflow: c8f0944e-6945-4dc2-965f-a89d835d7eb9

FROM runpod/worker-comfyui:5.5.0-base

# Install huggingface-cli for model downloads
RUN pip install -q huggingface_hub

# ============================================
# INSTALL CUSTOM NODES
# ============================================
WORKDIR /comfyui/custom_nodes

# ComfyUI-Advanced-ControlNet
RUN git clone https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git && \
    cd ComfyUI-Advanced-ControlNet && pip install -r requirements.txt || true

# ComfyUI_essentials
RUN git clone https://github.com/cubiq/ComfyUI_essentials.git && \
    cd ComfyUI_essentials && pip install -r requirements.txt || true

# ComfyUI-Custom-Scripts
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git

# comfyui-art-venture
RUN git clone https://github.com/sipherxyz/comfyui-art-venture.git && \
    cd comfyui-art-venture && pip install -r requirements.txt || true

# ComfyUI-Easy-Use
RUN git clone https://github.com/yolain/ComfyUI-Easy-Use.git && \
    cd ComfyUI-Easy-Use && pip install -r requirements.txt || true

# ComfyUI_Comfyroll_CustomNodes
RUN git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git && \
    cd ComfyUI_Comfyroll_CustomNodes && pip install -r requirements.txt || true

WORKDIR /

# ============================================
# CREATE MODEL SYMLINKS TO NETWORK VOLUME
# ============================================
RUN rm -rf /comfyui/models/checkpoints && \
    rm -rf /comfyui/models/vae && \
    rm -rf /comfyui/models/clip && \
    rm -rf /comfyui/models/loras && \
    rm -rf /comfyui/models/controlnet && \
    ln -s /runpod-volume/models/checkpoints /comfyui/models/checkpoints && \
    ln -s /runpod-volume/models/vae /comfyui/models/vae && \
    ln -s /runpod-volume/models/clip /comfyui/models/clip && \
    ln -s /runpod-volume/models/loras /comfyui/models/loras && \
    ln -s /runpod-volume/models/controlnet /comfyui/models/controlnet

# ============================================
# COPY STARTUP SCRIPTS
# ============================================
COPY download-models.sh /download-models.sh
COPY start-with-models.sh /start-with-models.sh
RUN chmod +x /download-models.sh /start-with-models.sh

# ============================================
# START WITH MODEL DOWNLOAD
# ============================================
CMD ["/start-with-models.sh"]

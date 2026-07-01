#!/usr/bin/env sh
# Runs inside the download-model container (see docker-compose.yml). Skips the
# network entirely if the model is already there, so a blocked/offline host can
# still start the stack once the weights have been copied into ./models once.
set -eu

MODEL_ID="${MODEL_ID:-tencent/HunyuanOCR}"
TARGET="/models/${MODEL_DIR:-HunyuanOCR}"

if [ -f "${TARGET}/config.json" ]; then
  echo "Model already present at ${TARGET}, skipping download."
  exit 0
fi

pip install -q -U huggingface_hub
hf download "${MODEL_ID}" --local-dir "${TARGET}"

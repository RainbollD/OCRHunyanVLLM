#!/usr/bin/env sh
# Container entrypoint: downloads the model into /models/$MODEL_DIR if it isn't
# there yet, then hands off to vllm serve. Skips the network entirely once the
# model is present, so a host with no route to Hugging Face can still start
# after the weights were copied into ./models by some other machine.
set -eu

TARGET="/models/${MODEL_DIR:-HunyuanOCR}"

if [ ! -f "${TARGET}/config.json" ]; then
  echo "Model not found at ${TARGET}, downloading ${MODEL_ID:-tencent/HunyuanOCR}..."
  hf download "${MODEL_ID:-tencent/HunyuanOCR}" --local-dir "${TARGET}"
fi

exec vllm serve "${TARGET}" \
  --served-model-name hunyuan-ocr \
  --host 0.0.0.0 \
  --port 8000 \
  --no-enable-prefix-caching \
  --mm-processor-cache-gb 0 \
  --gpu-memory-utilization "${GPU_MEMORY_UTILIZATION:-0.70}" \
  --max-model-len "${MAX_MODEL_LEN:-16384}" \
  --max-num-seqs "${MAX_NUM_SEQS:-2}"

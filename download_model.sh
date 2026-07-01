set -euo pipefail

MODEL_ID="${1:-tencent/HunyuanOCR}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${SCRIPT_DIR}/models/${MODEL_ID#*/}"

if ! command -v hf >/dev/null 2>&1 && ! command -v huggingface-cli >/dev/null 2>&1; then
  echo "huggingface_hub CLI not found, installing..."
  pip install -q -U "huggingface_hub[cli]"
fi

DOWNLOAD_CMD=huggingface-cli
command -v hf >/dev/null 2>&1 && DOWNLOAD_CMD=hf

echo "Downloading ${MODEL_ID} into ${TARGET_DIR} (resumable, safe to re-run)..."
"${DOWNLOAD_CMD}" download "${MODEL_ID}" --local-dir "${TARGET_DIR}"

echo
echo "Done. In .env, set: MODEL_ID=/models/${MODEL_ID#*/}"
echo "Then: docker compose up -d"

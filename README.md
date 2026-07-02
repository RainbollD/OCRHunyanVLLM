# OCR HunyuanOCR (vLLM)

OpenAI-совместимый сервер для модели [HunyuanOCR](https://huggingface.co/tencent/HunyuanOCR)
на базе [vLLM](https://github.com/vllm-project/vllm), запускаемый через Docker Compose.

## Запуск

1. Скопируйте пример конфигурации и при необходимости отредактируйте:

   ```bash
   cp .env.example .env
   ```

2. Поднимите сервис:

   ```bash
   docker compose up -d
   ```

   При первом старте `entrypoint.sh` скачает модель в `./models/HunyuanOCR`
   (несколько минут). Дальше запуски идут без скачивания. Если Hugging Face
   недоступен — можно скопировать веса в `./models/HunyuanOCR` вручную.

3. Дождитесь, пока сервис станет здоровым:

   ```bash
   docker compose ps          # STATUS -> healthy
   docker compose logs -f ocr # смотреть прогресс загрузки/старта
   ```

Сервер слушает на порту из `PORT` (по умолчанию `6969`).

## Проверка

```bash
# health-check
curl http://localhost:6969/health

# список моделей
curl http://localhost:6969/v1/models
```

Распознать текст на картинке (OpenAI-совместимый chat/completions):

```bash
curl http://localhost:6969/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "hunyuan-ocr",
    "messages": [
      {"role": "user", "content": [
        {"type": "text", "text": "Извлеки весь текст с изображения."},
        {"type": "image_url", "image_url": {"url": "https://raw.githubusercontent.com/vllm-project/vllm/main/docs/source/assets/logos/vllm-logo-text-light.png"}}
      ]}
    ]
  }'
```

Локальную картинку передавайте как data URL (`data:image/png;base64,<...>`).

## Остановка

```bash
docker compose down        # остановить
docker compose down -v     # + удалить тома
```

## Настройки (`.env`)

| Переменная                | По умолчанию         | Описание |
|---------------------------|----------------------|----------|
| `VLLM_TAG`                | `v0.24.0`            | Тег образа vLLM (минимум для HunyuanOCR — `v0.12.0`) |
| `MODEL_ID`                | `tencent/HunyuanOCR` | Репозиторий модели на Hugging Face |
| `MODEL_DIR`               | `HunyuanOCR`         | Папка внутри `./models`, куда скачивается модель |
| `PORT`                    | `6969`               | Порт API на хосте |
| `GPU_MEMORY_UTILIZATION`  | `0.6`                | Доля VRAM, которую может занять vLLM |
| `MAX_MODEL_LEN`           | `16384`              | Максимальная длина контекста (vision + prompt + output) |
| `MAX_NUM_SEQS`            | `2`                  | Максимум одновременных запросов |

При нехватке VRAM (OOM) сначала снижайте `MAX_MODEL_LEN` и `MAX_NUM_SEQS`.

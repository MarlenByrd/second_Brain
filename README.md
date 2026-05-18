# Second Brain (local-first)

Локальный AI-ассистент («второй мозг») с фокусом на приватность: ingestion данных, AI-анализ, memory graph, semantic search.

## Что сейчас в репозитории
- Архитектурный blueprint: `architecture.md`
- Документация по структуре/схеме/MVP: `docs/*`
- Прототипы:
  - Telegram ingestion: `services/ingestion-telegram/main.py`
  - Local embeddings: `services/ai-pipeline/embedding_pipeline.py`
  - Semantic search: `services/api/semantic_search.py`
  - Core memory graph engine (Rust): `packages/core-memory/src/lib.rs`
- Локальная инфраструктура: `infra/docker/docker-compose.yml`

## Требования
- macOS/Linux
- Docker + Docker Compose
- Python 3.11+
- (опционально) Rust toolchain

## Быстрый запуск (MVP)

### 1) Поднять локальную инфраструктуру
```bash
./scripts/bootstrap.sh
```

> Если Docker не установлен (ошибка `docker: command not found`), `bootstrap.sh` автоматически запустит локальный web-интерфейс на `http://localhost:4173`.

Проверка статуса:
```bash
docker compose -f infra/docker/docker-compose.yml ps
```

Ожидаемые сервисы:
- `postgres` на `localhost:5432`
- `qdrant` на `localhost:6333`
- `ollama` на `localhost:11434`

### 2) Подтянуть локальную LLM-модель в Ollama
```bash
ollama pull qwen2.5:7b
```

> Можно заменить модель на любую локальную, поддерживаемую вашим железом.

### 3) Подготовить Python окружение
```bash
python -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install sentence-transformers
```

### 4) Проверить прототип Telegram ingestion
Создайте файл `services/ingestion-telegram/sample_telegram_export.json` в формате экспорта Telegram (`messages` array), затем:
```bash
cd services/ingestion-telegram
python main.py
```

Скрипт выведет первые canonical events (id, ts, text, hash).

### 5) Проверить semantic search модуль
Пример запуска в REPL:
```bash
python
```
```python
from services.api.semantic_search import Item, search

items = [
    Item(id="1", text="Talked with Alex about startup", vector=[0.9, 0.1, 0.0]),
    Item(id="2", text="Discussed relocation to Berlin", vector=[0.7, 0.2, 0.1]),
]

query = [0.88, 0.12, 0.0]
print(search(query, items, k=2))
```

### 6) Проверить embedding pipeline
```bash
python
```
```python
import importlib.util
from pathlib import Path

spec = importlib.util.spec_from_file_location("embedding_pipeline", Path("services/ai-pipeline/embedding_pipeline.py"))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
LocalEmbedder = module.LocalEmbedder

embedder = LocalEmbedder()
record = embedder.embed("mem_1", "I discussed a startup idea with Alex")
print(record.memory_id, len(record.vector))
```

## Остановка инфраструктуры
```bash
docker compose -f infra/docker/docker-compose.yml down
```

С удалением volume:
```bash
docker compose -f infra/docker/docker-compose.yml down -v
```

## Диагностика
- Логи сервисов:
```bash
docker compose -f infra/docker/docker-compose.yml logs -f
```
- Если Ollama недоступен, проверьте порт `11434` и наличие запущенного контейнера.
- Если embedding-модуль не стартует, проверьте установку `sentence-transformers` в активном venv.

## Следующий шаг разработки
- Добавить API-слой между ingestion -> AI pipeline -> storage.
- Добавить миграции БД и интеграционные тесты.
- Перевести прототипы в единый локальный daemon workflow.


## Быстрый старт UI без Docker
Если вам нужен сразу интерфейс (без БД/моделей), запустите:
```bash
./scripts/run_ui.sh
```

Откройте в браузере: `http://localhost:4173`


## Lightweight AI профили (чтобы не съедать SSD/RAM)
Для запуска нескольких маленьких локальных "ИИ-агентов" (вместо одной тяжелой модели):

```bash
./scripts/setup_light_models.sh balanced
```

Доступные профили:
- `minimal` — минимальный размер моделей
- `balanced` — рекомендованный
- `multimodal_light` — текст + легкая vision-модель

Детали: `docs/lightweight-ai-strategy.md`, `configs/model-profiles.yaml`.

# Monorepo Structure

```text
second_brain/
  apps/
    macos/                 # SwiftUI + Metal app shell
    ios/                   # iOS companion app
  services/
    api/                   # local API gateway
    ingestion-telegram/    # Telegram connector (Telethon/TDLib)
    ai-pipeline/           # extraction + embeddings + summarization
    sync/                  # LAN sync service
  packages/
    core-memory/           # Rust memory physics + graph scoring
    plugin-sdk/            # connector contract + sandbox boundaries
  infra/
    docker/                # local orchestration compose files
  scripts/
    bootstrap.sh
  docs/
    architecture.md
    tech-decisions.md
    schema.md
    roadmap.md
    mvp-plan.md
```

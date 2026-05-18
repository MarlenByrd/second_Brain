# Tech Decisions

1. **macOS native app: SwiftUI + Metal** for low-latency graph rendering.
2. **Core daemon in Rust** for performance, safety, and concurrency.
3. **Python AI pipeline** for model ecosystem maturity.
4. **PostgreSQL + Qdrant + local graph index** for hybrid retrieval.
5. **Ollama/llama.cpp runtime** for local LLM portability.
6. **Plugin SDK** with strict local permissions and schema contracts.
7. **Tauri deferred**; native UX prioritized over cross-platform.

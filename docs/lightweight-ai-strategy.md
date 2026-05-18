# Lightweight AI Strategy (Low RAM / Low SSD)

This guide defines a multi-agent style architecture using **small specialized local models** instead of one large general model.

## Why this approach
- Lower SSD usage (smaller checkpoints).
- Lower RAM pressure on Apple Silicon.
- Better battery/thermals for always-on background indexing.

## Recommended model topology
1. **Planner/Summarizer LLM**: `qwen2.5:3b` or `qwen2.5:7b`
2. **Embedding model**: `all-MiniLM-L6-v2` or `bge-small-en-v1.5`
3. **Optional Vision model**: `qwen2.5vl:3b` only when image/PDF analysis is needed

## Agent decomposition
- `agent_ingestion_cleaner`: cleans raw messages/files
- `agent_entity_extractor`: extracts people/topics/events
- `agent_memory_summarizer`: writes short + long memory summaries
- `agent_retrieval_ranker`: re-ranks semantic search results
- `agent_graph_linker`: updates relationship weights in graph

All agents can share the same small LLM (3B/7B) with different prompts and token limits.

## Memory-saving settings
- Keep context windows short (4k–8k).
- Chunk text aggressively (400–800 tokens per chunk).
- Run batch jobs incrementally (nightly consolidation).
- Keep only one heavy model loaded at a time.
- Disable vision model unless needed.

## Quick setup
```bash
./scripts/setup_light_models.sh minimal
# or
./scripts/setup_light_models.sh balanced
# or
./scripts/setup_light_models.sh multimodal_light
```

## Practical default for your case
Use `balanced` first. Move to `minimal` if you see memory pressure, or `multimodal_light` if you work with screenshots/documents regularly.

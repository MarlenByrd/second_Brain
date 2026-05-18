# Second Brain — System Architecture (Local-Only, Offline-First)

## 1) Product Direction
Second Brain is a native **macOS-first memory OS** with an iOS companion. All data capture, indexing, inference, graph updates and retrieval run locally.

### Core Principles
- **Zero cloud dependency** for user content.
- **Privacy-by-design**: encryption-at-rest, biometric unlock, no telemetry.
- **Neural memory UX**: interactive graph as primary interface.
- **Performance on Apple Silicon**: Metal rendering + incremental AI pipeline.
- **Modular integrations**: Telegram now, extensible plugin ingestion framework later.

## 2) High-Level Architecture

```text
[macOS SwiftUI App] --XPC--> [Local Core Daemon (Rust)]
                                  |
                                  +--> PostgreSQL (metadata/events/entities)
                                  +--> Qdrant (embeddings/vector search)
                                  +--> Graph Store (RocksDB adjacency + graph index)
                                  +--> Local Model Runtime (Ollama/llama.cpp)
                                  +--> Ingestion Workers (Telegram, Files, Calendar...)
                                  +--> Sync Service (LAN peer sync with iOS)

[iOS Companion App] <--local encrypted sync--> [Local Core Daemon]
```

## 3) Components
- **macOS App (SwiftUI + Metal):** Neural Map, Timeline, People, Search, Settings.
- **Core Daemon (Rust):** orchestration, policy engine, plugin host, job queue.
- **AI Pipeline (Python microservice local):** extraction, embeddings, clustering, summarization.
- **Storage Layer:**
  - PostgreSQL (events, memories, entities, users, relations metadata)
  - Qdrant (chunk vectors)
  - Graph engine (weighted dynamic graph + activation cache)
- **Ingestion Layer:** source adapters + normalization.
- **Sync Layer:** peer-to-peer local network sync, conflict-free merge (CRDT-inspired records).

## 4) Data Flow
1. Connector ingests raw record.
2. Normalizer maps to canonical event schema.
3. Dedup/entity resolver merges or creates entities.
4. Embedding pipeline chunks and indexes semantic vectors.
5. Graph engine upserts nodes/edges and recomputes relation weights.
6. Memory physics engine updates decay/reinforcement.
7. UI queries feed/search/graph APIs and animates activation paths.

## 5) AI Pipeline
- **Models:** local-only via Ollama/llama.cpp (Mistral/Llama/Qwen).
- **Stages:**
  1) Language detection + PII tagging
  2) Entity/relation extraction
  3) Topic classification + sentiment/emotional score
  4) Summary generation (short + long)
  5) Embedding generation (`all-MiniLM` or multilingual equivalent)
  6) Link prediction + hidden association scoring

## 6) Memory Physics Model
`score = w_i*importance + w_r*recency + w_e*emotional + w_f*frequency + w_c*context`

- **Decay:** exponential half-life by memory type.
- **Reinforcement:** score boosts on recall, repeated mentions, downstream relevance.
- **Spreading activation:** BFS/priority propagation over weighted edges with attenuation.
- **Consolidation:** move stable high-value clusters to long-term memory summaries.

## 7) Neural Graph Engine
- Weighted multigraph: `Person, Event, Topic, Place, Artifact, Conversation` nodes.
- Edge weights recomputed from semantic similarity + temporal proximity + co-occurrence + emotional affinity.
- Algorithms:
  - Louvain clustering
  - Personalized PageRank for importance
  - A* / Dijkstra for thought trails
  - Incremental community updates per ingestion batch

## 8) Security
- SQLCipher/PG encryption strategy + filesystem encryption support.
- Key material in macOS Keychain/Secure Enclave.
- Biometric unlock gate for app + daemon APIs.
- Sandboxed connectors with least privilege.

## 9) Offline Sync (macOS <-> iOS)
- Local-only transport: mDNS discovery + TLS on LAN.
- Per-record vector clocks + merge policy.
- Encrypted replication bundles.
- iOS primarily reads/searches; optional capture (voice, notes).

## 10) MVP Scope
- Telegram import + incremental sync.
- Canonical memory/event schema.
- Embeddings + semantic search endpoint.
- People cards with summaries.
- Basic neural map rendering with activation highlight.

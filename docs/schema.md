# Database Schema (MVP)

## PostgreSQL
- `sources(id, type, account_ref, created_at)`
- `events(id, source_id, external_id, event_type, ts, payload_json, hash, created_at)`
- `memories(id, event_id, text, summary_short, summary_long, importance, emotional_score, created_at)`
- `entities(id, kind, canonical_name, aliases_json, confidence, created_at)`
- `memory_entities(memory_id, entity_id, role, confidence)`
- `relations(id, src_entity_id, dst_entity_id, relation_type, weight, evidence_json, updated_at)`
- `embeddings(id, memory_id, vector_ref, model, dim, created_at)`

## Vector DB (Qdrant)
- collection: `memory_chunks`
- payload: `{memory_id, ts, source_type, entity_ids, importance}`

## Graph Store
- node key: `type:id`
- edge: `(src, dst, weight, last_update, features)`
- materialized activation cache for UI.

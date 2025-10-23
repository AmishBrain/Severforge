# ⚙️ Severforge Command Verbs

Each **verb** maps to a specific automation action inside the Forge ecosystem.  
Think of these as *spoken runes* — concise, auditable commands that drive the forge.

| Verb | Description | Script Path | Notes |
|------|--------------|--------------|-------|
| `sf_status` | Check system health, uptime, and integrity | `scripts/sf_status` | Displays version, forge mood, and directory verification |
| `sf_sanitize` | Clean up temp, cache, or residue | `scripts/sanitize.sh` | Optional pre-push hygiene |
| `sf_hash` | Generate cryptographic evidence manifest | `scripts/evidence_hash.py` | Produces `hash_manifest.json` |
| `sf_watch` | Start the forge heartbeat and reactive watcher | `ops/watcher.sh` | Monitors `/evidence` and `/logs` |
| `sf_push` | Commit + push to GitHub with signed metadata | `ops/pipeline.sh` | (Coming soon) Auto-includes hash and log signatures |
| `sf_init` | Initialize directories and config baseline | `scripts/setup_env.sh` | Run once at environment creation |

---

### 🧠 Design Notes

- Verbs are short and human-readable.  
- Each maps to one physical file under `/scripts` or `/ops`.  
- Future AI-integrated verbs (e.g. `sf_analyze`, `sf_reflect`) will live under `/ai/`.  

“Speak only the verb. The Forge knows the rest.” 🔥

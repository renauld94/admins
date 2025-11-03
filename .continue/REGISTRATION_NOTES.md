# Mistral model registration notes

Date: 2025-11-02

Summary
-------

- GGUF downloaded and staged under `/mnt/newdisk/models/mistral-7b-v0.1/mistral-7b-v0.1.gguf`.
- Copies were placed at:
  - `/opt/openwebui-data/models/mistral-7b-v0.1.gguf`
  - `/opt/ollama/models/mistral-7b-v0.1.gguf`
  - `/mnt/newdisk/ollama_models/mistral-7b-v0.1.gguf` (staging)

What succeeded
--------------

- The Ollama manifest/blob registration steps completed and `ollama list` shows `mistral-7b-v0.1:latest`.
- OpenWebUI restarted on host port 3001 and `http://127.0.0.1:3001/health` returned `{"status":true}`.
- Remote `/tmp` was cleaned of temporary leftover files and journal vacuumed to free space.

Observed failure when running inference
-------------------------------------

- A quick `ollama run` test failed with:

  Error: 500 Internal Server Error: unable to load model: /root/.ollama/models/blobs/sha256-310ed52d33df0bcb5432c47aa5ca9b35a858e3cee2066ca352a3874fbf42b01e

- Container logs show the loader scanned GGUF metadata but failed with:

  llama_model_load: error loading model: error loading model vocabulary: _Map_base::at

  (loader printed metadata/kv pairs and file format = GGUF V3 (latest), file type = Q4_0)

Interpretation and next actions
--------------------------------

- The GGUF is readable (metadata parsed) but Ollama failed while loading the tokenizer/vocab. This is likely a model-format or tokenizer mismatch for the Ollama runtime.
- Options to recover:
  1. Try a different, Ollama-validated GGUF or pull the same model from an Ollama registry (if available).

 2. Attempt a model conversion using a recommended tool (only if you trust the source) to an Ollama-compatible blob format.
 3. Re-download a different community GGUF variant (some community builds strip/alter KV fields that Ollama expects).
 4. If you want me to continue experimenting, I can try an alternative GGUF source and re-run registration.

Disk and housekeeping notes
---------------------------

- Root (`/`) LV is full (30G, 100% use). `/var` is the largest top-level directory (~18G).
- We freed space by removing large temp files and vacuuming journal (~195MB freed), but the root FS still needs attention.

Suggested safe housekeeping commands
----------------------------------
Run these manually or ask me to execute them (I avoided destructive pruning without explicit confirmation):

```bash
sudo apt-get clean
sudo journalctl --vacuum-size=200M
sudo du -xh --max-depth=1 / | sort -rh | head -n 30
# Review outputs and then optionally:
# sudo docker image prune -af --volumes   # destructive: removes unused images/containers/volumes
```

Files created/edited
--------------------

- Copied GGUF to `/opt/openwebui-data/models` and `/opt/ollama/models` (root-owned, 0644).
- Edited compose at `/opt/ollama-stack/docker-compose.vm159.yml` to map `3001:8080` for OpenWebUI.

Logs & artifacts
----------------

- Remote register script run captured at `/tmp/register_mistral_remote.log` (note: earlier the remote /tmp was full and tee failed; some logs may be partial).

Next recommended steps (pick one)
--------------------------------

1) Try an alternative GGUF build (I can fetch and test a different community GGUF).
2) If you have an Ollama-hosted model repo, try `ollama pull <model>` instead of manual registration.
3) Triage the tokenizer error by testing other GGUFs or contacting the GGUF provider for compatibility notes.
4) Clean up /var (review large subdirs) or expand the root LV.

If you want me to continue, say which of the Next steps above to attempt and I'll proceed.

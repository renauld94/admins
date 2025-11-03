# RUNBOOK — Importing Mistral into Ollama (GGUF / Safetensors)

This runbook walks through safe, repeatable steps to import a Mistral-family model into Ollama when the model isn't available to `ollama pull` from the registry. It covers authenticated Hugging Face downloads, local uploads, Modelfile creation, `ollama create`, quantization options, smoke tests and cleanup.

## Assumptions & paths
- Host model store: `/mnt/newdisk/ollama_models`
- Bind-mounted inside container: `/opt/ollama/models` (already configured)
- Recommended import directory for this operation:

  /mnt/newdisk/ollama_models/imports/mistral-7b

  This path will be visible inside the Ollama container at `/opt/ollama/models/imports/mistral-7b`.

## Quick pre-checks (run on VM)

Check free space and inodes:

```bash
df -h /mnt/newdisk
df -i /mnt/newdisk
du -sh /mnt/newdisk/ollama_models || true
ls -lh /opt/ollama/models/manifests/registry.ollama.ai/library || true
```

We observed ~50 GiB free in the environment tested. If the model artifact is larger than free space, either extend storage or use another machine with more disk.

## Option A — Download directly from Hugging Face (requires HF token for private/restricted repos)

1) Add your Hugging Face token to the environment on the VM (safer than pasting in chat):

```bash
# on the host, export HF token for the current shell only
export HF_TOKEN="hf_<redacted>"

# or place in a file and source it, or set in systemd service for short-lived use
```

2) Query model file list and sizes (authenticated):

```bash
curl -H "Authorization: Bearer $HF_TOKEN" -s \
  https://huggingface.co/api/models/<owner>/<repo> | jq '.siblings[] | {rfilename,name,size}'
```

Pick the file(s) you want. Prefer GGUF if available (single-file .gguf is simplest). Otherwise choose safetensors (may be split into multiple files or be an adapter).

3) Estimate total bytes required and confirm free space. Example to sum sizes in the JSON:

```bash
curl -H "Authorization: Bearer $HF_TOKEN" -s \
  https://huggingface.co/api/models/<owner>/<repo> | jq '[.siblings[] | select(.rfilename|test("gguf|safetensors|\.bin|pytorch")) | .size] | add'
```

4) Download chosen artifact(s) into the import directory:

```bash
mkdir -p /mnt/newdisk/ollama_models/imports/mistral-7b
cd /mnt/newdisk/ollama_models/imports/mistral-7b

# Example: download single file with auth
curl -L -H "Authorization: Bearer $HF_TOKEN" \
  -o model.gguf \
  "https://huggingface.co/<owner>/<repo>/resolve/main/<filename.gguf>"

# Example: download safetensors file(s)
curl -L -H "Authorization: Bearer $HF_TOKEN" \
  -o weights.safetensors \
  "https://huggingface.co/<owner>/<repo>/resolve/main/<safetensors-file>"
```

Notes:
- For large files you can use `aria2c` for parallel segmented downloads; however HF may rate-limit.
- If the model is published as multiple shards, download all shards into the same directory.

## Option B — Upload artifacts directly to the VM (you already have the files)

From your workstation:

```bash
ssh -i /path/to/key simonadmin@10.0.0.110 'mkdir -p /mnt/newdisk/ollama_models/imports/mistral-7b && chmod 755 /mnt/newdisk/ollama_models/imports/mistral-7b'
scp -i /path/to/key /local/path/to/model.gguf simonadmin@10.0.0.110:/mnt/newdisk/ollama_models/imports/mistral-7b/
```

Then confirm on the VM:

```bash
ls -lh /mnt/newdisk/ollama_models/imports/mistral-7b
```

## If you downloaded safetensors and prefer GGUF

Ollama accepts GGUF; it also accepts safetensors when used with a Modelfile pointing at the directory. If you want to convert safetensors -> GGUF you can use the Llama.cpp conversion tools such as `convert_hf_to_gguf.py`. Example (requires Llama.cpp tools installed):

```bash
# on a system with appropriate tools (may be CPU/GPU heavy depending on format)
python3 convert_hf_to_gguf.py --safetensors /path/to/weights.safetensors --outfile model.gguf
```

If you cannot convert in place, you can import safetensors directly using Modelfile pointing at the directory — Ollama will accept safetensors directories.

## Create a Modelfile

Place a `Modelfile` in the import directory (examples in `Modelfile.examples`). Minimal examples:

Single-file GGUF (Modelfile in same directory):

```
FROM .
```

If you want to explicitly reference the file:

```
FROM /mnt/newdisk/ollama_models/imports/mistral-7b/model.gguf
```

Adapter example (safetensors adapter):

```
FROM <base-model-name>
ADAPTER /mnt/newdisk/ollama_models/imports/mistral-7b/adapter.safetensors
```

## Build the model with Ollama

Run inside the host (makes the model visible to the Ollama container):

```bash
# ensure files are readable
chmod -R a+r /mnt/newdisk/ollama_models/imports/mistral-7b

# Run ollama create from the container (container sees /mnt/newdisk at /opt/ollama/models)
docker exec ollama sh -c 'cd /opt/ollama/models/imports/mistral-7b && ollama create mistral-7b-local'

# Optional: add quantization to reduce memory
docker exec ollama sh -c 'cd /opt/ollama/models/imports/mistral-7b && ollama create --quantize q4_K_M mistral-7b-local-quant'
```

Notes on quantization:
- Quantizing reduces memory but takes CPU time at create time. Try q4_K_M or q4_0 for different tradeoffs.

## Smoke test

Once `ollama create` finishes, run a quick smoke test:

```bash
docker exec ollama sh -c 'ollama run mistral-7b-local "Xin chào" --json'
```

Confirm the model returns usable text and that the watcher (if deployed) logs completion.

## Finalize ownership & cleanup

```bash
sudo chown -R simonadmin:simonadmin /mnt/newdisk/ollama_models/imports/mistral-7b
# optional: remove HF_TOKEN from the shell or environment
unset HF_TOKEN
```

## Troubleshooting

- `curl` or HF API returning 401: your token is missing or insufficient. Create a token at https://huggingface.co/settings/tokens and ensure it has `read` scope.
- Not enough free disk: extend VM disk or use a remote machine with larger storage.
- `ollama create` fails with file-format errors: ensure the Modelfile points at the correct format and all expected shards are present.
- If the container cannot access `/mnt/newdisk`, verify the bind-mount at `/opt/ollama/models` in `/etc/fstab` and restart container.

## Quick checklist before heavy download

1. Confirm free space: `df -h /mnt/newdisk` (need model size + ~10% buffer)
2. Confirm inodes: `df -i /mnt/newdisk`
3. Confirm destination dir: `mkdir -p /mnt/newdisk/ollama_models/imports/mistral-7b`
4. Download/upload the artifact(s)
5. Create Modelfile, run `ollama create`, smoke test, chown

---
If you want, I can now (choose):
- A: run the authenticated HF metadata query for a repo you name (I will ask you to set HF_TOKEN on the VM or paste token), then download and import automatically; or
- B: wait for you to upload files and I will complete the Modelfile + `ollama create` step; or
- C: produce a short command script I can run to do the whole flow with the HF token already set on the VM.

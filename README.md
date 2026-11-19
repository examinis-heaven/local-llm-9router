# local-llm-9router

Server API lokal berbasis [`llama.cpp`](https://github.com/ggml-org/llama.cpp) (`llama-server.exe` Vulkan GPU) yang menjalankan beberapa model GGUF ringan dari satu endpoint OpenAI-compatible (`http://127.0.0.1:8080/v1`) dengan **auto-swap VRAM**, dioptimalkan untuk GPU 4 GB VRAM (seperti NVIDIA RTX 2050) dan siap dihubungkan ke **9Router**.

## Fitur Utama
- **Multi-Model Router Mode (`--models-dir` + `--models-max 1`)**: Semua file `.gguf` di folder `models/` otomatis terdaftar di `/v1/models` dan di-load/unload bergantian secara otomatis di VRAM.
- **Hemat VRAM & Context Besar**: Menggunakan `-ngl 99`, `-c 32768` (32K context), `-np 1`, `-ctk q8_0 -ctv q8_0` (KV cache terkuantisasi Q8), dan `-fa on` (Flash Attention).
- **Siap untuk 9Router & Agent (Hermes, Cursor, Cline, dll.)**: Mendukung `--jinja` untuk chat template, reasoning, dan tool calling.

## Daftar Model yang Didukung & Teruji
Letakkan file `.gguf` berikut di folder `models/` (tidak ikut di-commit ke Git karena ukuran file besar):

| Model ID | Sumber Hugging Face | Ukuran | Catatan |
|---|---|---:|---|
| `LFM3-1.7B-Q4_K_M` | [`LiquidAI/LFM3-1.7B-GGUF`](https://huggingface.co/LiquidAI/LFM3-1.7B-GGUF) | ~1.05 GB | Cepat, mendukung reasoning & tool-calling |
| `MiniCPM5-2B-Q4_K_M` | [`openbmb/MiniCPM5-2B-GGUF`](https://huggingface.co/openbmb/MiniCPM5-2B-GGUF) | ~1.49 GB | Sangat cepat & responsif |
| `Qwen3.5-2B-Q4_K_M` | [`unsloth/Qwen3.5-2B-GGUF`](https://huggingface.co/unsloth/Qwen3.5-2B-GGUF) | ~1.22 GB | Akurasi tinggi & multibahasa |
| `Qwen3.5-0.8B-Q4_0` | [`unsloth/Qwen3.5-0.8B-GGUF`](https://huggingface.co/unsloth/Qwen3.5-0.8B-GGUF) | ~484 MB | Ultra-ringan (reasoning) |
| `Qwen3-1.7B-Q4_0` | [`unsloth/Qwen3-1.7B-GGUF`](https://huggingface.co/unsloth/Qwen3-1.7B-GGUF) | ~1.01 GB | Stabil untuk tugas umum |
| `Qwen3-0.6B-Q4_0` | [`unsloth/Qwen3-0.6B-GGUF`](https://huggingface.co/unsloth/Qwen3-0.6B-GGUF) | ~364 MB | Paling ringan & instan |
| `LFM2.5-1.2B-Instruct-Q4_0` | [`LiquidAI/LFM2.5-1.2B-Instruct-GGUF`](https://huggingface.co/LiquidAI/LFM2.5-1.2B-Instruct-GGUF) | ~664 MB | Ringan tanpa reasoning panjang |

## Cara Setup
1. Jalankan `setup.bat` (atau `.\setup.ps1` di PowerShell) untuk otomatis mengunduh `llama-server.exe` (Vulkan `b12521`) ke `bin/` dan ke-7 model `.gguf` ke `models/`.
2. Jalankan server dengan klik dua kali `start-api.bat` atau lewat PowerShell:
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\start-api.ps1
   ```
3. Cek daftar model aktif di `http://127.0.0.1:8080/v1/models`.

## Menghubungkan ke 9Router
1. Jalankan `9router` dan buka dashboard (`http://localhost:20128`).
2. Masuk ke **Providers → Custom Providers → Add Custom Provider**:
   - **Type**: `openai-compatible`
   - **API Type**: `chat` *(gunakan `chat`, bukan `responses`)*
   - **Name**: `local-ai`
   - **Prefix**: `local`
   - **Base URL**: `http://127.0.0.1:8080/v1`
3. Tambahkan **Connection** dengan API Key bebas (misalnya `local-key`).
4. Panggil model melalui 9Router (`http://localhost:20128/v1`) dengan format `<prefix>/<Model ID>`, contohnya `local/LFM3-1.7B-Q4_K_M` atau `local/MiniCPM5-2B-Q4_K_M`.

## Lisensi
Proyek ini menggunakan lisensi [MIT](LICENSE).

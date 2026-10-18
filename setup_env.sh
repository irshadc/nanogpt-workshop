#!/usr/bin/env bash
# ==============================================================================
# NanoGPT Workshop - Environment Setup (Linux & macOS)
# Minimal CPU-only setup using NumPy and PyTorch (Python 3.13)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== [1/4] Detecting Python 3.13 ==="
PYTHON_CMD=""

if command -v uv >/dev/null 2>&1; then
    USE_UV=1
    echo "[+] Found uv: $(uv --version)"
else
    USE_UV=0
    echo "[!] uv not found. Falling back to standard python / pip tooling."
fi

# Detect Python 3.13 for standard fallback or direct invocation
if command -v python3.13 >/dev/null 2>&1; then
    PYTHON_CMD="python3.13"
elif command -v python3 >/dev/null 2>&1 && python3 -c 'import sys; sys.exit(0 if sys.version_info[:2] == (3, 13) else 1)' 2>/dev/null; then
    PYTHON_CMD="python3"
elif command -v py >/dev/null 2>&1 && py -3.13 -c 'import sys; sys.exit(0)' 2>/dev/null; then
    PYTHON_CMD="py -3.13"
fi

if [ -n "$PYTHON_CMD" ]; then
    echo "[+] Detected local Python: $($PYTHON_CMD --version)"
fi

echo "=== [2/4] Creating Virtual Environment (.venv) ==="
if [ "$USE_UV" -eq 1 ]; then
    echo "[+] Creating virtual environment with uv for Python 3.13..."
    if [ -n "$PYTHON_CMD" ]; then
        uv venv --allow-existing --python "$PYTHON_CMD" .venv
    else
        uv venv --allow-existing --python 3.13 .venv
    fi
else
    if [ -z "$PYTHON_CMD" ]; then
        echo "[-] Error: Python 3.13 is required but neither 'python3.13' nor 'uv' (with Python 3.13) was found."
        echo "    Please install Python 3.13 or uv (https://docs.astral.sh/uv/)."
        exit 1
    fi
    echo "[+] Creating virtual environment using $PYTHON_CMD -m venv .venv..."
    $PYTHON_CMD -m venv .venv
fi

echo "=== [3/4] Activating Virtual Environment ==="
# shellcheck disable=SC1091
source .venv/bin/activate
echo "[+] Active Python: $(python --version)"

echo "=== [4/4] Installing CPU Dependencies ==="
OS_TYPE="$(uname -s)"
case "$OS_TYPE" in
    Linux*)
        echo "[+] Detected Linux OS. Installing from requirements-linux-cpu.txt..."
        if [ "$USE_UV" -eq 1 ]; then
            uv pip install -r requirements-linux-cpu.txt --index-strategy unsafe-best-match
        else
            python -m pip install --upgrade pip
            python -m pip install -r requirements-linux-cpu.txt
        fi
        ;;
    Darwin*|MINGW*|MSYS*|CYGWIN*)
        echo "[+] Detected macOS/Unix-like ($OS_TYPE). Installing from requirements.txt..."
        if [ "$USE_UV" -eq 1 ]; then
            uv pip install -r requirements.txt
        else
            python -m pip install --upgrade pip
            python -m pip install -r requirements.txt
        fi
        ;;
    *)
        echo "[!] Unrecognized OS ($OS_TYPE). Defaulting to requirements.txt..."
        if [ "$USE_UV" -eq 1 ]; then
            uv pip install -r requirements.txt
        else
            python -m pip install --upgrade pip
            python -m pip install -r requirements.txt
        fi
        ;;
esac

echo ""
echo "=== Environment Setup Completed Successfully! ==="
echo "To activate manually in your terminal, run:"
echo "    source .venv/bin/activate"

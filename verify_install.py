"""Verification script for NanoGPT workshop runtime environment.

Validates:
- Imports numpy and torch
- Prints versions and active python executable
- Verifies CUDA is NOT available (CPU-only requirement)
- Performs a basic CPU matrix multiplication tensor test
"""
import sys
import numpy as np
import torch

def verify() -> None:
    print(f"[+] Python executable: {sys.executable}")
    print(f"[+] Python version:    {sys.version.split()[0]}")
    print(f"[+] NumPy version:     {np.__version__}")
    print(f"[+] PyTorch version:   {torch.__version__}")

    # Verify CPU-only build / CUDA unavailable
    cuda_available = torch.cuda.is_available()
    print(f"[+] torch.cuda.is_available(): {cuda_available}")
    assert not cuda_available, "Expected CPU-only setup, but CUDA is reported as available!"

    # Matrix multiplication CPU tensor test
    a = torch.tensor([[1.0, 2.0], [3.0, 4.0]], device="cpu")
    b = torch.tensor([[5.0, 6.0], [7.0, 8.0]], device="cpu")
    c = torch.matmul(a, b)
    expected = np.array([[19.0, 22.0], [43.0, 50.0]], dtype=np.float32)

    np.testing.assert_allclose(c.numpy(), expected, rtol=1e-5)
    print(f"[+] Tensor CPU matmul test passed successfully: \n{c}")
    print("\n[SUCCESS] Runtime environment verified and ready for NanoGPT workshop!")

if __name__ == "__main__":
    verify()

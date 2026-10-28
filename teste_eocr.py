# teste_eocr.py — executa run_eocr() isoladamente, com diagnóstico de crash nativo
import faulthandler
import sys
import time
import platform

# Se houver crash nativo, imprime a pilha de chamadas no stderr
faulthandler.enable(all_threads=True)

# Se travar (sem crash), despeja a pilha após 120s
faulthandler.dump_traceback_later(120, repeat=False)

print("Python:", sys.version)
print("Plataforma:", platform.platform())

import numpy as np
print("NumPy:", np.__version__)

import cv2
print("OpenCV:", cv2.__version__)

import torch
print("PyTorch:", torch.__version__, "| threads:", torch.get_num_threads())

import easyocr
print("EasyOCR:", easyocr.__version__)

try:
    import psutil
    mem = psutil.virtual_memory()
    print(f"RAM total: {mem.total/1e9:.1f} GB | disponível: {mem.available/1e9:.1f} GB")
except ImportError:
    print("psutil não instalado (opcional): pip install psutil")

if len(sys.argv) < 2:
    print("\nUso: python teste_eocr.py caminho\\da\\imagem.png")
    sys.exit(1)

caminho = sys.argv[1]

img = cv2.imread(caminho)
if img is None:
    print("ERRO: cv2.imread não conseguiu abrir a imagem.")
    sys.exit(1)
h, w = img.shape[:2]
print(f"\nImagem: {w}x{h} px ({w*h/1e6:.1f} MP)")

print("\nImportando eocr.eocr_engine (carrega o Reader)...", flush=True)
t0 = time.time()
from eocr.eocr_engine import run_eocr
print(f"Reader carregado em {time.time()-t0:.1f}s", flush=True)

print("Executando run_eocr()...", flush=True)
t0 = time.time()
try:
    regioes = run_eocr(caminho)
    print(f"OK: {len(regioes)} regiões em {time.time()-t0:.1f}s")
    for r in regioes[:5]:
        print(" -", r["text"], f"({r['confidence']:.2f})")
except Exception as e:
    import traceback
    print("EXCEÇÃO PYTHON capturada:")
    traceback.print_exc()
    sys.exit(2)
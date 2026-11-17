from pathlib import Path
import os

import cv2
import easyocr
import numpy as np
import torch
torch.set_num_threads(1)

PROJECT_ROOT = Path(__file__).resolve().parents[1]
MODEL_DIR = PROJECT_ROOT / "models" / "easyocr"

# Garante que a pasta de modelos existe no servidor
os.makedirs(MODEL_DIR, exist_ok=True)

# Maior lado da imagem enviada ao EasyOCR (reduz muito o uso de memória)
MAX_LADO_OCR = 1280

# dentro de run_eocr
results = reader.readtext(img_ocr, canvas_size=1280, batch_size=1)

# Criado uma única vez, no topo do arquivo, fora de qualquer função.
# Se os modelos não existirem na pasta, o EasyOCR baixa automaticamente.
reader = easyocr.Reader(
    ["pt"],
    gpu=False,
    model_storage_directory=str(MODEL_DIR),
    download_enabled=True
)


def run_eocr(image_path):
    # lê a imagem do disco
    img = cv2.imread(str(image_path))

    if img is None:
        raise ValueError(f"Não foi possível ler a imagem: {image_path}")

    # reduz a imagem se for muito grande, para não estourar a memória
    altura, largura = img.shape[:2]
    escala = min(1.0, MAX_LADO_OCR / max(altura, largura))

    if escala < 1.0:
        img_ocr = cv2.resize(
            img,
            (int(largura * escala), int(altura * escala)),
            interpolation=cv2.INTER_AREA
        )
    else:
        img_ocr = img

    # identifica os textos na imagem (já redimensionada)
    results = reader.readtext(img_ocr)

    # cria uma lista para guardar as informações dos textos
    text_regions = []

    # passa por cada texto
    for (bbox, text, prob) in results:

        # devolve as coordenadas para o tamanho ORIGINAL da imagem,
        # assim o resto do sistema continua usando as mesmas posições
        pts = (np.array(bbox, dtype=np.float32) / escala).astype(np.int32)

        # encontra um retângulo simples que envolve o texto
        x, y, w, h = cv2.boundingRect(pts)

        # encontra o menor retângulo que consegue envolver o texto
        rect = cv2.minAreaRect(pts)

        # pega o centro, tamanho e ângulo da região do texto
        (cx, cy), (width, height), angle = rect

        # guarda todas as informações encontradas sobre o texto
        text_regions.append({
            "text": text,
            "confidence": float(prob),
            "bbox": pts,
            "rect_box": (x, y, w, h),
            "center": (float(cx), float(cy)),
            "size": (float(width), float(height)),
            "angle": float(angle)
        })

    # retorna todas as regiões de texto
    return text_regions
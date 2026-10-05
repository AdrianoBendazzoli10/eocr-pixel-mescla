from pathlib import Path

import cv2
import easyocr
import numpy as np


PROJECT_ROOT = Path(__file__).resolve().parents[1]
MODEL_DIR = PROJECT_ROOT / "models" / "easyocr"

MODELOS_OBRIGATORIOS = [
    MODEL_DIR / "craft_mlt_25k.pth",
    MODEL_DIR / "latin_g2.pth",
]

faltando = [
    str(caminho.name)
    for caminho in MODELOS_OBRIGATORIOS
    if not caminho.exists()
]

if faltando:
    raise RuntimeError(
        "Modelos do EasyOCR não encontrados: "
        + ", ".join(faltando)
        + ". Execute setup.bat na raiz do projeto."
    )


reader = easyocr.Reader(
    ["pt", "en"],
    gpu=False,
    model_storage_directory=str(MODEL_DIR),
    download_enabled=False
)


def run_eocr(image_path):

    # lê a imagem e identifica os textos dela
    results = reader.readtext(image_path)

    # cria uma lista para guardar as informações dos textos
    text_regions = []

    # passa por cada texto
    for (bbox, text, prob) in results:

        # transforma os pontos da região do texto em um formato que o opencv entende
        pts = np.array(bbox, dtype=np.int32)

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

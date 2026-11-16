
=======
FROM python:3.12-slim

# Instala apenas o Tesseract com idioma português e bibliotecas mínimas do OpenCV
RUN apt-get update && apt-get install -y --no-install-recommends \
    tesseract-ocr \
    tesseract-ocr-por \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instala as dependências (já puxando o torch CPU-only do requirements.txt)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN apt-get update && apt-get install -y --no-install-recommends curl unzip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app/models/easyocr && cd /app/models/easyocr \
 && curl -L -o craft.zip https://github.com/JaidedAI/EasyOCR/releases/download/pre-v1.1.6/craft_mlt_25k.zip \
 && curl -L -o latin.zip https://github.com/JaidedAI/EasyOCR/releases/download/v1.3/latin_g2.zip \
 && unzip -o craft.zip && unzip -o latin.zip \
 && rm -f craft.zip latin.zip \
 && ls -la /app/models/easyocr

# Copia o código e os pesos do EasyOCR (models/easyocr)
COPY . .



# Cria as pastas de trabalho em tempo de execução
RUN mkdir -p temp results reports

ENV PORT=8080
ENV PYTHONUNBUFFERED=1

# 1 worker para não duplicar o EasyOCR na memória RAM
>>>>>>> b6b45fa (Permite download automatico dos modelos do EasyOCR no Railway):dockerfile
CMD gunicorn app:app --bind 0.0.0.0:${PORT} --workers 1 --threads 2 --timeout 180
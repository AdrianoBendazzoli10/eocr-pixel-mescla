FROM python:3.12-slim

# Instala Tesseract (português), dependências do OpenCV, curl e unzip
RUN apt-get update && apt-get install -y --no-install-recommends \
    tesseract-ocr \
    tesseract-ocr-por \
    libgl1 \
    libglib2.0-0 \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instala as dependências Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Baixa e extrai os modelos do EasyOCR diretamente na imagem
RUN mkdir -p /app/models/easyocr && cd /app/models/easyocr \
    && curl -L -o craft.zip https://github.com/JaidedAI/EasyOCR/releases/download/pre-v1.1.6/craft_mlt_25k.zip \
    && curl -L -o latin.zip https://github.com/JaidedAI/EasyOCR/releases/download/v1.3/latin_g2.zip \
    && unzip -o craft.zip && unzip -o latin.zip \
    && rm -f craft.zip latin.zip

# Copia o restante do código do projeto
COPY . .

# Cria as pastas de trabalho
RUN mkdir -p temp results reports

ENV PORT=8080
ENV PYTHONUNBUFFERED=1

# 1 worker para não duplicar o EasyOCR na memória RAM
CMD gunicorn app:app --workers 1 --threads 2 --timeout 300 --bind 0.0.0.0:$PORT
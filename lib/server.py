import os
import io
import re
from flask import Flask, request, jsonify
from flask_cors import CORS
import pytesseract
from PIL import Image
from google.cloud import vision
from google.oauth2 import service_account
import cv2
import numpy as np

# إعداد Google Vision credentials
CREDENTIAL_PATH = "manhal-457713-da87d830d727.json"
credentials = service_account.Credentials.from_service_account_file(CREDENTIAL_PATH)
client = vision.ImageAnnotatorClient(credentials=credentials)

# إعداد Flask
app = Flask(__name__)
CORS(app)

# إعداد Tesseract
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
os.environ['TESSDATA_PREFIX'] = r'C:\Program Files\Tesseract-OCR\tessdata_best'

# دالة تنظيف النص
def clean_text(text):
    return re.sub(r'[^\u0621-\u064A\u0660-\u0669\s]', '', text).strip()

# تحسين الصورة بتقنيات أقوى
def preprocess_image(image_path):
    img = cv2.imread(image_path)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    # تحسين التباين بطريقة أقوى:
    _, thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

    improved_path = 'temp_image_improved.png'
    cv2.imwrite(improved_path, thresh)
    return improved_path

# التعرف باستخدام Tesseract مع إعدادات دقيقة
def recognize_with_tesseract(image_path):
    img = Image.open(image_path)
    config = r'--psm 7 --oem 1 --tessdata-dir "C:\Program Files\Tesseract-OCR\tessdata_best"'
    text = pytesseract.image_to_string(img, lang='ara', config=config)
    print(f"📝 Tesseract أعاد: {text}")
    return clean_text(text)

# API
@app.route('/recognize', methods=['POST'])
def recognize_text():
    if 'image' not in request.files:
        return jsonify({'error': 'لم يتم تحميل صورة'}), 400

    image_file = request.files['image']
    content = image_file.read()
    image = vision.Image(content=content)

    # Google Vision
    response = client.text_detection(image=image)
    annotations = response.text_annotations

    if response.error.message:
        return jsonify({"error": response.error.message}), 500

    # جرب Google Vision أولاً
    if annotations:
        google_text = clean_text(annotations[0].description)
        print(f"🔍 Google Vision: {google_text}")

        # لو قصير أو أرقام/حروف فقط نستخدم Tesseract
        if len(google_text) <= 3 or re.fullmatch(r'[\u0621-\u064A\u0660-\u0669]{1,3}', google_text):
            print("🔁 استخدام Tesseract لأنه نص بسيط أو حرفي...")
            with open("temp_image.png", "wb") as f:
                f.write(content)
            improved_path = preprocess_image("temp_image.png")
            tesseract_text = recognize_with_tesseract(improved_path)
            return jsonify({"text": tesseract_text})
        else:
            return jsonify({"text": google_text})

    # لو Google ما قدر يقرأ
    print("🚫 Google Vision فشل، استخدام Tesseract...")
    with open("temp_image.png", "wb") as f:
        f.write(content)
    improved_path = preprocess_image("temp_image.png")
    tesseract_text = recognize_with_tesseract(improved_path)
    return jsonify({"text": tesseract_text})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
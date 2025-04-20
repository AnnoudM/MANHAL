import re
from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
from PIL import Image
import pytesseract
import easyocr

# تحديد مسار tesseract
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

app = Flask(__name__)
CORS(app)

reader = easyocr.Reader(['ar'], gpu=False)

# --------- المعالجة البصرية للصورة ---------
def preprocess_image(image):
    image_np = np.array(image)
    gray = cv2.cvtColor(image_np, cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    _, thresh = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    return thresh

# --------- تعقيم النص ---------
def clean_text(text):
    # احتفظ فقط بالحروف والأرقام العربية
    return re.sub(r'[^\u0621-\u064A\u0660-\u0669\s]', '', text).strip()

# --------- التعرف باستخدام Tesseract ---------
def recognize_tesseract(image):
    config = '-l ara --psm 7'
    raw_text = pytesseract.image_to_string(image, config=config)
    return clean_text(raw_text)

# --------- التعرف باستخدام EasyOCR ---------
def recognize_easyocr(image):
    result = reader.readtext(image, detail=0, paragraph=False)
    combined = ' '.join(result).strip()
    return clean_text(combined)

# --------- نقطة النهاية /recognize ---------
@app.route('/recognize', methods=['POST'])
def recognize_text():
    if 'image' not in request.files:
        return jsonify({"error": "لم يتم تحميل صورة"}), 400

    try:
        image_file = request.files['image']
        image = Image.open(image_file).convert('RGB')
        processed_image = preprocess_image(image)

        # جرّب Tesseract أولًا
        text = recognize_tesseract(processed_image)

        # لو فاضي أو قصير جدًا، جرّب EasyOCR
        if len(text) < 2:
            text = recognize_easyocr(processed_image)

        return jsonify({"text": text})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# --------- تشغيل التطبيق ---------
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

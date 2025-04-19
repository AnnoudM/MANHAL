import re
from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
from PIL import Image
import easyocr

app = Flask(__name__)
CORS(app)

reader = easyocr.Reader(['ar'], gpu=False)

def preprocess_image(image):
    image_np = np.array(image)
    gray = cv2.cvtColor(image_np, cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    _, thresh = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    return thresh

def is_valid_arabic_phrase(text):
    text = text.strip()
    
    # رقم عربي فقط (مثل ١ أو ٢)
    if re.fullmatch(r'[٠-٩]+', text):
        return True

    # حرف عربي فقط (مثل أ أو ل)
    if re.fullmatch(r'[ء-ي]', text):
        return True

    # جملة مكونة من 1 أو 2 كلمات عربية فقط
    words = text.split()
    if 1 <= len(words) <= 2:
        for word in words:
            if not re.fullmatch(r'[ء-ي]+', word):  # فقط أحرف عربية داخل الكلمة
                return False
        return True

    return False

@app.route('/recognize', methods=['POST'])
def recognize_text():
    if 'image' not in request.files:
        return jsonify({"error": "لم يتم تحميل صورة"}), 400

    try:
        image_file = request.files['image']
        image = Image.open(image_file).convert('RGB')
        processed_image = preprocess_image(image)

        results = reader.readtext(processed_image, detail=0, paragraph=True)

        valid_results = [text for text in results if is_valid_arabic_phrase(text)]

        if len(valid_results) == 0:
            return jsonify({"text": ""})  # لا يوجد شيء واضح

        return jsonify({"text": valid_results[0]})  # نرجع أول نتيجة فقط

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

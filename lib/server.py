from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
from PIL import Image
import easyocr
import io

app = Flask(__name__)
CORS(app)

reader = easyocr.Reader(['ar', 'en'])

def preprocess_image(image):
    # تحويل لـ numpy array
    image_np = np.array(image)

    # تحويل لتدرج الرمادي
    gray = cv2.cvtColor(image_np, cv2.COLOR_BGR2GRAY)

    # إزالة الضوضاء
    blur = cv2.GaussianBlur(gray, (5, 5), 0)

    # تحسين التباين
    _, thresh = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

    return thresh

@app.route('/recognize', methods=['POST'])
def recognize_text():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    try:
        image_file = request.files['image']
        image = Image.open(image_file).convert('RGB')
        processed_image = preprocess_image(image)

        result = reader.readtext(processed_image, detail=0, paragraph=True)

        extracted_text = ' '.join(result).strip()
        return jsonify({"text": extracted_text})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

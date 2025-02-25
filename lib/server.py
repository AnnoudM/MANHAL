from flask import Flask, request, jsonify
from flask_cors import CORS
import pytesseract
from PIL import Image

app = Flask(__name__)
CORS(app)  # السماح للـ Flutter بالاتصال بالسيرفر

pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

@app.route('/recognize', methods=['POST'])
def recognize_text():
    if 'image' not in request.files:
        print("❌ No image received!")
        return jsonify({"error": "No image uploaded"}), 400

    try:
        image_file = request.files['image']
        image = Image.open(image_file)

        print("📸 Image received, processing with Tesseract...")
        extracted_text = pytesseract.image_to_string(image, lang='ara', config='--psm 11')

        print(f"✅ Extracted Text: {extracted_text.strip()}")
        return jsonify({"text": extracted_text.strip()})

    except Exception as e:
        print(f"❌ Error processing image: {e}")
        return jsonify({"error": "Failed to process image"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

import os
import io
import re
from flask import Flask, request, jsonify
from flask_cors import CORS
from google.cloud import vision
from google.oauth2 import service_account

# Google Vision API credentials
CREDENTIAL_PATH = "manhal-457713-63bb22e0fbac.json"
credentials = service_account.Credentials.from_service_account_file(CREDENTIAL_PATH)
client = vision.ImageAnnotatorClient(credentials=credentials)

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for cross-origin requests

# Remove unwanted characters (keep only Arabic letters/numbers/spaces)
def clean_text(text):
    return re.sub(r'[^\u0621-\u064A\u0660-\u0669\s]', '', text).strip()

# API endpoint: POST /recognize
@app.route('/recognize', methods=['POST'])
def recognize_text():
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400

    image_file = request.files['image']
    content = image_file.read()
    image = vision.Image(content=content)

    # Run Google Vision OCR
    response = client.text_detection(image=image)
    annotations = response.text_annotations

    if response.error.message:
        return jsonify({"error": response.error.message}), 500

    if annotations:
        google_text = clean_text(annotations[0].description)
        print(f"🔍 Google Vision: {google_text}")
        return jsonify({"text": google_text})

    # If Vision fails completely (empty result)
    print("🚫 Google Vision failed, empty result")
    return jsonify({"text": ""})

# Run Flask app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

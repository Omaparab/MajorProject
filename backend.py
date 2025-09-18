# backend.py
from flask import Flask, request, jsonify
import spacy

app = Flask(__name__)
nlp = spacy.load("en_core_web_sm")  # spaCy model

@app.route("/process", methods=["POST"])
def process():
    data = request.get_json()   # get data from JS
    text = data.get("query", "")

    # Process with spaCy (just tokenize)
    doc = nlp(text)
    tokens = [token.text for token in doc]

    return jsonify({"output": tokens})

if __name__ == "__main__":
    app.run(port=8000, debug=True)

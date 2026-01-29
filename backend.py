from flask import Flask, request, Response
from flask_cors import CORS
import spacy
from collections import OrderedDict
import json

app = Flask(__name__)
CORS(app)

nlp = spacy.load("en_core_web_sm")

@app.route("/process", methods=["POST"])
def process():
    data = request.get_json()
    text = data.get("query", "")

    doc = nlp(text)

    # 1️⃣ Tokenization
    tokens = [token.text for token in doc]

    # 2️⃣ Stopword removal
    tokens_no_stop = [token.text for token in doc if not token.is_stop and not token.is_punct]

    # 3️⃣ Lemmatization
    lemmatized_tokens = [token.lemma_ for token in doc if not token.is_stop and not token.is_punct]

    # 4️⃣ Noun groups
    noun_chunks = [chunk.text for chunk in doc.noun_chunks]

    # Use OrderedDict to preserve sequence
    response = OrderedDict([
        ("original_query", text),
        ("tokens", tokens),
        ("tokens_no_stopwords", tokens_no_stop),
        ("lemmatized_tokens", lemmatized_tokens),
        ("named_entities", noun_chunks)
    ])

    # Convert to JSON string with indentation
    return Response(json.dumps(response, indent=2, ensure_ascii=False), mimetype='application/json')

if __name__ == "__main__":
    app.run(port=8000, debug=True)

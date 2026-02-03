from flask import Flask, request, jsonify
import logging

app = Flask(__name__)

@app.route('/webhook', methods=['POST'])
def webhook():
    payload = request.get_json(silent=True)
    logging.getLogger(__name__).info("Received stub slack webhook: %s", payload)
    return jsonify({"ok": True})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

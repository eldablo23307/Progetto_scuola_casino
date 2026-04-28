from flask import Flask, request 

app = Flask(__name__)

@app.route('/login', methods=["POST", "GET"])
def login():
    if request.method == "POST":
        return "Code: 100"
    else:
        return "Code: 400"

if __name__ == "__main__":
    app.run(host="0.0.0.0")

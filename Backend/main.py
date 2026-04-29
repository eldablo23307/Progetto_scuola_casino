from flask import Flask, request, jsonify
from Database_Handler import Database
app = Flask(__name__)
#db = Database()

@app.route('/login', methods=["POST", "GET"])
def login():
    if request.method == "POST":
        data = request.get_json()
        email = data["email"]
        password = data["password"]
        #db.login(email, password)
        return "Code: 200"
    else:
        return "Code: 400"

if __name__ == "__main__":
    app.run(host="0.0.0.0")

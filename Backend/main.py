from flask import Flask, request, jsonify, abort
from flask_cors import CORS

from Database_Handler import Database
app = Flask(__name__)
CORS(app)
db = Database()

@app.route('/login', methods=["POST", "GET"])
def login():
    if request.method == "POST":
        data = request.get_json()
        email = data["email"]
        password = data["password"]
        if (db.login(email, password)):
            return "Logged Succesfully"
        else:
            abort(500)
    else:
        abort(501)

@app.route("/register", methods=["POST", "GET"])
def register():
    if request.method == "POST":
        data = request.get_json()
        name = data["name"]
        surname = data["surname"]
        email = data["email"]
        password = data["password"]
        account_type = data["account_type"]
        address = data["address"]
        if(db.register(name, surname, email, password, account_type, address)):
            return "Register Succesfully"
        else:
            print("Errore nella registrazione")
            abort(500)
    else:
        abort(501)

@app.route("/get_slot", methods=["GET"])
def get_game():
    if request.method == "GET":
        return db.get_slot()
    else:
        abort(501)
if __name__ == "__main__":
    app.run(host="0.0.0.0")

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
        user = db.login(email, password)
        if user:
            return jsonify(user)
        abort(500)
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
        user = db.register(name, surname, email, password, account_type, address)
        if user:
            return jsonify(user)
        print("Errore nella registrazione")
        abort(500)
    abort(501)


@app.route("/MainApp", methods=["GET"])
def main_app():
    id_giocatore = request.args.get("id_giocatore", type=int)
    if id_giocatore is None:
        abort(400)
    user = db.get_user_data(id_giocatore)
    if user:
        return jsonify(user)
    abort(404)


@app.route("/get_slot", methods=["GET"])
def get_game():
    if request.method == "GET":
        return jsonify(db.get_slot())
    abort(501)


if __name__ == "__main__":
    app.run(host="0.0.0.0")

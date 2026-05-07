from flask import Flask, request, jsonify, abort
from flask_cors import CORS

from Database_Handler import Database
from Casino_Handler import Casino

app = Flask(__name__)
CORS(app)
db = Database()
casino = Casino()


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


def _game_payload():
    data = request.get_json(silent=True) or {}
    id_giocatore = data.get("id_giocatore")
    bet = data.get("bet")
    if id_giocatore is None or bet is None:
        abort(400, description="id_giocatore e bet sono obbligatori")
    try:
        return int(id_giocatore), float(bet), data
    except (TypeError, ValueError):
        abort(400, description="Parametri di gioco non validi")


def _play(callback):
    id_giocatore, bet, _ = _game_payload()
    try:
        return jsonify(db.play_game(id_giocatore, bet, callback))
    except LookupError:
        abort(404)
    except ValueError as exc:
        abort(400, description=str(exc))


@app.route("/games/roulette/play", methods=["POST"])
def play_roulette():
    id_giocatore, bet, data = _game_payload()
    choice = data.get("choice", "")
    try:
        return jsonify(db.play_game(id_giocatore, bet, lambda wager: casino.roulette(wager, choice)))
    except LookupError:
        abort(404)
    except ValueError as exc:
        abort(400, description=str(exc))


@app.route("/games/ice-fishing/play", methods=["POST"])
def play_ice_fishing():
    id_giocatore, bet, data = _game_payload()
    choice = data.get("choice", "")
    try:
        return jsonify(db.play_game(id_giocatore, bet, lambda wager: casino.ice_fishing(wager, choice)))
    except LookupError:
        abort(404)
    except ValueError as exc:
        abort(400, description=str(exc))


@app.route("/games/slots/<theme>/play", methods=["POST"])
def play_slot(theme):
    return _play(lambda wager: casino.slot(theme, wager))


if __name__ == "__main__":
    app.run(host="0.0.0.0")

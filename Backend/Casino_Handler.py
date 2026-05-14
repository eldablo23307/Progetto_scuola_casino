import random
from dataclasses import dataclass


@dataclass(frozen=True)
class GameResult:
    game: str
    bet: float
    payout: float
    profit: float
    result: dict
    message: str


class Casino:
    """Pure game engine used by the Flask routes.

    Each method receives the bet amount and a player choice, then returns a
    serialisable dictionary with the outcome. The database layer is responsible
    for debiting the bet and crediting the payout atomically.
    """

    ROULETTE_RED_NUMBERS = {1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36}

    ICE_WHEEL_SEGMENTS = [
        {"key": "1x", "label": "1x", "weight": 22, "multiplier": 1},
        {"key": "2x", "label": "2x", "weight": 18, "multiplier": 2},
        {"key": "5x", "label": "5x", "weight": 10, "multiplier": 5},
        {"key": "10x", "label": "10x", "weight": 5, "multiplier": 10},
        {"key": "coin_flip", "label": "Coin Flip", "weight": 4, "bonus": True},
        {"key": "pachinko", "label": "Pachinko", "weight": 3, "bonus": True},
        {"key": "ice_bonus", "label": "Ice Bonus", "weight": 2, "bonus": True},
    ]

    SLOT_CONFIGS = {
        "fruit": {
            "game": "Slot Frutta",
            "symbols": ["🍒", "🍋", "🍊", "🍉", "7️⃣"],
            "jackpot": "7️⃣",
            "triple": 8,
            "jackpot_multiplier": 18,
            "pair": 1.5,
        },
        "crystal": {
            "game": "Slot Cristalli",
            "symbols": ["💎", "🔷", "🔮", "✨", "👑"],
            "jackpot": "👑",
            "triple": 10,
            "jackpot_multiplier": 24,
            "pair": 2,
        },
        "thunder": {
            "game": "Slot Fulmini",
            "symbols": ["⚡", "🌩️", "⭐", "🔥", "W"],
            "jackpot": "W",
            "triple": 12,
            "jackpot_multiplier": 30,
            "pair": 2.5,
        },
        "olympus": {
            "game": "Gate of Olympus",
            "symbols": ["⚡", "👑", "💎", "🏺", "🦅", "🛡️", "🧿"],
            "premium": {"⚡": 4, "👑": 3, "💎": 2.5},
            "scatter": "⚡",
            "wild": "🧿",
            "rows": 3,
            "columns": 5,
        },
    }

    def roulette(self, bet: float, choice: str) -> dict:
        choice = choice.lower().strip()
        bet_data = self._roulette_bet(choice)

        number = random.randint(0, 36)
        if number == 0:
            color = "green"
        elif number in self.ROULETTE_RED_NUMBERS:
            color = "red"
        else:
            color = "black"

        won = bet_data["matcher"](number, color)
        multiplier = bet_data["multiplier"] if won else 0
        payout = bet * multiplier
        return self._result(
            "Roulette",
            bet,
            payout,
            {
                "number": number,
                "color": color,
                "choice": choice,
                "choiceLabel": bet_data["label"],
                "betType": bet_data["type"],
                "multiplier": multiplier,
            },
            f"La pallina si ferma su {number} {color}. Giocata: {bet_data['label']}.",
        )

    def _roulette_bet(self, choice: str) -> dict:
        color_bets = {
            "red": {"label": "Rosso", "type": "colore", "multiplier": 2, "matcher": lambda number, color: color == "red"},
            "black": {"label": "Nero", "type": "colore", "multiplier": 2, "matcher": lambda number, color: color == "black"},
            "green": {"label": "Verde", "type": "colore", "multiplier": 14, "matcher": lambda number, color: color == "green"},
        }
        if choice in color_bets:
            return color_bets[choice]

        parity_bets = {
            "even": {"label": "Pari", "type": "pari/dispari", "matcher": lambda number, color: number != 0 and number % 2 == 0},
            "odd": {"label": "Dispari", "type": "pari/dispari", "matcher": lambda number, color: number % 2 == 1},
        }
        if choice in parity_bets:
            return {**parity_bets[choice], "multiplier": 2}

        range_bets = {
            "low": {"label": "1-18", "type": "pezzo", "matcher": lambda number, color: 1 <= number <= 18},
            "high": {"label": "19-36", "type": "pezzo", "matcher": lambda number, color: 19 <= number <= 36},
            "dozen_1": {"label": "1ª dozzina (1-12)", "type": "pezzo", "matcher": lambda number, color: 1 <= number <= 12},
            "dozen_2": {"label": "2ª dozzina (13-24)", "type": "pezzo", "matcher": lambda number, color: 13 <= number <= 24},
            "dozen_3": {"label": "3ª dozzina (25-36)", "type": "pezzo", "matcher": lambda number, color: 25 <= number <= 36},
            "column_1": {"label": "Colonna 1", "type": "pezzo", "matcher": lambda number, color: number != 0 and number % 3 == 1},
            "column_2": {"label": "Colonna 2", "type": "pezzo", "matcher": lambda number, color: number != 0 and number % 3 == 2},
            "column_3": {"label": "Colonna 3", "type": "pezzo", "matcher": lambda number, color: number != 0 and number % 3 == 0},
        }
        if choice in range_bets:
            multiplier = 2 if choice in {"low", "high"} else 3
            return {**range_bets[choice], "multiplier": multiplier}

        if choice.startswith("number_"):
            try:
                selected_number = int(choice.split("_", 1)[1])
            except ValueError as exc:
                raise ValueError("Numero roulette non valido") from exc
            if 0 <= selected_number <= 36:
                return {
                    "label": f"Numero {selected_number}",
                    "type": "numero singolo",
                    "multiplier": 36,
                    "matcher": lambda number, color: number == selected_number,
                }

        raise ValueError("Scelta roulette non valida")

    def slot(self, theme: str, bet: float) -> dict:
        if theme not in self.SLOT_CONFIGS:
            raise ValueError("Slot non valida")
        if theme == "olympus":
            return self._olympus_slot(bet)

        config = self.SLOT_CONFIGS[theme]
        reels = [random.choice(config["symbols"]) for _ in range(3)]
        counts = {symbol: reels.count(symbol) for symbol in set(reels)}

        multiplier = 0
        message = "Nessuna combinazione vincente."
        win_tier = "none"
        if len(counts) == 1:
            symbol = reels[0]
            multiplier = config["jackpot_multiplier"] if symbol == config["jackpot"] else config["triple"]
            message = "Jackpot esplosivo!" if symbol == config["jackpot"] else "Tre simboli uguali!"
            win_tier = "jackpot" if symbol == config["jackpot"] else "triple"
        elif max(counts.values()) == 2:
            multiplier = config["pair"]
            message = "Coppia vincente!"
            win_tier = "pair"

        payout = bet * multiplier
        return self._result(
            config["game"],
            bet,
            payout,
            {"reels": reels, "multiplier": multiplier, "winTier": win_tier, "events": []},
            message,
        )

    def _olympus_slot(self, bet: float) -> dict:
        config = self.SLOT_CONFIGS["olympus"]
        rows = config["rows"]
        columns = config["columns"]
        symbols = config["symbols"]
        grid = [[random.choice(symbols) for _ in range(columns)] for _ in range(rows)]
        flat = [symbol for row in grid for symbol in row]
        counts = {symbol: flat.count(symbol) for symbol in set(flat)}

        events = []
        multiplier = 0.0
        wild_count = counts.get(config["wild"], 0)
        scatter_count = counts.get(config["scatter"], 0)

        for symbol, count in counts.items():
            if symbol == config["wild"]:
                continue
            effective_count = count + wild_count
            if effective_count >= 8:
                symbol_multiplier = config["premium"].get(symbol, 1.4)
                combo_multiplier = round(symbol_multiplier * (effective_count - 6), 2)
                multiplier += combo_multiplier
                events.append({"type": "combo", "symbol": symbol, "count": effective_count, "multiplier": combo_multiplier})

        if scatter_count >= 3:
            bonus_multiplier = random.choice([5, 8, 12, 20, 35])
            multiplier += bonus_multiplier
            events.append({"type": "free_spins", "label": "Pioggia di fulmini", "multiplier": bonus_multiplier})

        if wild_count >= 2:
            wild_multiplier = random.choice([2, 3, 5, 10])
            multiplier += wild_multiplier
            events.append({"type": "wild", "label": "Moltiplicatore divino", "multiplier": wild_multiplier})

        cascade_count = 0
        if events:
            cascade_count = random.randint(1, 4)
            cascade_multiplier = cascade_count * random.choice([1, 1.5, 2, 3])
            multiplier += cascade_multiplier
            events.append({"type": "cascade", "label": f"{cascade_count} cascata/e", "multiplier": cascade_multiplier})

        multiplier = round(multiplier, 2)
        payout = bet * multiplier
        if multiplier >= 50:
            message = "Vincita mitica dell'Olimpo!"
            win_tier = "mythic"
        elif multiplier >= 20:
            message = "Mega vincita divina!"
            win_tier = "mega"
        elif multiplier > 0:
            message = "Gli dei accendono i rulli!"
            win_tier = "win"
        else:
            message = "Gli dei restano in silenzio. Ritenta!"
            win_tier = "none"

        return self._result(
            config["game"],
            bet,
            payout,
            {
                "grid": grid,
                "reels": flat[:3],
                "multiplier": multiplier,
                "events": events,
                "winTier": win_tier,
                "cascadeCount": cascade_count,
            },
            message,
        )

    def blackjack(self, bet: float, choice: str) -> dict:
        choice = choice.lower().strip()
        if choice not in {"stand", "hit"}:
            raise ValueError("Scelta blackjack non valida")

        deck = self._blackjack_deck()
        player = [deck.pop(), deck.pop()]
        dealer = [deck.pop(), deck.pop()]
        events = ["Carte iniziali distribuite"]

        if choice == "hit":
            player.append(deck.pop())
            events.append("Hai chiesto carta")

        player_score = self._blackjack_score(player)
        if player_score <= 21:
            while self._blackjack_score(dealer) < 17:
                dealer.append(deck.pop())
                events.append("Il banco pesca")

        dealer_score = self._blackjack_score(dealer)
        if player_score > 21:
            multiplier = 0
            message = "Hai sballato. Vince il banco."
            outcome = "lose"
        elif len(player) == 2 and player_score == 21:
            multiplier = 2.5
            message = "Blackjack naturale!"
            outcome = "blackjack"
        elif dealer_score > 21 or player_score > dealer_score:
            multiplier = 2
            message = "Hai battuto il banco!"
            outcome = "win"
        elif player_score == dealer_score:
            multiplier = 1
            message = "Push: puntata restituita."
            outcome = "push"
        else:
            multiplier = 0
            message = "Il banco vince la mano."
            outcome = "lose"

        return self._result(
            "Blackjack",
            bet,
            bet * multiplier,
            {
                "playerHand": player,
                "dealerHand": dealer,
                "playerScore": player_score,
                "dealerScore": dealer_score,
                "choice": choice,
                "outcome": outcome,
                "multiplier": multiplier,
                "events": events,
            },
            message,
        )

    def _blackjack_deck(self) -> list[str]:
        cards = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"] * 4
        random.shuffle(cards)
        return cards

    def _blackjack_score(self, hand: list[str]) -> int:
        score = 0
        aces = 0
        for card in hand:
            if card == "A":
                aces += 1
                score += 11
            elif card in {"J", "Q", "K"}:
                score += 10
            else:
                score += int(card)
        while score > 21 and aces:
            score -= 10
            aces -= 1
        return score

    def ice_fishing(self, bet: float, choice: str) -> dict:
        """Crazy Time inspired wheel with number slices and bonus rounds."""
        choice = choice.lower().strip()
        valid_choices = {segment["key"] for segment in self.ICE_WHEEL_SEGMENTS}
        if choice not in valid_choices:
            raise ValueError("Scelta Ice Fishing non valida")

        segment = self._weighted_choice(self.ICE_WHEEL_SEGMENTS)
        bonus_detail = None
        multiplier = 0

        if segment.get("bonus"):
            bonus_detail = self._play_ice_bonus(segment["key"])
            if choice == segment["key"]:
                multiplier = bonus_detail["multiplier"]
        elif choice == segment["key"]:
            multiplier = segment["multiplier"]

        payout = bet * multiplier
        message = f"La ruota si ferma su {segment['label']}!"
        if bonus_detail:
            message += f" Bonus: {bonus_detail['label']} vale {bonus_detail['multiplier']}x."

        return self._result(
            "Ice Fishing",
            bet,
            payout,
            {
                "choice": choice,
                "segment": segment["key"],
                "segmentLabel": segment["label"],
                "multiplier": multiplier,
                "bonus": bonus_detail,
                "wheel": [{"key": s["key"], "label": s["label"], "weight": s["weight"]} for s in self.ICE_WHEEL_SEGMENTS],
            },
            message,
        )

    def _play_ice_bonus(self, key: str) -> dict:
        if key == "coin_flip":
            side = random.choice(["Orca", "Pinguino"])
            multiplier = random.choice([2, 3, 4, 7, 10, 15])
            return {"type": key, "label": f"{side} Flip", "multiplier": multiplier}
        if key == "pachinko":
            slot = random.choice([5, 7, 10, 15, 20, 25, 50])
            return {"type": key, "label": "Pallina nel ghiaccio", "multiplier": slot}

        fish = random.choice([
            {"name": "Merluzzo", "multiplier": 8},
            {"name": "Salmone", "multiplier": 12},
            {"name": "Tonno artico", "multiplier": 20},
            {"name": "Squalo glaciale", "multiplier": 40},
            {"name": "Balena leggendaria", "multiplier": 75},
        ])
        return {"type": key, "label": fish["name"], "multiplier": fish["multiplier"]}

    def _weighted_choice(self, segments: list[dict]) -> dict:
        total = sum(segment["weight"] for segment in segments)
        pick = random.uniform(0, total)
        cumulative = 0
        for segment in segments:
            cumulative += segment["weight"]
            if pick <= cumulative:
                return segment
        return segments[-1]

    def _result(self, game: str, bet: float, payout: float, result: dict, message: str) -> dict:
        profit = payout - bet
        return GameResult(
            game=game,
            bet=round(bet, 2),
            payout=round(payout, 2),
            profit=round(profit, 2),
            result=result,
            message=message,
        ).__dict__

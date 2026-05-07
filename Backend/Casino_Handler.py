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
    }

    def roulette(self, bet: float, choice: str) -> dict:
        choice = choice.lower().strip()
        allowed = {"red", "black", "green"}
        if choice not in allowed:
            raise ValueError("Scelta roulette non valida")

        number = random.randint(0, 36)
        if number == 0:
            color = "green"
        elif number in self.ROULETTE_RED_NUMBERS:
            color = "red"
        else:
            color = "black"

        multiplier = 14 if color == "green" else 2
        payout = bet * multiplier if choice == color else 0
        return self._result(
            "Roulette",
            bet,
            payout,
            {"number": number, "color": color, "choice": choice, "multiplier": multiplier if choice == color else 0},
            f"La pallina si ferma su {number} {color}.",
        )

    def slot(self, theme: str, bet: float) -> dict:
        if theme not in self.SLOT_CONFIGS:
            raise ValueError("Slot non valida")

        config = self.SLOT_CONFIGS[theme]
        reels = [random.choice(config["symbols"]) for _ in range(3)]
        counts = {symbol: reels.count(symbol) for symbol in set(reels)}

        multiplier = 0
        message = "Nessuna combinazione vincente."
        if len(counts) == 1:
            symbol = reels[0]
            multiplier = config["jackpot_multiplier"] if symbol == config["jackpot"] else config["triple"]
            message = "Jackpot!" if symbol == config["jackpot"] else "Tre simboli uguali!"
        elif max(counts.values()) == 2:
            multiplier = config["pair"]
            message = "Coppia vincente!"

        payout = bet * multiplier
        return self._result(
            config["game"],
            bet,
            payout,
            {"reels": reels, "multiplier": multiplier},
            message,
        )

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

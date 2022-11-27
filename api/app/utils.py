import hashlib
import random
import string
from datetime import datetime, timezone, timedelta

import jwt
import bcrypt
from fastapi_sqlalchemy import db
from sqlalchemy import or_, and_

from app.models import Transaction
from app.settings import logger, JWT_SECRET, CURRENCY_PRICES


def generate_password_hash(password: str):
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode(), salt).decode('utf-8'), salt.decode('utf-8')


def check_password_hash(password: str, hashpass: str, salt: str) -> bool:
    return bcrypt.checkpw(password.encode(), hashpass.encode())


def generate_token_jwt(user_id) -> str:
    exp = datetime.now(tz=timezone.utc) + timedelta(minutes=60)
    return jwt.encode({"user_id": user_id, "exp": exp}, JWT_SECRET, algorithm="HS256")


def decode_token_jwt(token) -> dict:
    return jwt.decode(token, JWT_SECRET, algorithms=["HS256"])


def generate_random() -> str:
    length = 34
    letters = string.ascii_lowercase.replace('i', '').replace('l', '') + string.digits
    wallet = ''.join(random.choice(letters) for i in range(length))
    return wallet


def generate_transaction_hash(transaction: Transaction) -> str:
    value = f"{transaction.currency}|{transaction.from_address}|{transaction.to_address}|{transaction.value}|" \
            f"{transaction.message}|{transaction.date}"
    return hashlib.sha256(value.encode('utf-8')).hexdigest()


def get_wallet_balance(address: str, currency: str) -> float:
    balance = 0.0
    transactions = db.session.query(Transaction).filter(and_(Transaction.currency == currency,
                                                             or_(Transaction.from_address == address,
                                                                 Transaction.to_address == address))).all()
    for transaction in transactions:
        balance += float(transaction.value)

    return balance


def calculate_transactions_balance(wallets: list[str], transactions: list[Transaction]) -> dict:
    result = {
        "BTC": {
            "value": 0,
            "converted": 0,
            "address": ""
        },
        "ETH": {
            "value": 0,
            "converted": 0,
            "address": ""
        },
        "LTC": {
            "value": 0,
            "converted": 0,
            "address": ""
        }
    }

    for transaction in transactions:
        if transaction.to_address in wallets:
            result[transaction.currency]["value"] += float(abs(transaction.value))
        elif transaction.from_address in wallets:
            result[transaction.currency]["value"] -= float(abs(transaction.value))

        result[transaction.currency]["converted"] = result[transaction.currency]["value"] * CURRENCY_PRICES[transaction.currency]

    return result


def format_price(value: float):
    if not value:
        return "R$ 0,00"

    text = "{:.2f}".format(value)
    return f"R$ {text.replace('.', ',')}"

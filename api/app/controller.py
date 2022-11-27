from datetime import datetime

from fastapi_sqlalchemy import db
from sqlalchemy import or_
from sqlalchemy.exc import IntegrityError

from app.schema import User as UserSchema, Login, Transaction
from app.models import User as ModelUser, Wallet as ModelWallet, Transaction as ModelTransaction
from app.utils import generate_password_hash, check_password_hash, generate_token_jwt, format_price, \
    generate_random, generate_transaction_hash, calculate_transactions_balance, get_wallet_balance


def register_user(user: UserSchema):
    password, salt = generate_password_hash(user.password)
    db_user = ModelUser(
        name=user.name,
        email=user.email,
        password=password,
        salt=salt,
        phone=user.phone
    )
    db.session.add(db_user)
    db.session.flush()

    btc_wallet = ModelWallet(name="BTC", currency="BTC", address=generate_random(), user_id=db_user.id,
                             private_key=generate_random(), public_key=generate_random())
    eth_wallet = ModelWallet(name="ETH", currency="ETH", address=generate_random(), user_id=db_user.id,
                             private_key=generate_random(), public_key=generate_random())
    ltc_wallet = ModelWallet(name="LTC", currency="LTC", address=generate_random(), user_id=db_user.id,
                             private_key=generate_random(), public_key=generate_random())

    db.session.add(btc_wallet)
    db.session.add(eth_wallet)
    db.session.add(ltc_wallet)
    db.session.flush()

    ltc_genesis_transaction = ModelTransaction(
        currency="LTC",
        from_address="genesisltcaddress",
        to_address=ltc_wallet.address,
        value=111.11,
        message=f"New account bonus",
        date=datetime.now()
    )

    ltc_genesis_transaction.hash = generate_transaction_hash(ltc_genesis_transaction)

    db.session.add(ltc_genesis_transaction)
    db.session.commit()

    return db_user, 201


def login_user(user: Login):
    usr = db.session.query(ModelUser).filter(ModelUser.email == user.email).first()

    if not usr:
        return {'msg': 'error'}, 401

    if check_password_hash(user.password, usr.password, usr.salt):
        return {'msg': 'Success', 'name': usr.name, 'email': usr.email, 'token': generate_token_jwt(usr.id)}, 200

    return {'msg': 'error'}, 401


def create_transaction(user_id: str, payload: Transaction):
    wallet = db.session.query(ModelWallet).filter(ModelWallet.user_id == user_id,
                                                  ModelWallet.currency == payload.currency).first()
    if not wallet:
        return {"msg": "wallet not found"}, 404

    actual_balance = get_wallet_balance(wallet.address, payload.currency)
    if actual_balance < payload.amount:
        return {"msg": "insufficient founds"}, 400

    try:
        transaction = ModelTransaction(
            currency=payload.currency,
            from_address=wallet.address,
            to_address=payload.to_address,
            value=payload.amount * -1,
            message=payload.message,
            date=datetime.now()
        )

        transaction.hash = generate_transaction_hash(transaction)

        db.session.add(transaction)
        db.session.flush()
        db.session.commit()

        return {"hash": transaction.hash, "date": transaction.date, "fee": 0.0}, 200
    except IntegrityError:
        return {"msg": "invalid wallet address"}, 400


def extract_wallets(user_id):
    wallets = db.session.query(ModelWallet).filter(ModelWallet.user_id == user_id).all()
    if not wallets:
        return {}, 404

    wallets_address = [wallet.address for wallet in wallets]

    transacts = db.session.query(ModelTransaction).filter(
        or_(ModelTransaction.from_address.in_(wallets_address),
            ModelTransaction.to_address.in_(wallets_address))
    ).all()

    transactions = []
    for transact in transacts:
        if transact.to_address in wallets_address:
            value = float(abs(transact.value))
        else:
            value = float(transact.value)
        transactions.append({
            'currency': transact.currency,
            'fromAddress': transact.from_address,
            'toAddress': transact.to_address,
            'value': value,
            'date': transact.date.strftime("%d/%m/%Y %H:%M"),
            'hash': transact.hash,
            'message': transact.message
        })

    return {'extract': transactions}, 200


def balance_wallets(user_id):
    wallets = db.session.query(ModelWallet).filter(ModelWallet.user_id == user_id).all()
    if not wallets:
        return {}, 404

    wallets_address = []
    addresses = {}
    for wallet in wallets:
        wallets_address.append(wallet.address)
        addresses[wallet.currency] = wallet.address

    transactions = db.session.query(ModelTransaction).filter(or_(ModelTransaction.from_address.in_(wallets_address),
                                                                 ModelTransaction.to_address.in_(wallets_address))
                                                             ).all()

    result = calculate_transactions_balance(wallets_address, transactions)
    return {
               "balance": {
                   "Total": format_price(
                       result["BTC"]["converted"] + result["ETH"]["converted"] + result["LTC"]["converted"]),
                   "BTC": {
                       "value": result["BTC"]["value"] or 0.0,
                       "converted": result["BTC"]["converted"] or 0.0
                   },
                   "ETH": {
                       "value": result["ETH"]["value"] or 0.0,
                       "converted": result["ETH"]["converted"] or 0.0
                   },
                   "LTC": {
                       "value": result["LTC"]["value"] or 0.0,
                       "converted": result["LTC"]["converted"] or 0.0
                   }
               },
               "addresses": {
                   "BTC": {
                       "value": addresses["BTC"] or "",
                   },
                   "ETH": {
                       "value": addresses["ETH"] or "",
                   },
                   "LTC": {
                       "value": addresses["LTC"] or "",
                   }
               }
           }, 200

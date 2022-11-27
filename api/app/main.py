from typing import Union

import uvicorn
from fastapi import FastAPI, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware
from fastapi_sqlalchemy import DBSessionMiddleware
from fastapi.staticfiles import StaticFiles

from app.settings import DB_URL
from app.schema import Login as LoginSchema, Transaction
from app.schema import User as UserSchema
from app.controller import register_user, login_user, balance_wallets, create_transaction, extract_wallets
from app.utils import decode_token_jwt

app = FastAPI()

app.add_middleware(DBSessionMiddleware, db_url=DB_URL)

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def read_root():
    return {"status": "ok"}


@app.post("/api/v1/user/login")
def user_login(user: LoginSchema):
    usr, code = login_user(user)
    if code != 200:
        raise HTTPException(status_code=code, detail="Forbidden")
    return usr


@app.post("/api/v1/user/register", status_code=201)
def user_register(user: UserSchema):
    usr, code = register_user(user)
    if code != 201:
        raise HTTPException(status_code=code, detail="Unable to create user")
    return usr


@app.get("/api/v1/wallet/balance")
def wallet_balance(x_token: Union[str, None] = Header(default=None)):
    try:
        data = decode_token_jwt(x_token)
    except Exception as e:
        raise HTTPException(status_code=401, detail="Invalid Token")

    balance, code = balance_wallets(data['user_id'])
    if code != 200:
        raise HTTPException(status_code=code, detail="Error")
    return balance


@app.get("/api/v1/wallet/extract")
def wallet_balance(x_token: Union[str, None] = Header(default=None)):
    try:
        data = decode_token_jwt(x_token)
    except Exception as e:
        raise HTTPException(status_code=401, detail="Invalid Token")

    extract, code = extract_wallets(data['user_id'])
    if code != 200:
        raise HTTPException(status_code=code, detail="Error")
    return extract


@app.post("/api/v1/transaction/new")
def transaction_create(payload: Transaction, x_token: Union[str, None] = Header(default=None)):
    try:
        data = decode_token_jwt(x_token)
    except Exception as e:
        raise HTTPException(status_code=401, detail="Invalid Token")

    transaction, code = create_transaction(data['user_id'], payload)
    if code != 200:
        raise HTTPException(status_code=code, detail=transaction)
    return transaction


app.mount("/", StaticFiles(directory="/code/web", html=True), name="web")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080, log_level="info")

from pydantic import BaseModel
from typing import Optional


class Login(BaseModel):
    email: str
    password: str


class User(BaseModel):
    name: str
    email: str
    password: str
    phone: Optional[str]

    class Config:
        orm_mode = True


class Transaction(BaseModel):
    currency: str
    from_address: Optional[str]
    to_address: str
    amount: float
    message: Optional[str]

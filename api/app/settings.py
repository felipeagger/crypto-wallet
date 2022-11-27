import logging
import os

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

DB_URL = f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}@{os.getenv('DB_HOST')}:5432/crypto-wallet"

JWT_SECRET = os.getenv("JWT_SECRET") or "default-secret-0"

# prices of 27/11
CURRENCY_PRICES = {
    "BTC": 89375.90,
    "ETH": 6554.22,
    "LTC": 416.95
}

import hashlib
import os
from base64 import b64encode

from cryptography.hazmat.primitives.ciphers.aead import AESGCM

from app.config import get_settings

settings = get_settings()


def _get_key() -> bytes:
    key = settings.EVIDENCE_ENCRYPTION_KEY.encode("utf-8")
    return key[:32].ljust(32, b"0")


def encrypt_data(data: bytes) -> bytes:
    aesgcm = AESGCM(_get_key())
    nonce = os.urandom(12)
    ciphertext = aesgcm.encrypt(nonce, data, None)
    return nonce + ciphertext


def decrypt_data(encrypted: bytes) -> bytes:
    aesgcm = AESGCM(_get_key())
    nonce, ciphertext = encrypted[:12], encrypted[12:]
    return aesgcm.decrypt(nonce, ciphertext, None)


def hash_file_content(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()

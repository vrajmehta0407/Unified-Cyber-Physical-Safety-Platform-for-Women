import hashlib


def sha256_hash(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()

import os
import uuid
from pathlib import Path
from uuid import UUID

from sqlalchemy.orm import Session

from app.models import ChainOfCustody, Evidence
from app.utils.chain_of_custody import log_custody_action
from app.utils.encryption import encrypt_data, hash_file_content

# Evidence storage directory (relative to backend root)
UPLOAD_DIR = Path(__file__).resolve().parent.parent.parent / "uploads" / "evidence"


def upload_evidence(
    db: Session,
    user_id: UUID,
    content: bytes,
    mime_type: str,
    incident_id: UUID | None = None,
) -> Evidence:
    file_hash = hash_file_content(content)
    encrypted = encrypt_data(content)

    # Create the directory structure and persist the encrypted file to disk
    user_dir = UPLOAD_DIR / str(user_id)
    user_dir.mkdir(parents=True, exist_ok=True)
    file_id = uuid.uuid4()
    encrypted_file_path = user_dir / f"{file_id}.enc"
    encrypted_file_path.write_bytes(encrypted)

    # Store the relative path in DB
    file_path = f"evidence/{user_id}/{file_id}.enc"

    evidence = Evidence(
        incident_id=incident_id,
        user_id=user_id,
        file_path=file_path,
        hash=file_hash,
        mime_type=mime_type,
    )
    db.add(evidence)
    db.commit()
    db.refresh(evidence)

    log_custody_action(db, evidence.id, "uploaded", str(user_id))
    return evidence


def list_evidence(db: Session, user_id: UUID) -> list[Evidence]:
    return db.query(Evidence).filter(Evidence.user_id == user_id).order_by(Evidence.timestamp.desc()).all()


def get_evidence_file(user_id: UUID, file_id: str) -> bytes | None:
    """Retrieve the encrypted evidence file from disk."""
    file_path = UPLOAD_DIR / str(user_id) / f"{file_id}.enc"
    if file_path.exists():
        return file_path.read_bytes()
    return None

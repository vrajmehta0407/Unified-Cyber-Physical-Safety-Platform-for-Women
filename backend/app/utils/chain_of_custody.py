from datetime import datetime
from uuid import UUID

from sqlalchemy.orm import Session

from app.models import ChainOfCustody


def log_custody_action(db: Session, evidence_id: UUID, action: str, actor: str) -> ChainOfCustody:
    entry = ChainOfCustody(
        evidence_id=evidence_id,
        action=action,
        actor=actor,
        timestamp=datetime.utcnow(),
    )
    db.add(entry)
    db.commit()
    db.refresh(entry)
    return entry

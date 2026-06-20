from typing import Optional

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import AdvisoryBroadcast, User

router = APIRouter(prefix="/broadcasts", tags=["Broadcasts"])


class BroadcastCreate(BaseModel):
    title: str
    message: str
    target_audience: Optional[str] = "all"
    priority: Optional[str] = "medium"


class BroadcastResponse(BaseModel):
    id: str
    title: str
    message: str
    target_audience: str
    priority: str
    created_at: str
    created_by_name: Optional[str] = None

    class Config:
        from_attributes = True


@router.get("/", response_model=list[BroadcastResponse])
def list_broadcasts(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    rows = (
        db.query(AdvisoryBroadcast, User.name)
        .join(User, AdvisoryBroadcast.created_by == User.id)
        .order_by(AdvisoryBroadcast.created_at.desc())
        .limit(100)
        .all()
    )
    results = []
    for bc, creator_name in rows:
        results.append(
            BroadcastResponse(
                id=str(bc.id),
                title=bc.title,
                message=bc.message,
                target_audience=bc.target_audience,
                priority=bc.priority,
                created_at=bc.created_at.isoformat(),
                created_by_name=creator_name,
            )
        )
    return results


@router.post("/", response_model=BroadcastResponse)
def create_broadcast(
    data: BroadcastCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role not in ("admin", "police"):
        raise HTTPException(status_code=403, detail="Police access required")

    broadcast = AdvisoryBroadcast(
        title=data.title,
        message=data.message,
        target_audience=data.target_audience or "all",
        priority=data.priority or "medium",
        created_by=current_user.id,
    )
    db.add(broadcast)
    db.commit()
    db.refresh(broadcast)

    return BroadcastResponse(
        id=str(broadcast.id),
        title=broadcast.title,
        message=broadcast.message,
        target_audience=broadcast.target_audience,
        priority=broadcast.priority,
        created_at=broadcast.created_at.isoformat(),
        created_by_name=current_user.name,
    )


@router.delete("/{broadcast_id}")
def delete_broadcast(
    broadcast_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role not in ("admin", "police"):
        raise HTTPException(status_code=403, detail="Police access required")

    broadcast = db.query(AdvisoryBroadcast).filter(AdvisoryBroadcast.id == broadcast_id).first()
    if not broadcast:
        raise HTTPException(status_code=404, detail="Broadcast not found")
    db.delete(broadcast)
    db.commit()
    return {"message": "Broadcast deleted"}

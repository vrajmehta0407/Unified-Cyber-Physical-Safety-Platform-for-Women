from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import Notification, User

router = APIRouter(prefix="/notifications", tags=["Notifications"])


class NotificationSendRequest(BaseModel):
    user_id: UUID
    title: str
    body: str


class NotificationResponse(BaseModel):
    id: UUID
    user_id: UUID
    title: str
    body: str
    read: bool
    timestamp: str

    class Config:
        from_attributes = True


@router.get("/")
def get_notifications(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return (
        db.query(Notification)
        .filter(Notification.user_id == current_user.id)
        .order_by(Notification.timestamp.desc())
        .limit(50)
        .all()
    )


@router.get("/unread-count")
def get_unread_count(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    count = (
        db.query(Notification)
        .filter(Notification.user_id == current_user.id, Notification.read == False)
        .count()
    )
    return {"unread_count": count}


@router.post("/send", status_code=status.HTTP_201_CREATED)
def send_notification(
    data: NotificationSendRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role not in ("admin", "police"):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")
    target_user = db.query(User).filter(User.id == data.user_id).first()
    if not target_user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Target user not found")
    notification = Notification(
        user_id=data.user_id,
        title=data.title,
        body=data.body,
    )
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return {"message": "Notification sent", "id": str(notification.id)}


@router.put("/{notification_id}/read")
def mark_as_read(
    notification_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    notification = (
        db.query(Notification)
        .filter(Notification.id == notification_id, Notification.user_id == current_user.id)
        .first()
    )
    if not notification:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notification not found")
    notification.read = True
    db.commit()
    return {"message": "Marked as read"}

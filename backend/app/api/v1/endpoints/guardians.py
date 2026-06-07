from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import Guardian, User
from app.schemas.guardian_schema import GuardianCreate, GuardianResponse

router = APIRouter(prefix="/guardians", tags=["Guardians"])


@router.post("/", response_model=GuardianResponse)
def add_guardian(
    data: GuardianCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    guardian = Guardian(user_id=current_user.id, name=data.name, phone=data.phone, relation=data.relation)
    db.add(guardian)
    db.commit()
    db.refresh(guardian)
    return guardian


@router.get("/", response_model=list[GuardianResponse])
def list_guardians(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return db.query(Guardian).filter(Guardian.user_id == current_user.id).all()


@router.delete("/{guardian_id}")
def remove_guardian(
    guardian_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    guardian = db.query(Guardian).filter(Guardian.id == guardian_id, Guardian.user_id == current_user.id).first()
    if not guardian:
        raise HTTPException(status_code=404, detail="Guardian not found")
    db.delete(guardian)
    db.commit()
    return {"message": "Guardian removed"}

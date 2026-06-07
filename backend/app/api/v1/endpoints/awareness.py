from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import AwarenessContent, User

router = APIRouter(prefix="/awareness", tags=["Awareness"])


class ArticleCreate(BaseModel):
    title: str
    body: str
    category: Optional[str] = None
    language: str = "en"


class ArticleUpdate(BaseModel):
    title: Optional[str] = None
    body: Optional[str] = None
    category: Optional[str] = None
    language: Optional[str] = None


@router.get("/articles")
def get_awareness_articles(language: str = "en", db: Session = Depends(get_db)):
    return db.query(AwarenessContent).filter(AwarenessContent.language == language).all()


@router.get("/articles/{article_id}")
def get_article(article_id: UUID, db: Session = Depends(get_db)):
    article = db.query(AwarenessContent).filter(AwarenessContent.id == article_id).first()
    if not article:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Article not found")
    return article


@router.post("/articles", status_code=status.HTTP_201_CREATED)
def create_article(
    data: ArticleCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin only")
    article = AwarenessContent(
        title=data.title,
        body=data.body,
        category=data.category,
        language=data.language,
    )
    db.add(article)
    db.commit()
    db.refresh(article)
    return article


@router.put("/articles/{article_id}")
def update_article(
    article_id: UUID,
    data: ArticleUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin only")
    article = db.query(AwarenessContent).filter(AwarenessContent.id == article_id).first()
    if not article:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Article not found")
    if data.title is not None:
        article.title = data.title
    if data.body is not None:
        article.body = data.body
    if data.category is not None:
        article.category = data.category
    if data.language is not None:
        article.language = data.language
    db.commit()
    db.refresh(article)
    return article


@router.delete("/articles/{article_id}")
def delete_article(
    article_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin only")
    article = db.query(AwarenessContent).filter(AwarenessContent.id == article_id).first()
    if not article:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Article not found")
    db.delete(article)
    db.commit()
    return {"message": "Article deleted"}

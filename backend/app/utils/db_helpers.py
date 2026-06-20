"""
db_helpers.py — SQLite/PostgreSQL-compatible UUID query helpers.

SQLite stores UUIDs as CHAR(32) strings without hyphens.
SQLAlchemy's UUID type calls .hex on the value for SQLite,
which fails when a plain hyphenated string comes from a URL path param.

Use `_id(raw)` to safely convert any string/UUID path param
before passing it to filter(...) calls.
"""

from uuid import UUID


def _id(raw: str | UUID) -> UUID:
    """Convert a string path param to a proper UUID object for DB filtering."""
    if isinstance(raw, UUID):
        return raw
    return UUID(str(raw))

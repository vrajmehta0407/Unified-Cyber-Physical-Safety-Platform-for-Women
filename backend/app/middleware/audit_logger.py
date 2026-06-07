import logging
import time
from uuid import UUID

from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware

from app.database import SessionLocal
from app.models import AuditLog

logger = logging.getLogger("cybershield.audit")


class AuditLoggerMiddleware(BaseHTTPMiddleware):
    """Logs all API requests to the audit_logs database table."""

    async def dispatch(self, request: Request, call_next):
        start_time = time.time()
        response = await call_next(request)
        duration_ms = (time.time() - start_time) * 1000

        if request.url.path.startswith("/api/"):
            # Extract user_id from request state (set by auth middleware)
            user_id = None
            if hasattr(request.state, "user_id"):
                try:
                    user_id = UUID(request.state.user_id)
                except (ValueError, AttributeError):
                    pass

            client_ip = request.client.host if request.client else "unknown"
            action = f"{request.method} {request.url.path}"
            resource = request.url.path

            # Log to console
            logger.info(
                f"[AUDIT] {action} -> {response.status_code} ({duration_ms:.0f}ms) "
                f"ip={client_ip} user={user_id or 'anonymous'}"
            )

            # Persist to database (fire-and-forget, don't block the response)
            try:
                db = SessionLocal()
                audit_entry = AuditLog(
                    user_id=user_id,
                    action=action,
                    resource=resource,
                    ip_address=client_ip,
                )
                db.add(audit_entry)
                db.commit()
            except Exception as e:
                logger.warning(f"[AUDIT] Failed to persist audit log: {e}")
            finally:
                db.close()

        return response

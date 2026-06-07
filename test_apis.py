"""End-to-end API smoke test for CyberShield."""
import httpx
import json

print("=" * 50)
print("BACKEND TESTS (http://localhost:8000)")
print("=" * 50)

# 1. Register
r = httpx.post("http://localhost:8000/api/v1/auth/register", json={
    "name": "Test User", "mobile": "9876543210", "password": "Test@1234", "role": "user"
})
print(f"  Register:       {r.status_code}  {r.text[:120]}")

# 2. Login
r = httpx.post("http://localhost:8000/api/v1/auth/login", json={
    "mobile": "9876543210", "password": "Test@1234"
})
print(f"  Login:          {r.status_code}  {r.text[:120]}")

token = ""
if r.status_code == 200:
    token = r.json().get("access_token", "")

if token:
    headers = {"Authorization": f"Bearer {token}"}

    # 3. Awareness articles
    r = httpx.get("http://localhost:8000/api/v1/awareness/articles", headers=headers)
    print(f"  Awareness:      {r.status_code}  items={len(r.json()) if r.status_code == 200 else 'error'}")

    # 4. Notifications
    r = httpx.get("http://localhost:8000/api/v1/notifications/", headers=headers)
    print(f"  Notifications:  {r.status_code}  items={len(r.json()) if r.status_code == 200 else 'error'}")

    # 5. Unread count
    r = httpx.get("http://localhost:8000/api/v1/notifications/unread-count", headers=headers)
    print(f"  Unread Count:   {r.status_code}  {r.text[:80]}")
else:
    print("  SKIPPED auth-protected tests (no token)")

print()
print("=" * 50)
print("AI ENGINE TESTS (http://localhost:8001)")
print("=" * 50)

# 6. Health
r = httpx.get("http://localhost:8001/health")
print(f"  Health:         {r.status_code}  {r.json()}")

# 7. Phishing
r = httpx.post("http://localhost:8001/predict/phishing", json={
    "url": "http://bit.ly/free-prize-winner", "text": "click now urgent"
})
d = r.json()
print(f"  Phishing:       {r.status_code}  score={d.get('risk_score')} verdict={d.get('verdict')}")

# 8. Fake Profile
r = httpx.post("http://localhost:8001/predict/fake-profile", json={
    "username": "bot12345", "platform": "instagram",
    "profile_data": {"followers": 5, "following": 3000, "posts": 0, "has_profile_photo": False}
})
d = r.json()
print(f"  Fake Profile:   {r.status_code}  score={d.get('risk_score')} verdict={d.get('verdict')}")

# 9. Unsafe Zones
r = httpx.get("http://localhost:8001/predict/unsafe-zone?city=Ahmedabad")
d = r.json()
zones = d.get("zones", [])
print(f"  Unsafe Zones:   {r.status_code}  zones={len(zones)} total_incidents={d.get('statistics', {}).get('total_incidents')}")

# 10. Crime Patterns
r = httpx.get("http://localhost:8001/analytics/pattern")
d = r.json()
print(f"  Patterns:       {r.status_code}  categories={len(d.get('crime_categories', []))} hotspots={len(d.get('top_hotspots', []))}")

print()
print("ALL TESTS COMPLETE")

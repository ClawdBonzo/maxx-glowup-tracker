#!/usr/bin/env python3
"""Create subscription group localizations + subscription localizations (7 locales) via ASC API."""
import jwt, time, requests, os, json
KEY_ID="K34HFNJTXH"; ISSUER="69a6de84-f289-47e3-e053-5b8c7c11a4d1"
P8=os.path.expanduser("~/.appstoreconnect/private_keys/AuthKey_K34HFNJTXH.p8")
BASE="https://api.appstoreconnect.apple.com"
GROUP_ID="22016224"
SUBS={"weekly":"6761698312","monthly":"6761698240","yearly":"6761698287"}
LOCALES=["en-US","ko","pt-BR","de-DE","es-ES","es-MX","tr"]

GROUP_NAME={l:"Maxx Pro" for l in LOCALES}  # brand kept across locales

NAME={
 "weekly":{"en-US":"Maxx Pro Weekly","ko":"Maxx Pro 주간","pt-BR":"Maxx Pro Semanal","de-DE":"Maxx Pro Wöchentlich","es-ES":"Maxx Pro Semanal","es-MX":"Maxx Pro Semanal","tr":"Maxx Pro Haftalık"},
 "monthly":{"en-US":"Maxx Pro Monthly","ko":"Maxx Pro 월간","pt-BR":"Maxx Pro Mensal","de-DE":"Maxx Pro Monatlich","es-ES":"Maxx Pro Mensual","es-MX":"Maxx Pro Mensual","tr":"Maxx Pro Aylık"},
 "yearly":{"en-US":"Maxx Pro Yearly","ko":"Maxx Pro 연간","pt-BR":"Maxx Pro Anual","de-DE":"Maxx Pro Jährlich","es-ES":"Maxx Pro Anual","es-MX":"Maxx Pro Anual","tr":"Maxx Pro Yıllık"},
}
DESC={
 "weekly":{"en-US":"Full Pro access, billed weekly","ko":"모든 Pro 기능, 주간 결제","pt-BR":"Acesso Pro completo, semanal","de-DE":"Voller Pro-Zugang, wöchentlich","es-ES":"Acceso Pro completo, semanal","es-MX":"Acceso Pro completo, semanal","tr":"Tam Pro erişimi, haftalık"},
 "monthly":{"en-US":"Full Pro access. 3-day free trial","ko":"모든 Pro 기능. 3일 무료 체험","pt-BR":"Acesso Pro completo. 3 dias grátis","de-DE":"Voller Pro-Zugang. 3 Tage gratis","es-ES":"Acceso Pro completo. 3 días gratis","es-MX":"Acceso Pro completo. 3 días gratis","tr":"Tam Pro erişimi. 3 gün ücretsiz"},
 "yearly":{"en-US":"Best value. Full Pro access, yearly","ko":"최고의 가치. 모든 Pro 기능, 연간","pt-BR":"Melhor valor. Acesso Pro completo","de-DE":"Bester Wert. Voller Pro-Zugang","es-ES":"Mejor valor. Acceso Pro completo","es-MX":"Mejor precio. Acceso Pro completo","tr":"En iyi değer. Tam Pro erişimi"},
}

def tok():
    now=int(time.time())
    return jwt.encode({"iss":ISSUER,"iat":now,"exp":now+1000,"aud":"appstoreconnect-v1"},open(P8).read(),algorithm="ES256",headers={"kid":KEY_ID})
def H(): return {"Authorization":f"Bearer {tok()}","Content-Type":"application/json"}
def g(u): return requests.get(u,headers={"Authorization":f"Bearer {tok()}"}).json()
def post(u,b):
    r=requests.post(u,headers=H(),json=b)
    if r.status_code>=300: print("  POST ERR",r.status_code,r.text[:300])
    return r
def patch(u,b):
    r=requests.patch(u,headers=H(),json=b)
    if r.status_code>=300: print("  PATCH ERR",r.status_code,r.text[:300])
    return r

# 1. Group localizations
print("== Group localizations ==")
existing={x["attributes"]["locale"]:x["id"] for x in g(f"{BASE}/v1/subscriptionGroups/{GROUP_ID}/subscriptionGroupLocalizations").get("data",[])}
for loc in LOCALES:
    body={"data":{"type":"subscriptionGroupLocalizations","attributes":{"name":GROUP_NAME[loc],"locale":loc},
          "relationships":{"subscriptionGroup":{"data":{"type":"subscriptionGroups","id":GROUP_ID}}}}}
    if loc in existing:
        patch(f"{BASE}/v1/subscriptionGroupLocalizations/{existing[loc]}",{"data":{"type":"subscriptionGroupLocalizations","id":existing[loc],"attributes":{"name":GROUP_NAME[loc]}}})
        print(f"  {loc}: updated")
    else:
        r=post(f"{BASE}/v1/subscriptionGroupLocalizations",body)
        print(f"  {loc}: {'created' if r.status_code<300 else 'FAIL'}")

# 2. Subscription localizations
for plan,sid in SUBS.items():
    print(f"== {plan} ({sid}) ==")
    existing={x["attributes"]["locale"]:x["id"] for x in g(f"{BASE}/v1/subscriptions/{sid}/subscriptionLocalizations").get("data",[])}
    for loc in LOCALES:
        attrs={"name":NAME[plan][loc],"description":DESC[plan][loc],"locale":loc}
        if loc in existing:
            patch(f"{BASE}/v1/subscriptionLocalizations/{existing[loc]}",{"data":{"type":"subscriptionLocalizations","id":existing[loc],"attributes":{"name":attrs["name"],"description":attrs["description"]}}})
            print(f"  {loc}: updated")
        else:
            body={"data":{"type":"subscriptionLocalizations","attributes":attrs,
                  "relationships":{"subscription":{"data":{"type":"subscriptions","id":sid}}}}}
            r=post(f"{BASE}/v1/subscriptionLocalizations",body)
            print(f"  {loc}: {'created' if r.status_code<300 else 'FAIL'}")

# 3. Re-check states
print("== States after ==")
for plan,sid in SUBS.items():
    a=g(f"{BASE}/v1/subscriptions/{sid}")["data"]["attributes"]
    print(f"  {plan}: {a.get('state')}")

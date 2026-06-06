#!/usr/bin/env python3
"""Replace App Store screenshots on the editable iOS version with the new sets.
iPhone -> APP_IPHONE_67 (1290x2796), iPad -> APP_IPAD_PRO_3GEN_129 (2064x2752)."""
import jwt, time, requests, hashlib, os, json

KEY_ID="K34HFNJTXH"; ISSUER="69a6de84-f289-47e3-e053-5b8c7c11a4d1"; APP_ID="6761697914"
P8=os.path.expanduser("~/.appstoreconnect/private_keys/AuthKey_K34HFNJTXH.p8")
BASE="https://api.appstoreconnect.apple.com"
HERE=os.path.dirname(os.path.abspath(__file__))
LOCALES=["en-US","ko","pt-BR","de-DE","es-ES","es-MX","tr"]
IPHONE_DISPLAY="APP_IPHONE_67"; IPAD_DISPLAY="APP_IPAD_PRO_3GEN_129"
IPHONE_DIR=os.path.join(HERE,"v12_iphone"); IPAD_DIR=os.path.join(HERE,"v12_ipad")
FILES=["01-track.png","02-build.png","03-levelup.png","04-see.png","05-unlock.png"]

def token():
    k=open(P8).read(); now=int(time.time())
    return jwt.encode({"iss":ISSUER,"iat":now,"exp":now+1100,"aud":"appstoreconnect-v1"},k,algorithm="ES256",headers={"kid":KEY_ID,"typ":"JWT"})
S=requests.Session()
def hdr(): return {"Authorization":f"Bearer {token()}"}
def g(u): r=S.get(u,headers=hdr()); r.raise_for_status(); return r.json()
def jpost(u,b):
    r=S.post(u,headers={**hdr(),"Content-Type":"application/json"},json=b)
    if r.status_code>=300: print("POST",r.status_code,r.text[:300]); r.raise_for_status()
    return r.json()
def jpatch(u,b):
    r=S.patch(u,headers={**hdr(),"Content-Type":"application/json"},json=b)
    if r.status_code>=300: print("PATCH",r.status_code,r.text[:300]); r.raise_for_status()
    return r.json()
def jdel(u):
    r=S.delete(u,headers=hdr())
    if r.status_code>=300 and r.status_code!=404: print("DEL",r.status_code,r.text[:200])

vers=g(f"{BASE}/v1/apps/{APP_ID}/appStoreVersions?filter[platform]=IOS&limit=50")["data"]
editable={"PREPARE_FOR_SUBMISSION","DEVELOPER_REJECTED","REJECTED","METADATA_REJECTED","WAITING_FOR_REVIEW","INVALID_BINARY"}
ver=next((v for v in vers if v["attributes"]["appStoreState"] in editable),vers[0])
VID=ver["id"]; print("version",ver["attributes"]["versionString"],ver["attributes"]["appStoreState"],VID)
locs=g(f"{BASE}/v1/appStoreVersions/{VID}/appStoreVersionLocalizations?limit=200")["data"]
loc_by={l["attributes"]["locale"]:l["id"] for l in locs}

def get_or_create_set(loc_id,display):
    for s in g(f"{BASE}/v1/appStoreVersionLocalizations/{loc_id}/appScreenshotSets")["data"]:
        if s["attributes"]["screenshotDisplayType"]==display: return s["id"]
    b={"data":{"type":"appScreenshotSets","attributes":{"screenshotDisplayType":display},
       "relationships":{"appStoreVersionLocalization":{"data":{"type":"appStoreVersionLocalizations","id":loc_id}}}}}
    return jpost(f"{BASE}/v1/appScreenshotSets",b)["data"]["id"]
def clear_set(sid):
    for sc in g(f"{BASE}/v1/appScreenshotSets/{sid}/appScreenshots")["data"]:
        jdel(f"{BASE}/v1/appScreenshots/{sc['id']}")
def upload_one(sid,path):
    data=open(path,"rb").read(); fname=os.path.basename(path)
    res=jpost(f"{BASE}/v1/appScreenshots",{"data":{"type":"appScreenshots",
        "attributes":{"fileName":fname,"fileSize":len(data)},
        "relationships":{"appScreenshotSet":{"data":{"type":"appScreenshotSets","id":sid}}}}})
    s2=res["data"]["id"]
    for op in res["data"]["attributes"]["uploadOperations"]:
        h={x["name"]:x["value"] for x in op["requestHeaders"]}
        requests.put(op["url"],headers=h,data=data[op["offset"]:op["offset"]+op["length"]]).raise_for_status()
    jpatch(f"{BASE}/v1/appScreenshots/{s2}",{"data":{"type":"appScreenshots","id":s2,
        "attributes":{"uploaded":True,"sourceFileChecksum":hashlib.md5(data).hexdigest()}}})

report={}
for locale in LOCALES:
    lid=loc_by.get(locale)
    if not lid: report[locale]="NO LOC"; continue
    res={}
    for display,dirp in ((IPHONE_DISPLAY,IPHONE_DIR),(IPAD_DISPLAY,IPAD_DIR)):
        sid=get_or_create_set(lid,display); clear_set(sid); ok=0
        for f in FILES:
            try: upload_one(sid,os.path.join(dirp,f)); ok+=1
            except Exception as e: print(locale,display,f,"FAIL",e)
        res[display]=f"{ok}/{len(FILES)}"
    report[locale]=res; print(locale,res)
print("\n=== REPORT ==="); print(json.dumps(report,indent=1))

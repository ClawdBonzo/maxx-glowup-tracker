#!/usr/bin/env python3
"""Upload localized App Store screenshots via the App Store Connect API.
Uploads the 6.7" (1290x2796) set to APP_IPAD_PRO_3GEN_129 for all 7 locales."""
import jwt, time, requests, hashlib, os, sys, json

KEY_ID = "K34HFNJTXH"
ISSUER = "69a6de84-f289-47e3-e053-5b8c7c11a4d1"
APP_ID = "6761697914"
P8 = os.path.expanduser("~/.appstoreconnect/private_keys/AuthKey_K34HFNJTXH.p8")
BASE = "https://api.appstoreconnect.apple.com"
ROOT = os.path.join(os.path.dirname(__file__), "screenshots_ipad")
DISPLAY = "APP_IPAD_PRO_3GEN_129"

# folder -> ASC localization locale code
LOCALES = {"en":"en-US","ko":"ko","pt-BR":"pt-BR","de":"de-DE","es":"es-ES","es-MX":"es-MX","tr":"tr"}
FILES = ["01-home.png","02-routines.png","03-analytics.png"]  # 6.7" versions

def token():
    key = open(P8).read()
    now = int(time.time())
    return jwt.encode({"iss":ISSUER,"iat":now,"exp":now+1100,"aud":"appstoreconnect-v1"},
                      key, algorithm="ES256", headers={"kid":KEY_ID,"typ":"JWT"})

S = requests.Session()
def hdr(): return {"Authorization":f"Bearer {token()}"}
def g(url,**kw): r=S.get(url,headers=hdr(),**kw); r.raise_for_status(); return r.json()
def jpost(url,body):
    r=S.post(url,headers={**hdr(),"Content-Type":"application/json"},json=body)
    if r.status_code>=300: print("POST ERR",r.status_code,r.text[:500]); r.raise_for_status()
    return r.json()
def jpatch(url,body):
    r=S.patch(url,headers={**hdr(),"Content-Type":"application/json"},json=body)
    if r.status_code>=300: print("PATCH ERR",r.status_code,r.text[:500]); r.raise_for_status()
    return r.json()

# 1. find editable iOS appStoreVersion
vers = g(f"{BASE}/v1/apps/{APP_ID}/appStoreVersions?filter[platform]=IOS&limit=50")["data"]
editable_states = {"PREPARE_FOR_SUBMISSION","DEVELOPER_REJECTED","REJECTED","METADATA_REJECTED","WAITING_FOR_REVIEW","INVALID_BINARY"}
ver = next((v for v in vers if v["attributes"]["appStoreState"] in editable_states), vers[0])
VID = ver["id"]
print("appStoreVersion:", VID, ver["attributes"]["appStoreState"], ver["attributes"]["versionString"])

# 2. localizations
locs = g(f"{BASE}/v1/appStoreVersions/{VID}/appStoreVersionLocalizations?limit=200")["data"]
loc_by_locale = {l["attributes"]["locale"]: l["id"] for l in locs}
print("localizations present:", list(loc_by_locale.keys()))

def get_or_create_set(loc_id):
    sets = g(f"{BASE}/v1/appStoreVersionLocalizations/{loc_id}/appScreenshotSets")["data"]
    for s in sets:
        if s["attributes"]["screenshotDisplayType"] == DISPLAY:
            return s["id"]
    body={"data":{"type":"appScreenshotSets","attributes":{"screenshotDisplayType":DISPLAY},
          "relationships":{"appStoreVersionLocalization":{"data":{"type":"appStoreVersionLocalizations","id":loc_id}}}}}
    return jpost(f"{BASE}/v1/appScreenshotSets",body)["data"]["id"]

def existing_count(set_id):
    return len(g(f"{BASE}/v1/appScreenshotSets/{set_id}/appScreenshots")["data"])

def upload_one(set_id, path):
    data = open(path,"rb").read()
    fname = os.path.basename(path)
    # reserve
    res = jpost(f"{BASE}/v1/appScreenshots", {"data":{"type":"appScreenshots",
        "attributes":{"fileName":fname,"fileSize":len(data)},
        "relationships":{"appScreenshotSet":{"data":{"type":"appScreenshotSets","id":set_id}}}}})
    sid = res["data"]["id"]
    ops = res["data"]["attributes"]["uploadOperations"]
    for op in ops:
        h = {hh["name"]:hh["value"] for hh in op["requestHeaders"]}
        chunk = data[op["offset"]:op["offset"]+op["length"]]
        rr = requests.put(op["url"], headers=h, data=chunk); rr.raise_for_status()
    md5 = hashlib.md5(data).hexdigest()
    jpatch(f"{BASE}/v1/appScreenshots/{sid}",
           {"data":{"type":"appScreenshots","id":sid,"attributes":{"uploaded":True,"sourceFileChecksum":md5}}})
    return sid

report={}
for folder, locale in LOCALES.items():
    loc_id = loc_by_locale.get(locale)
    if not loc_id:
        report[folder]=f"NO LOCALIZATION {locale}"; print(report[folder]); continue
    set_id = get_or_create_set(loc_id)
    if existing_count(set_id) > 0:
        report[folder]="skipped (already has screenshots)"; print(folder,report[folder]); continue
    ok=0
    for f in FILES:
        p=os.path.join(ROOT,folder,f)
        try: upload_one(set_id,p); ok+=1
        except Exception as e: print(folder,f,"FAIL",e)
    report[folder]=f"{ok}/3 uploaded -> set {set_id}"
    print(folder, report[folder])

print("\n=== REPORT ===")
print(json.dumps(report,indent=1))

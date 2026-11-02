"""Opt-in official Poly Haven texture download for NEXUS, run on your PC.

Does not run automatically in ChatGPT; only CC0 from Poly Haven API.
API usage should visibly credit 'Powered by Poly Haven' per its public API ToS.
Never mix third-party Fab/Mixamo packs into redistributed source ZIPs.
"""
from pathlib import Path
import urllib.request,json,time,hashlib
BASE="https://api.polyhaven.com/files/"
IDS=["cracked_concrete","painted_plaster_wall","concrete"]
MAPS={"albedo":["Diffuse","diff"],"normal":["nor_dx","Normal (DX)"],
      "roughness":["Rough","rough"],"ao":["AO","ao"],"metallic":["Metallic","metal"]}
RESOLUTION="2k"
FMT=("png","jpg")

def fetch(url):
    if not url.startswith(("https://api.polyhaven.com/","https://dl.polyhaven.org/")):
        raise ValueError("Unexpected asset host")
    req=urllib.request.Request(url,headers={"User-Agent":"NEXUS-Licensed-CC0-Importer/1.0"})
    with urllib.request.urlopen(req,timeout=30) as response:
        return response.read()

def pick(info,names):
    for key in names:
        obj=info.get(key)
        if not isinstance(obj,dict):continue
        resolutions=[RESOLUTION,"1k","4k"]
        for resolution in resolutions:
            row=obj.get(resolution,{})
            if isinstance(row,dict):
                for fmt in FMT:
                    leaf=row.get(fmt)
                    if isinstance(leaf,dict) and leaf.get("url"):
                        return leaf["url"],resolution,fmt
    return None

def main(target):
    target=Path(target);target.mkdir(parents=True,exist_ok=True)
    record={"provider":"Poly Haven","asset_license":"CC0-1.0",
            "api_credit":"Powered by Poly Haven","assets":[]}
    for asset in IDS:
        info=json.loads(fetch(BASE+asset).decode("utf-8"))
        out=target/asset
        out.mkdir(exist_ok=True)
        details={"id":asset,"source_page":"https://polyhaven.com/a/"+asset,"maps":[]}
        for ch,aliases in MAPS.items():
            item=pick(info,aliases)
            if item is None:continue
            url,res,ext=item
            data=fetch(url)
            p=out/(asset+"_"+ch+"_"+res+"."+ext)
            p.write_bytes(data)
            details["maps"].append({"channel":ch,"file":p.name,
                "sha256":hashlib.sha256(data).hexdigest(),"source_url":url})
            time.sleep(.4)
        record["assets"].append(details)
    (target/"CC0_PROVENANCE.json").write_text(json.dumps(record,indent=2),encoding="utf-8")
    print("Downloaded verified-provider material sources to",target)
if __name__=="__main__":
    import argparse
    parser=argparse.ArgumentParser()
    parser.add_argument("target",nargs="?",default="Content/SourceArt/PolyHaven_CC0")
    main(parser.parse_args().target)

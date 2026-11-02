"""Inspect official Poly Haven public API models before a CC0 asset import.
No credentials and no download beyond metadata in this step.
API credit: Powered by Poly Haven — https://polyhaven.com
"""
import json, pathlib, urllib.request
OUT=pathlib.Path("build/polyhaven_metadata")
OUT.mkdir(parents=True,exist_ok=True)
for asset in ("rock_moss_set_02","mossy_rock"):
    url=f"https://api.polyhaven.com/files/{asset}"
    req=urllib.request.Request(url,headers={"User-Agent":"NEXUS-CC0-AssetResearch/1.0"})
    with urllib.request.urlopen(req,timeout=20) as res:
        data=json.load(res)
    (OUT/(asset+".json")).write_text(json.dumps(data,indent=2),encoding="utf-8")
    print("ASSET",asset,"FORMATS",list(data.keys()))
    for fmt,content in data.items():
        if isinstance(content,dict):
            print(" FORMAT",fmt,"RESOLUTIONS",list(content.keys())[:12])
            if fmt=="gltf":
                for key,value in content.items():
                    if isinstance(value,dict):print("  ENTRY",key,"MEMBERS",list(value.keys())[:20])
print("NEXUS_POLYHAVEN_API_PROBE_COMPLETE")

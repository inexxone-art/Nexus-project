"""Generate original architectural GLBs for the NEXUS UE5 kit.

Offline build: python Scripts/generate_nexus_buildings.py <output-folder>
Requires trimesh and numpy. Units: metres, Z up. Outputs are modular
3D prototypes with physically modeled windows, doors, roof, balcony,
interior floor and facade trim, NOT photogrammetric AAA hero assets.
"""
import json
import sys
from pathlib import Path
import numpy as np
import trimesh

def cuboid(parts, center, size, rgba):
    mesh=trimesh.creation.box(extents=size)
    mesh.apply_translation(center)
    mesh.visual.vertex_colors=np.tile(np.array(rgba,dtype=np.uint8),(len(mesh.vertices),1))
    parts.append(mesh)

def build(style, width=12., depth=9., levels=2):
    parts=[]
    palettes={
        "alpine":((179,161,136,255),(81,56,38,255),(70,64,57,255)),
        "european":((202,195,175,255),(224,224,216,255),(76,73,74,255)),
        "contemporary":((132,134,131,255),(55,66,74,255),(40,43,47,255)),
        "urban":((145,151,158,255),(58,74,90,255),(44,48,53,255)),
        "industrial":((116,126,134,255),(67,73,79,255),(62,62,62,255)),
        "civic":((184,181,174,255),(66,85,99,255),(72,77,79,255)),
        "transport":((154,158,161,255),(71,90,99,255),(54,60,65,255)),
        "planetary":((194,199,204,255),(75,100,119,255),(62,72,82,255)),
        "orbital":((168,180,190,255),(48,82,110,255),(41,50,58,255)),
        "ignis":((66,62,61,255),(160,79,40,255),(45,44,44,255)),
        "nivora":((180,203,213,255),(75,132,153,255),(80,100,114,255)),
        "sahra":((199,159,114,255),(99,84,64,255),(116,91,66,255)),
        "umbra":((86,81,109,255),(94,148,159,255),(56,53,71,255))
    }
    facade,window,roof=palettes[style]
    h=levels*3.15
    # Shell uses segmented walls, preserving actual window/door openings.
    cuboid(parts,(0,0,-.16),(width+.5,depth+.5,.32),(99,97,92,255))
    for level in range(levels):
        z=level*3.15
        cuboid(parts,(0,0,z+.12),(width-.24,depth-.24,.24),(145,138,126,255))
        for front in [-1,1]:
            y=front*depth/2
            for i in range(4):
                x=-width/2+(i+.5)*width/4
                seg=width/4-.1
                if level==0 and front==-1 and i==1:
                    # A walkable doorway, 1.2 m wide, 2.2 m high.
                    cuboid(parts,(x-seg*.36,y,z+1.6),(seg*.28,.24,3.2),facade)
                    cuboid(parts,(x+seg*.36,y,z+1.6),(seg*.28,.24,3.2),facade)
                    cuboid(parts,(x,y,z+2.72),(seg*.5,.24,.55),facade)
                    cuboid(parts,(x,y,z+1.1),(1.16,.10,2.2),(87,59,40,255))
                else:
                    cuboid(parts,(x,y,z+.45),(seg,.24,.9),facade)
                    cuboid(parts,(x,y,z+2.77),(seg,.24,.76),facade)
                    for sign in [-1,1]:
                        cuboid(parts,(x+sign*seg*.46,y,z+1.73),(.12,.24,1.72),facade)
                    cuboid(parts,(x,y,z+1.73),(seg*.88,.08,1.55),window)
                    cuboid(parts,(x,y+front*.17,z+1.73),(.08,.09,1.55),roof)
                    cuboid(parts,(x,y,z+2.55),(seg,.31,.09),roof)
        for side in [-1,1]:
            x=side*width/2
            for i in range(3):
                y=-depth/2+(i+.5)*depth/3
                cuboid(parts,(x,y,z+.55),(.25,depth/3-.1,1.1),facade)
                cuboid(parts,(x,y,z+2.76),(.25,depth/3-.1,.78),facade)
                cuboid(parts,(x,y,z+1.72),(.13,depth/3-.28,1.35),window)
                cuboid(parts,(x+side*.11,y,z+1.72),(.10,.09,1.35),roof)
        cuboid(parts,(0,0,z+3.05),(width+.4,depth+.4,.15),facade)
    # Roof silhouette and eaves are physically present.
    cuboid(parts,(0,0,h+.16),(width+.9,depth+.9,.32),roof)
    for sign in [-1,1]:
        cuboid(parts,(0,sign*(depth/2+.4),h+.26),(width+.9,.16,.20),roof)
    # Distinct balcony and railing on the front facade.
    if levels>1:
        cuboid(parts,(width*.24,-depth/2-.8,3.18),(width*.36,1.6,.16),roof)
        for k in range(7):
            x=width*.07+k*width*.06
            cuboid(parts,(x,-depth/2-1.54,3.68),(.08,.08,1.),roof)
        cuboid(parts,(width*.24,-depth/2-1.54,4.18),(width*.38,.10,.12),roof)
    # Entry steps and roof HVAC/chimney.
    cuboid(parts,(-width*.125,-depth/2-.7,.08),(2.2,1.4,.16),(130,127,123,255))
    cuboid(parts,(width*.3,depth*.22,h+.9),(.65,.65,1.7),facade)
    return trimesh.Scene(trimesh.util.concatenate(parts))

def main(out):
    catalog=json.loads((Path(__file__).resolve().parents[1]/"Content/Data/nexus_building_world_catalog.json").read_text())
    out.mkdir(parents=True,exist_ok=True)
    manifest=[]
    for building in catalog["buildings"]:
        i=int(building["id"][1:])
        levels=3 if i in (4,6,8,11) else 2
        width=16. if i in (6,8,9,10,12,14,15,18,20) else 12.
        scene=build(building["style"],width=width,levels=levels)
        path=out/(building["id"]+"_"+building["style"]+".glb")
        path.write_bytes(scene.export(file_type="glb"))
        manifest.append({"id":building["id"],"file":path.name,"status":"PROTOTYPE_NOT_PHOTOREAL","meters":True})
    (out/"MANIFEST.json").write_text(json.dumps(manifest,indent=2)+"\n")
    print(f"Generated {len(manifest)} modular architectural GLBs in {out}")

if __name__=="__main__":
    main(Path(sys.argv[1] if len(sys.argv)>1 else "Content/SourceArt/Geometry/Buildings"))

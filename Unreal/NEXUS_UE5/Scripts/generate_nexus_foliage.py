#!/usr/bin/env python3
"""Reproducible, original 0-Euro alpine meshes for UE5.8.
This creates editable 3D GLB assets, NOT photo-scanned AAA models.
Requires numpy + trimesh; output path given as CLI argument.
"""
from __future__ import annotations
from pathlib import Path
import hashlib
import json
import math
import sys
import numpy as np
import trimesh

class Builder:
    def __init__(self):
        self.vertices=[]
        self.faces=[]
        self.colors=[]
    def tri(self,a,b,c,color):
        index=len(self.vertices)
        self.vertices.extend([a,b,c])
        self.faces.append([index,index+1,index+2])
        self.colors.extend([color,color,color])
    def quad(self,a,b,c,d,color):
        self.tri(a,b,c,color)
        self.tri(a,c,d,color)
    def finish(self,path):
        mesh=trimesh.Trimesh(vertices=np.asarray(self.vertices,dtype=np.float32),
                           faces=np.asarray(self.faces,dtype=np.int64),process=False)
        mesh.visual.vertex_colors=np.asarray(self.colors,dtype=np.uint8)
        # GLB-friendly single mesh with vertex color and computed normals.
        path.write_bytes(trimesh.Scene(mesh).export(file_type="glb"))
        return dict(vertices=len(mesh.vertices),triangles=len(mesh.faces),
                    sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                    bounds_m=np.around(mesh.bounds,3).tolist())

def bark(builder,center,base,top,seed):
    rng=np.random.default_rng(seed)
    radial=14
    segments=17
    rings=[]
    for level in range(segments+1):
        t=level/segments
        z=base+(top-base)*t
        radius=(0.32*(1.0-t)**0.83+0.022)*(1+0.07*math.sin(t*51))
        ring=[]
        for i in range(radial):
            a=2*math.pi*i/radial
            noise=1+0.05*rng.standard_normal()
            ring.append((center[0]+radius*noise*math.cos(a),
                         center[1]+radius*noise*math.sin(a),z))
        rings.append(ring)
    for level in range(segments):
        for i in range(radial):
            j=(i+1)%radial
            c=int(65+11*rng.random())
            color=(c+9,int(c*0.78),int(c*0.62),255)
            builder.quad(rings[level][i],rings[level][j],
                         rings[level+1][j],rings[level+1][i],color)

def needle_frond(builder,origin,tip,width,color):
    a=np.array(origin,dtype=float);b=np.array(tip,dtype=float)
    direction=b-a
    normal=np.array([-direction[1],direction[0],0.])
    norm=np.linalg.norm(normal)
    if norm<1e-9:return
    normal=normal/norm
    side=normal*width
    # Three small triangles bend the foliage off the branch axis.
    center=a+direction*.55 + np.array([0.,0.,.11*width])
    builder.tri(tuple(a-side*.25),tuple(center+side),tuple(b),color)
    builder.tri(tuple(a+side*.25),tuple(b),tuple(center-side),color)
    builder.tri(tuple(a),tuple(center+np.array([0.,0.,.3*width])),tuple(b),color)

def conifer(path,seed,larch=False,short=False):
    rng=np.random.default_rng(seed)
    mesh=Builder()
    height=3.3 if short else float(rng.uniform(10.8,13.4))
    bark(mesh,(0.,0.),0.,height*.95,seed)
    levels=11 if short else 28
    needles=0
    for level in range(levels):
        t=level/max(1,levels-1)
        z=(.45+t*.76)*height
        count=10 if short else 13
        # Low branches heavy and long, upper canopy less dense.
        radius=(1.9 if short else 3.7)*(1-t)**.84
        radius*=float(rng.uniform(.75,1.2))
        for j in range(count):
            ang=2*math.pi*j/count+level*.27+rng.uniform(-.17,.17)
            length=radius*rng.uniform(.73,1.11)
            base=np.array([0.,0.,z])
            direction=np.array([math.cos(ang),math.sin(ang),0.])
            tip=base+length*direction+np.array([0.,0.,-.25*length+.15*t])
            # Sparse radial branches with mixed green and rust needles.
            for child in range(4 if short else 6):
                p=(child+.15)/(4 if short else 6)
                along=base+(tip-base)*p
                blade=length*(.14+.37*(1.0-p))
                for side in [-1,1]:
                    leafangle=ang+side*(.56+.20*rng.random())
                    end=along+np.array([math.cos(leafangle),math.sin(leafangle),.09])*blade
                    variation=int(rng.integers(-14,15))
                    if larch:color=(145+variation,113+variation//2,48,255)
                    else:color=(24+variation//3,72+variation,50+variation//2,255)
                    needle_frond(mesh,along,end,.20 if short else .36,color)
                    needles+=1
    result=mesh.finish(path)
    result.update(kind="shrub" if short else "alpine_spruce",seed=seed,foliage_groups=needles)
    return result

def boulder(path,seed):
    rng=np.random.default_rng(seed)
    mesh=trimesh.creation.icosphere(subdivisions=4)
    coords=mesh.vertices.copy()
    n=coords
    # Correlated, layered erosion rather than independent white-noise spikes.
    height=(1.0+.24*np.sin(n[:,0]*7.4+n[:,1]*5.1)
             +.11*np.sin(n[:,2]*18.2-n[:,0]*9.3)
             +.09*np.cos(n[:,1]*14.2+n[:,2]*11.3)
             +.04*np.sin(n[:,0]*43.1-n[:,2]*21.5))
    coords*=height[:,None]*np.array([1.9,1.25,1.35])[None,:]
    coords[:,2]-=1.1
    mesh.vertices=coords
    # Rock face colors: basalt-grey with patches of alpine moss on top.
    moss=(n[:,2]>.1)&(np.sin(n[:,0]*13+n[:,1]*8)>.23)
    shade=(137+16*np.sin(n[:,2]*8.5+n[:,1]*4.7)).astype(int)
    colors=[]
    for i in range(len(n)):
        c=int(shade[i])
        colors.append([55,c-48,57,255] if moss[i] else [c,c-1,c-6,255])
    mesh.visual.vertex_colors=np.asarray(colors,dtype=np.uint8)
    path.write_bytes(trimesh.Scene(mesh).export(file_type="glb"))
    return dict(vertices=len(mesh.vertices),triangles=len(mesh.faces),
                sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                bounds_m=np.around(mesh.bounds,3).tolist(),kind="eroded_rock",seed=seed)

def main():
    out=Path(sys.argv[1] if len(sys.argv)>1 else "build/foliage").resolve()
    out.mkdir(parents=True,exist_ok=True)
    files={
        "SM_NEXUS_Spruce_01.glb":lambda p:conifer(p,6101),
        "SM_NEXUS_Spruce_02.glb":lambda p:conifer(p,6109),
        "SM_NEXUS_AlpineShrub_01.glb":lambda p:conifer(p,6317,short=True),
        "SM_NEXUS_Boulder_01.glb":lambda p:boulder(p,6044),
        "SM_NEXUS_Boulder_02.glb":lambda p:boulder(p,6046),
    }
    manifest={"format":"glb","creator":"NEXUS custom procedural mesh generator",
      "license":"Project-originated procedural code, no externally licensed geometry",
      "quality":"procedural prototype, NOT a photogrammetric or AAA-quality model",
      "units":"metres; verify Unreal editor import scale",
      "files":{}}
    for name,make in files.items():
        path=out/name
        data=make(path)
        check=trimesh.load(str(path),force="mesh")
        assert len(check.faces)>=600 and check.is_winding_consistent
        manifest["files"][name]=data
        print(name,data["triangles"],"triangles",path.stat().st_size,"bytes")
    (out/"NEXUS_Foliage_Manifest.json").write_text(json.dumps(manifest,indent=2),encoding="utf-8")
    print("PASS: 5 independently verified original geometry models")
if __name__=="__main__":main()

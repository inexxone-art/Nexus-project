import importlib.util
import json
from pathlib import Path
import struct
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'tools' / 'import_real_assets.py'
spec = importlib.util.spec_from_file_location('nexus_assets_v24', SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def glb(meshes=True):
    d = {'asset': {'version': '2.0'}, 'meshes': [{'name':'body'}] if meshes else [], 'animations':[{'name':'rotor-spin'}]}
    chunk = json.dumps(d).encode('utf8')
    chunk += b' ' * ((-len(chunk))%4)
    return struct.pack('<4sII', b'glTF', 2, 20+len(chunk)) + struct.pack('<I4s',len(chunk),b'JSON')+chunk

class ImporterTests(unittest.TestCase):
    def test_valid_binary_glb(self):
        self.assertEqual(module.read_glb_header(glb())['mesh_count'],1)
        self.assertEqual(module.read_glb_header(glb())['animation_names'],['rotor-spin'])

    def test_rejects_invalid_glb(self):
        with self.assertRaises(ValueError):module.read_glb_header(b'not glb')
        with self.assertRaises(ValueError):module.read_glb_header(glb(False))
        with self.assertRaises(ValueError):module.read_glb_header(glb() + b'bad')

    def test_excavator_selection(self):
        demo={'models':[{'name':'Tracked excavator with hydraulic breaker','id':12}, {'name':'Tracked excavator with digging bucket','cdnUrl':'https://cdn.3dassets.dev/assets/42/v1/model.glb'}, {'name':'High reach excavator','id':24}]}
        self.assertEqual(module.find_excavator(demo),'https://cdn.3dassets.dev/assets/42/v1/model.glb')
        self.assertEqual(module.find_excavator({}), '')

    def test_texture_channel_routing(self):
        fixture={'Diffuse':{'2k':{'jpg':{'url':'https://dl.polyhaven.org/1.jpg'}}},'nor_gl':{'2k':{'png':{'url':'https://dl.polyhaven.org/2.png'}}},'Rough':{'1k':{'png':{'url':'https://dl.polyhaven.org/3.png'}}}}
        self.assertEqual(module.poly_file_url(fixture,'albedo','2k'), ('https://dl.polyhaven.org/1.jpg','jpg'))
        self.assertEqual(module.poly_file_url(fixture,'normal','2k'), ('https://dl.polyhaven.org/2.png','png'))
        self.assertEqual(module.poly_file_url(fixture,'roughness','2k'), ('https://dl.polyhaven.org/3.png','png'))

    def test_atomic_files(self):
        with tempfile.TemporaryDirectory() as t:
            p=Path(t)/'new'/'data.glb'
            module.store(p,glb())
            self.assertEqual(p.read_bytes(),glb())

if __name__=='__main__': unittest.main()

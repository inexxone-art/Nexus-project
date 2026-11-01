"""Lightweight tests for official trailer manifest and capture integrity rules."""
import importlib.util
import json
import pathlib
import unittest

ROOT=pathlib.Path(__file__).resolve().parents[1]
SPEC=importlib.util.spec_from_file_location('nexus_trailer',ROOT/'tools'/'build_trailer.py')
module=importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(module)

class TrailerTests(unittest.TestCase):
    def test_eight_distinct_shots(self):
        data=json.loads((ROOT/'trailer'/'shotlist.json').read_text())
        self.assertEqual(len(data['shots']),8)
        self.assertEqual(len({item['id'] for item in data['shots']}),8)
        self.assertEqual(sum(item["duration"] for item in data["shots"])+data["intro_seconds"]+data["outro_seconds"],75)
    def test_no_missing_captures_silently_faked(self):
        data=json.loads((ROOT/'trailer'/'shotlist.json').read_text())
        with self.assertRaises(FileNotFoundError):
            module.validate(data)
    def test_no_external_movie_accepted(self):
        data=json.loads((ROOT/'trailer'/'shotlist.json').read_text())
        data['shots'][0]['source']='some_external_video.mp4'
        with self.assertRaises(ValueError):
            module.validate(data)

if __name__=='__main__': unittest.main()
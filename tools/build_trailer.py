#!/usr/bin/env python3
"""Assemble a PROJECT NEXUS trailer from verified in-engine gameplay captures.

Requires ffmpeg/ffprobe, no external Python dependencies. It intentionally
refuses missing captures rather than replacing gameplay with synthetic shots.
"""
from __future__ import annotations
import argparse
import json
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / 'trailer' / 'shotlist.json'


def run(*args: str) -> None:
    subprocess.run(list(args), check=True, stdout=subprocess.DEVNULL)


def probe(path: Path) -> dict:
    p = subprocess.run(['ffprobe','-v','error','-show_entries',
                        'format=duration:stream=codec_type,width,height',
                        '-of','json',str(path)], check=True, capture_output=True, text=True)
    return json.loads(p.stdout)


def validate(manifest: dict) -> list[tuple[Path, dict]]:
    shots = manifest.get('shots', [])
    if not shots:
        raise ValueError('Keine Trailer-Shots im Manifest.')
    missing = []
    result = []
    seen = set()
    for shot in shots:
        src = str(shot['source'])
        if shot['id'] in seen:
            raise ValueError('Doppelte Shot-ID: ' + shot['id'])
        seen.add(shot['id'])
        if not src.startswith('captures/gameplay/') or not src.endswith('.mp4'):
            raise ValueError('Trailer akzeptiert nur Gameplay-Aufnahmen in captures/gameplay: ' + src)
        path = (ROOT / src).resolve()
        if not path.is_relative_to((ROOT / 'captures' / 'gameplay').resolve()):
            raise ValueError('Ungültiger Pfad: ' + src)
        if not path.exists():
            missing.append(src)
        if shot['duration'] <= 0:
            raise ValueError('Ungültige Shot-Dauer: ' + shot['id'])
        result.append((path, shot))
    if missing:
        raise FileNotFoundError('Echte Gameplay-Captures fehlen:\n' + '\n'.join(missing))
    return result


def title_card(path: Path, title: str, seconds: int, width: int, height: int, fps: int) -> None:
    # Text rendering can vary across systems; use a plain title-safe black card.
    # Project text is added with optional drawtext only if a working font is available.
    vf = f'format=yuv420p'
    font = Path('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf')
    if font.exists():
        sanitized = title.replace("'", "").replace(':', '\\:')
        vf += f",drawtext=fontfile={font}:text='{sanitized}':fontcolor=white:fontsize=52:x=(w-text_w)/2:y=(h-text_h)/2"
    run('ffmpeg','-hide_banner','-loglevel','error','-y',
        '-f','lavfi','-i',f'color=c=black:s={width}x{height}:r={fps}:d={seconds}',
        '-vf',vf,'-t',str(seconds),'-c:v','libx264','-crf','18','-preset','medium',
        '-pix_fmt','yuv420p','-an',str(path))


def assemble(manifest: dict, shots: list[tuple[Path,dict]], output: Path, music: Path | None) -> None:
    if not shutil.which('ffmpeg') or not shutil.which('ffprobe'):
        raise RuntimeError('ffmpeg und ffprobe erforderlich.')
    w, h, fps = (int(manifest[k]) for k in ('width','height','frame_rate'))
    if not 320 <= w <= 7680 or not 240 <= h <= 4320 or not 12 <= fps <= 120:
        raise ValueError('Ungültige Videoausgabe.')
    with tempfile.TemporaryDirectory(prefix='nexus_trailer_') as tmp:
        folder = Path(tmp)
        clips = []
        intro = folder / 'intro.mp4'
        title_card(intro, 'PROJECT NEXUS', int(manifest.get('intro_seconds',3)), w,h,fps)
        clips.append(intro)
        for idx, (path, item) in enumerate(shots):
            info = probe(path)
            duration = float(info.get('format',{}).get('duration',0))
            if duration + 0.04 < float(item['duration']):
                raise ValueError(f'Gameplay-Clip zu kurz: {item["id"]} ({duration:.1f}s)')
            if not any(s.get('codec_type') == 'video' for s in info.get('streams', [])):
                raise ValueError('Videospur fehlt: ' + str(path))
            outfile = folder / f'shot_{idx:02d}.mp4'
            seconds = float(item['duration'])
            vf = (f'scale={w}:{h}:force_original_aspect_ratio=increase,'
                  f'crop={w}:{h},fps={fps},format=yuv420p,'
                  f'fade=t=in:st=0:d=0.45,fade=t=out:st={max(0,seconds-0.45)}:d=0.45')
            run('ffmpeg','-hide_banner','-loglevel','error','-y',
                '-i',str(path),'-t',str(seconds),'-vf',vf,
                '-an','-c:v','libx264','-crf','18','-preset','medium',
                '-pix_fmt','yuv420p',str(outfile))
            clips.append(outfile)
        outro = folder / 'outro.mp4'
        title_card(outro,'PROJECT NEXUS - WORK IN PROGRESS',int(manifest.get('outro_seconds',4)),w,h,fps)
        clips.append(outro)
        txt = folder / 'concat.txt'
        txt.write_text(''.join(f"file '{p.as_posix()}'\n" for p in clips), encoding='utf-8')
        output.parent.mkdir(parents=True, exist_ok=True)
        if music:
            if not music.exists():
                raise FileNotFoundError('Musikdatei fehlt: ' + str(music))
            run('ffmpeg','-hide_banner','-loglevel','error','-y',
                '-f','concat','-safe','0','-i',str(txt),'-stream_loop','-1','-i',str(music),
                '-map','0:v:0','-map','1:a:0','-c:v','copy','-c:a','aac','-b:a','192k',
                '-shortest','-movflags','+faststart',str(output))
        else:
            run('ffmpeg','-hide_banner','-loglevel','error','-y',
                '-f','concat','-safe','0','-i',str(txt),'-c:v','copy',
                '-movflags','+faststart',str(output))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest',type=Path,default=DEFAULT_MANIFEST)
    parser.add_argument('--output',type=Path,default=ROOT/'build'/'PROJECT_NEXUS_OFFICIAL_TRAILER.mp4')
    parser.add_argument('--music',type=Path,help='Only original or properly licensed audio.')
    args = parser.parse_args()
    manifest = json.loads(args.manifest.read_text(encoding='utf-8'))
    shots = validate(manifest)
    assemble(manifest,shots,args.output,args.music)
    print('FERTIG:',args.output)

if __name__ == '__main__':
    main()
"""Reproduce acceptance evidence from hash-verified, read-only source captures.

Run from repository root. Requires Pillow/numpy. Never updates a golden.
"""
import hashlib
import json
import math
from io import BytesIO
import zipfile
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'docs/reports/auth-conformance'
OUT = ROOT / 'docs/reports/auth-acceptance'
OUT.mkdir(parents=True, exist_ok=True)


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def save(name, data):
    (OUT / name).write_text(json.dumps(data, indent=2) + '\n', encoding='utf-8')


def ink():
    data = json.loads(read(SOURCE / 'figma-text-evidence.json')['content'][0]['text'])
    nodes = {t['id']: t for f in data['frames'] for t in f['texts']}
    runtime = read(SOURCE / 'runtime-measurements.json')
    rows = []
    for row in read(SOURCE / 'rect-comparison.json'):
        if not row['aboveTolerance'] or not row['element'].startswith('text '):
            continue
        node = nodes[row['element'].split(' ', 2)[1]]
        state = 'focused' if row['state'] == 'focusedEmpty' else row['state']
        color = node['segments'][0]['fills'][0]['color']
        fg = np.array([color[k] * 255 for k in 'rgb'])
        boxes = []
        for label in ['figma', 'ours']:
            rect = row[label]
            im = np.asarray(Image.open(SOURCE / f'{label}-{state}.png').convert('RGB'))
            x = math.floor(rect['x'])
            y = math.floor(rect['y'])
            crop = im[y:math.ceil(rect['y'] + rect['height']),
                      x:math.ceil(rect['x'] + rect['width'])].astype(float)
            colors, counts = np.unique(crop.reshape(-1, 3), axis=0, return_counts=True)
            bg = colors[counts.argmax()]
            direction = fg - bg
            alpha = ((crop - bg) @ direction) / (direction @ direction)
            residual = abs(crop - (bg + alpha[..., None] * direction)).max(axis=2)
            # Include every non-background AA pixel on the text paint ramp.
            # The 2-level residual allows RGB rounding, not ink thresholding.
            mask = ((abs(crop - bg).max(axis=2) >= 1) &
                    (alpha > 0) & (alpha <= 1.03) & (residual <= 2))
            # Editing caret is a separate visible element, not glyph ink.
            if node['text'] in [e['text'] for e in runtime[row['state']]['editable']]:
                editable = runtime[row['state']]['editable'][0]
                if label == 'ours':
                    caret = editable['caretRect']
                else:
                    caret_rows = [r for r in read(SOURCE / 'rect-comparison.json')
                                  if r['state'] == row['state'] and 'caret' in r['element'].lower()]
                    caret = caret_rows[0]['figma'] if caret_rows else None
                if caret:
                    # A vector stroke's AA fringe extends one pixel outside its
                    # geometric rect; exclude that separate caret fringe too.
                    xx0, xx1 = max(0, math.floor(caret['x']) - x - 1), min(mask.shape[1], math.ceil(caret['x'] + caret['width']) - x + 1)
                    yy0, yy1 = max(0, math.floor(caret['y']) - y - 1), min(mask.shape[0], math.ceil(caret['y'] + caret['height']) - y + 1)
                    mask[yy0:yy1, xx0:xx1] = False
            ys, xs = np.where(mask)
            boxes.append([int(xs.min() + x), int(ys.min() + y),
                          int(xs.max() - xs.min() + 1), int(ys.max() - ys.min() + 1)])
        delta = [b - a for a, b in zip(*boxes)]
        rendered = runtime[row['state']]['paragraphs'] + runtime[row['state']]['editable']
        actual_text = next((p['text'] for p in rendered if
                            p['text'].strip().casefold() == node['text'].strip().casefold()), node['text'])
        rows.append(dict(element=node['text'], oursText=actual_text, state=row['state'], boundsDelta=row['delta'],
                         figmaInk=boxes[0], oursInk=boxes[1], inkDelta=delta,
                         passed=max(map(abs, delta)) <= 1))
    save('ink.json', rows)
    lines = ['# Glyph ink evidence', '',
             'Figma captures are read-only 402×874 exports from the preceding conformance task. '
             'Coordinates are global pixels at DPR1. Each text crop uses its measured frame; '
             'the modal flat background and source foreground define the AA paint ramp. '
             'Every differing pixel on that ramp is included (minimum difference 1/255); '
             'a maximum residual of 2/255 permits channel rounding. Caret rects are excluded '
             'using independently recorded geometry plus a one-pixel vector AA fringe. '
             'Where caret and glyph ink overlap the original glyph cannot be recovered; '
             'the exclusion is conservative. No image registration or per-string offsets. '
             'This measures a bbox, not glyph-by-glyph raster equality or font identity.', '',
             '|Element|State|Bounds Δ x/y/w/h|Figma ink x/y/w/h|Ours ink x/y/w/h|Ink Δ x/y/w/h|Result|',
             '|---|---|---|---|---|---|---|']
    for r in rows:
        bounds = '/'.join(f'{r["boundsDelta"][k]:+.3f}' for k in ['x', 'y', 'width', 'height'])
        lines.append(f'|{r["element"]}|{r["state"]}|{bounds}|{r["figmaInk"]}|{r["oursInk"]}|{r["inkDelta"]}|{"PASS" if r["passed"] else "FAIL"}|')
    lines += ['', f'Passed {sum(r["passed"] for r in rows)}/{len(rows)}. '
              'Container aliases (title/reward) are represented by their text children; carets and divider strokes are not text.']
    if any(not row['passed'] for row in rows):
        lines += ['', 'Failure diagnosis: Figma `Playstation` vs product ARB `PlayStation` '
              '(uppercase S). Both request Outfit600,14/18,-0.56 tracking. '
              'This is a copy-case mismatch (E-016), not a demonstrated font-weight defect. '
              'Propose agreeing the label copy and updating localization consistently; '
              'no per-string font, width, transform or offset compensation. '
              'No per-string font or geometric compensation is applied.']
    else:
        lines += ['', 'All measured ink deltas are within1px. D-062 aligns the localized '
                  'label with the source copy; no font, tracking, width or offset hack.']
    (OUT / 'ink.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print('Ink:', sum(r['passed'] for r in rows), '/', len(rows))


def sheets():
    archive_path = OUT / 'review-before.zip'
    archive = zipfile.ZipFile(archive_path) if archive_path.exists() else None
    archive_manifest = json.loads(archive.read('manifest.json')) if archive else None
    before_path = ROOT / 'build/auth-conformance/before-image-locations.json'
    before = read(before_path) if before_path.exists() else {}
    expected = archive_manifest['sha256'] if archive_manifest else read(ROOT / 'build/auth-conformance/goldens-before.json')
    changed = read(SOURCE / 'changed-goldens.json')
    groups = {}
    records = []
    for name in changed:
        after = ROOT / name
        family = 'Auth screens' if name.startswith('test/') else after.name.split('-')[0]
        if family == 'auth':
            family = 'Auth primitives'
        candidates = [ROOT / p for p in before.get(name, [])]
        original = next((p for p in candidates if p.exists() and
                         hashlib.sha256(p.read_bytes()).hexdigest() == expected[name]), None)
        archived = archive.read(name) if archive and name in archive_manifest['sha256'] else None
        if archived:
            assert hashlib.sha256(archived).hexdigest() == expected[name], name
        native_a = Image.open(after).convert('RGBA')
        native_b = Image.open(BytesIO(archived)).convert('RGBA') if archived else Image.open(original).convert('RGBA') if original else None
        def display(im):
            matte = Image.new('RGBA', im.size, '#202020')
            return Image.alpha_composite(matte, im).convert('RGB')
        a = display(native_a)
        b = display(native_b) if native_b else None
        percent = None
        if b and b.size == a.size:
            percent = float(np.any(np.asarray(native_a) != np.asarray(native_b), axis=2).mean() * 100)
        flag = 'Font/Button-height scope; pixel attribution requires owner review.'
        if family == 'Auth screens':
            state = after.name.split('-')[1]
            flag = {
                'idle': 'REVIEW beyond font/height: body inside stroke, centered field label, legal inline links, social frame (D-059); localized source casing (D-062).',
                'focused': 'REVIEW beyond font/height: native caret geometry (D-059); empty-input fixture unchanged.',
                'phone': 'REVIEW beyond font/height: fixture input 09123456789 -> +98 912 827 9503; phone16/24 presentation and native caret (D-059).',
                'email': 'REVIEW beyond font/height: fixture input User12@example.com -> me.ardeshir.rashidi@gmail.com; native caret (D-059).',
            }[state]
        elif family == 'Auth primitives':
            flag = 'REVIEW beyond font/height: legal link48dp targets replaced by inline18dp text controls (D-059).'
        elif family == 'textfield':
            flag = 'REVIEW beyond font/height: source label centering and native caret geometry (D-059).'
        record = dict(sample=after.name, family=family, changedPixelPercent=percent,
                      before=f'review-before.zip!{name}' if archived else str(original.relative_to(ROOT)) if original else None,
                      beforeProvenance=archive_manifest['provenance'][name] if archived else 'saved original' if original else None,
                      beforeSHA256=expected[name], afterSHA256=hashlib.sha256(after.read_bytes()).hexdigest(),
                      flag=flag)
        records.append(record)
        # Fit large source sheets on a review contact sheet; percentages always use native pixels.
        scale = min(1, 440 / a.width)
        size = (round(a.width * scale), round(a.height * scale))
        thumb = a.resize(size, Image.Resampling.LANCZOS)
        row = Image.new('RGB', (1340, size[1] + 76), '#202020')
        draw = ImageDraw.Draw(row)
        draw.text((8, 4), after.name, fill='white')
        draw.text((8, 22), f'Changed native pixels: {percent:.4f}%' if percent is not None else
                  'BEFORE MISSING: no trustworthy diff or changed-pixel percentage', fill='#ffb020' if b is None else 'white')
        for x, title in [(0, 'BEFORE (hash verified)'), (448, 'AFTER'), (896, 'DIFF (4x contrast)')]:
            draw.text((x + 8, 42), title, fill='white')
        row.paste(thumb, (448, 70))
        if b:
            row.paste(b.resize(size, Image.Resampling.LANCZOS), (0, 70))
            diff = abs(np.asarray(native_a).astype('int16') - np.asarray(native_b).astype('int16'))
            diff = np.maximum(diff[..., :3], diff[..., 3, None])
            d = Image.fromarray(np.minimum(255, diff * 4).astype('uint8'))
            row.paste(d.resize(size, Image.Resampling.LANCZOS), (896, 70))
        else:
            draw.text((8, 90), 'Original PNG unavailable', fill='#ff8060')
            draw.text((904, 90), 'DIFF UNAVAILABLE', fill='#ff8060')
        groups.setdefault(family, []).append(row)
    for family, rows in groups.items():
        canvas = Image.new('RGB', (1340, sum(r.height for r in rows)), '#202020')
        y = 0
        for row in rows:
            canvas.paste(row, (0, y))
            y += row.height
        canvas.save(OUT / (family.lower().replace(' ', '-') + '.png'))
    save('golden-diffs.json', records)
    if archive:
        archive.close()
    lines = ['# Golden review contacts', '',
             'One PNG per component. Before columns are accepted only when SHA-256 matches '
             'the saved pre-conformance manifest. A hash-identical historical replay is identified '
             'in golden-diffs.json; the complete before set is preserved in review-before.zip. '
             'Contact thumbnails are downscaled; percentages '
             'compare unscaled native RGBA pixels (no tolerance). Transparent previews use a neutral '
             '#202020 matte; alpha changes are highlighted in the diff. Missing originals are explicitly '
             'marked, never reconstructed or replaced by current images. All baselines remain pending review.', '',
             '|Sample|Changed pixels %|Attribution / review flag|', '|---|---:|---|']
    for r in records:
        value = f'{r["changedPixelPercent"]:.4f}' if r['changedPixelPercent'] is not None else 'UNAVAILABLE'
        lines.append(f'|{r["sample"]}|{value}|{r["flag"]}|')
    lines += ['', f'{sum(r["before"] is not None for r in records)}/{len(records)} original samples recovered and hash verified.', '']
    for family in groups:
        name = family.lower().replace(' ', '-') + '.png'
        lines.append(f'- [{family}]({name})')
    (OUT / 'goldens.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print('Contact sheets:', len(groups), '; verified before:', sum(r['before'] is not None for r in records), '/', len(records))


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=Path)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    if args.source:
        SOURCE = args.source.resolve()
    if args.output:
        OUT = args.output.resolve()
        OUT.mkdir(parents=True, exist_ok=True)
    ink()
    sheets()

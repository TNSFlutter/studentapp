#!/usr/bin/env python3
"""
Generates full app_strings_*.dart files for regional locales by translating
English strings (Google Translate via deep-translator).

Usage (from project root):
  pip install deep-translator
  dart run tool/export_app_strings_en.dart > /tmp/en.json
  python3 tool/generate_regional_l10n.py /tmp/en.json

Or pipe JSON on stdin:
  dart run tool/export_app_strings_en.dart | python3 tool/generate_regional_l10n.py

Requires network.
"""

from __future__ import annotations

import json
import subprocess
import sys
import time
from pathlib import Path

from deep_translator import GoogleTranslator

# locale code in app -> GoogleTranslator target language code
LOCALES = {
    "bn": "bn",
    "pa": "pa",
    "te": "te",
    "or": "or",
    "mr": "mr",
    "gu": "gu",
    "kn": "kn",
    "ur": "ur",
    "ml": "ml",
    "ta": "ta",
    "as": "as",
}

ROOT = Path(__file__).resolve().parent.parent
TRANSLATIONS = ROOT / "lib" / "l10n" / "translations"
# Batched translation with per-string fallback when the free endpoint fails a chunk.
CHUNK = 18
SLEEP_SEC = 0.25


def load_en_map() -> dict[str, str]:
    json_arg = None
    for a in sys.argv[1:]:
        if a == "--only" or a.startswith("--"):
            continue
        if a.endswith(".json") or Path(a).suffix == ".json":
            json_arg = a
            break
    if json_arg:
        raw = Path(json_arg).read_text(encoding="utf-8")
        return json.loads(raw)
    raw = sys.stdin.read()
    if not raw.strip():
        proc = subprocess.run(
            ["dart", "run", "tool/export_app_strings_en.dart"],
            cwd=str(ROOT),
            capture_output=True,
            text=True,
            check=True,
        )
        raw = proc.stdout
    return json.loads(raw)


def dart_escape(s: str) -> str:
    """Escape for Dart single-quoted map values (must escape \\, ', newlines, and $)."""
    out = []
    for c in s:
        if c == "\\":
            out.append("\\\\")
        elif c == "'":
            out.append("\\'")
        elif c == "\n":
            out.append("\\n")
        elif c == "\r":
            out.append("\\r")
        elif c == "$":
            out.append("\\$")
        else:
            out.append(c)
    return "".join(out)


def translate_one(translator: GoogleTranslator, text: str, fallback: str) -> str:
    t = text.strip()
    if not t:
        return fallback
    try:
        r = translator.translate(t)
        return (r or "").strip() or fallback
    except Exception:
        time.sleep(0.5)
        try:
            r = translator.translate(t)
            return (r or "").strip() or fallback
        except Exception:
            return fallback


def translate_locale(code: str, target_lang: str, en_map: dict[str, str]) -> dict[str, str]:
    keys = sorted(en_map.keys())
    translator = GoogleTranslator(source="en", target=target_lang)
    out: dict[str, str] = {}
    for i in range(0, len(keys), CHUNK):
        batch_keys = keys[i : i + CHUNK]
        texts = [en_map[k] for k in batch_keys]
        try:
            translated = translator.translate_batch(texts)
            if len(translated) != len(batch_keys):
                raise ValueError("batch length mismatch")
            for k, t in zip(batch_keys, translated):
                out[k] = (t or "").strip() or en_map[k]
        except Exception as e:
            print(f"  [{code}] fallback chunk @ {i}: {e}", file=sys.stderr)
            for k in batch_keys:
                out[k] = translate_one(translator, en_map[k], en_map[k])
                time.sleep(0.06)
        time.sleep(SLEEP_SEC)
        if (i // CHUNK) % 5 == 0:
            print(f"  [{code}] {min(i + CHUNK, len(keys))}/{len(keys)}", file=sys.stderr)
    return out


def write_dart(filename: str, var_name: str, locale_comment: str, m: dict[str, str]) -> None:
    lines = [
        f"/// {locale_comment}",
        "/// Full catalog for GetX — machine-translated from English; review critical copy.",
        f"final Map<String, String> {var_name} = {{",
    ]
    for k in sorted(m.keys()):
        lines.append(f"    '{dart_escape(k)}': '{dart_escape(m[k])}',")
    lines.append("};")
    path = TRANSLATIONS / filename
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {path}")


DISPLAY_NAMES = {
    "bn": "Bengali",
    "pa": "Punjabi",
    "te": "Telugu",
    "or": "Odia",
    "mr": "Marathi",
    "gu": "Gujarati",
    "kn": "Kannada",
    "ur": "Urdu",
    "ml": "Malayalam",
    "ta": "Tamil",
    "as": "Assamese",
}


def main() -> None:
    only = set()
    if "--only" in sys.argv:
        i = sys.argv.index("--only")
        if i + 1 < len(sys.argv):
            only = set(sys.argv[i + 1].replace(" ", "").split(","))

    en_map = load_en_map()
    print(f"Loaded {len(en_map)} keys", file=sys.stderr)
    for short, gt in LOCALES.items():
        if only and short not in only:
            continue
        print(f"Translating -> {short} ({gt})...", file=sys.stderr)
        tr = translate_locale(short, gt, en_map)
        name_map = {
            "bn": "appStringsBn",
            "pa": "appStringsPa",
            "te": "appStringsTe",
            "or": "appStringsOr",
            "mr": "appStringsMr",
            "gu": "appStringsGu",
            "kn": "appStringsKn",
            "ur": "appStringsUr",
            "ml": "appStringsMl",
            "ta": "appStringsTa",
            "as": "appStringsAs",
        }
        fn = f"app_strings_{short}.dart"
        write_dart(
            fn,
            name_map[short],
            f"{DISPLAY_NAMES[short]} — full UI coverage.",
            tr,
        )


if __name__ == "__main__":
    main()

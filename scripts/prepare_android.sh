#!/usr/bin/env bash
set -euo pipefail

if [ ! -d android ]; then
  flutter create --platforms=android --org br.com.marerio --project-name consulta_nf_mr .
fi

MANIFEST="android/app/src/main/AndroidManifest.xml"
python3 - <<'PY'
from pathlib import Path
p = Path('android/app/src/main/AndroidManifest.xml')
s = p.read_text(encoding='utf-8')
if 'android.permission.CAMERA' not in s:
    s = s.replace('<manifest xmlns:android="http://schemas.android.com/apk/res/android">', '<manifest xmlns:android="http://schemas.android.com/apk/res/android">\n    <uses-permission android:name="android.permission.CAMERA" />\n    <uses-feature android:name="android.hardware.camera" android:required="false" />')
s = s.replace('android:label="consulta_nf_mr"', 'android:label="Consulta NF M&amp;R"')
p.write_text(s, encoding='utf-8')

for candidate in [Path('android/app/build.gradle.kts'), Path('android/app/build.gradle')]:
    if candidate.exists():
        text = candidate.read_text(encoding='utf-8')
        text = text.replace('minSdk = flutter.minSdkVersion', 'minSdk = 24')
        text = text.replace('minSdkVersion flutter.minSdkVersion', 'minSdkVersion 24')
        candidate.write_text(text, encoding='utf-8')
PY

flutter pub get
dart run flutter_launcher_icons

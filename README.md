# MOBA 1V1 - Godot Android

Godot 4.3 project using the supplied 1V1.glb map. Prototype map viewer with touch camera pan and zoom. This is **not** yet a playable MOBA.

## Build APK with GitHub Actions
1. Upload all project files to the root of a GitHub repository on branch `main`, including `.github/workflows/build-apk.yml` and `assets/1V1.glb`.
2. Open **Actions → Build Godot Android APK → Run workflow** (or push to `main`).
3. When the workflow finishes, open the run and download **MOBA-1V1-Android-APK** from Artifacts.
4. Unzip artifact and install `MOBA-1V1.apk` on Android.

The first export is a debug-signed ARM64 APK. It is not a Play Store release build.

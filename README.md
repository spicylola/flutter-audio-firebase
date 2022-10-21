# audio_sound_recording_app

The Long Term Goal of this project is create an Audio/Record app that can

1. Record an Audio
2. Stop Recording an Audio
3. Replay an Audio
4. A Button that can generate a link and send an audio to firebase (TODO)
5. A Button that can play a link from a list of widgets set by rules (probably read audio links from table collection in FB)(TODO)

## Getting Started
***Note will need to update line 523, 693: 
 .../../development/flutter/.pub-cache/hosted/pub.dartlang.org/assets_audio_player-3.0.5/lib/src/assets_audio_player.dart

from:
before:
```bash
WidgetsBinding.instance.removeObserver(_lifecycleObserver!);
```
after:
```bash
WidgetsBinding.instance?.removeObserver(_lifecycleObserver!);
```

Getting Started Android:
In your AndroidManifest.xml,

```bash
<uses-permission android:name="android.permission.RECORD_AUDIO" />

    <uses-permission android:name=
        "android.permission.READ_EXTERNAL_STORAGE" />

    <uses-permission android:name=
        "android.permission.WRITE_EXTERNAL_STORAGE" />
   <application
       android:requestLegacyExternalStorage="true"
```
build.gradle, your min compile sdk version should be 31

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

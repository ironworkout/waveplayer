# WavePlayer 🎵
**Lecteur MP3 local + Streaming YouTube**
Crossfade automatique · Smart Shuffle · Stats · Samsung A13 ✓

---

## ⚡ Installation rapide (étape par étape)

### 1. Prérequis
```bash
# Installe Flutter si pas encore fait :
# → https://flutter.dev/docs/get-started/install

flutter doctor   # Vérifie que Flutter + Android toolchain sont OK
```

### 2. Clone / copie le projet
```bash
# Place le dossier waveplayer/ où tu veux, puis :
cd waveplayer
```

### 3. Installe les dépendances
```bash
flutter pub get
```

### 4. Génère les adaptateurs Hive (base locale)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
> ⚠️ Cette étape est **obligatoire** — elle génère les fichiers `.g.dart`

### 5. Branche ton Samsung A13
- Active le **mode développeur** : Paramètres → À propos → numéro de build (appuie 7×)
- Active le **débogage USB** : Paramètres → Options développeur → Débogage USB ✓

### 6. Lance en dev (test sur le tel)
```bash
flutter run
```

### 7. Génère l'APK final
```bash
flutter build apk --release
```
L'APK se trouve dans :
```
build/app/outputs/flutter-apk/app-release.apk
```

### 8. Installe l'APK sur le Samsung A13
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```
Ou transfère le fichier `.apk` par câble et installe-le manuellement (autorise les sources inconnues).

---

## 🎵 Fonctionnalités

| Fonctionnalité | Description |
|---|---|
| **Import MP3** | Scan automatique de tous tes MP3 du téléphone |
| **Crossfade** | Fondu enchaîné automatique (2–12s, réglable) |
| **Smart Shuffle** | Algo pondéré : likes +0.5, écoutes +0.1, skips -0.2 |
| **Streaming** | Recherche + lecture via `youtube_explode_dart` |
| **Notification** | Contrôles play/pause/skip depuis le volet Android |
| **Bluetooth** | Contrôle depuis écouteurs/casque via MediaSession |
| **Stats** | Temps d'écoute, top titres, heatmap semaine |
| **Thème** | 6 couleurs accent personnalisables |
| **Widget** | Mini-lecteur sur l'écran d'accueil Samsung |

---

## 🗂 Architecture

```
lib/
├── main.dart                  # Init Hive + JustAudioBackground
├── app.dart                   # MaterialApp + MultiProvider
├── models/
│   ├── song.dart              # Modèle Song (local + stream)
│   ├── playlist.dart          # Modèle Playlist
│   └── listening_stats.dart   # Stats d'écoute
├── services/
│   ├── audio_engine.dart      # 2 players + crossfade
│   ├── smart_shuffle.dart     # Algo shuffle pondéré
│   ├── file_scanner.dart      # Scan MP3 + permissions
│   ├── stream_service.dart    # youtube_explode_dart
│   └── stats_service.dart     # Enregistrement écoutes
├── screens/
│   ├── home_screen.dart       # Navigation principale
│   ├── library_tab.dart       # Onglet MP3 locaux
│   ├── stream_tab.dart        # Onglet streaming
│   ├── player_screen.dart     # Lecteur principal
│   ├── stats_screen.dart      # Statistiques
│   └── settings_screen.dart   # Réglages
└── widgets/
    ├── song_tile.dart          # Ligne de chanson
    ├── mini_player.dart        # Mini-lecteur persistant
    ├── audio_visualizer.dart   # Barres animées
    └── playlist_card.dart      # Carte playlist
```

---

## 🛠 Dépendances clés

| Package | Rôle |
|---|---|
| `just_audio` | Moteur audio principal |
| `just_audio_background` | Lecture en arrière-plan + notification |
| `youtube_explode_dart` | Extraction URL stream YouTube |
| `on_audio_query` | Scan MP3 + ID3 tags |
| `hive` | Base de données locale |
| `provider` | State management |
| `palette_generator` | Couleur dominante depuis pochette |
| `cached_network_image` | Cache des pochettes streaming |

---

## 📱 Compatibilité

- **Samsung Galaxy A13** ✓ (Android 13 / API 33)
- Android 7.0+ (API 24) minimum
- Architecture ARM64 (A13 = Exynos 850 / MediaTek Helio G80)

---

## ⚙️ Commandes utiles

```bash
flutter pub get                          # Installe les dépendances
flutter pub run build_runner build       # Génère les .g.dart (Hive)
flutter run                             # Lance en mode debug
flutter run --release                   # Lance en mode release
flutter build apk --release             # Génère l'APK signé
flutter build apk --split-per-abi      # APKs séparés par archi (plus léger)
adb install app-release.apk            # Installe sur le tel branché
adb logcat | grep flutter              # Voir les logs Flutter
```

---

## 🤝 Basé sur

[Musify](https://github.com/gokadzev/Musify) par gokadzev — GPL v3.0
Le moteur de streaming (`youtube_explode_dart`) est directement inspiré de leur implémentation.

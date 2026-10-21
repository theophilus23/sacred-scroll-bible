# SacredScroll Bible — Flutter iOS Application

A native-styled **Flutter iOS Bible App** (`Cupertino` + Material 3) pre-bundled with **28 offline Bible translations** (**King James Version (KJV)** + all **27 versions** from `a.zip` and `b.zip`).

## Included Bible Translations (28 Offline Versions)

All 28 translations are cleaned (UTF-8 sanitized, zero `\uFFFD` replacement characters, and complete 66-book `0.json`–`65.json` coverage) inside `assets/bibles/`:

### English Translations (18)
1. **KJV** (`king-james-version`) — *King James Version (Default)*
2. **NKJV** (`new-king-james-version-1982`) — *New King James Version (1982)*
3. **KJ21** (`21st-century-kjv`) — *21st Century King James Version*
4. **AKJV** (`american-king-james-version-1999`) — *American King James Version (1999)*
5. **NIV-US** (`new-international-version-1984-us`) — *New International Version (1984 US)*
6. **NIV-UK** (`new-international-version-uk`) — *New International Version (UK)*
7. **NIrV** (`new-international-reader-s-version-1998`) — *New International Reader's Version (1998)*
8. **NLT** (`new-living-translation-1996`) — *New Living Translation (1996)*
9. **NET** (`new-english-translation-2005`) — *New English Translation (2005)*
10. **HCSB** (`holman-christian-standard-bible-2004`) — *Holman Christian Standard Bible (2004)*
11. **RSV** (`revised-standard-version-1952`) — *Revised Standard Version (1952)*
12. **RV** (`holy-bible-revised-version-1885`) — *Holy Bible Revised Version (1885)*
13. **WEB** (`world-english-bible`) — *World English Bible*
14. **YLT** (`young-s-literal-translation-1898`) — *Young's Literal Translation (1898)*
15. **BBE** (`bible-in-basic-english-1964`) — *Bible in Basic English (1964)*
16. **CEV** (`complementary-english-version-1995`) — *Contemporary / Complementary English Version (1995)*
17. **ERV** (`easy-to-read-revised-version-2005`) — *Easy-to-Read Revised Version (2005)*
18. **GNB** (`today-s-english-version-good-news-bible-`) — *Good News Bible / Today's English Version*

### Messianic & Hebraic Translations (2)
19. **CJB** (`the-complete-jewish-bible-1998`) — *The Complete Jewish Bible (1998)*
20. **HNV** (`hebrew-names-version`) — *Hebrew Names Version*

### Indian Regional Languages (8)
21. **TEL-BSI** (`telugu-bible-bsi`) — *Telugu Bible (BSI) — తెలుగు పరిశుద్ధ గ్రంథము*
22. **TEL-WBTC** (`telugu-bible-wbtc`) — *Telugu Bible (WBTC) — తెలుగు బైబిల్*
23. **TEL-ROM** (`english-lo-parishuddha-grandham`) — *English-lo Parishuddha Grandham (Romanized Telugu)*
24. **TAM** (`tamil-bible`) — *Tamil Bible — தமிழ் பரிசுத்த வேதாகமம்*
25. **MAL** (`malayalam-bible`) — *Malayalam Bible — സത്യവേദപുസ്തകം*
26. **KAN** (`kannada-bible`) — *Kannada Bible — ಕನ್ನಡ ಸತ್ಯವೇದವು*
27. **HIN** (`hindi-bible`) — *Hindi Bible — पवित्र बाइबिल*
28. **BEN** (`bengali-bible`) — *Bengali Bible — পবিত্র বাইবেল*

## Project Structure

```text
sacred_scroll_bible/
├── pubspec.yaml                           # Registers all 28 Bible asset directories
├── ios/Runner/Info.plist                  # iOS bundle & orientation config
├── assets/bibles/
│   ├── manifest.json                      # Metadata index for all 28 versions
│   └── <version-id>/0.json .. 65.json     # 66 canonical books per version (1,848 JSON files)
└── lib/
    ├── main.dart                          # App entry point
    ├── models/bible_models.dart           # 28 versions, 66 books, highlights, bookmarks, notes, plans
    ├── services/bible_repository.dart     # Asset JSON loader, LRU cache, search & parallel comparator
    ├── services/study_state_controller.dart # Reactive state for reader, themes & study vault
    └── screens/bible_screens.dart         # 5 iOS tabs + Book/Chapter, Version & Study modals
```

## Quick Start for iOS Simulator / Physical iPhone

1. Extract `sacred_scroll_ios_bible_flutter.zip` and navigate into the project folder:
   ```bash
   unzip sacred_scroll_ios_bible_flutter.zip -d sacred_scroll_bible
   cd sacred_scroll_bible
   ```
2. Initialize any missing platform runner scaffolds (if needed on your machine) and fetch packages:
   ```bash
   flutter create --platforms=ios .
   flutter pub get
   ```
3. Run on iOS Simulator or connected iPhone:
   ```bash
   flutter run -d ios
   ```

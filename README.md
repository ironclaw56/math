# Mathematics Learning App (Flutter)

A fast, offline-first Material Design 3 app for Class 9–12 math students.
Navigation: **Home → Class → Chapter → Exercise → PDF**.

## Getting started

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel).
2. From this project folder, run:
   ```
   flutter pub get
   flutter run
   ```
   (Connect an Android device/emulator, or run `flutter run -d chrome` to preview in a browser.)

3. For real speed testing, always use a **release** build — debug builds are
   noticeably slower on every Flutter app:
   ```
   flutter run --release
   # or, to build an installable APK:
   flutter build apk --release
   ```

## Project structure

```
lib/
  main.dart                 # App entry point — opens straight to Home, no splash delay
  models/                   # ClassModel, ChapterModel, ExerciseModel
  screens/                  # HomeScreen, ChapterScreen, ExerciseScreen,
                             # ExerciseContentScreen, SettingsScreen, AboutScreen
  widgets/                  # ClassButton, ChapterCard, ExerciseCard,
                             # LoadingIndicator, EmptyState
  services/                 # DataService (loads JSON), AppTheme, AppState
assets/
  books/class9/class9.json  # Chapter/exercise list per class (id + title only)
  books/class10/class10.json
  books/class11/class11.json
  books/class12/class12.json
  pdfs/                     # <-- put your exercise PDFs here (see below)
```

## Adding exercise PDFs (only you can do this)

Every exercise now opens its own PDF instead of placeholder text/images.
The PDF is **bundled inside the app at build time** as an asset — it is not
something an installed app's user can pick, upload, or change from within
the app. The only way to add or update a PDF is to drop the file into this
project and rebuild the app yourself.

Steps:

1. Open `PDF_CHECKLIST.txt` in this folder — it lists the exact filename
   expected for every exercise of every class/chapter, e.g.:
   ```
   assets/pdfs/class9-ch1-ex1.pdf   <-- Exercise 1.1
   ```
2. Save your PDF for that exercise into `assets/pdfs/` using that **exact**
   filename.
3. Run `flutter pub get` (only needed once after adding new files) and
   rebuild/run the app. No code changes needed — the exercise screen
   automatically shows the PDF if the file exists, and shows a friendly
   "PDF not added yet" message if it doesn't.

You don't have to add every PDF at once — add them gradually, chapter by
chapter; exercises without a PDF yet just show that message instead of
crashing.

## Adding a new chapter/exercise

Edit the relevant `assets/books/classX/classX.json` file — add a chapter or
exercise object with a unique `id` and a `title`. Then add a matching PDF
under `assets/pdfs/<id>.pdf`.

## Already wired up

- **Dark mode** — toggle in Settings.
- **Bookmarks** — tap the bookmark icon on any chapter card or exercise screen.
- **Search** — search box on the Chapter screen filters by title/number.

## What changed for speed

- Removed the splash screen's artificial ~1.8s delay and its animation
  controller — the app now opens directly to Home.
- Removed the unused placeholder image and the three fake "pinch to zoom"
  boxes + Lorem-ipsum text per exercise (they did nothing useful and added
  extra widgets to build on every exercise screen).
- Removed the non-functional "Share (coming soon)" button.
- PDFs load lazily — only when you open a specific exercise, not upfront —
  keeping navigation between screens instant.
- Biggest real-world speed win: always test with `flutter run --release` or
  a release APK. Debug builds are inherently much slower for every Flutter app.

## Notes on this build

This code was written and reviewed by hand; the sandbox used to prepare it
does not have the Flutter SDK installed, so it hasn't been run through
`flutter analyze` or `flutter run` directly. Please run `flutter pub get`
and `flutter analyze` after downloading — if anything doesn't compile,
share the error and it can be fixed quickly.

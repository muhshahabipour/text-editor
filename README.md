# Text Editor

A native macOS plain-text editor (Swift + AppKit) with first-class Persian (RTL) and English (LTR) support, including mixed bidirectional text.

## Build

```bash
brew install xcodegen
xcodegen generate
xcodebuild -project TextEditor.xcodeproj -scheme TextEditor -configuration Debug -derivedDataPath build build
open build/Build/Products/Debug/TextEditor.app
```

Core logic tests: `cd EditorCore && swift test`

## Features and shortcuts

- Native tabs (Cmd+T), automatic direction per paragraph, manual direction: Cmd+Shift+→ (LTR) / Cmd+Shift+← (RTL)
- Find bar (Cmd+F) and Persian-aware find/replace (Cmd+Opt+F) that can ignore ي/ی and ك/ک differences
- Line numbers (Cmd+Opt+L), status bar with line/column, words, characters; Latin digits by default, Persian digits optional
- Theme: View → Theme (System / Light / Dark)
- Export As… (Cmd+Shift+E): .txt, .md, .html, .rtf, .pdf (HTML/RTF/PDF keep per-paragraph RTL/LTR direction)
- Spell check in English and Persian

## Notes

- Persian spell check needs Persian enabled in System Settings → Keyboard → Text Input → Spelling. This is a system setting, not an app one.
- Vazirmatn is used if installed, otherwise the system font.
- Files are read as UTF-8, then UTF-16 (with BOM), then Windows-1256. A file read as Windows-1256 is saved back in Windows-1256.

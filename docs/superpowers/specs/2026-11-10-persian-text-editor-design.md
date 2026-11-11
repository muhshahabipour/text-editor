# Persian/English Plain-Text Editor for macOS — Design

## Goal
A native macOS plain-text editor with first-class Persian (RTL) and English (LTR) support, including mixed bidirectional text.

## Decisions
- **Stack:** Swift + AppKit, document-based (`NSDocument`), TextKit 2 (`NSTextView`). Minimum macOS 13.
- **Type:** Plain text (.txt, UTF-8).
- **v1 features:** native multi-tab, Find & Replace (with Persian-aware matching), Persian spell check, line numbers, status bar stats (words/characters/lines).
- **Base behavior:** open/save UTF-8, undo/redo, automatic per-paragraph direction.
- **Digits:** Latin (123) by default; Persian digits (۱۲۳) optional in the status bar.
- **Project generation:** XcodeGen (`project.yml`) so it builds from the command line.

## Architecture
| Unit | Responsibility | Depends on |
|---|---|---|
| `AppDelegate` / `@main` | App lifecycle, menus, preferences | AppKit |
| `TextDocument` (`NSDocument`) | Read/write files; encoding detection | `TextEncodingDetector` |
| `TextEncodingDetector` | Try UTF-8, then UTF-16 (BOM), then Windows-1256; report failure | Foundation |
| `EditorViewController` | `NSScrollView` + `NSTextView` + ruler + status bar wiring | AppKit, below units |
| `LineNumberRulerView` | Line numbers; always on the left edge (macOS ruler convention) | AppKit |
| `StatsCalculator` | Pure functions: word, character, line counts; cursor line/column | Foundation |
| `PersianText` | Normalize ي/ی and ك/ک; Latin → Persian digit conversion | Foundation |
| `PersianFindPanel` | Optional "ignore Arabic/Persian letter variants" search on top of the native find bar | `PersianText` |

Each unit is testable without UI except the view controller, ruler and find panel.

## Behavior
- **Direction:** paragraph `baseWritingDirection = .natural`; Cmd+Shift+→ / ← force a paragraph's direction manually.
- **Font:** default to Vazirmatn if installed, else the system font (SF Arabic coverage via fallback).
- **Spell check:** `NSSpellChecker` with automatic language identification. Persian must be enabled in macOS language settings (system-level, not app-level).
- **Find:** native find bar (`usesFindBar = true`) plus a toggle for variant-insensitive matching via `PersianText` normalization.
- **Status bar:** `Line 12, Col 4 · 340 words · 2,100 chars`; digits Latin by default, switchable to Persian.
- **Line numbers:** `NSRulerView` on the left edge, one number per paragraph; hidden/shown via View menu (Cmd+Opt+L).

## Errors
- Undecodable file: alert explaining the problem with a choice of encoding to retry.
- Save failure: standard `NSDocument` error presentation.

## Testing
- Unit tests: `StatsCalculator`, `PersianText`, `TextEncodingDetector` (including Persian, mixed bidi, emoji, ZWNJ).
- Manual/screenshot checks: RTL cursor movement, mixed-direction lines, tabs, find bar, ruler placement.

## Out of scope (v1)
Rich text, syntax highlighting, Markdown preview, Windows/Linux, iOS, plugins.

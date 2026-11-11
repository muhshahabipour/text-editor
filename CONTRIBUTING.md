# Contributing

Thanks for helping. Bug reports, Persian/RTL fixes and small features are all welcome.

## Report a bug or suggest something

Open an [issue](https://github.com/muhshahabipour/text-editor/issues). For text-direction or encoding bugs, please include:

- a small sample of the text (or the file, if it is not private)
- what you expected and what you saw
- your macOS version

## Set up

```bash
brew install xcodegen
xcodegen generate
xcodebuild -project TextEditor.xcodeproj -scheme TextEditor -configuration Debug -derivedDataPath build build
open build/Build/Products/Debug/TextEditor.app
```

## Project layout

- `EditorCore/`: Swift package with the text logic (statistics, Persian normalisation, encoding detection). No UI, fully unit-tested.
- `App/Sources/`: the AppKit app (documents, window, editor, line numbers, find, export).
- `docs/`: the project page and design notes.

## Before you open a pull request

1. Branch from `main`.
2. Run the core tests: `cd EditorCore && swift test` (the line `Executed N tests, with 0 failures` is the result that matters).
3. Add a test for any change to `EditorCore`.
4. Build the app and try your change, with both Persian and English text, in light and dark mode.
5. Keep the change focused and describe what it does and why in the pull request.

## Style

- Plain Swift and AppKit, no third-party dependencies.
- Keep logic that does not need UI in `EditorCore`.
- Persian normalisation must stay a 1:1 character replacement so text offsets map back to the original.

By contributing you agree your work is released under the [MIT License](LICENSE).

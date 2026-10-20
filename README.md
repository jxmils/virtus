# Virtus

A quotation a day for men who like their words set in black and serif. Today's quote, an archive of past
days, a profile with the quotes you pinned, and Home / Lock Screen widgets that show today's quote or your
pinned ones. No account, no server: everything lives in the App Group that the widget shares with the app.

- `Virtus/` the app (SwiftUI, iOS 18), `VirtusWidget/` the widget extension, `Shared/` what both use
  (the quote library, the daily order, the profile store, the quote views).
- `Tools/check.sh` type-checks both targets against the iOS SDK as Mac Catalyst, runs the self-test and
  renders `build/selftest/{widgets,screens,AppIcon}.png`. No Xcode needed for that; building for a phone does.
- One build setting, `VIRTUS_ID_PREFIX` (default `com.jasonmiller`), drives the bundle ids and the App Group.

Every day has one quote, the same for everyone, in a fixed shuffled order with no author two days running.
The id of a quote is a hash of its text, so pins survive edits to the library.
- `Portraits/`: bundled artwork fading into black on Today, the detail view, the share card and the large
  widget, with subtle backgrounds in archive rows, pins and compact Home Screen widgets. Fourteen shared
  themes cover all 658 quotes and 149 authors; individual `<author-slug>.jpg`
  portraits take priority. `Shared/QuoteArtwork.swift` assigns themes; new authors use the olive branch.
  These shared sculptures illustrate ideas rather than depict the authors. Prompts are in `docs/artwork-prompts.json`.
- `.github/workflows/ios.yml` builds on a macOS runner and uploads to TestFlight with an App Store Connect
  API key (setup in `docs/testflight.md`). `docs/app-store.md` has the listing text.

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
The separate **Year in Dots** widget comes in small, medium and large sizes. Each completed day is a
filled dot; days left, including today, are outlined. It updates at local midnight and includes leap days.
The Archive starts at public release on **November 9, 2026**, configured in `Shared/VirtusConfig.swift`.
It stays empty through launch day. At local midnight on November 10, the November 9 quote becomes its
first entry; it then grows by one day, retaining up to 90 past published days. Pre-release dates are
never backfilled. This cutoff does not change daily quote selection, widgets, reminders, or saved pins.
Today's visible issue number starts at No. 1 on release day and is hidden beforehand.
- `Portraits/`: bundled artwork fading into black on Today, the detail view, the share card and the large
  widget, with subtle backgrounds in archive rows, pins and compact Home Screen widgets. Fourteen shared
  themes cover all 664 quotes and 149 authors; individual `<author-slug>.jpg`
  portraits take priority. `Shared/QuoteArtwork.swift` assigns themes; new authors use the olive branch.
  These shared marble figures and painted portraits illustrate ideas rather than depict the authors. Prompts are in `docs/artwork-prompts.json`.
- `.github/workflows/ios.yml` builds on a macOS runner and uploads to TestFlight with an App Store Connect
  API key (setup in `docs/testflight.md`). `docs/app-store.md` has the listing text.

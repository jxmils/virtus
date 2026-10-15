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
- `Portraits/`: optional `<author-slug>.jpg` per author (see `Portraits/PROMPT.md`). Shown fading into black
  on Today, the detail view, the share card and the large widget; authors without one stay text-only.

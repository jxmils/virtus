# TestFlight from GitHub, without Xcode

One-time setup, about ten minutes.

1. **Register the App Group and the two app ids.** developer.apple.com > Account > Identifiers.
   - Use the menu at the top right of the list (it says App IDs) to switch to **App Groups**, then **+**.
     Description `Virtus`, Identifier `group.com.jasonmiller.Virtus`. Register.
   - Switch the menu back to **App IDs**, **+** > App IDs > App. Description `Virtus`, Bundle ID explicit
     `com.jasonmiller.Virtus`, tick **App Groups** and press its **Edit/Configure** button to select
     `group.com.jasonmiller.Virtus`. Register.
   - Same again for the widget: Description `Virtus Widget`, Bundle ID explicit `com.jasonmiller.Virtus.Widget`,
     App Groups ticked and configured to the same group. (If the id already exists because a build ran first,
     open it, tick App Groups, Configure, pick the group, Save.)
   Without the group assigned to both ids the archive fails with "Provisioning profile doesn't match the
   entitlements file's value for the com.apple.security.application-groups entitlement".
2. **Create the app record.** appstoreconnect.apple.com > My Apps > + > New App.
   iOS, name `Virtus` (or `Virtus Quotes` if taken), bundle id from step 1, SKU `virtus`.
3. **Make an API key.** App Store Connect > Users and Access > Integrations > App Store Connect API >
   Team Keys > +. Name `GitHub`, access **Admin**. Download the `.p8` file (you can only download it once).
   Note the **Issuer ID** (top of that page) and the key's **Key ID**.
4. **Add four secrets.** github.com/jxmils/virtus > Settings > Secrets and variables > Actions > New repository secret:
   - `APPSTORE_ISSUER_ID`: the Issuer ID
   - `APPSTORE_KEY_ID`: the Key ID
   - `APPSTORE_PRIVATE_KEY`: open the `.p8` in TextEdit and paste the whole thing, BEGIN and END lines included
   - `APPLE_TEAM_ID`: developer.apple.com > Account > Membership details > Team ID
5. **Run it.** GitHub > Actions > iOS > Run workflow. Leave the defaults. About 5 minutes.
   (Pushing a tag like `v1.0-rc10` starts a run too.) The runner builds with its newest Xcode 26, which
   App Store Connect requires since 2026; the build number is the run number.

The build shows up in App Store Connect > TestFlight (processing takes another 10 to 30 minutes).
The archive uses a local ad-hoc signature; the export step applies Apple's cloud-managed distribution
signature and uploads the build. This avoids issuing a fresh development certificate for every temporary
GitHub runner. The workflow checks both targets' App Group entitlements and bundled artwork before export.
Then: TestFlight > Internal Testing > **+** > name the group (e.g. `Me`), add yourself as a tester, tick the
build. Install the TestFlight app on your iPhone, accept the email invite, and Virtus installs from there.
Builds before build 10 show "Missing Compliance": click Manage next to the build and answer No to the
encryption question. Later builds carry the answer in Info.plist.

To release: in App Store Connect pick that build on the version page, paste the text from `docs/app-store.md`,
upload the screenshots from the workflow's `renders` artifact, and Submit for Review.

If the archive step fails, open the run and download the `logs` artifact. The first run registers the widget's
bundle id and the App Group automatically; if Apple refuses, add them by hand under Identifiers.

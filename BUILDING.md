# Building Glass for your iPhone

Glass has no Apple Developer account wired into this repo. GitHub Actions
builds an **unsigned** `.ipa` on a macOS runner, and you resign/install it
yourself locally with [Sideloadly](https://sideloadly.io).

## Trigger a build

1. Push to the `claude/admiring-hawking-gxsksw` branch, **or**
2. Trigger it manually:
   - Go to the repo on GitHub → **Actions** tab
   - Select the **Build IPA** workflow in the left sidebar
   - Click **Run workflow**, choose the branch, click the green **Run workflow** button

## Download the IPA

1. Open the **Actions** tab → click the completed **Build IPA** run
2. Scroll to the **Artifacts** section at the bottom of the run summary page
3. Download **`Glass-IPA`** — it's a zip containing `Glass.ipa`

## Installing with Sideloadly

The `.ipa` produced by CI is **unsigned** — it has no valid code signature and
will not install as-is. That's expected:

1. Open Sideloadly on your Mac/PC, plug in your iPhone
2. Drag `Glass.ipa` into Sideloadly
3. Sign in with your Apple ID when prompted
4. Sideloadly resigns the app with a signing identity derived from your Apple
   ID and installs it to your device

## Limitations of unsigned CI builds

- **No Apple ID, certificate, or provisioning profile is stored in this
  repo or in GitHub Secrets.** The workflow explicitly disables code signing
  (`CODE_SIGNING_ALLOWED=NO`) when archiving, so nothing sensitive is ever
  needed in CI.
- Because of that, the IPA **cannot be installed directly** — it must be
  resigned by Sideloadly (or a similar tool) using your own Apple ID first.
- Free Apple ID sideloads are capped at **3 apps installed at once** and the
  install **expires after 7 days** (or 1 year with a paid Apple Developer
  account), same as any other Sideloadly/AltStore install — this is an Apple
  platform limit, not something this workflow can change.
- The build targets a physical iPhone (`generic/platform=iOS`), not the
  simulator, so the resulting `.app` inside the archive is a real
  device build.
- CI artifacts are retained for 14 days, then GitHub deletes them
  automatically — download promptly after a run finishes.

## Project details the workflow relies on

- Project file: `Glass.xcodeproj` (no workspace)
- Scheme: `Glass`
- Bundle identifier: `com.azm.glass`
- Deployment target: iOS 26.0
- Signing: `Automatic` in the project, overridden to unsigned at archive time
  via command-line build settings — nothing in the project itself needed to
  change.

# Releasing 7-Zip for Mac

Releases for [elliotttate/7zip-mac](https://github.com/elliotttate/7zip-mac) are built
locally, signed with a Developer ID Application certificate, notarized by Apple,
and published as GitHub releases. The inherited source history remains intact.
The original port's Homebrew tap distributes the original port, so this repository
does not update that tap.

## Build and validate

Use the installed Xcode via `DEVELOPER_DIR`; never change the global Xcode selection.
`Mac/scripts/bump-version.sh minor` (or `patch`) updates `Mac/VERSION` and adds a
changelog section. Date that section, include the release notes, and commit the
source and reviewed screenshots under `docs/images/` before packaging.

```sh
export DEVELOPER_DIR=/Applications/Xcode.app
Mac/scripts/check-hygiene.sh
Mac/scripts/check-links.sh
Mac/scripts/test.sh
Mac/scripts/test.sh -A x86_64
```

Run the focused native AppKit checks described in [macos-design.md](macos-design.md).
Historical tests that compare the UI against Windows are being migrated to the
native design; a failing obsolete appearance assertion is not evidence that the
archive engine failed. Record any live XCUITest environment limitation in the
release notes.

## Sign and notarize

A Developer ID Application identity must exist in the keychain. Store notarization
credentials using `xcrun notarytool store-credentials <profile>`; do not put passwords,
certificate private keys, or API keys in source control.

```sh
Mac/scripts/package.sh \
  --identity "Developer ID Application: Your Name (TEAMID)" \
  --team TEAMID --notary-profile YOUR_PROFILE
```

The script builds both architectures, signs the framework and four extensions,
checks their entitlements, signs the app and disk image, submits to Apple, staples
the ticket, then mounts and verifies the finished image.

Also verify the finished release explicitly:

```sh
xcrun stapler validate Mac/build/7-Zip-26.04-macOS-1.3.0.dmg
spctl --assess --type open --context context:primary-signature -v Mac/build/7-Zip-26.04-macOS-1.3.0.dmg
```

## Publish

Create an annotated `v<PORT_VERSION>` tag at the packaged commit, push the `macos`
branch and that tag to this repository, and publish the DMG and its SHA-256 file.
Use `Mac/scripts/release-notes.sh --notarized` to generate the body and include the
light/dark screenshots via their raw GitHub URLs at the tag.

The [Release workflow](../.github/workflows/release.yml) is a manual build-validation
workflow. It uploads artifacts and never overwrites the locally signed release.
Its optional signing/notarization secrets follow the existing `MACOS_CERT_P12`,
`MACOS_CERT_PASSWORD`, `APPLE_TEAM_ID`, and Apple API-key or app-specific-password
configuration in the workflow. Regular CI still builds and tests the source.

Keep the original port and engine credits, licenses, and historical release links.
App update URLs, current release links, and security reporting point to this repository.

## Upstream: merging a new 7-Zip release

Follow [the upstream integration guide](upstream.md) when updating the engine.
Use `Mac/scripts/bump-version.sh minor --upstream <version>` once the new engine
has been integrated, refresh the pinned bundled assets, and record the change.
The engine version must agree with `C/7zVersion.h`; version tests and hygiene
checks enforce this before packaging.

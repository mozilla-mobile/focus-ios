# Firefox Focus for iOS

_Browse like no one’s watching. The new Firefox Focus automatically blocks a wide range of online trackers — from the moment you launch it to the second you leave it. Easily erase your history, passwords and cookies, so you won’t get followed by things like unwanted ads._

Download on the [App Store](https://itunes.apple.com/app/id1055677337).

Getting Involved
----------------

We encourage you to participate in this open source project. We love Pull Requests, Bug Reports, ideas, (security) code reviews or any kind of positive contribution. Please read the [Community Participation Guidelines](https://www.mozilla.org/en-US/about/governance/policies/participation/).

* Chat:           See [#focus-ios](https://chat.mozilla.org/#/room/#focus-ios:mozilla.org) for general discussion
* Bugs:           [File a new bug](https://github.com/mozilla-mobile/focus-ios/issues/new) • [Existing bugs](https://github.com/mozilla-mobile/focus-ios/issues)

If you're looking for a good way to get started contributing, check out some [good first issues](https://github.com/mozilla-mobile/focus-ios/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22).

We also tag recommended bugs for contributions with [help wanted](https://github.com/mozilla-mobile/focus-ios/issues?q=is%3Aopen+is%3Aissue+label%3A%22help+wanted%22).

Main Branch
----------------

This branch works with Xcode 13 and supports iOS 13.0 and newer.

Pull requests should be submitted with `main` as the base branch.

Build Instructions
------------------

1. Install Xcode 13 [Xcode developer tools](https://developer.apple.com/xcode/downloads/) from Apple.
2. Clone the repository:

  ```shell
  git clone https://github.com/mozilla-mobile/focus-ios.git
  ```

3. Pull in the project dependencies:

  ```shell
  cd focus-ios
  ./checkout.sh
  ```

4. Open `Blockzilla.xcodeproj` in Xcode.
5. Build the `Focus` scheme in Xcode.

Run on a Device with a Free Apple Developer Account
---------------

> This process is not required for simulator based development.

Since the bundle identifier we use for Focus is tied to Mozilla developer account, you'll need to generate your own identifier and update the existing configuration.

1. Add your Apple ID as an account in Xcode.
2. Open FocusDebug.xcconfig
3. Change PRODUCT_BUNDLE_PREFIX to your own bundle identifier prefix e.g., com.your_github_id.ios
4. Change DEVELOPMENT_TEAM to your Apple developer account Team ID.
5. Make sure FOCUS_ENTITLEMENTS value is Focus_contributor.entitlements
6. Build and Run on a device.

Due to a bug(or limitation) of Xcode, for the first time build/run Focus, please change `group.$(PRODUCT_BUNDLE_PREFIX).Focus` to actual value (like `group.com.your_github_id.ios.Focus`) in "Focus_contributor.entitlements" and "FocusIntentExtension/FocusIntentExtension.entitlements". Then let Xcode to build and complete signing process. After first build/run, the values could be reverted.


![Focus by Firefox](https://raw.githubusercontent.com/mozilla/focus/master/README.png)

Focus by Firefox is a free content blocker for Safari users on iOS 9 that gives users greater control of their mobile Web experience. Focus by Firefox puts users in control of their privacy by allowing them to block categories of trackers such as those used for ads, analytics and social media. Focus by Firefox may also increase performance and reduce mobile data usage by blocking Web fonts.

Download on the [App Store](https://itunes.apple.com/app/id1055677337).

We welcome your [feedback](https://input.mozilla.org/feedback/focus) as we explore ways to offer more features in the future.

Getting Involved
----------------

We encourage you to participate in this open source project. We love Pull Requests, Bug Reports, ideas, (security) code reviews or any kind of positive contribution. Please read the [Community Participation Guidelines](https://www.mozilla.org/en-US/about/governance/policies/participation/).

* IRC:            [#mobile](https://wiki.mozilla.org/IRC) for general discussion and [#mobistatus](https://wiki.mozilla.org/IRC) for team status updates.
* Bugs:           [File a new bug](https://bugzilla.mozilla.org/enter_bug.cgi?bug_file_loc=http%3A%2F%2F&bug_ignored=0&op_sys=iOS%20&product=Focus&rep_platform=All) • [Existing bugs](https://bugzilla.mozilla.org/describecomponents.cgi?product=Focus)


Build Instructions
------------------

1. Install the latest [Xcode developer tools](https://developer.apple.com/xcode/downloads/) from Apple.
1. Install [Carthage](https://github.com/Carthage/Carthage#installing-carthage).
1. Clone the repository:

  ```shell
  git clone https://github.com/mozilla/focus
  ```

1. Pull in the project dependencies:

  ```shell
  cd focus
  ./checkout.sh
  ```

1. Open `Blockzilla.xcodeproj` in Xcode.
1. Build the `Focus` scheme in Xcode.

Building for Distribution
-------------------------

I think all the steps below can go away if we move this project to Carthage or CocoaPods.

* Run `./checkout.sh`
* Open the project
* Select *GCDWebServer* project. Select the *GCDWebServers (iOS)* target. Select the *Build Settings*. Under *Deployment* change *Skip Install* from *No* to *Yes*.
* Select *General* and change the *Team* to *None*. Set the *Version* to *1.0*. Set the *Build* to *1*.
* Now *Archive* and upload

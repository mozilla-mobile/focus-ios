/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import UIKit

struct UIConstants {
    struct colors {
        static let background = UIColor(rgb: 0x221F1F)
        static let buttonHighlight = UIColor(rgb: 0x333333)
        static let cellSelected = UIColor(rgb: 0x2C6EC8)
        static let defaultFont = UIColor(rgb: 0xE1E5EA)
        static let deleteButtonBackground = UIColor(white: 1, alpha: 0.2)
        static let deleteButtonBorder = UIColor(white: 1, alpha: 0.5)
        static let firstRunButton = UIColor.white
        static let firstRunButtonBackground = UIColor(white: 1, alpha: 0.2)
        static let firstRunButtonBorder = UIColor(white: 1, alpha: 0.3)
        static let firstRunDisclaimer = UIColor(white: 1, alpha: 0.5)
        static let firstRunMessage = UIColor.white
        static let firstRunTitle = UIColor.white
        static let focusLightBlue = UIColor(rgb: 0x00A7E0)
        static let focusDarkBlue = UIColor(rgb: 0x005DA5)
        static let focusBlue = UIColor(rgb: 0x00A7E0)
        static let focusGreen = UIColor(rgb: 0x7ED321)
        static let focusMaroon = UIColor(rgb: 0xE63D2F)
        static let focusOrange = UIColor(rgb: 0xF26C23)
        static let focusRed = UIColor(rgb: 0xE63D2F)
        static let focusViolet = UIColor(rgb: 0x95368C)
        static let gradientBackground = UIColor(rgb: 0x363B40)
        static let gradientLeft = UIColor(rgb: 0xC43B31)
        static let gradientMiddle = UIColor(rgb: 0x96368D)
        static let gradientRight = UIColor(rgb: 0x135EA4)
        static let navigationButton = UIColor(rgb: 0x00A7E0)
        static let navigationTitle = UIColor(rgb: 0x61666D)
        static let overlayBackground = UIColor(white: 0, alpha: 0.8)
        static let progressBar = UIColor(rgb: 0xC86DD7)
        static let settingsButtonBorder = UIColor(rgb: 0x5F6368, alpha: 0.8)
        static let settingsTextLabel = UIColor(rgb: 0xE1E5EA)
        static let settingsDetailLabel = UIColor(rgb: 0x61666D)
        static let settingsSeparator = UIColor(rgb: 0x333333)
        static let tableSectionHeader = UIColor(rgb: 0x61666D)
        static let toastBackground = UIColor(white: 1, alpha: 0.2)
        static let toastText = UIColor.white
        static let toggleOn = UIColor(rgb: 0x00A7E0)
        static let toggleOff = UIColor(rgb: 0x585E64)
        static let toolbarBorder = UIColor(rgb: 0x5F6368)
        static let toolbarButtonNormal = UIColor.darkGray
        static let urlTextBackground = UIColor(white: 1, alpha: 0.2)
        static let urlTextFont = UIColor.white
        static let urlTextHighlight = UIColor(rgb: 0xC86DD7)
        static let urlTextPlaceholder = UIColor(white: 1, alpha: 0.4)
        static let urlTextShadow = UIColor.black
    }

    struct fonts {
        static let aboutText = UIFont.systemFont(ofSize: 14)
        static let cancelButton = UIFont.systemFont(ofSize: 15)
        static let deleteButton = UIFont.systemFont(ofSize: 11)
        static let firstRunButton = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        static let firstRunDisclaimer = UIFont.systemFont(ofSize: 14)
        static let firstRunMessage = UIFont.systemFont(ofSize: 14)
        static let firstRunTitle = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        static let homeLabel = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        static let safariInstruction = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        static let searchButton = UIFont.systemFont(ofSize: 15)
        static let searchButtonQuery = UIFont.boldSystemFont(ofSize: 15)
        static let settingsHomeButton = UIFont.systemFont(ofSize: 15)
        static let settingsOverlayButton = UIFont.systemFont(ofSize: 13)
        static let tableSectionHeader = UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold)
        static let toast = UIFont.systemFont(ofSize: 12)
        static let urlText = UIFont.systemFont(ofSize: 15)
    }

    struct layout {
        static let browserToolbarDisabledOpacity: CGFloat = 0.3
        static let browserToolbarHeight: Float = 44
        static let deleteAnimationDuration: TimeInterval = 0.15
        static let lockIconInset: Float = 6
        static let navigationDoneOffset: Float = -10
        static let overlayAnimationDuration: TimeInterval = 0.25
        static let progressVisibilityAnimationDuration: TimeInterval = 0.25
        static let searchButtonInset: CGFloat = 15
        static let searchButtonAnimationDuration: TimeInterval = 0.1
        static let toastAnimationDuration: TimeInterval = 0.3
        static let toastDuration: TimeInterval = 1.5
        static let toolbarFadeAnimationDuration = 0.25
        static let urlBarCornerRadius: CGFloat = 2
        static let urlBarTransitionAnimationDuration: TimeInterval = 0.2
        static let urlBarMargin: CGFloat = 8
        static let urlBarHeightInset: CGFloat = 10
        static let urlBarShadowOpacity: Float = 0.3
        static let urlBarShadowRadius: CGFloat = 2
        static let urlBarShadowOffset = CGSize(width: 0, height: 2)
        static let urlBarWidthInset: CGFloat = 8
    }

    struct strings {
        static let aboutLearnMoreButton = NSLocalizedString("About.learnMoreButton", value: "Learn more", comment: "Button on About screen")
        static let aboutMissionLabel = NSLocalizedString("About.missionLabel", value: "%@ is produced by Mozilla. Our mission is to foster a healthy, open Internet.", comment: "Label on About screen")
        static let aboutPrivateBulletHeader = NSLocalizedString("About.privateBulletHeader", value: "Use it as a private browser:", comment: "Label on About screen")
        static let aboutPrivateBullet1 = NSLocalizedString("About.privateBullet1", value: "Search and browse right in the app", comment: "Label on About screen")
        static let aboutPrivateBullet2 = NSLocalizedString("About.privateBullet2", value: "Block trackers (or update settings to allow trackers)", comment: "Label on About screen")
        static let aboutPrivateBullet3 = NSLocalizedString("About.privateBullet3", value: "Erase to delete cookies as well as search and browsing history", comment: "Label on About screen")
        static let aboutRowHelp = NSLocalizedString("About.rowHelp", value: "Help", comment: "Label for row in About screen")
        static let aboutRowRights = NSLocalizedString("About.rowRights", value: "Your Rights", comment: "Label for row in About screen")
        static let aboutSafariBulletHeader = NSLocalizedString("About.safariBulletHeader", value: "Use it as a Safari extension:", comment: "Label on About screen")
        static let aboutSafariBullet1 = NSLocalizedString("About.safariBullet1", value: "Block trackers for improved privacy", comment: "Label on About screen")
        static let aboutSafariBullet2 = NSLocalizedString("About.safariBullet2", value: "Block Web fonts to reduce page size", comment: "Label on About screen")
        static let aboutTitle = NSLocalizedString("About.screenTitle", value: "About", comment: "Title for the About screen")
        static let aboutTopLabel = NSLocalizedString("About.topLabel", value: "%@ puts you in control.", comment: "Label on About screen")
        static let eraseButton = NSLocalizedString("URL.eraseButtonLabel", value: "ERASE", comment: "Erase button in the URL bar")
        static let eraseMessage = NSLocalizedString("URL.eraseMessageLabel", value: "Your browsing history has been erased.", comment: "Message shown after pressing the Erase button")
        static let errorTryAgain = NSLocalizedString("Error.tryAgainButton", value: "Try again", comment: "Button label to reload the error page")
        static let firstRunButton = NSLocalizedString("FirstRun.buttonLabel", value: "OK, GOT IT!", comment: "Label on button to dismiss first run UI")
        static let firstRunMessage = NSLocalizedString("FirstRun.messageLabel2", value: "Automatically block online trackers while you browse. Then tap to erase visited pages, searches, cookies and passwords from your device. ", comment: "Message label on the first run screen")
        static let firstRunTitle = NSLocalizedString("FirstRun.messageLabel1", value: "Browse like no one’s watching.", comment: "Message label on the first run screen")
        static let firstRunDisclaimer = NSLocalizedString("FirstRun.disclaimerMessage", value: "To be clear, the sites and services you use can still learn about you as you browse.", comment: "Message label shown under the button in the first run UI")
        static let homeLabel1 = NSLocalizedString("Home.descriptionLabel1", value: "Automatic private browsing.", comment: "First label for product description on the home screen")
        static let homeLabel2 = NSLocalizedString("Home.descriptionLabel2", value: "Browse. Erase. Repeat.", comment: "Second label for product description on the home screen")
        static let labelBlockAds = NSLocalizedString("Settings.toggleBlockAds", value: "Block ad trackers", comment: "Label for toggle on main screen")
        static let labelBlockAnalytics = NSLocalizedString("Settings.toggleBlockAnalytics", value: "Block analytics trackers", comment: "Label for toggle on main screen")
        static let labelBlockSocial = NSLocalizedString("Settings.toggleBlockSocial", value: "Block social trackers", comment: "Label for toggle on main screen")
        static let labelBlockOther = NSLocalizedString("Settings.toggleBlockOther", value: "Block other content trackers", comment: "Label for toggle on main screen")
        static let labelBlockFonts = NSLocalizedString("Settings.toggleBlockFonts", value: "Block Web fonts", comment: "Label for toggle on main screen")
        static let labelSendAnonymousUsageData = NSLocalizedString("Settings.toggleSendAnonymousUsageData", value: "Send anonymous usage data", comment: "Label for Send Anonymous Usage Data toggle on main screen")
        static let safariInstructionsContentBlockers = NSLocalizedString("Safari.instructionsContentBlockers", value: "Tap Safari, then select Content Blockers", comment: "Label for instructions to enable Safari, shown when enabling Safari Integration in Settings")
        static let safariInstructionsEnable = NSLocalizedString("Safari.instructionsEnable", value: "Enable %@", comment: "Label for instructions to enable Safari, shown when enabling Safari Integration in Settings")
        static let safariInstructionsOpen = NSLocalizedString("Safari.instructionsOpen", value: "Open Settings App", comment: "Label for instructions to enable Safari, shown when enabling Safari Integration in Settings")
        static let safariInstructionsNotEnabled = String(format: NSLocalizedString("Safari.instructionsNotEnabled", value: "%@ is not enabled.", comment: "Error label when the blocker is not enabled, shown in the intro and main app when disabled"), AppInfo.ProductName)
        static let searchButton = NSLocalizedString("URL.searchLabel", value: "Search for %@", comment: "Label displayed for search button when typing in the URL bar")
        static let settingsBlockOtherMessage = NSLocalizedString("Settings.blockOtherMessage", value: "Blocking other content trackers may break some videos and Web pages.", comment: "Alert message shown when toggling the Content blocker")
        static let settingsBlockOtherNo = NSLocalizedString("Settings.blockOtherNo", value: "No, Thanks", comment: "Button label for declining Content blocker alert")
        static let settingsBlockOtherYes = NSLocalizedString("Settings.blockOtherYes", value: "I Understand", comment: "Button label for accepting Content blocker alert")
        static let settingsSearchSection = NSLocalizedString("Settings.searchSection", value: "SEARCH ENGINE", comment: "Title for the search engine row")
        static let settingsSearchTitle = NSLocalizedString("Settings.searchTitle", value: "Search Engine", comment: "Title for the search engine selection screen")
        static let settingsTitle = NSLocalizedString("Settings.screenTitle", value: "Settings", comment: "Title for settings screen")
        static let settingsToggleOtherSubtitle = NSLocalizedString("Settings.toggleOtherSubtitle", value: "May break some videos and Web pages", comment: "Label subtitle for toggle on main screen")
        static let subtitleSendAnonymousUsageData = NSLocalizedString("Settings.toggleSendAnonymousUsageDataSubtitle", value: "Learn more", comment: "Subtitle for Send Anonymous Usage Data toggle on main screen")
        static let toggleSectionIntegration = NSLocalizedString("Settings.sectionIntegration", value: "INTEGRATION", comment: "Label for Safari integration section")
        static let toggleSectionMozilla = NSLocalizedString("Settings.sectionMozilla", value: "MOZILLA", comment: "Section label for Mozilla toggles")
        static let toggleSectionPerformance = NSLocalizedString("Settings.sectionPerformance", value: "PERFORMANCE", comment: "Section label for performance toggles")
        static let toggleSectionPrivacy = NSLocalizedString("Settings.sectionPrivacy", value: "PRIVACY", comment: "Section label for privacy toggles")
        static let toggleSafari = NSLocalizedString("Settings.toggleSafari", value: "Safari", comment: "Safari toggle label on settings screen")
        static let urlBarCancel = NSLocalizedString("URL.cancelLabel", value: "Cancel", comment: "Label for cancel button shown when entering a URL or search")
        static let urlTextPlaceholder = NSLocalizedString("URL.placeholderText", value: "Search or enter address", comment: "Placeholder text shown in the URL bar before the user navigates to a page")
    }
}

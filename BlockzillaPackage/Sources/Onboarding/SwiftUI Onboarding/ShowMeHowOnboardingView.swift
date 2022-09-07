// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

@available(iOS 14.0, *)
struct ShowMeHowOnboardingView: View {
    private let config: ShowMeHowOnboardingViewConfig
    private let dismissAction: () -> Void

    public init(config: ShowMeHowOnboardingViewConfig, dismissAction: @escaping () -> Void) {
        self.config = config
        self.dismissAction = dismissAction
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
                HStack(alignment: .top, spacing: Constants.horizontalSpacing) {
                    Image(systemName: "1.circle.fill")
                        .resizable()
                        .frame(width: Constants.iconSize, height: Constants.iconSize)
                        .foregroundColor(.gray)
                    Text(config.subtitleStep1)
                        .font(.body16)
                }
                VStack(alignment: .leading, spacing: Constants.horizontalSpacing) {
                    HStack(alignment: .top, spacing: Constants.horizontalSpacing) {
                        Image(systemName: "2.circle.fill")
                            .resizable()
                            .frame(width: Constants.iconSize, height: Constants.iconSize)
                            .foregroundColor(.gray)
                        Text(config.subtitleStep2)
                            .font(.body16)
                    }
                    HStack {
                        Spacer()
                        Image.jiggleModeImage
                        Spacer()
                    }
                }
                HStack(alignment: .top, spacing: Constants.horizontalSpacing) {
                    Image(systemName: "3.circle.fill")
                        .resizable()
                        .frame(width: Constants.iconSize, height: Constants.iconSize)
                        .foregroundColor(.gray)
                    Text(config.subtitleStep3)
                        .font(.body16)
                }
                Spacer()
            }.padding(EdgeInsets(top: Constants.topBottomPadding, leading: Constants.leadingTrailingPadding, bottom: Constants.topBottomPadding, trailing: Constants.leadingTrailingPadding))
                .navigationTitle(config.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button(config.buttonText) {
                        dismissAction()
                    }
                }
        }
    }

    private struct Constants {
        static let iconSize: CGFloat = 24
        static let topBottomPadding: CGFloat = 30
        static let leadingTrailingPadding: CGFloat = 40
        static let horizontalSpacing: CGFloat = 15
        static let verticalSpacing: CGFloat = 24
    }
}

public struct ShowMeHowOnboardingViewConfig {
    let title: String
    let subtitleStep1: String
    let subtitleStep2: String
    let subtitleStep3: String
    let buttonText: String

    public init(title: String, subtitleStep1: String, subtitleStep2: String, subtitleStep3: String, buttonText: String) {
        self.title = title
        self.subtitleStep1 = subtitleStep1
        self.subtitleStep2 = subtitleStep2
        self.subtitleStep3 = subtitleStep3
        self.buttonText = buttonText
    }
}

@available(iOS 14.0, *)
struct ShowMeHowOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        ShowMeHowOnboardingView(config: ShowMeHowOnboardingViewConfig(title: "Turn on Sync", subtitleStep1: "Long press on the Home screen until the icons start to jiggle.", subtitleStep2: "Tap on the plus icon.", subtitleStep3: "Search for FireFox Focus. Then choose a widget.", buttonText: "Done"), dismissAction: { })
    }
}

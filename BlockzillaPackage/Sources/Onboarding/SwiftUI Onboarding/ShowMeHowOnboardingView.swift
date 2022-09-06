// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

@available(iOS 14.0, *)
struct ShowMeHowOnboardingView: View {
    private let config: ShowMeHowOnboardingViewConfig
    private let dismissAction: () -> Void
    @Environment(./presentationMode) var presentationMode

    public init(config: ShowMeHowOnboardingViewConfig, dismissAction: @escaping () -> Void) {
        self.config = config
        self.dismissAction = dismissAction
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "1.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                    Text(config.subtitleStep1)
                        .font(.body16)
                }
                VStack(alignment: .leading, spacing: 15) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "2.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
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
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "3.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                    Text(config.subtitleStep3)
                        .font(.body16)
                }
                Spacer()
            }.padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
                .navigationTitle(config.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button(config.buttonText) {
                        dismissAction()
                        presentationMode.wrappedValue.dismiss()
                        
                    }
                }
        }
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
        ShowMeHowOnboardingView()
    }
}

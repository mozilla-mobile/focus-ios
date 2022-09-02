// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

struct SecondOnboardingView: View {
    private let dismiss: () -> Void

    init(dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }, label: {
                    Image.close
                })
            }
            Image.huggingFocus
                .resizable()
                .scaledToFit()
                .frame(maxHeight: .imageMaxHeight)
            VStack {
                Text(String.onboardingSecondScreenTitleV2)
                    .bold()
                    .font(.system(size: .titleSize))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, .titleBottomPadding)
                VStack(alignment: .leading) {
                    Text(String.onboardingSecondScreenFirstSubtitleV2)
                        .padding(.bottom, .firstSubtitleBottomPadding)
                    Text(String.onboardingSecondScreenSecondSubtitleV2)
                }
            }
            .foregroundColor(.secondOnboardingScreenText)
            Spacer()
            Button(action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }, label: {
                Text(String.onboardingSecondScreenTopButtonTitleV2)
                    .foregroundColor(.systemBackground)
                    .font(.body16Bold)
                    .frame(maxWidth: .infinity)
                    .frame(height: .navigationLinkViewHeight)
                    .background(Color.secondOnboardingScreenTopButton)
                    .cornerRadius(.radius)
            })
            Button(action: {
                dismiss()
            }, label: {
                Text(String.onboardingSecondScreenBottomButtonTitleV2)
                    .foregroundColor(.black)
                    .font(.body16Bold)
                    .frame(maxWidth: .infinity)
                    .frame(height: .navigationLinkViewHeight)
                    .background(Color.secondOnboardingScreenBottomButton)
                    .cornerRadius(.radius)
            })
            .padding(.bottom, .skipButtonPadding)
        }
        .padding([.top, .leading, .trailing], .viewPadding)
        .navigationBarHidden(true)
        .background(Color.secondOnboardingScreenBackground
            .edgesIgnoringSafeArea(.bottom))
    }
}

fileprivate extension String {
    static let onboardingSecondScreenTitleV2 = NSLocalizedString("Onboarding.SecondScreen.Title.V2", value: "Focus isn't like other browsers", comment: "Text for a label that indicates the title for the second onboarding screen version 2.")
    static let onboardingSecondScreenFirstSubtitleV2 = NSLocalizedString("Onboarding.SecondScreen.FirstSubtitle.V2", value: "We clear your history when you close the app for extra privacy.", comment: "Text for a label that indicates the first subtitle for the second onboarding screen version 2.")
    static let onboardingSecondScreenSecondSubtitleV2 = NSLocalizedString("Onboarding.SecondScreen.SecondSubtitle.V2", value: "Make Focus your default to protect your data with every link you open.", comment: "Text for a label that indicates the second subtitle for the second onboarding screen version 2.")
    static let onboardingSecondScreenTopButtonTitleV2 = NSLocalizedString("Onboarding.SecondScreen.TopButtonTitle.V2", value: "Set as Default Browser", comment: "Text for a label that indicates the title of the top button from the second onboarding screen version 2.")
    static let onboardingSecondScreenBottomButtonTitleV2 = NSLocalizedString("Onboarding.SecondScreen.BottomButtonTitle.V2", value: "Skip", comment: "Text for a label that indicates the title of the bottom button from the second onboarding screen version 2.")
}

fileprivate extension CGFloat {
    static let imageSize: CGFloat = 30
    static let titleSize: CGFloat = 26
    static let titleBottomPadding: CGFloat = 12
    static let skipButtonPadding: CGFloat = 12
    static let firstSubtitleBottomPadding: CGFloat = 14
    static let viewPadding: CGFloat = 26
    static let radius: CGFloat = 12
    static let navigationLinkViewHeight: CGFloat = 44
    static let imageMaxHeight: CGFloat = 300
}

struct SecondOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        SecondOnboardingView(dismiss: {})
    }
}

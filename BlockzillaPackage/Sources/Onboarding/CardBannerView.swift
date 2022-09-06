// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

@available(iOS 14, *)
public struct CardBannerView: View {
    let dismiss: () -> Void

    public init(dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.01)
                .onTapGesture(perform: dismiss)
                .ignoresSafeArea()

            ZStack {

                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(.white)
                    .shadow(radius: 36)

                VStack(spacing: 20.0) {
                    HStack {
                        Spacer()
                        Button(action: dismiss, label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                        })
                        .frame(width: 30, height: 30)
                        .padding(.trailing)
                    }

                    Text("Browsing history cleared! 🎉")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text("We’ll leave you to your private browsing, but get a quicker start next time with the Focus widget on your Home screen.")
                        .multilineTextAlignment(.center)

                    VStack(spacing: 20.0) {
                        SearchWidgetView(title: "Search in", appName: "Focus")
                            .frame(width: 135, height: 135)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        Button(action: dismiss, label: {
                            Text("Show Me How")
                                .foregroundColor(.white)
                                .font(.body)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.blue)
                                .cornerRadius(8)
                                .padding(.horizontal, 24.0)
                        })
                    }
                }
            }
            .frame(height: 400)
            .padding(.horizontal)
        }
    }
}

struct CardBannerView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14, *) {
            ZStack {
                Color.pink.ignoresSafeArea()
                CardBannerView(dismiss: {})
            }
        }
    }
}

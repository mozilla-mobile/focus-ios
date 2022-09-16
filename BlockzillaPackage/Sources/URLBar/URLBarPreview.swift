// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

// MARK: SwiftUI Preview

struct BackgroundViewContainer: UIViewRepresentable {
    let urlBarViewModel: URLBarViewModel

    func makeUIView(context: Context) -> URLBar {
        URLBar(viewModel: urlBarViewModel)
    }
    func updateUIView(_ uiView: URLBar, context: Context) { }
}

public struct URLBarPreview: View {
    @State private var urlBarViewModel = URLBarViewModel(
        strings: URLBarStrings(
            autocompleteAddCustomUrlError: "UIConstants.strings.autocompleteAddCustomUrlError",
            urlTextPlaceholder: "UIConstants.strings.urlTextPlaceholder",
            browserBack: "UIConstants.strings.browserBack",
            browserForward: "UIConstants.strings.browserForward",
            browserSettings: "UIConstants.strings.browserSettings",
            browserStop: "UIConstants.strings.browserStop",
            browserReload: "UIConstants.strings.browserReload",
            copyMenuButton: "UIConstants.strings.copyMenuButton",
            urlPasteAndGo: "UIConstants.strings.urlPasteAndGo"
        ),
        enableCustomDomainAutocomplete: { /*Settings.getToggle(.enableCustomDomainAutocomplete)*/ false },
        getCustomDomainSetting: { /*Settings.getCustomDomainSetting()*/ [] },
        setCustomDomainSetting: { /*Settings.setCustomDomainSetting(domains: $0)*/ _ in },
        enableDomainAutocomplete: { /*Settings.getToggle(.enableDomainAutocomplete)*/  false }
    )

    public var body: some View {
        ZStack {
            VStack {
                BackgroundViewContainer(urlBarViewModel: urlBarViewModel)
                    .frame(height: 64)
                    .background(Color.purple)
                Spacer()
                HStack {
                    Button("Home") { urlBarViewModel.browsingState = .home }
                    Button("Browsing") { urlBarViewModel.browsingState = .browsing }
                }
                Spacer()
            }
        }
    }
}

struct URLBarPreview_Previews: PreviewProvider {
    static var previews: some View {
        URLBarPreview()
    }
}

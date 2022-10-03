// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

@available(iOS 14.0, *)
public struct PageTabView<Page: View>: View {

    let content: () -> Page
    @StateObject private var screenController = ScreenController()

    public init(@ViewBuilder content: @escaping () -> Page) {
        self.content = content
        stylePageControl()
    }

    public var body: some View {
        TabView(selection: $screenController.activeScreen) {
            content()
        }
        .environmentObject(screenController)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .ignoresSafeArea()
    }

    func stylePageControl() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .systemBlue
        UIPageControl.appearance().pageIndicatorTintColor = .systemGray
    }
}

@available(iOS 14.0, *)
struct PageViewStyle_Previews: PreviewProvider {
    static var previews: some View {
        PageTabView {
            Text("Get Started Screen")
                .tag(Screen.getStarted)
            Text("Default Screen")
                .tag(Screen.default)
        }
    }
}

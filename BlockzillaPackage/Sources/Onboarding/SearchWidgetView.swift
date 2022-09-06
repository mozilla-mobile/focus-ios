// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI
import WidgetKit

public struct SearchWidgetView: View {
    let title: String
    let appName: String

    public init(title: String, appName: String) {
        self.title = title
        self.appName = appName
    }
    
    public var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                    Text(appName)
                        .font(.headline)
                        .fontWeight(.medium)
                }
                .minimumScaleFactor(0.8)
                .foregroundColor(.white)

                Spacer()

                Image.magnifyingGlass
                    .foregroundColor(.white)
                    .frame(height: .magnifyingGlassHeight)
            }
            Spacer()
            HStack {
                Spacer()
                Image.mozilla
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(height: .logoHeight)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: .quickAccessWidget,
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
        )
    }
}

@available(iOS 14, *)
struct SearchWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SearchWidgetView(title: "Search in", appName: "Focus")
            .frame(width: 135, height: 135)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

fileprivate extension CGFloat {
    static let logoHeight: CGFloat = 22
    static let magnifyingGlassHeight: CGFloat = 18
}

fileprivate extension Image {
    static let magnifyingGlass = Image(systemName: "magnifyingglass")
    static let mozilla = Image("icon_mozilla", bundle: .module)
}

fileprivate extension Gradient {
    static let quickAccessWidget = Gradient(colors: [Color("GradientFirst", bundle: .module), Color("GradientSecond", bundle: .module)])
}

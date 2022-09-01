// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

struct SearchWidgetView: View {
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text("Search in \nFocus")
                    .foregroundColor(.white)
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .frame(height: 18)
            }
            Spacer()
            HStack {
                Spacer()
                Image("icon_mozilla")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(height: 22)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("GradientFirst"), Color("GradientSecond")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
        )
    }
}

struct SearchWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SearchWidgetView()
    }
}

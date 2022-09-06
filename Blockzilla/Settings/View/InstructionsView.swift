/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class InstructionsView: UIView {
    init() {
        super.init(frame: CGRect.zero)

        let settingsInstruction = InstructionView(text: UIConstants.strings.safariInstructionsOpen, image: #imageLiteral(resourceName: "instructions-cog"))
        let safariInstruction = InstructionView(text: UIConstants.strings.safariInstructionsContentBlockers, image: #imageLiteral(resourceName: "instructions-safari"))
        let enableInstruction = InstructionView(text: String(format: UIConstants.strings.safariInstructionsEnable, AppInfo.productName), image: #imageLiteral(resourceName: "instructions-switch"))

        settingsInstruction.translatesAutoresizingMaskIntoConstraints = false
        safariInstruction.translatesAutoresizingMaskIntoConstraints = false
        enableInstruction.translatesAutoresizingMaskIntoConstraints = false

        addSubview(settingsInstruction)
        addSubview(safariInstruction)
        addSubview(enableInstruction)

        NSLayoutConstraint.activate([
            settingsInstruction.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            settingsInstruction.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            settingsInstruction.topAnchor.constraint(equalTo: self.topAnchor),

            safariInstruction.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            safariInstruction.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            safariInstruction.topAnchor.constraint(equalTo: settingsInstruction.bottomAnchor, constant: UIConstants.layout.settingsViewOffset),

            enableInstruction.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            enableInstruction.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            enableInstruction.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            enableInstruction.topAnchor.constraint(equalTo: safariInstruction.bottomAnchor, constant: UIConstants.layout.settingsViewOffset)

        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class InstructionView: UIView {
    init(text: String, image: UIImage) {
        super.init(frame: CGRect.zero)

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        addSubview(imageView)

        let label = SmartLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = .defaultFont
        label.numberOfLines = 0
        label.font = .body16Medium
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        addSubview(label)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: image.size.height),
            imageView.widthAnchor.constraint(equalToConstant: image.size.width),

            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: UIConstants.layout.settingsPadding),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

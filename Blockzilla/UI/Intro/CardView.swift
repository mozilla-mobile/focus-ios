/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

struct CardViewModel {
    let title: String
    let text: String
    let image: UIImageView
    let isLast: Bool
}

protocol CardViewDelegate: class {
    func cardView(_ cardView: CardView, didTapButton button: UIButton)
}

final class CardView: UIView {

    let model: CardViewModel
    weak var delegate: CardViewDelegate?

    init(model: CardViewModel) {
        self.model = model

        super.init(frame: .zero)

        self.layer.shadowRadius = UIConstants.layout.introViewShadowRadius
        self.layer.shadowOpacity = UIConstants.layout.introViewShadowOpacity
        self.layer.cornerRadius = UIConstants.layout.introViewCornerRadius
        self.layer.masksToBounds = false

        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {

        // Add gradient layer
        let gradientLayer = IntroCardGradientBackgroundView()
        gradientLayer.layer.cornerRadius = UIConstants.layout.introViewCornerRadius

        addSubview(gradientLayer)

        gradientLayer.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        // Add image
        let image = model.image
        addSubview(image)
        image.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.centerX.equalTo(self)
            make.width.equalTo(UIConstants.layout.introViewImageWidth)
            make.height.equalTo(UIConstants.layout.introViewImageHeight)
        }

        // Add title label
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = IntroViewControllerUX.MinimumFontScale
        titleLabel.textColor = UIConstants.colors.firstRunTitle
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = model.title
        titleLabel.font = UIConstants.fonts.firstRunTitle

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom).offset(UIConstants.layout.introViewTitleLabelOffset)
            make.leading.equalTo(self).offset(UIConstants.layout.introViewTitleLabelOffset)
            make.trailing.equalTo(self).inset(UIConstants.layout.introViewTitleLabelInset)
            make.centerX.equalTo(self)
        }

        // Add text label
        let textLabel = UILabel()
        textLabel.numberOfLines = 5
        textLabel.attributedText = attributedStringForLabel(model.text)
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = IntroViewControllerUX.MinimumFontScale
        textLabel.lineBreakMode = .byTruncatingTail
        textLabel.textAlignment = .center
        textLabel.textColor = UIConstants.colors.firstRunMessage
        textLabel.font = UIConstants.fonts.firstRunMessage

        addSubview(textLabel)
        textLabel.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(titleLabel.snp.bottom).offset(UIConstants.layout.introViewTextLabelOffset)
            make.centerX.equalTo(self)
            make.leading.equalTo(self).offset(UIConstants.layout.introViewTextLabelPadding)
            make.trailing.equalTo(self).inset(UIConstants.layout.introViewTextLabelInset)
        })

        // Add card button
        let cardButton = UIButton()
        let title: String

        title =  model.isLast ? UIConstants.strings.firstRunButton : UIConstants.strings.NextIntroButtonTitle
        cardButton.setTitle(title, for: .normal)
        cardButton.setTitleColor(UIConstants.colors.firstRunNextButton, for: .normal)
        cardButton.titleLabel?.font = UIConstants.fonts.firstRunButton
        cardButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        addSubview(cardButton)
        bringSubviewToFront(cardButton)
        cardButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(textLabel.snp.bottom).offset(UIConstants.layout.introViewCardButtonOffset).priority(.required)
            make.bottom.equalTo(self).offset(-UIConstants.layout.introViewOffset).priority(.low)
            make.centerX.equalTo(self)
        }
    }

    @objc func buttonTapped(_ sender: UIButton) {
        delegate?.cardView(self, didTapButton: sender)
    }

    private func attributedStringForLabel(_ text: String) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = IntroViewControllerUX.CardTextLineHeight
        paragraphStyle.alignment = .center

        let string = NSMutableAttributedString(string: text)
        string.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: string.length))
        return string
    }
}

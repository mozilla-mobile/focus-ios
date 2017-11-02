///* This Source Code Form is subject to the terms of the Mozilla Public
// * License, v. 2.0. If a copy of the MPL was not distributed with this
// * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
//
//import UIKit
//import SnapKit
//
//struct IntroViewControllerUX {
//    static let Width = 375
//    static let Height = 667
//    static let SyncButtonTopPadding = 5
//    static let MinimumFontScale: CGFloat = 0.5
//
//    static let CardSlides = ["onboarding_1", "onboarding_2"]
//    static let NumberOfCards = CardSlides.count
//
//    static let PagerCenterOffsetFromScrollViewBottom = UIScreen.main.bounds.width <= 320 ? 20 : 30
//
//    static let StartBrowsingButtonTitle = NSLocalizedString("OK, Got it!", tableName: "Intro", comment: "Button to start browsing in Focus")
//    static let StartBrowsingButtonColor = UIColor(rgb: 0x4990E2)
//    static let StartBrowsingButtonHeight = 56
//
//    static let CardTextLineHeight = UIScreen.main.bounds.width <= 320 ? CGFloat(2) : CGFloat(6)
//    static let CardTextWidth = UIScreen.main.bounds.width <= 320 ? 240 : 280
//    static let CardTitleHeight = 50
//
//    static let FadeDuration = 0.25
//}
//
//let IntroViewControllerSeenProfileKey = "IntroViewControllerSeen"
//
//protocol IntroViewControllerDelegate: class {
//    func introViewControllerDidFinish(_ introViewController: IntroViewController, requestToLogin: Bool)
//}
//
//class IntroViewController: UIViewController, UIScrollViewDelegate {
//    weak var delegate: IntroViewControllerDelegate?
//
//    var slides = [UIImage]()
//    var cards = [UIImageView]()
//    var introViews = [UIView]()
//
//    var startBrowsingButton: UIButton!
//    var introView: UIView?
//    var slideContainer: UIView!
//    var pageControl: UIPageControl!
//    var backButton: UIButton!
//    var forwardButton: UIButton!
//
//    fileprivate var scrollView: IntroOverlayScrollView!
//
//    var slideVerticalScaleFactor: CGFloat = 1.0
//
//    override func viewDidLoad() {
//        let background = GradientBackgroundView(alpha: 0.7)
//        view.addSubview(background)
//        background.snp.makeConstraints { make in
//            make.edges.equalTo(view.snp.edges)
//        }
//
//        // scale the slides down for iPhone 4S
//        if view.frame.height <=  480 {
//            slideVerticalScaleFactor = 1.33
//            slideVerticalScaleFactor = 1.33 //4S
//        } else if view.frame.height <= 568 {
//            slideVerticalScaleFactor = 1.15 //SE
//        }
//
//        for slideName in IntroViewControllerUX.CardSlides {
//            slides.append(UIImage(named: slideName)!)
//        }
//
//        startBrowsingButton = UIButton()
//        startBrowsingButton.backgroundColor = UIColor.clear
//        startBrowsingButton.setTitle(IntroViewControllerUX.StartBrowsingButtonTitle, for: UIControlState())
//        startBrowsingButton.setTitleColor(IntroViewControllerUX.StartBrowsingButtonColor, for: UIControlState())
//        startBrowsingButton.addTarget(self, action: #selector(IntroViewController.SELstartBrowsing), for: UIControlEvents.touchUpInside)
//        startBrowsingButton.accessibilityIdentifier = "IntroViewController.startBrowsingButton"
//
//        view.addSubview(startBrowsingButton)
//
//        scrollView = IntroOverlayScrollView()
//        scrollView.backgroundColor = UIColor.clear
//        scrollView.accessibilityLabel = NSLocalizedString("Intro Tour Carousel", comment: "Accessibility label for the introduction tour carousel")
//        scrollView.delegate = self
//        scrollView.bounces = false
//        scrollView.isPagingEnabled = true
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.contentSize = CGSize(width: scaledWidthOfSlide * CGFloat(IntroViewControllerUX.NumberOfCards), height: scaledHeightOfSlide)
//        scrollView.accessibilityIdentifier = "IntroViewController.scrollView"
//        view.addSubview(scrollView)
//
//        pageControl = UIPageControl()
//        pageControl.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.3)
//        pageControl.currentPageIndicatorTintColor = UIColor.black
//        pageControl.numberOfPages = IntroViewControllerUX.NumberOfCards
//        pageControl.accessibilityIdentifier = "IntroViewController.pageControl"
//        pageControl.addTarget(self, action: #selector(IntroViewController.changePage), for: UIControlEvents.valueChanged)
//        view.addSubview(pageControl)
//
////        scrollView.addSubview(slideContainer)
//        scrollView.snp.makeConstraints { (make) -> Void in
//            make.left.right.top.bottom.equalTo(self.view)
//        }
//        self.view.layoutIfNeeded()
//        self.scrollView.layoutIfNeeded()
//
//        pageControl.snp.makeConstraints { (make) -> Void in
//            make.centerX.equalTo(self.scrollView)
//            make.bottom.equalTo(view).offset(-15)
//        }
//
//        startBrowsingButton.snp.makeConstraints { (make) -> Void in
//            make.left.right.equalTo(self.view)
//            make.height.equalTo(IntroViewControllerUX.StartBrowsingButtonHeight)
//            make.bottom.equalTo(pageControl.snp.top).offset(-15)
//        }
//
//        func addCard(title: String, text: String, introView: UIView, image: UIImageView) {
//            self.introViews.append(introView)
//
//            introView.backgroundColor = .white
//            introView.layer.shadowRadius = 3
//            introView.layer.shadowOpacity = 0.5
//            introView.layer.cornerRadius = 5
//
//            introView.addSubview(image)
//            image.snp.makeConstraints { make in
//                make.top.equalTo(introView)
//                make.centerX.equalTo(introView)
//            }
//
//            let titleLabel = UILabel()
//            titleLabel.numberOfLines = 2
//            titleLabel.adjustsFontSizeToFitWidth = true
//            titleLabel.minimumScaleFactor = IntroViewControllerUX.MinimumFontScale
//            titleLabel.textAlignment = NSTextAlignment.center
//            titleLabel.text = title
//            titleLabel.font = UIConstants.fonts.firstRunTitle
//
//            introView.addSubview(titleLabel)
//            titleLabel.snp.makeConstraints { (make ) -> Void in
//                make.top.equalTo(image.snp.bottom)
//                make.centerX.equalTo(introView)
//                make.height.equalTo(IntroViewControllerUX.CardTitleHeight)
//                make.width.equalTo(IntroViewControllerUX.CardTextWidth)
//            }
//
//            let textLabel = UILabel()
//            textLabel.numberOfLines = 5
//            textLabel.attributedText = attributedStringForLabel(text)
//            textLabel.adjustsFontSizeToFitWidth = true
//            textLabel.minimumScaleFactor = IntroViewControllerUX.MinimumFontScale
//            textLabel.lineBreakMode = .byTruncatingTail
//            textLabel.font = UIConstants.fonts.firstRunMessage
//
//            introView.addSubview(textLabel)
//            textLabel.snp.makeConstraints({ (make) -> Void in
//                make.top.equalTo(titleLabel.snp.bottom).offset(20)
//                make.centerX.equalTo(introView)
//                make.width.equalTo(IntroViewControllerUX.CardTextWidth)
//            })
//        }
//
//        for i in 0..<IntroViewControllerUX.NumberOfCards {
//            //            if let imageView = slideContainer.subviews[i] as? UIImageView {
//            //                imageView.frame = CGRect(x: CGFloat(i)*scaledWidthOfSlide, y: 0, width: scaledWidthOfSlide, height: scaledHeightOfSlide)
//            //                imageView.contentMode = UIViewContentMode.scaleAspectFit
//            //            }
//        }
//
//        addCard(title: UIConstants.strings.CardTitleWelcome, text: UIConstants.strings.CardTextWelcome, introView: UIView(), image: UIImageView(image: slides[0]))
//        addCard(title: UIConstants.strings.CardTitleSearch, text: UIConstants.strings.CardTextSearch, introView: UIView(), image: UIImageView(image: slides[1]))
//
//        // Add all the cards to the view, make them invisible with zero alpha
//        for introView in introViews {
//            introView.alpha = 0
//            self.view.addSubview(introView)
//
//            introView.snp.makeConstraints { (make) -> Void in
//                make.center.equalTo(self.view)
//                make.width.equalTo(self.view.frame.width/1.2)
//                make.height.equalTo(self.view.frame.height/1.3)
//            }
//        }
//
//        slideContainer = UIView()
//        slideContainer.backgroundColor = UIColor.red
//        for i in 0..<IntroViewControllerUX.NumberOfCards {
//            let imageView = UIImageView(frame: CGRect(x: CGFloat(i)*scaledWidthOfSlide, y: 0, width: scaledWidthOfSlide, height: scaledHeightOfSlide))
//            imageView.image = slides[i]
//            slideContainer.addSubview(imageView)
//        }
//
//        // Make whole screen scrollable by bringing the scrollview to the top
//        view.bringSubview(toFront: scrollView)
//
//        // Activate the first card
//        setActiveIntroView(introViews[0], forPage: 0)
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        scrollView.snp.remakeConstraints { (make) -> Void in
//            make.left.right.top.bottom.equalTo(self.view)
//        }
//
////        slideContainer.frame = CGRect(x: 0, y: 0, width: scaledWidthOfSlide * CGFloat(IntroViewControllerUX.NumberOfCards), height: scaledHeightOfSlide)
////        scrollView.contentSize = CGSize(width: slideContainer.frame.width, height: slideContainer.frame.height)
//    }
//
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
//
//    override var shouldAutorotate: Bool {
//        return false
//    }
//
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        // This actually does the right thing on iPad where the modally
//        // presented version happily rotates with the iPad orientation.
//        return UIInterfaceOrientationMask.portrait
//    }
//
//    @objc func SELstartBrowsing() {
//        dismiss(animated: true, completion: nil)
//    }
//
//    func SELback() {
//        if introView == introViews[1] {
//            setActiveIntroView(introViews[0], forPage: 0)
//            scrollView.scrollRectToVisible(scrollView.subviews[0].frame, animated: true)
//            pageControl.currentPage = 0
//        } else if introView == introViews[2] {
//            setActiveIntroView(introViews[1], forPage: 1)
//            scrollView.scrollRectToVisible(scrollView.subviews[1].frame, animated: true)
//            pageControl.currentPage = 1
//        }
//    }
//
//    func SELforward() {
//        if introView == introViews[0] {
//            setActiveIntroView(introViews[1], forPage: 1)
//            scrollView.scrollRectToVisible(scrollView.subviews[1].frame, animated: true)
//            pageControl.currentPage = 1
//        } else if introView == introViews[1] {
//            setActiveIntroView(introViews[2], forPage: 2)
//            scrollView.scrollRectToVisible(scrollView.subviews[2].frame, animated: true)
//            pageControl.currentPage = 2
//        }
//    }
//
//    @objc func SELlogin() {
//        delegate?.introViewControllerDidFinish(self, requestToLogin: true)
//    }
//
//    fileprivate var accessibilityScrollStatus: String {
//        let number = NSNumber(value: pageControl.currentPage + 1)
//        return String(format: NSLocalizedString("Introductory slide %@ of %@", tableName: "Intro", comment: "String spoken by assistive technology (like VoiceOver) stating on which page of the intro wizard we currently are. E.g. Introductory slide 1 of 3"), NumberFormatter.localizedString(from: number, number: .decimal), NumberFormatter.localizedString(from: NSNumber(value: IntroViewControllerUX.NumberOfCards), number: .decimal))
//    }
//
//    @objc func changePage() {
//        let swipeCoordinate = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
//        scrollView.setContentOffset(CGPoint(x: swipeCoordinate, y: 0), animated: true)
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        // Need to add this method so that when forcibly dragging, instead of letting deceleration happen, should also calculate what card it's on.
//        // This especially affects sliding to the last or first slides.
//        if !decelerate {
//            scrollViewDidEndDecelerating(scrollView)
//        }
//    }
//
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        // Need to add this method so that tapping the pageControl will also change the card texts.
//        // scrollViewDidEndDecelerating waits until the end of the animation to calculate what card it's on.
//        scrollViewDidEndDecelerating(scrollView)
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
//        setActiveIntroView(introViews[page], forPage: page)
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let maximumHorizontalOffset = scrollView.frame.width
//        let currentHorizontalOffset = scrollView.contentOffset.x
//
//        var percentageOfScroll = currentHorizontalOffset / maximumHorizontalOffset
//        percentageOfScroll = percentageOfScroll > 1.0 ? 1.0 : percentageOfScroll
//        let whiteComponent = UIColor.white.components
//        let grayComponent = UIColor(rgb: 0xF2F2F2).components
//
//        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
//        pageControl.currentPage = page
//
//        let newRed   = (1.0 - percentageOfScroll) * whiteComponent.red   + percentageOfScroll * grayComponent.red
//        let newGreen = (1.0 - percentageOfScroll) * whiteComponent.green + percentageOfScroll * grayComponent.green
//        let newBlue  = (1.0 - percentageOfScroll) * whiteComponent.blue  + percentageOfScroll * grayComponent.blue
//        let newColor =  UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
//        slideContainer.backgroundColor = newColor
//    }
//
//    fileprivate func setActiveIntroView(_ newIntroView: UIView, forPage page: Int) {
//        if introView != newIntroView {
//            UIView.animate(withDuration: IntroViewControllerUX.FadeDuration, animations: { () -> Void in
//                self.introView?.alpha = 0
//                self.introView = newIntroView
//                newIntroView.alpha = 1.0
//                if page == 0 {
//                    self.startBrowsingButton.alpha = 0
//                } else {
//                    self.startBrowsingButton.alpha = 1
//                }
//            }, completion: { _ in
//                if page == (IntroViewControllerUX.NumberOfCards - 1) {
//                } else {
//                    self.scrollView.signinButton = nil
//                }
//            })
//        }
//    }
//
//    fileprivate var scaledWidthOfSlide: CGFloat {
//        return view.frame.width
//    }
//
//    fileprivate var scaledHeightOfSlide: CGFloat {
//        return (view.frame.width / slides[0].size.width) * slides[0].size.height / slideVerticalScaleFactor
//    }
//
//    fileprivate func attributedStringForLabel(_ text: String) -> NSMutableAttributedString {
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = IntroViewControllerUX.CardTextLineHeight
//        paragraphStyle.alignment = .center
//
//        let string = NSMutableAttributedString(string: text)
//        string.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: string.length))
//        return string
//    }
//}
//
//fileprivate class IntroOverlayScrollView: UIScrollView {
//    weak var signinButton: UIButton?
//
//    fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        if let signinFrame = signinButton?.frame {
//            let convertedFrame = convert(signinFrame, from: signinButton?.superview)
//            if convertedFrame.contains(point) {
//                return false
//            }
//        }
//
//        return CGRect(origin: self.frame.origin, size: CGSize(width: self.contentSize.width, height: self.frame.size.height)).contains(point)
//    }
//}
//
//extension UIColor {
//    var components:(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
//        var r: CGFloat = 0
//        var g: CGFloat = 0
//        var b: CGFloat = 0
//        var a: CGFloat = 0
//        getRed(&r, green: &g, blue: &b, alpha: &a)
//        return (r, g, b, a)
//    }
//}
//
//

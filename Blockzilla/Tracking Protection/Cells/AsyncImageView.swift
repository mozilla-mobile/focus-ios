/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class AsyncImageView: UIView {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)
    
    let loader = ImageLoader()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        addSubview(imageView)
        addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints { make in
            make.centerY.centerY.equalToSuperview()
        }
    }
    
    func load(imageURL: URL, defaultImage: UIImage) {
        activityIndicator.startAnimating()
        loader.loadImage(imageURL) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self?.activityIndicator.stopAnimating()
                    self?.imageView.image = image
                    
                case .error:
                    self?.imageView.image = defaultImage
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
    }
}

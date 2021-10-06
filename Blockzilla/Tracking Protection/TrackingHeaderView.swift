

import UIKit

class ImageLoader {
    private var loadedImages = [URL: UIImage]()
    private var runningRequests = [UUID: URLSessionDataTask]()
}

extension ImageLoader {
    @discardableResult
    func loadImage(_ url: URL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        
        if let image = loadedImages[url] {
            completion(.success(image))
            return nil
        }
        
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer { self.runningRequests.removeValue(forKey: uuid) }
            
            if let data = data, let image = UIImage(data: data) {
                self.loadedImages[url] = image
                completion(.success(image))
                return
            }
            
            guard let error = error else { return }
            
            guard (error as NSError).code == NSURLErrorCancelled else {
                completion(.error(error))
                return
            }
        }
        task.resume()
        
        runningRequests[uuid] = task
        return uuid
    }
    
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}

class AsyncImage: UIView {
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
    
    func load(imageURL: URL) {
        activityIndicator.startAnimating()
        loader.loadImage(imageURL) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self?.activityIndicator.stopAnimating()
                    self?.imageView.image = image
                    
                case .error:
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
    }
}



class TrackingHeaderView: UIView {
    private lazy var faviImageView: AsyncImage = {
        let shieldLogo = AsyncImage()
        return shieldLogo
    }()
    
    private lazy var domainLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = UIConstants.colors.defaultFont
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [faviImageView, domainLabel])
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.axis = .horizontal
        return stackView
    }()
    
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .searchSeparator.withAlphaComponent(0.65)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(separator)
        addSubview(stackView)
        faviImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        separator.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.bottom.leading.trailing.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(16)
        }
    }
    
    func configure(domain: String, imageURL: URL) {
        self.domainLabel.text = domain
        self.faviImageView.load(imageURL: imageURL)
    }
}

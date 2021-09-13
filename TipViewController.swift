import UIKit

class TipViewController: UIViewController {
    
    private lazy var tipTitleLabel: SmartLabel = {
        let label = SmartLabel()
        label.textColor = UIConstants.colors.defaultFont
        label.font = UIConstants.fonts.shareTrackerStatsLabel
        label.numberOfLines = 0
        label.minimumScaleFactor = UIConstants.layout.homeViewLabelMinimumScale
        return label
    }()
    
    private let tipDescriptionLabel: SmartLabel = {
        let label = SmartLabel()
        label.textColor = .accent
        label.font = UIConstants.fonts.shareTrackerStatsLabel
        label.numberOfLines = 0
        label.minimumScaleFactor = UIConstants.layout.homeViewLabelMinimumScale
        return label
    }()
    
    var tip: TipManager.Tip
    
    init(tip: TipManager.Tip) {
        self.tip = tip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tipTitleLabel)
        view.addSubview(tipDescriptionLabel)

        tipTitleLabel.text = tip.title
        tipDescriptionLabel.text = tip.description
        
        tipDescriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        tipTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(tipDescriptionLabel.snp.top)
        }
    }
}

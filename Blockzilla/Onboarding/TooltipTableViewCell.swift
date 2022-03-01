//
//  TooltipTableViewCell.swift
//  Blockzilla
//
//  Created by catalin.neculaide on 25.02.2022.
//  Copyright © 2022 Mozilla. All rights reserved.
//

import UIKit

class TooltipTableViewCell: UITableViewCell {

    var tooltip = TooltipView()
    
    convenience init(title: String, body: String, style: UITableViewCell.CellStyle = .default, reuseIdentifier: String? = nil, delegate: TooltipViewDelegate) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(tooltip)
        tooltip.set(title: title, body: body, maxWidth: UIScreen.main.bounds.width)
        tooltip.delegate = delegate
        tooltip.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

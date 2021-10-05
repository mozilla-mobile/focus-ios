//
//  ImageCell.swift
//  Blockzilla
//
//  Created by razvan.litianu on 05.10.2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {
    
    convenience init(image: UIImage, title: String, style: UITableViewCell.CellStyle = .default, reuseIdentifier: String? = nil) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        imageView?.image = image
        textLabel?.text = title
        textLabel?.textColor = .primaryText
        textLabel?.numberOfLines = 0
        backgroundColor = .secondaryBackground
        selectionStyle = .none
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//
//  MessageCell.swift
//  PaginationTest
//
//  Created by Shakhzod Omonbayev on 23/09/23.
//

import UIKit

final class MessageCell: UICollectionViewCell {
    private var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        label.textColor = .white
        
        return label
    }()
    
    static let reuseIdentifier = String.init(describing: MessageCell.self)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(messageLabel)
        
        self.backgroundColor = .blue.withAlphaComponent(0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
        
        self.layer.cornerRadius = frame.size.height / 8
        self.layer.masksToBounds = true
    }
    
    func configure(with message: String) {
        messageLabel.text = message
    }
}

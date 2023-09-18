//
//  CustomContentView.swift
//  CollapsingHeaderTest
//
//  Created by 福田正知 on 2023/09/18.
//

import UIKit

// MARK: CustomContentView
class CustomContentView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "CustomContentView\nWidth: \(self.frame.width)\nHeight: \(self.frame.height)"
        label.font = UIFont.boldSystemFont(ofSize: 21)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
    }
    
    func setup(color: UIColor) {
        backgroundColor = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

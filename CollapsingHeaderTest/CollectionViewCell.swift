//
//  CollectionViewCell.swift
//  CollapsingHeaderTest
//
//  Created by 福田正知 on 2023/09/17.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderColor = CGColor(red: 0.9, green: 0.5, blue: 0.5, alpha: 1)
        layer.borderWidth = 1.0
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

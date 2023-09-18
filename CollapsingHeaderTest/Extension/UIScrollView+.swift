//
//  UIScrollView+.swift
//  CollapsingHeaderTest
//
//  Created by 福田正知 on 2023/09/18.
//

import UIKit

extension UIScrollView {
    
    var currentPage: Int {
        let currentPage = Int((self.contentOffset.x + (0.5 * self.bounds.width)) / self.bounds.width) + 1
        return currentPage
    }
}

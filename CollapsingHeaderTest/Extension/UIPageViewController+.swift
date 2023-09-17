//
//  UIPageViewController+.swift
//  CollapsingHeaderTest
//
//  Created by 福田正知 on 2023/09/17.
//

import UIKit

extension UIPageViewController {
    
    var currentPage: Int {
        if let currentViewController = self.viewControllers?.first {
            return currentViewController.view.tag
        } else {
            return 0
        }
    }
}

//
//  ViewController.swift
//  CollapsingHeaderTest
//
//  Created by 福田正知 on 2023/09/18.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let collapsibleHeaderPagerViewController = CollapsibleHeaderPagerViewController()
        collapsibleHeaderPagerViewController.dataSource = self
        
        self.addChild(collapsibleHeaderPagerViewController)
        self.view.addSubview(collapsibleHeaderPagerViewController.view)
        collapsibleHeaderPagerViewController.didMove(toParent: self)
    }
}

extension ViewController: CollapsibleHeaderPagerViewControllerDatasource {
    
    func collapsingHeaderScrollViewControllerHeaderView() -> UIView {
//        let headerView = CustomHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 160))
        let headerView = TwitterLikeHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 320))
        
        return headerView
    }
    
    // TODO: データ内容によって高さが変わる場合の対応
    
    func collapsingHeaderScrollViewControllerHeaderHeight() -> CGFloat {
        return 320
    }
    
    func collapsingHeaderScrollViewControllerTabBarHeight() -> CGFloat {
        return 50
    }
    
    func collapsingHeaderScrollViewControllerPagesTabBarColor() -> UIColor {
        return .orange
    }
    
    func collapsingHeaderScrollViewControllerPages() -> [CollapsibleHeaderPagerViewPage] {
        
        let pages: [CollapsibleHeaderPagerViewPage] = [
            CollapsibleHeaderPagerViewPage(title: "Page1", view: CustomContentView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))),
            CollapsibleHeaderPagerViewPage(title: "Page2", view: CustomContentView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 600))),
            CollapsibleHeaderPagerViewPage(title: "Page3", view: CustomContentView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 900))),
            CollapsibleHeaderPagerViewPage(title: "Page4", view: CustomContentView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1200))),
            CollapsibleHeaderPagerViewPage(title: "etc.", view: CustomContentView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300)))
        ]
        let colors: Array<UIColor> = [
            UIColor(hex: "F5D4E9"),
            UIColor(hex: "D6D0F5"),
            UIColor(hex: "F9F4CF"),
            UIColor(hex: "B3DFB5"),
            UIColor(hex: "F6CCA7")
        ]
        for (index, page) in pages.enumerated() {
            if let view = page.view as? CustomContentView {
                view.setup(color: colors[index])
            }
        }
        
        return pages
    }
    
    // TODO: Create delegate method to provide page frame height?
}

//
//  ViewController.swift
//  CollapsingHeaderTest
//
//  Created by 福田正知 on 2023/09/18.
//

import UIKit

class ViewController: UIViewController {
    
    var pages: [CollapsibleHeaderPagerViewPage] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPages()
        
        let collapsibleHeaderPagerViewController = CollapsibleHeaderPagerViewController()
        collapsibleHeaderPagerViewController.dataSource = self
        
        self.addChild(collapsibleHeaderPagerViewController)
        self.view.addSubview(collapsibleHeaderPagerViewController.view)
        collapsibleHeaderPagerViewController.didMove(toParent: self)
    }
    
    private func setupPages() {
        // Sample content UIView
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
        self.pages = pages
    }
}

extension ViewController: CollapsibleHeaderPagerViewControllerDatasource {
    
    func collapsingHeaderScrollViewControllerHeaderView() -> UIView {
        let headerView = CustomHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 160))
        return headerView
    }
    
    func collapsingHeaderScrollViewControllerHeaderHeight() -> CGFloat {
        return 160
    }
    
    func collapsingHeaderScrollViewControllerPages() -> [CollapsibleHeaderPagerViewPage] {
        return self.pages
    }
    
    func collapsingHeaderScrollViewController(_ viewController: CollapsibleHeaderPagerViewController) -> Int {
        return self.pages.count
    }
    
    func collapsibleHeaderScrollViewController(_ viewController: CollapsibleHeaderPagerViewController, index: Int) -> CollapsibleHeaderPagerViewPage {
        return self.pages[index]
    }
}

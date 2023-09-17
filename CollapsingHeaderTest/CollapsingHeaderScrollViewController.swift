//
//  CollapsingHeaderScrollViewController.swift
//  CollapsingHeaderTest
//
//  Created by 福田正知 on 2023/09/17.
//

import Foundation
import UIKit

// MARK: CollapsingHeaderScrollViewController
class CollapsingHeaderScrollViewController: UIViewController {
    
    var statusBarHeight: CGFloat = 0
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
    let pageViewObserver = PageViewObserver()
    
    let parentScrollView = UIScrollView()
    
    var viewControllersArray: Array<UIViewController> = []
    let colors: Array<UIColor> = [UIColor.red, UIColor.gray, UIColor.blue, UIColor.systemCyan]
    
    var pageControl = UIPageControl()
    
    let headerView = UIView()
    let headerViewHeight: CGFloat = 160
    var headerViewTopAnchor = NSLayoutConstraint()
    
    let tabView = UIStackView()
    let tabViewHeight: CGFloat = 50
    var barViewLeftAnchor = NSLayoutConstraint()
    
    var isHeaderEnableToMoveWithScroll = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIScrollViewを一番上に持ってくるパターン
        setupScrollView()
        
        // MARK: headerView
        headerView.frame = CGRect()
        headerView.backgroundColor = UIColor(cgColor: CGColor(red: 0.8, green: 0.8, blue: 0.3, alpha: 1))
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        headerViewTopAnchor = headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        headerViewTopAnchor.isActive = true
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: headerViewHeight).isActive = true
        
        let label = UILabel()
        label.text = "test label"
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            label.widthAnchor.constraint(equalTo: headerView.widthAnchor),
            label.heightAnchor.constraint(equalTo: headerView.heightAnchor)
        ])
        
        // MARK: tabView
        tabView.translatesAutoresizingMaskIntoConstraints = false
        tabView.distribution = .fillEqually
        tabView.alignment = .fill
        tabView.axis = .horizontal
        tabView.spacing = 0.0
        tabView.backgroundColor = .white
        
        view.addSubview(tabView)
        tabView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tabView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tabView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        tabView.heightAnchor.constraint(equalToConstant: tabViewHeight).isActive = true
        
        let button1 = TabButtonView(frame: UIView().frame)
        button1.setup(title: "button1", tag: 1, handler: { self.makePageMoveByTab(toIndex: 0) })
        button1.updateState(selectedIndex: 0)
        let button2 = TabButtonView(frame: UIView().frame)
        button2.setup(title: "button2", tag: 2, handler: { self.makePageMoveByTab(toIndex: 1) })
        let button3 = TabButtonView(frame: UIView().frame)
        button3.setup(title: "button3", tag: 3, handler: { self.makePageMoveByTab(toIndex: 2) })
        let button4 = TabButtonView(frame: UIView().frame)
        button4.setup(title: "button4", tag: 4, handler: { self.makePageMoveByTab(toIndex: 3) })
        tabView.addArrangedSubview(button1)
        tabView.addArrangedSubview(button2)
        tabView.addArrangedSubview(button3)
        tabView.addArrangedSubview(button4)
        
        // tabView's bottom border
        let tabViewBottomBorder = CALayer()
        tabViewBottomBorder.frame = CGRect(x: 0, y: tabViewHeight, width: view.frame.width, height: 1.0)
        tabViewBottomBorder.backgroundColor = UIColor.lightGray.cgColor.copy(alpha: 0.5)
        tabView.layer.addSublayer(tabViewBottomBorder)
        
        // tabView Bar
        let barView = UIView()
        barView.backgroundColor = .systemMint
        barView.layer.cornerRadius = 2
        
        barView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(barView)
        barViewLeftAnchor = barView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        barViewLeftAnchor.isActive = true
        barView.bottomAnchor.constraint(equalTo: tabView.bottomAnchor, constant: 0).isActive = true
        barView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        barView.widthAnchor.constraint(equalToConstant: view.frame.width / 4).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        statusBarHeight = view.window!.safeAreaInsets.top
    }

    // scrollViewを試すパターン☆
    private func setupScrollView() {
        parentScrollView.accessibilityIdentifier = "OuterScrollView"
        parentScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        parentScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(colors.count), height: view.frame.height)
        parentScrollView.isPagingEnabled = true
        parentScrollView.delegate = self
        
        for index in 0 ..< colors.count {
            let childScrollView = UIScrollView()
            childScrollView.accessibilityIdentifier = "\(index)"
            childScrollView.isPagingEnabled = false
            childScrollView.frame = CGRect(x: view.frame.width * CGFloat(index), y: 0, width: view.frame.width, height: view.frame.height)
            childScrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height * 1.5)
            childScrollView.delegate = self
            childScrollView.backgroundColor = .white
            
            let boxView = UIView(frame: CGRect(x: 40, y: 10 + headerViewHeight + tabViewHeight, width: 300, height: 200))
            boxView.backgroundColor = colors[index]
//            boxView.translatesAutoresizingMaskIntoConstraints = false
            childScrollView.addSubview(boxView)

            let label = UILabel(frame: CGRect(x: 10, y: 10, width: 200, height: 50))
            label.text = "page:" + index.description
            label.textColor = .black
            label.font = UIFont.boldSystemFont(ofSize: 40)
            label.textAlignment = .center
            
            // label.translatesAutoresizingMaskIntoConstraints = falseするとUIScrollViewが真っ白になるので一旦そのままaddSubviewする
//            label.translatesAutoresizingMaskIntoConstraints = false
            boxView.addSubview(label)
            
            childScrollView.translatesAutoresizingMaskIntoConstraints = false
            parentScrollView.addSubview(childScrollView)
        }
        
        view.addSubview(parentScrollView)
        parentScrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        parentScrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
        self.view.layoutSubviews()
    }
    
    /// タブ選択でページ遷移するためのfunction
    private func makePageMoveByTab(toIndex: Int) -> Void {
        parentScrollView.setContentOffset(CGPoint(x: CGFloat(toIndex) * view.frame.width, y: 0), animated: true)
        // Set Y offset on other pages
        parentScrollView.subviews.filter { $0.isKind(of: UIScrollView.self) }
            .filter { $0.accessibilityIdentifier != "OuterScrollView" }
            .forEach {
                if let childScrollView = $0 as? UIScrollView {
                    childScrollView.setContentOffset(CGPoint(x: 0, y: -headerViewTopAnchor.constant), animated: false)
                }
            }
        tabView.subviews.filter { $0.isKind(of: TabButtonView.self) }
            .forEach { view in
                if let button = view as? TabButtonView {
                    button.updateState(selectedIndex: toIndex)
                }
            }
    }
}

// MARK: UIScrollView
extension CollapsingHeaderScrollViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // UIPageViewControllerのscrollViewか、各ページ内のscrollViewかをIdで判定する
        debugPrint("[scrollViewDidScroll] scrollView ID: \(String(describing: scrollView.accessibilityIdentifier))")
        if scrollView.accessibilityIdentifier != "OuterScrollView" {
            // UIPageViewControllerを横移動中はこの中の処理を呼ばないようにする
            print("Inner scrollView.contentOffset: \(scrollView.contentOffset)")
            if isHeaderEnableToMoveWithScroll {
                headerViewTopAnchor.constant = max(-scrollView.contentOffset.y, -headerViewHeight + statusBarHeight)
            }
        } else if scrollView.accessibilityIdentifier == "OuterScrollView" {
            // PageViewController自体のUIQueuingScrollViewが呼ばれた時
//            print("PageViewController's scrollView.contentOffset: \(scrollView.contentOffset)")
//            print("pageViewController.currentPage: \(pageViewController.currentPage)")
            barViewLeftAnchor.constant = (scrollView.contentOffset.x / 4) + CGFloat(pageViewObserver.isMovingFrom) * (view.frame.width / 4)
        }
    }
    
    // ページネーション開始時に呼ばれる
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("---scrollViewWillBeginDragging---: \(scrollView.accessibilityIdentifier ?? "")-\(scrollView.currentPage)")
        // 前後両ページに対して位置調整を行う
        scrollView.subviews.filter { $0.isKind(of: UIScrollView.self) }
            .filter { $0.accessibilityIdentifier != "OuterScrollView" }
            .forEach {
                if let childScrollView = $0 as? UIScrollView {
                    childScrollView.setContentOffset(CGPoint(x: 0, y: -headerViewTopAnchor.constant), animated: false)
                }
            }
    }
    
    // ページネーション中に指を離したら呼ばれる
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("---scrollViewWillBeginDecelerating")
    }
    
    // ページネーション完了時に呼ばれる。
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("---scrollViewDidEndDecelerating---: \(scrollView.accessibilityIdentifier ?? "")-\(scrollView.currentPage)")
        
        tabView.subviews.filter { $0.isKind(of: TabButtonView.self) }
            .forEach { view in
                if let button = view as? TabButtonView {
                    let currentPageIndex = scrollView.currentPage - 1
                    button.updateState(selectedIndex: currentPageIndex)
                }
            }
    }
}

//// MARK: UIPageViewController
//extension CollapsingHeaderScrollViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
//    
//    // 最後に選択・表示されたViewControllerの後のViewControllerを返す
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        var index = viewController.view.tag
//        
//        pageControl.currentPage = index
//        if index == colors.count - 1{
//            return nil
//        }
//        index = index + 1
//        return viewControllersArray[index]
//    }
//
//    // 最後に選択・表示されたViewControllerの前のViewControllerを返す
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        var index = viewController.view.tag
//        pageControl.currentPage = index
//        index = index - 1
//        if index < 0{
//            return nil
//        }
//        return viewControllersArray[index]
//    }
//    
//    // Viewが変更されると呼ばれる（scrollViewDidScrollが呼ばれるのはこれよりも後）
//    func pageViewController(_ pageViewController: UIPageViewController,
//                            didFinishAnimating: Bool,
//                            previousViewControllers: [UIViewController],
//                            transitionCompleted: Bool) {
//        let previousPageIndex = previousViewControllers.first!.view.tag
//        print("---moved from Page.\(previousPageIndex)")
//        pageViewObserver.isMoving = false
//        if let nextPageIndex = pageViewController.viewControllers?.first!.view.tag {
//            pageViewObserver.isMovingFrom = nextPageIndex
//            pageControl.currentPage = nextPageIndex
//        }
//        Task {
//            try await Task.sleep(nanoseconds: 100 * 1000 * 1000)
//            print("--- 0.1 sec after move completed")
//            isHeaderEnableToMoveWithScroll = true
//        }
//    }
//    
//    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
//        print("Previous page: \(pageViewController.viewControllers?.first!.view.tag ?? 0)")
//        print("Next Page (pendingViewControllers.first!.view.tag): \(pendingViewControllers.first!.view.tag)")
//        isHeaderEnableToMoveWithScroll = false
//        pageViewObserver.isMoving = true
//        pageViewObserver.isMovingFrom = pageViewController.viewControllers?.first!.view.tag ?? 0
//        // ここで現在のスクロール量を遷移予定のViewControllerに渡してあげる
//        let nextVc = pendingViewControllers.first!.view
//        guard let nextScrollView = nextVc?.subviews.first as? UIScrollView else { return }
//        nextScrollView.setContentOffset(CGPoint(x: 0, y: -headerViewTopAnchor.constant), animated: false)
//        // 初回表示の時にステータスバーの高さ分だけ強制的に補正されるため、0.01秒の非同期で再補正かけるようにする（根本的な解決は難しそう）
//        Task {
//            try await Task.sleep(nanoseconds: 10 * 1000 * 1000)
//            nextScrollView.setContentOffset(CGPoint(x: 0, y: -headerViewTopAnchor.constant), animated: false)
//        }
//    }
//}

extension UIScrollView {
    
    var currentPage: Int {
        let currentPage = Int((self.contentOffset.x + (0.5 * self.bounds.width)) / self.bounds.width) + 1
        return currentPage
    }
}

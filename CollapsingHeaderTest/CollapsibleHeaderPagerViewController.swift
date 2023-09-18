//
//  CollapsibleHeaderPagerViewController.swift
//  CollapsingHeaderTest
//
//  Created by 福田正知 on 2023/09/17.
//

import Foundation
import UIKit

// MARK: CollapsingHeaderScrollViewController
public class CollapsibleHeaderPagerViewController: UIViewController {
    
    var statusBarHeight: CGFloat = 0
    
    let parentScrollView = UIScrollView()
        
    let headerViewHeight: CGFloat = 160
    var headerViewTopAnchor = NSLayoutConstraint()
    
    let tabView = UIStackView()
    let tabViewHeight: CGFloat = 50
    var barViewLeftAnchor = NSLayoutConstraint()
    
    var dataSource: CollapsibleHeaderPagerViewControllerDatasource?
    var pages: [CollapsibleHeaderPagerViewPage] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        let headerView = CustomHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: headerViewHeight))
        
        // Sample content UIView
        let pages: [CollapsibleHeaderPagerViewPage] = [
            CollapsibleHeaderPagerViewPage(title: "Page1", view: CustomContentView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))),
            CollapsibleHeaderPagerViewPage(title: "Page2", view: CustomContentView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 600))),
            CollapsibleHeaderPagerViewPage(title: "Page3", view: CustomContentView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 900))),
            CollapsibleHeaderPagerViewPage(title: "Page4", view: CustomContentView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1200)))
        ]
        let colors: Array<UIColor> = [
            UIColor(hex: "F5D4E9"),
            UIColor(hex: "D6D0F5"),
            UIColor(hex: "F9F4CF"),
            UIColor(hex: "B3DFB5")
        ]
        for (index, page) in pages.enumerated() {
            if let view = page.view as? CustomContentView {
                view.setup(color: colors[index])
            }
        }
        
        setup(header: headerView, headerHeight: headerView.frame.height, pages: pages)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        statusBarHeight = view.window!.safeAreaInsets.top
    }
    
    private func createHeaderView() -> UIView {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: headerViewHeight)
        return headerView
    }
    
    /// Create CollapsibleHeaderPagerView
    /// - Parameters:
    ///     - headerView: A UIView to be set on the upside (required)
    ///     - headerHeight: HeaderView's height (required)
    private func setup(header: UIView, headerHeight: CGFloat, pages: [CollapsibleHeaderPagerViewPage]) {
        
        self.pages = pages
        
        setupScrollView()
        
        // MARK: header
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)
        headerViewTopAnchor = header.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        headerViewTopAnchor.isActive = true
        header.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        header.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        header.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true
        
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
        tabView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 0).isActive = true
        tabView.heightAnchor.constraint(equalToConstant: tabViewHeight).isActive = true
        
        // MARK: setup tabView's buttons
        for (index, _) in pages.enumerated() {
            let button = TabButtonView(frame: UIView().frame)
            button.setup(title: "\(pages[index].title)", tag: index + 1, handler: { self.makePageMoveByTab(toIndex: index) })
            tabView.addArrangedSubview(button)
            if index == 0 { button.updateState(selectedIndex: 0) }
        }
        
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
        barView.widthAnchor.constraint(equalToConstant: view.frame.width / pages.count.cgFloat).isActive = true
    }

    /// set up ParentScrollView and ChildScrollViews
    private func setupScrollView() {
        parentScrollView.accessibilityIdentifier = "OuterScrollView"
        parentScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        parentScrollView.contentSize = CGSize(width: view.frame.width * pages.count.cgFloat, height: view.frame.height)
        parentScrollView.isPagingEnabled = true
        parentScrollView.delegate = self
        
        let headerAreaHeight = headerViewHeight + tabViewHeight
            
        for index in 0 ..< pages.count {
            
            let contentView = self.dataSource?.collapsibleHeaderScrollViewController(self, index: index).view ?? UIView()
            
            let childScrollView = UIScrollView()
            childScrollView.accessibilityIdentifier = "\(index)"
            childScrollView.isPagingEnabled = false
            childScrollView.alwaysBounceVertical = true
            childScrollView.frame = CGRect(x: view.frame.width * CGFloat(index), y: 0, width: view.frame.width, height: view.frame.height)
            childScrollView.contentSize.width = view.frame.width
            childScrollView.contentSize.height = headerAreaHeight + contentView.frame.height
            childScrollView.delegate = self
            childScrollView.backgroundColor = .white
            
            // dataSourceから取ってくるUIViewにはY方向のオフセットは付けられてないはず
            // addSubviewする前にframe位置を調整する必要あり
            contentView.frame = CGRect(x: contentView.frame.minX, y: headerAreaHeight + contentView.frame.minY,
                                   width: contentView.frame.width, height: contentView.frame.height)
            
            childScrollView.addSubview(contentView)
            
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

// MARK: UIScrollViewDelegate
extension CollapsibleHeaderPagerViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // parentScrollViewか、各ページ内のchildScrollViewかをIdで判定する
        if scrollView.accessibilityIdentifier != "OuterScrollView" {
            // To make TabView sticky, set limit to the headerViewTopAnchor max value.
            headerViewTopAnchor.constant = max(-scrollView.contentOffset.y, -headerViewHeight + statusBarHeight)
        } else if scrollView.accessibilityIdentifier == "OuterScrollView" {
            // ParentScrollViewが移動中であれば移動量に合わせてTabViewのバー位置を更新する
            barViewLeftAnchor.constant = (scrollView.contentOffset.x / 4)
        }
    }
    
    // ページネーション開始時に呼ばれる
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("---scrollViewWillBeginDragging---: \(scrollView.accessibilityIdentifier ?? "")-\(scrollView.currentPage)")
        
        // 前後両ページに対して位置調整を行う
        // 横スクロール開始時に表示中のchildScrollViewのスクロール位置がリセットされてしまうのをフィルタリングで防ぐ
        scrollView.subviews.filter { $0.isKind(of: UIScrollView.self) }
            .filter { $0.accessibilityIdentifier != "OuterScrollView" && $0.accessibilityIdentifier != String(scrollView.currentPage - 1) }
            .forEach {
                if let childScrollView = $0 as? UIScrollView {
                    childScrollView.setContentOffset(CGPoint(x: 0, y: -headerViewTopAnchor.constant), animated: false)
                }
            }
    }
    
    // ページネーション中に指を離したら呼ばれる
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {}
    
    // ページネーション完了時に呼ばれる
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("---scrollViewDidEndDecelerating---: \(scrollView.accessibilityIdentifier ?? "")-\(scrollView.currentPage)")
        
        // ページが切り替わったらTabViewのUIを更新する
        if scrollView.accessibilityIdentifier == "OuterScrollView" {
            tabView.subviews.filter { $0.isKind(of: TabButtonView.self) }
                .forEach { view in
                    if let button = view as? TabButtonView {
                        let currentPageIndex = scrollView.currentPage - 1
                        button.updateState(selectedIndex: currentPageIndex)
                    }
                }
        }
    }
}

// MARK: CollapsingHeaderScrollViewControllerDatasource
extension CollapsibleHeaderPagerViewController: CollapsibleHeaderPagerViewControllerDatasource {
    
    public func collapsingHeaderScrollViewController(_ viewController: CollapsibleHeaderPagerViewController) -> Int {
        return pages.count
    }
    
    public func collapsibleHeaderScrollViewController(_ viewController: CollapsibleHeaderPagerViewController, index: Int) -> CollapsibleHeaderPagerViewPage {
        return pages[index]
    }
}

public protocol CollapsibleHeaderPagerViewControllerDatasource {
    
    /// Asks for the number of pages to display.
    ///
    /// - Parameter viewController: the CollapsibleHeaderScrollViewController requesting the information.
    ///
    /// - Returns: the number of pages to display.
    func collapsingHeaderScrollViewController(_ viewController: CollapsibleHeaderPagerViewController) -> Int
    
    /// Asks for the metadata of the CollapsibleHeaderPagerViewPage that will be displayed in the given N th place.
    ///
    /// - Parameter viewController: the CollapsibleHeaderScrollViewController requesting the information.
    /// - Parameter index: the index referring to the N th place. (ex: index "0" corresponds to "page 1")
    ///
    /// - Returns: the CollapsibleHeaderPagerViewPage metadata.
    func collapsibleHeaderScrollViewController(_ viewController: CollapsibleHeaderPagerViewController, index: Int) -> CollapsibleHeaderPagerViewPage
}

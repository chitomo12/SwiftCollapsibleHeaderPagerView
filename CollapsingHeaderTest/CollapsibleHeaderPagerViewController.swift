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
    
    var statusBarHeight: CGFloat {
        get { return view.window!.safeAreaInsets.top }
    }
    
    let parentScrollView = UIScrollView()
        
    var headerViewTopAnchor = NSLayoutConstraint()
    
    var headerViewHeight: CGFloat {
        get { return dataSource?.collapsingHeaderScrollViewControllerHeaderHeight() ?? 0 }
    }
    
    let tabView = UIStackView()
    var barViewLeftAnchor = NSLayoutConstraint()
    
    var dataSource: CollapsibleHeaderPagerViewControllerDatasource?
    var pages: [CollapsibleHeaderPagerViewPage] = []
    
    struct State {
        var currentPage: Int = 1 // 1ページ目は1とする（配列のindexとは異なるため注意）
    }
    
    var state = State()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let headerView = dataSource?.collapsingHeaderScrollViewControllerHeaderView(),
              let pages = dataSource?.collapsingHeaderScrollViewControllerPages()
        else { return }
        
        setup(header: headerView, headerHeight: headerView.frame.height, pages: pages)
    }
    
    /// Set up CollapsibleHeaderPagerView
    /// - Parameters:
    ///     - headerView: A UIView to be set on the upside (required)
    ///     - headerHeight: HeaderView's height (required)
    private func setup(header: UIView, headerHeight: CGFloat, pages: [CollapsibleHeaderPagerViewPage]) {
        
        self.pages = pages
        
        setupScrollView()
        setupHeaderView(header, height: headerHeight)
        setupTabView(headerView: header)
    }
    
    private func setupTabView(headerView: UIView) {
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
        tabView.heightAnchor.constraint(equalToConstant: dataSource?.collapsingHeaderScrollViewControllerTabBarHeight() ?? 0).isActive = true
        
        // MARK: setup tabView's buttons
        for (index, _) in pages.enumerated() {
            let button = TabButtonView(frame: UIView().frame)
            button.setup(title: "\(pages[index].title)",
                         tag: index + 1,
                         selectedColor: dataSource?.collapsingHeaderScrollViewControllerPagesTabBarColor() ?? .black,
                         handler: { self.makePageMoveByTab(toIndex: index) })
            tabView.addArrangedSubview(button)
            if index == 0 { button.updateState(selectedIndex: 0) }
        }
        
        // tabView's bottom border
        let tabViewBottomBorder = CALayer()
        tabViewBottomBorder.frame = CGRect(x: 0, y: dataSource?.collapsingHeaderScrollViewControllerTabBarHeight() ?? 0, width: view.frame.width, height: 1.0)
        tabViewBottomBorder.backgroundColor = UIColor.lightGray.cgColor.copy(alpha: 0.5)
        tabView.layer.addSublayer(tabViewBottomBorder)
        
        setupTabBarView(tabView: tabView)
    }
    
    private func setupTabBarView(tabView: UIStackView) {
        let barView = UIView()
        barView.backgroundColor = dataSource?.collapsingHeaderScrollViewControllerPagesTabBarColor()
        barView.layer.cornerRadius = 2
        
        barView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(barView)
        barViewLeftAnchor = barView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        barViewLeftAnchor.isActive = true
        barView.bottomAnchor.constraint(equalTo: tabView.bottomAnchor, constant: 0).isActive = true
        barView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        barView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1 / pages.count.cgFloat).isActive = true
    }
    
    // TODO: create set up tabView method

    /// Set up ParentScrollView and ChildScrollViews
    private func setupScrollView() {
        // Use accessibilityIdentifer to distinct vertical scroll and horizontal scroll.
        parentScrollView.accessibilityIdentifier = "OuterScrollView"
        parentScrollView.contentSize = CGSize(width: view.frame.width * pages.count.cgFloat, height: view.frame.height)
        parentScrollView.isPagingEnabled = true
        parentScrollView.delegate = self
        
        let tabViewHeight: CGFloat = dataSource?.collapsingHeaderScrollViewControllerTabBarHeight() ?? 0
        let headerAreaHeight = headerViewHeight + tabViewHeight
            
        for index in 0 ..< pages.count {
            
//            let contentView = self.dataSource?.collapsibleHeaderScrollViewController(self, index: index).view ?? UIView()
            let contentView = self.dataSource?.collapsingHeaderScrollViewControllerPages()[index].view ?? UIView()
            
            let childScrollView = UIScrollView()
            // IDはindex基準に（ex: 1ページ目はID:0）
            childScrollView.accessibilityIdentifier = "\(index)"
            childScrollView.isPagingEnabled = false
            childScrollView.alwaysBounceVertical = true
//            childScrollView.frame = CGRect(x: view.frame.width * CGFloat(index), y: 0, width: view.frame.width, height: view.frame.height)
//            childScrollView.contentSize.width = view.frame.width
//            childScrollView.contentSize.height = headerAreaHeight + contentView.frame.height
            childScrollView.delegate = self
            childScrollView.backgroundColor = .white
            
            contentView.translatesAutoresizingMaskIntoConstraints = false
            childScrollView.addSubview(contentView)
            contentView.topAnchor.constraint(equalTo: childScrollView.topAnchor, constant: headerAreaHeight).isActive = true
            contentView.leftAnchor.constraint(equalTo: childScrollView.leftAnchor, constant: 0).isActive = true
            contentView.widthAnchor.constraint(equalTo: childScrollView.widthAnchor, constant: 0).isActive = true
            contentView.heightAnchor.constraint(equalToConstant: contentView.frame.height).isActive = true
            
            childScrollView.translatesAutoresizingMaskIntoConstraints = false
            parentScrollView.addSubview(childScrollView)
            childScrollView.topAnchor.constraint(equalTo: parentScrollView.topAnchor, constant: 0).isActive = true
            // 左にchildScrollViewがあればそのrightAnchorを参照する
            if let previousChildScrollView = parentScrollView.subviews.filter({ $0.accessibilityIdentifier == "\(index - 1)" }).first {
                childScrollView.leftAnchor.constraint(equalTo: previousChildScrollView.rightAnchor, constant: 0).isActive = true
            } else {
                childScrollView.leftAnchor.constraint(equalTo: parentScrollView.leftAnchor, constant: 0).isActive = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.parentScrollView.contentOffset.x = 0 // Adjust for misalignment on first loading
                }
            }
            childScrollView.widthAnchor.constraint(equalTo: parentScrollView.widthAnchor, constant: 0).isActive = true
            childScrollView.heightAnchor.constraint(equalTo: parentScrollView.heightAnchor, constant: 0).isActive = true
            
            childScrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: 0).isActive = true
            childScrollView.contentLayoutGuide.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: headerAreaHeight).isActive = true
        }
        
        parentScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(parentScrollView)
        parentScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        parentScrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        parentScrollView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        parentScrollView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 0).isActive = true
        
        parentScrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: pages.count.cgFloat).isActive = true
        parentScrollView.contentLayoutGuide.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 0).isActive = true
    }
    
    /// Set up headerView method
    private func setupHeaderView(_ headerView: UIView, height: CGFloat) {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        headerViewTopAnchor = headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        headerViewTopAnchor.isActive = true
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    /// タブ選択でページ遷移するためのfunction
    private func makePageMoveByTab(toIndex: Int) -> Void {
        parentScrollView.setContentOffset(CGPoint(x: CGFloat(toIndex) * view.frame.width, y: 0), animated: true)
        // Set Y offset on other pages
        parentScrollView.subviews
            .filter { $0.accessibilityIdentifier != "OuterScrollView" }
            .compactMap { return $0 as? UIScrollView }
            .forEach { childScrollView in
                childScrollView.setContentOffset(CGPoint(x: 0, y: -headerViewTopAnchor.constant), animated: false)
            }
        tabView.subviews.compactMap { return $0 as? TabButtonView }
            .forEach { button in
                button.updateState(selectedIndex: toIndex)
            }
        state.currentPage = toIndex + 1
    }
    
    // MARK: Rotation
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("viewWillTransition to size: \(size)")
        // 現在のページ番号に合わせてparentScrollViewにsetOffsetXする
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            self.parentScrollView.setContentOffset(CGPoint(x: (self.state.currentPage.cgFloat - 1) * size.width, y: 0), animated: true)
        })
        
        // childScrollViewのスクロール量（contentOffsetY）に合わせてheaderViewの位置を調整する
        var currentPageContentOffsetY: CGFloat = 0
        parentScrollView.subviews
            .filter { $0.accessibilityIdentifier == String(self.state.currentPage - 1) }
            .compactMap { $0 as? UIScrollView }.first
            .map { currentChildScrollView in
                currentPageContentOffsetY = currentChildScrollView.contentOffset.y
            }
        headerViewTopAnchor.constant = max(-currentPageContentOffsetY, -headerViewHeight + statusBarHeight)
    }
}

// MARK: UIScrollViewDelegate
extension CollapsibleHeaderPagerViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // parentScrollViewか、各ページ内のchildScrollViewかをIdで判定する
        if scrollView.accessibilityIdentifier == "\(state.currentPage - 1)" {
            // To make TabView sticky, set limit to the headerViewTopAnchor max value.
            headerViewTopAnchor.constant = max(-scrollView.contentOffset.y, -headerViewHeight + statusBarHeight)
        } else if scrollView.accessibilityIdentifier == "OuterScrollView" {
            // ParentScrollViewが移動中であれば移動量に合わせてTabViewのバー位置を更新する
            barViewLeftAnchor.constant = (scrollView.contentOffset.x / pages.count.cgFloat)
        }
    }
    
    // ページネーション開始時に呼ばれる
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        print("---scrollViewWillBeginDragging---: \(scrollView.accessibilityIdentifier ?? "")-\(scrollView.currentPage)")
        
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
//        print("---scrollViewDidEndDecelerating---: \(scrollView.accessibilityIdentifier ?? "")-\(scrollView.currentPage)")
        // ページが切り替わったらTabViewのUIを更新する
        if scrollView.accessibilityIdentifier == "OuterScrollView" {
            tabView.subviews.compactMap { return $0 as? TabButtonView }
                .forEach { buttonView in
                    let currentPageIndex = scrollView.currentPage - 1
                    buttonView.updateState(selectedIndex: currentPageIndex)
                    self.state.currentPage = scrollView.currentPage
                }
        }
    }
}

public protocol CollapsibleHeaderPagerViewControllerDatasource {
    
    /// Asks header's UIView
    func collapsingHeaderScrollViewControllerHeaderView() -> UIView
    
    /// Asks header's height
    func collapsingHeaderScrollViewControllerHeaderHeight() -> CGFloat
    
    /// Asks header's height
    func collapsingHeaderScrollViewControllerTabBarHeight() -> CGFloat
    
    /// Asks TabBar's color
    func collapsingHeaderScrollViewControllerPagesTabBarColor() -> UIColor
    
    /// Asks for the pages to display.
    ///
    /// - Parameter viewController: the CollapsibleHeaderScrollViewController requesting the information.
    ///
    /// - Returns: the pages array to display.
    func collapsingHeaderScrollViewControllerPages() -> [CollapsibleHeaderPagerViewPage]
}

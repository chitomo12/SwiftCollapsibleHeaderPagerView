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
    let colors: Array<UIColor> = [
        UIColor(hex: "F5D4E9"),
        UIColor(hex: "D6D0F5"),
        UIColor(hex: "F9F4CF"),
        UIColor(hex: "B3DFB5")
    ]
    
    var pageControl = UIPageControl()
    
    let headerViewHeight: CGFloat = 160
    var headerViewTopAnchor = NSLayoutConstraint()
    
    let tabView = UIStackView()
    let tabViewHeight: CGFloat = 50
    var barViewLeftAnchor = NSLayoutConstraint()
    
    var isHeaderEnableToMoveWithScroll = true
    
    let page = CollapsibleHeaderPagerViewPage(title: "page1", view: pageOneView)
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let headerView = createHeaderView()
        let headerView = CustomHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: headerViewHeight))
        setup(header: headerView, headerHeight: headerView.frame.height)
//        setup(header: headerView, headerHeight: headerView.frame.height, tabButtons: [])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        statusBarHeight = view.window!.safeAreaInsets.top
    }
    
    private func createHeaderView() -> UIView {
        let headerView = UIView()
        // MARK: headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: headerViewHeight)
        headerView.backgroundColor = UIColor(cgColor: CGColor(red: 0.8, green: 0.8, blue: 0.3, alpha: 1))
        return headerView
    }
    
    /// Create CollapsibleHeaderPageView
    /// - Parameters:
    ///     - headerView: A UIView to be set on the upside (required)
    ///     - headerHeight: HeaderView's height (required)
    private func setup(header: UIView, headerHeight: CGFloat) {
        // headerView、button、[view]を渡せばセットアップしてくれるような関数にする。buttonは何も渡されなければ[view]に基づいて適当に番号を振ったボタンを渡す。
        
        // UIScrollViewを一番上に持ってくるパターン
        setupScrollView()
        
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
            childScrollView.alwaysBounceVertical = true
            childScrollView.frame = CGRect(x: view.frame.width * CGFloat(index), y: 0, width: view.frame.width, height: view.frame.height)
            let headerAreaHeight = headerViewHeight + tabViewHeight
            childScrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height - 60 + 200 * CGFloat(index))
            childScrollView.delegate = self
            childScrollView.backgroundColor = .white
            
            let boxView = UIView(frame: CGRect(x: 40, y: 10 + headerAreaHeight, width: 300, height: view.frame.height - headerAreaHeight - 60 + 200 * CGFloat(index)))
            boxView.backgroundColor = colors[index]
//            boxView.translatesAutoresizingMaskIntoConstraints = false
            childScrollView.addSubview(boxView)

            let label = UILabel(frame: CGRect(x: 0, y: 10, width: 300, height: 50))
            label.text = "Page:" + index.description
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 20)
            label.textAlignment = .center
            
            // label.translatesAutoresizingMaskIntoConstraints = falseするとUIScrollViewが真っ白になるので一旦そのままaddSubviewする
//            label.translatesAutoresizingMaskIntoConstraints = false
            boxView.addSubview(label)
            
//            childScrollView.translatesAutoresizingMaskIntoConstraints = false
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
        if scrollView.accessibilityIdentifier != "OuterScrollView" {
            // UIPageViewControllerを横移動中はこの中の処理を呼ばないようにする
            print("Inner scrollView.contentOffset: \(scrollView.contentOffset)")
            if isHeaderEnableToMoveWithScroll {
                headerViewTopAnchor.constant = max(-scrollView.contentOffset.y, -headerViewHeight + statusBarHeight)
            }
        } else if scrollView.accessibilityIdentifier == "OuterScrollView" {
            // ParentScrollViewが移動中であれば移動量に合わせてTabViewのバー位置を更新する
            barViewLeftAnchor.constant = (scrollView.contentOffset.x / 4) + CGFloat(pageViewObserver.isMovingFrom) * (view.frame.width / 4)
        }
    }
    
    // ページネーション開始時に呼ばれる
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("---scrollViewWillBeginDragging---: \(scrollView.accessibilityIdentifier ?? "")-\(scrollView.currentPage)")
        
        // 前後両ページに対して位置調整を行う
        // 横スクロール時に元のchildScrollViewもoffsetまでスクロール位置リセットされてしまうのをフィルタリングで防ぐ
        scrollView.subviews.filter { $0.isKind(of: UIScrollView.self) }
            .filter { $0.accessibilityIdentifier != "OuterScrollView" && $0.accessibilityIdentifier != String(scrollView.currentPage - 1) }
            .forEach {
                if let childScrollView = $0 as? UIScrollView {
                    childScrollView.setContentOffset(CGPoint(x: 0, y: -headerViewTopAnchor.constant), animated: false)
                }
            }
    }
    
    // ページネーション中に指を離したら呼ばれる
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {}
    
    // ページネーション完了時に呼ばれる。
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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

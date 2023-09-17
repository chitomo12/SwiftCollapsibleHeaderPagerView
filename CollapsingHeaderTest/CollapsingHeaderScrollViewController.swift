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
    var viewControllersArray: Array<UIViewController> = []
    let colors: Array<UIColor> = [UIColor.red, UIColor.gray, UIColor.blue, UIColor.systemCyan]
    
    var pageControl = UIPageControl()
    
    let headerView = UIView()
    let headerViewHeight: CGFloat = 200
    var headerViewTopAnchor = NSLayoutConstraint()
    
    let tabView = UIStackView()
    let tabViewHeight: CGFloat = 50
    var barViewLeftAnchor = NSLayoutConstraint()
    
    var isHeaderEnableToMoveWithScroll = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        
        // UIPageViewControllerを使ったパターン
        setupPageViewController()
        
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
        tabView.backgroundColor = UIColor(cgColor: CGColor(red: 0.7, green: 0.3, blue: 0.6, alpha: 1))
        view.addSubview(tabView)
        tabView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tabView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tabView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        tabView.heightAnchor.constraint(equalToConstant: tabViewHeight).isActive = true
        
        let button1 = TabButtonView(frame: UIView().frame)
        button1.setup(title: "button1", tag: 1, handler: { self.makePageMoveByTab(toIndex: 1) })
        let button2 = TabButtonView(frame: UIView().frame)
        button2.setup(title: "button2", tag: 2, handler: { self.makePageMoveByTab(toIndex: 2) })
        let button3 = TabButtonView(frame: UIView().frame)
        button3.setup(title: "button3", tag: 3, handler: { self.makePageMoveByTab(toIndex: 3) })
        let button4 = TabButtonView(frame: UIView().frame)
        button4.setup(title: "button3", tag: 4, handler: { self.makePageMoveByTab(toIndex: 4) })
        tabView.addArrangedSubview(button1)
        tabView.addArrangedSubview(button2)
        tabView.addArrangedSubview(button3)
        tabView.addArrangedSubview(button4)
        
        // tabView Bar
        let barView = UIView()
        barView.backgroundColor = .systemMint
        
        barView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(barView)
        barViewLeftAnchor = barView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        barViewLeftAnchor.isActive = true
        barView.bottomAnchor.constraint(equalTo: tabView.bottomAnchor, constant: 0).isActive = true
        barView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        barView.widthAnchor.constraint(equalToConstant: view.frame.width / 4).isActive = true
        
//        // pageViewController内のviewの高さ調整
//        changePosition((pageViewController.viewControllers?.first!)!)
    }
    
//    /// headerViewとtabViewの高さだけコンテンツを下に下げておく
//    private func changeScrollViewContentOffset(_ viewController: UIViewController) {
//        guard let scrollView = viewController.view.subviews.first as? UIScrollView else { return }
//        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
//        let offsetSize: CGFloat = self.headerViewHeight + self.tabViewHeight + statusBarHeight
//        scrollView.contentInset = UIEdgeInsets(top: offsetSize, left: 0, bottom: 0, right: 0)
//        scrollView.setContentOffset(CGPoint(x: 0, y: -offsetSize), animated: false)
//    }
    
    /// UICollectionViewを試すパターン
    /// - Parameters:
    ///   - tabView: 上を合わせるtabView
    private func setupCollectionView(tabView: UIStackView) {
        // UICollectionViewを試すパターン
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRect(),
                                              collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .systemCyan
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: tabView.bottomAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    /// UIPageViewControllerで試すパターン
    /// - Parameters:
    ///   - tabView: 上を合わせるtabView
    private func setupPageViewController() {
        
        for index in 0 ..< colors.count {
            let viewController = UIViewController()
            viewController.view.backgroundColor = colors[index]
            viewController.view.tag = index
            viewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            
            let scrollView = UIScrollView()
            scrollView.accessibilityIdentifier = String(index)
            scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
//            scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 500)
            scrollView.delegate = self
            
            // scrollViewのコンテンツを格納するUIView。これを元にScrollView.contentSizeを決定する
            let parentView = UIView()
            
            // ヘッダーで隠される領域のView
            let emptyView = UIView()
            emptyView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: headerViewHeight + tabViewHeight)
            emptyView.backgroundColor = .white
            
            emptyView.translatesAutoresizingMaskIntoConstraints = false
            parentView.addSubview(emptyView)
            emptyView.leftAnchor.constraint(equalTo: parentView.leftAnchor, constant: 0).isActive = true
            emptyView.rightAnchor.constraint(equalTo: parentView.rightAnchor, constant: 0).isActive = true
            emptyView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 0).isActive = true
            emptyView.heightAnchor.constraint(equalToConstant: headerViewHeight + tabViewHeight).isActive = true
            
            // labelの代わりに入れたいUIViewを入れてもらうようにする
            let label = UILabel()
            label.text = "page:" + index.description
            label.textColor = .white
            label.font = UIFont.boldSystemFont(ofSize: 40)
            label.textAlignment = .center
            
            label.translatesAutoresizingMaskIntoConstraints = false
            parentView.addSubview(label)
            label.leftAnchor.constraint(equalTo: parentView.leftAnchor, constant: 0).isActive = true
            label.rightAnchor.constraint(equalTo: parentView.rightAnchor, constant: 0).isActive = true
            label.topAnchor.constraint(equalTo: emptyView.bottomAnchor, constant: 0).isActive = true
            label.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true

            parentView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(parentView)
            parentView.heightAnchor.constraint(equalToConstant: emptyView.frame.height + view.frame.height).isActive = true
            parentView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
            
            scrollView.contentSize = CGSize(width: view.frame.width, height: emptyView.frame.height + view.frame.height)
            viewController.view.addSubview(scrollView)
            viewControllersArray.append(viewController)
        }
        
        pageViewController.setViewControllers([viewControllersArray.first!], direction: .forward, animated: true)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.isUserInteractionEnabled = true
        self.addChild(pageViewController)
        view.addSubview(pageViewController.view!)
        
        // pageViewController自体のScrollViewにdelegateをセットする
        pageViewController.view.subviews.filter{ $0.isKind(of: UIScrollView.self) }
            .forEach{
                if let scrollView = $0 as? UIScrollView {
                    scrollView.accessibilityIdentifier = "scrollView"
                    scrollView.delegate = self
                }
            }
        
        /// UIPageControleを表示する場合は下のコメントアウトを解除
        // setupPageControl()
    }
    
    /// PageControlを生成
    private func setupPageControl() {
        pageControl = UIPageControl(frame: CGRect(x:0, y:self.view.frame.height - 100, width:self.view.frame.width, height:50))
        pageControl.backgroundColor = .orange
        
        // PageControlするページ数を設定する.
        pageControl.numberOfPages = colors.count
        
        // 現在ページを設定する.
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = true
        pageControl.addAction(makePageMoveUIAction(), for: .valueChanged)
        view.addSubview(pageControl)
    }
    
    /// PageControlを操作した時に呼ぶUIActionを設定
    private func makePageMoveUIAction() -> UIAction {
        let action = UIAction { action in
            let sender = action.sender as? UIPageControl
            if let sender,
               let currentViewController = self.pageViewController.viewControllers?.first {
                // currentViewController.view.tag: 変化前のUIPageViewControllerのpageのindexが入る（tagにindexを与えていることが前提）
                print("currentViewController.view.tag: \(currentViewController.view.tag)")
                // sender.currentPage: 変化後のUIPageControlのindexが入る
                print("sender.currentPage: \(sender.currentPage)")
                let previousIndex = currentViewController.view.tag
                let direction: UIPageViewController.NavigationDirection = previousIndex < sender.currentPage ? .forward : .reverse
                let nextViewController = [self.viewControllersArray[sender.currentPage]]
                self.pageViewController.setViewControllers(nextViewController, direction: direction, animated: true)
            }
        }
        return action
    }
    
    /// PageControlを操作した時に呼ぶUIActionを設定
    private func makePageMoveByTab(toIndex: Int) -> Void {
        if let currentViewController = self.pageViewController.viewControllers?.first {
            // currentViewController.view.tag: 変化前のUIPageViewControllerのpageのindexが入る（tagにindexを与えていることが前提）
            print("currentViewController.view.tag: \(currentViewController.view.tag)")
            let previousIndex = currentViewController.view.tag
            let direction: UIPageViewController.NavigationDirection = previousIndex < toIndex ? .forward : .reverse
            let nextViewController = [self.viewControllersArray[toIndex - 1]]
            self.pageViewController.setViewControllers(nextViewController, direction: direction, animated: true)
        }
    }
}

// MARK: UIScrollView
extension CollapsingHeaderScrollViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // UIPageViewControllerのscrollViewか、各ページ内のscrollViewかをIdで判定する
        debugPrint("scrollView accessibilityIdentifier: \(String(describing: scrollView.accessibilityIdentifier))")
        if scrollView.accessibilityIdentifier != "scrollView" {
            // UIPageViewControllerを横移動中はこの中の処理を呼ばないようにする
            print("Inner scrollView.contentOffset: \(scrollView.contentOffset)")
            if isHeaderEnableToMoveWithScroll {
                headerViewTopAnchor.constant = -scrollView.contentOffset.y
            }
        } else {
            // PageViewController自体のUIQueuingScrollViewが呼ばれた時
            print("PageViewController's scrollView.contentOffset: \(scrollView.contentOffset)")
            print("pageViewController.currentPage: \(pageViewController.currentPage)")
            barViewLeftAnchor.constant = (scrollView.contentOffset.x / 4) + CGFloat(pageViewObserver.isMovingFrom - 1) * (view.frame.width / 4)
        }
    }
}

// MARK: UIPageViewController
extension CollapsingHeaderScrollViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // 最後に選択・表示されたViewControllerの後のViewControllerを返す
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag
        
        pageControl.currentPage = index
        if index == colors.count - 1{
            return nil
        }
        index = index + 1
        return viewControllersArray[index]
    }

    // 最後に選択・表示されたViewControllerの前のViewControllerを返す
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag
        pageControl.currentPage = index
        index = index - 1
        if index < 0{
            return nil
        }
        return viewControllersArray[index]
    }
    
    // Viewが変更されると呼ばれる（scrollViewDidScrollが呼ばれるのはこれよりも後）
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted: Bool) {
        let previousPageIndex = previousViewControllers.first!.view.tag
        print("---moved from Page.\(previousPageIndex)")
        pageViewObserver.isMoving = false
        if let nextPageIndex = pageViewController.viewControllers?.first!.view.tag {
            pageViewObserver.isMovingFrom = nextPageIndex
            pageControl.currentPage = nextPageIndex
        }
        Task {
            try await Task.sleep(nanoseconds: 100 * 1000 * 1000)
            print("--- 0.1 sec after move completed")
            isHeaderEnableToMoveWithScroll = true
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        print("Previous page: \(pageViewController.viewControllers?.first!.view.tag ?? 0)")
        print("Next Page (pendingViewControllers.first!.view.tag): \(pendingViewControllers.first!.view.tag)")
        isHeaderEnableToMoveWithScroll = false
        pageViewObserver.isMoving = true
        pageViewObserver.isMovingFrom = pageViewController.viewControllers?.first!.view.tag ?? 0
        // ここで現在のスクロール量を遷移予定のViewControllerに渡してあげる
        let nextVc = pendingViewControllers.first!.view
        guard let nextScrollView = nextVc?.subviews.first as? UIScrollView else { return }
        nextScrollView.setContentOffset(CGPoint(x: 0, y: -headerViewTopAnchor.constant), animated: false)
        // 初回表示の時にステータスバーの高さ分だけ強制的に補正されるため、0.01秒の非同期で再補正かけるようにする（根本的な解決は難しそう）
        Task {
            try await Task.sleep(nanoseconds: 10 * 1000 * 1000)
            nextScrollView.setContentOffset(CGPoint(x: 0, y: -headerViewTopAnchor.constant), animated: false)
        }
    }
}

// MARK: UICollection
extension CollapsingHeaderScrollViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
        
        return cell
    }
}

extension CollapsingHeaderScrollViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 50
    }
    
}

//
//  ViewController.swift
//  CollapsingHeaderTest
//
//  Created by 福田正知 on 2023/09/16.
//

import UIKit

class ViewController: UIViewController {
    
    let collapsingHeaderViewController = CollapsingHeaderViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(cgColor: CGColor(red: 0.1, green: 0.5, blue: 0.5, alpha: 1))
        // Do any additional setup after loading the view.
        Task {
            try await Task.sleep(nanoseconds: 300 * 1_000 * 1_000)
            collapsingHeaderViewController.modalPresentationStyle = .fullScreen
            self.present(collapsingHeaderViewController, animated: true)
        }
    }

}

// MARK: CollapsingHeaderViewController
class CollapsingHeaderViewController: UIViewController {
    
    var statusBarHeight: CGFloat = 0
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
    var viewControllersArray: Array<UIViewController> = []
    let colors: Array<UIColor> = [UIColor.red, UIColor.gray, UIColor.blue, UIColor.systemCyan]
    var pageControl = UIPageControl()
    let headerView = UIView()
    let headerViewHeight: CGFloat = 200
    var headerViewTopAnchor = NSLayoutConstraint()
    let tabView = UIStackView()
    let tabViewHeight: CGFloat = 60
    
    var isHeaderEnableToMoveWithScroll = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        
        // UICollectionViewを使ったパターン
//        setupCollectionView(tabView: tabView)
        
        // UIPageViewControllerを使ったパターン
        setupPageViewController()
        
        // MARK: headerView
//        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
        headerView.frame = CGRect()
        headerView.backgroundColor = UIColor(cgColor: CGColor(red: 0.8, green: 0.8, blue: 0.3, alpha: 1))
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        headerViewTopAnchor = headerView.topAnchor.constraint(equalTo: view.superview?.topAnchor ?? view.topAnchor, constant: 0)
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
        button1.setup(title: "button1", tag: 1)
        let button2 = TabButtonView(frame: UIView().frame)
        button2.setup(title: "button2", tag: 2)
        let button3 = TabButtonView(frame: UIView().frame)
        button3.setup(title: "button3", tag: 3)
        tabView.addArrangedSubview(button1)
        tabView.addArrangedSubview(button2)
        tabView.addArrangedSubview(button3)
        
//        // pageViewController内のviewの高さ調整
//        changePosition((pageViewController.viewControllers?.first!)!)
    }
    
    /// headerViewとtabViewの高さだけコンテンツを下に下げておく
    private func changeScrollViewContentOffset(_ viewController: UIViewController) {
        guard let scrollView = viewController.view.subviews.first as? UIScrollView else { return }
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let offsetSize: CGFloat = self.headerViewHeight + self.tabViewHeight + statusBarHeight
        scrollView.contentInset = UIEdgeInsets(top: offsetSize, left: 0, bottom: 0, right: 0)
        scrollView.setContentOffset(CGPoint(x: 0, y: -offsetSize), animated: false)
    }
    
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
            
            let scrollView = UIScrollView()
            
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
            self.view.layoutIfNeeded()
            viewController.view.addSubview(scrollView)
            viewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            viewControllersArray.append(viewController)
//            scrollView.setContentOffset(CGPoint(x: 0, y: statusBarHeight), animated: false)
        }
        
        pageViewController.setViewControllers([viewControllersArray.first!], direction: .forward, animated: true)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.isUserInteractionEnabled = true
        self.addChild(pageViewController)
        view.addSubview(pageViewController.view!)
        
        /// UIPageControleを表示する場合は下のコメントアウトを解除する
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
}

// MARK: UIScrollView
extension CollapsingHeaderViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // UIPageViewControllerを横移動中はこの中の処理を呼ばないようにする
        debugPrint("scrollView.contentOffset: \(scrollView.contentOffset)")
        if isHeaderEnableToMoveWithScroll {
            headerViewTopAnchor.constant = -scrollView.contentOffset.y
        }
    }
}

// MARK: UIPageViewController
extension CollapsingHeaderViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // 最後に選択・表示されたViewControllerの後のViewControllerを返す
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag
        
        pageControl.currentPage = index
        if index == colors.count - 1{
            return nil
        }
        index = index + 1
//        changeScrollViewContentOffset(viewControllersArray[index])
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
//        changeScrollViewContentOffset(viewControllersArray[index])
        return viewControllersArray[index]
    }
    
    // Viewが変更されると呼ばれる（scrollViewDidScrollが呼ばれるのはこれよりも後）
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted: Bool) {
        print("---moved")
        let previousPageIndex = previousViewControllers.first!.view.tag
        if let nextPageIndex = pageViewController.viewControllers?.first!.view.tag {
            pageControl.currentPage = nextPageIndex
        }
        Task {
            try await Task.sleep(nanoseconds: 100 * 1000 * 1000)
            print("--- 0.1 sec after move completed")
            isHeaderEnableToMoveWithScroll = true
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        print("pendingViewControllers.first!.view.tag: \(pendingViewControllers.first!.view.tag)")
        isHeaderEnableToMoveWithScroll = false
        
        // ここで現在のスクロール量を遷移予定のViewControllerに渡してあげる
        let nextVc = pendingViewControllers.first!.view
        guard let nextScrollView = nextVc?.subviews.first as? UIScrollView else { return }
        print("nextScrollView.contentOffset[Before]: \(nextScrollView.contentOffset)")
        nextScrollView.setContentOffset(CGPoint(x: 0, y: -headerViewTopAnchor.constant), animated: false)
        print("nextScrollView.contentOffset[After]: \(nextScrollView.contentOffset)")
        // 初回表示の時にステータスバーの高さ分だけ強制的に補正されるため、0.01秒の非同期で再補正かけるようにする（根本的な解決は難しそう）
        Task {
            try await Task.sleep(nanoseconds: 10 * 1000 * 1000)
            nextScrollView.setContentOffset(CGPoint(x: 0, y: -headerViewTopAnchor.constant), animated: false)
        }
    }
}

// MARK: UICollection
extension CollapsingHeaderViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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

extension CollapsingHeaderViewController: UICollectionViewDelegateFlowLayout {
    
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

@IBDesignable
class TabButtonView: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setup(title: String, tag: Int) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.setTitleColor(.white.withAlphaComponent(0.5), for: .highlighted)
        self.tag = tag
        self.addAction(UIAction(handler: { _ in
            print("Tap Button \(self.tag)")
        }), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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

extension UIPageViewController {
    
    func currentPage() {
        
    }
}

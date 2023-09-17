//
//  TabButtonView.swift
//  CollapsingHeaderTest
//
//  Created by 福田正知 on 2023/09/17.
//

import UIKit

@IBDesignable
class TabButtonView: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setup(title: String, tag: Int, handler: @escaping () -> Void) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.setTitleColor(.white.withAlphaComponent(0.5), for: .highlighted)
        self.tag = tag
        self.addAction(UIAction(handler: { _ in
            print("Tap Button \(self.tag)")
            handler()
        }), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
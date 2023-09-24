//
//  TabButtonView.swift
//  CollapsingHeaderTest
//
//  Created by 福田正知 on 2023/09/17.
//

import UIKit

@IBDesignable
class TabButtonView: UIButton {
    
    var handler: () -> Void = {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setup(title: String, tag: Int, selectedColor: UIColor, handler: @escaping () -> Void) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(.gray, for: .normal)
        self.setTitleColor(selectedColor, for: .selected)
        self.setTitleColor(.gray.withAlphaComponent(0.5), for: .highlighted)
        self.tag = tag
        if #available(iOS 14.0, *) {
            self.addAction(UIAction(handler: { _ in
                print("Tap Button \(self.tag)")
                handler()
            }), for: .touchUpInside)
        } else {
            self.handler = handler
            self.addTarget(self, action: #selector(executeHandler), for: .touchUpInside)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateState(selectedIndex: Int) {
        self.isSelected = ((selectedIndex + 1) == self.tag)
    }
    
    @objc
    func executeHandler() {
        self.handler()
    }
}

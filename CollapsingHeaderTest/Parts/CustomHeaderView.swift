//
//  CustomHeaderView.swift
//  CollapsingHeaderTest
//
//  Created by 福田正知 on 2023/09/18.
//

import UIKit

class CustomHeaderView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
        label.text = "CustomHeaderView \nHeight: \(self.frame.height)"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }

    func loadNib() {
        if let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }
}

//
//  TwitterLikeHeaderView.swift
//  CollapsingHeaderTest
//
//  Created by 福田正知 on 2023/09/24.
//

import UIKit

class TwitterLikeHeaderView: UIView {

    @IBOutlet weak var profileImageView: UIImageView! {
        willSet {
            newValue.layer.cornerRadius = 40
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
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

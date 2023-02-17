import UIKit

open class SelfSizingCollectionFlowLayout: UICollectionViewFlowLayout {
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

open class AutoSizeCollectionView: UICollectionView {
    fileprivate var heightConstraint: NSLayoutConstraint!
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.associateConstraints()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.associateConstraints()
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        if self.heightConstraint != nil {
            self.heightConstraint.constant = ceil(self.contentSize.height)
        }
        else {
            self.sizeToFit()
        }
    }
    public func associateConstraints() {
        // iterate through height constraints and identify
        for constraint: NSLayoutConstraint in constraints {
            if constraint.firstAttribute == .height {
                if constraint.relation == .equal {
                    heightConstraint = constraint
                }
            }
        }
    }
}


import UIKit

@objc public protocol AutoSlideViewDelegate {
    func didSelectItemAt(indexPath: IndexPath)
    @objc optional func didDisplayItemAtIndexpath(indexPath:IndexPath)
}

public protocol AutoSlideViewDataSource: AnyObject {
    func registerCollectionViewCells(for collectionView: AutoSlideCollectionView)
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellForRow(at indexPath: IndexPath, for collectionView: AutoSlideCollectionView) -> UICollectionViewCell
}

open class AutoSlideCollectionView: AutoSizeCollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public var autoSlideDelegate : AutoSlideViewDelegate?
    public var autoSlideDataSource : AutoSlideViewDataSource?
    
    public var cellSizeRatio:CGFloat = 1
    public var cellCornerRadius: CGFloat = 0
    public var adjustInsetsToCenterItems: Bool = false
    public var shouldTakeFullWidthIfSingleSlide: Bool = false
    public var shouldTakeFullWidth: Bool = false
    public var itemSpacing: CGFloat = 8
    public var timerInterval:TimeInterval = 3
    
    private var timer: Timer?
    private var inset: CGFloat {
        let itemWidth = frame.height / cellSizeRatio
        let maxWidth = frame.width
        return (maxWidth/2) - (itemWidth/2)
    }
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    private func commonInit() {
        delegate = self
        dataSource = self
        if adjustInsetsToCenterItems {
            let inset:CGFloat = self.inset
            contentInset = .init(top: 0, left: inset, bottom: 0, right: inset)
            setContentOffset(.init(x: -inset, y: 0), animated: false)
        }
        else {
            let inset:CGFloat = 14
            contentInset = .init(top: 0, left: inset, bottom: 0, right: inset)
        }
        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    deinit {
        timer?.invalidate()
    }
    private var sliders:Int = 0 {
        didSet {
            self.reloadData()
            if adjustInsetsToCenterItems {
                let inset:CGFloat = self.inset
                contentInset = .init(top: 0, left: inset, bottom: 0, right: inset)
                setContentOffset(.init(x: -inset, y: 0), animated: false)
            }
            if (sliders >= 1) {
                setTimer()
            }
            else {
                contentInset = .init(top: 0, left: itemSpacing, bottom: 0, right: itemSpacing)
            }
        }
    }
    
    private var isFirstLayoutSubviews: Bool = false
    open override func layoutSubviews() {
        super.layoutSubviews()
        if adjustInsetsToCenterItems {
            let inset = self.inset
            self.contentInset.left = inset
            self.contentInset.right = inset
        }
    }
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        reloadData()
        autoSlideDataSource?.registerCollectionViewCells(for: self)
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = autoSlideDataSource?.numberOfRowsInSection(section) {
            sliders = count
            return count
        } else {
            return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = autoSlideDataSource?.cellForRow(at: indexPath, for: self) {
            return cell
        }else {            
            return UICollectionViewCell()
        }
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (shouldTakeFullWidthIfSingleSlide && sliders == 1) || shouldTakeFullWidth {
            let width = collectionView.frame.width - (itemSpacing * 2)
            return .init(width: width, height: width * cellSizeRatio)
        }
        let itemWidth = collectionView.frame.height / cellSizeRatio
        return CGSize.init(width: itemWidth, height: collectionView.frame.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.autoSlideDelegate != nil{
        self.autoSlideDelegate?.didSelectItemAt(indexPath: indexPath)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        itemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        itemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        autoSlideDelegate?.didDisplayItemAtIndexpath?(indexPath: indexPath)
    }
}


extension AutoSlideCollectionView {
    private func setTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true, block: { [weak self] (timer) in
            self?.scrollToNextIndex()
        })
    }
    @objc
    private func scrollToNextIndex() {
        let point = CGPoint.init(x: contentOffset.x + frame.midX, y: ((self.contentInset.top) + (self.adjustedContentInset.top)))
        if let indexPath = self.indexPathForItem(at: point) {
            let nextItem = ((indexPath.item + 1) >= (self.sliders)) ? 0 : (indexPath.item + 1)
            let newIndexPath = IndexPath.init(item: nextItem, section: indexPath.section)
            if newIndexPath.item < (self.sliders) {
                self.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    func snapToCenter() {
        let centerPoint = CGPoint.init(x: contentOffset.x + frame.midX, y: ((self.contentInset.top) + (self.adjustedContentInset.top)))
        guard let centerIndexPath = indexPathForItem(at: centerPoint) else { return }
        scrollToItem(at: centerIndexPath, at: .centeredHorizontally, animated: true)
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToCenter()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapToCenter()
        }
    }

}

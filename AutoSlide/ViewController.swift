//
//  ViewController.swift
//  AutoSlide
//
//  Created by iOS on 17/02/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var viewHeader: UIView!
    private lazy var collectionView: AutoSlideCollectionView = {
        let layout = SelfSizingCollectionFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = AutoSlideCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var arrSlider: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        arrSlider = [
            "Slider 1",
            "Slider 2",
            "Slider 3",
            "Slider 4",
            "Slider 5",
        ]
        collectionView.frame = CGRect(x: 0, y: 0, width: viewHeader.frame.width, height: viewHeader.frame.height)
        viewHeader.addSubview(collectionView)
        
        collectionView.autoSlideDelegate = self
        collectionView.autoSlideDataSource = self

        collectionView.timerInterval = 3
        let ratio: CGFloat = viewHeader.frame.height/viewHeader.frame.width
        collectionView.cellSizeRatio = ratio
        collectionView.cellCornerRadius = 15
        collectionView.shouldTakeFullWidthIfSingleSlide = true
        collectionView.adjustInsetsToCenterItems = true
    }
}

extension ViewController: AutoSlideViewDelegate{
    func didSelectItemAt(indexPath: IndexPath) {
        debugPrint("indexPath:\(indexPath.row)")
    }
}

extension ViewController: AutoSlideViewDataSource{
    
    func registerCollectionViewCells(for customView: AutoSlideCollectionView) {
        customView.register(UINib.init(nibName: "CustomCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CustomCollectionCell")
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        arrSlider.count
    }
    func cellForRow(at indexPath: IndexPath, for collectionView: AutoSlideCollectionView) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionCell", for: indexPath) as! CustomCollectionCell
        cell.lblTitle.text = arrSlider[indexPath.row]
        return cell
    }
}

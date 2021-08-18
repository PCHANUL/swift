//
//  PreviewListCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/04.
//

import UIKit
import ImageIO
import Foundation
import MobileCoreServices

class PreviewAndLayerCollectionViewCell: UICollectionViewCell {
    var canvas: Canvas!
    var panelContainerVC: PanelContainerViewController!
    var panelCollectionView: UICollectionView!
    
    @IBOutlet weak var previewAndLayerCVC: UICollectionView!
    @IBOutlet weak var animatedPreviewUIView: UIView!
    @IBOutlet weak var animatedPreview: UIImageView!
    @IBOutlet weak var goDownView: UIView!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var changeStatusToggle: UISegmentedControl!
    
    // cells
    var previewListCell = PreviewListCollectionViewCell()
    var layerListCell = LayerListCollectionViewCell()
    
    // viewModels
    var animatedPreviewVM: AnimatedPreviewViewModel!
    var layerVM: LayerListViewModel!
    var coreData: CoreData!
    
    // constraints
    var downAnchor: NSLayoutConstraint!
    var upAnchor: NSLayoutConstraint!
    
    // values
    var isScroll: Bool!
    var selectedBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setViewShadow(target: animatedPreview, radius: 5, opacity: 0.7)
        coreData = CoreData()
    }
    
    override func layoutSubviews() {
        isScroll = false
        panelCollectionView = panelContainerVC.panelCollectionView
        if (layerVM.frames.count == 0) {
            canvas.initViewModelImage(data: coreData.items[coreData.selectedDataIndex].data!)
//            panelContainerVC.superViewController.timeMachineVM.addTime()
        }
        canvas.updateAnimatedPreview()
    }
    
    @IBAction func tappedAnimate(_ sender: Any) {
        // layers 탭에서 비활성화
        if (changeStatusToggle.selectedSegmentIndex == 1) { return }
        
        // category list popup
        let categoryPopupVC = UIStoryboard(name: "AnimatedPreviewPopupViewController", bundle: nil).instantiateViewController(identifier: "AnimatedPreviewPopupViewController") as! AnimatedPreviewPopupViewController
        categoryPopupVC.categorys = layerVM.getCategorys()
        categoryPopupVC.animatedPreviewVM = animatedPreviewVM
        categoryPopupVC.positionY = self.frame.maxY - animatedPreview.frame.maxY - 10 - panelCollectionView.contentOffset.y
        categoryPopupVC.modalPresentationStyle = .overFullScreen
        self.window?.rootViewController?.present(categoryPopupVC, animated: false, completion: nil)
    }
    
    @IBAction func changedToggleStatus(_ sender: Any) {
        let maxYoffset = previewAndLayerCVC.contentSize.height - previewAndLayerCVC.frame.size.height
        switch changeStatusToggle.selectedSegmentIndex {
        case 0:
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            setAnimatedPreviewLayerForFrameList()
        case 1:
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: maxYoffset), animated: true)
            setAnimatedPreviewLayerForLayerList()
        default:
            return
        }
    }
}


extension PreviewAndLayerCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewListCollectionViewCell", for: indexPath) as! PreviewListCollectionViewCell
            cell.canvas = canvas
            cell.layerVM = layerVM
            cell.animatedPreviewVM = animatedPreviewVM
            cell.panelCollectionView = panelCollectionView
            cell.animatedPreview = animatedPreview
            cell.previewAndLayerCVC = self
            previewListCell = cell
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LayerListCollectionViewCell", for: indexPath) as! LayerListCollectionViewCell
            cell.canvas = canvas
            cell.layerVM = layerVM
            cell.panelCV = panelContainerVC
            layerListCell = cell
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension PreviewAndLayerCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let panelCVWidth = panelContainerVC.superViewController.panelContainerView.frame.width
        let animatedImageWidth = animatedPreviewUIView.frame.width
        let width: CGFloat = panelCVWidth - animatedImageWidth - 17
        let height = previewAndLayerCVC.frame.height
        return CGSize(width: width, height: height)
    }
}

extension PreviewAndLayerCollectionViewCell: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let maxYoffset: CGFloat
        
        maxYoffset = previewAndLayerCVC.contentSize.height - previewAndLayerCVC.frame.size.height
        if previewAndLayerCVC.contentOffset.y < maxYoffset / 3 {
            changeStatusToggle.selectedSegmentIndex = 0
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else {
            changeStatusToggle.selectedSegmentIndex = 1
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: maxYoffset), animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let maxYoffset: CGFloat
        
        maxYoffset = previewAndLayerCVC.contentSize.height - previewAndLayerCVC.frame.size.height
        if (previewAndLayerCVC.contentOffset.y <= maxYoffset / 3) {
            setAnimatedPreviewLayerForFrameList()
            changeStatusToggle.selectedSegmentIndex = 0
        } else {
            setAnimatedPreviewLayerForLayerList()
            changeStatusToggle.selectedSegmentIndex = 1
        }
    }
    
    func setAnimatedPreviewLayerForFrameList() {
        let categoryName: String
        let color: CGColor
        
        categoryName = animatedPreviewVM.curCategory
        color = animatedPreviewVM.categoryListVM.getCategoryColor(category: categoryName).cgColor
        animatedPreview.layer.borderWidth = 0
        animatedPreview.layer.shadowColor = UIColor.black.cgColor
        animatedPreviewUIView.layer.backgroundColor = color
        animatedPreviewVM.changeAnimatedPreview()
    }
    
    func setAnimatedPreviewLayerForLayerList() {
        let categoryName: String
        let color: CGColor
        
        categoryName = (animatedPreviewVM.viewModel?.selectedFrame!.category) ?? "Default"
        color = animatedPreviewVM.categoryListVM.getCategoryColor(category: categoryName).cgColor
        animatedPreview.layer.borderWidth = 1
        animatedPreview.layer.borderColor = color
        animatedPreview.layer.shadowColor = color
        animatedPreviewVM.setSelectedFramePreview()
        animatedPreviewUIView.layer.backgroundColor = UIColor.clear.cgColor
    }
}

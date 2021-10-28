//
//  HomeViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/05.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var menubarStackView: UIStackView!
    @IBOutlet weak var selectedMenubar: UIView!
    @IBOutlet weak var menubarConstraint: NSLayoutConstraint!
    @IBOutlet weak var button: UIButton!
    
    weak var superViewController: ViewController!
    weak var homeMenuPanelViewController: HomeMenuPanelViewController!
    var selectedMenuIndex: Int!
    var isFirstLoad: Bool!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        homeMenuPanelViewController = segue.destination as? HomeMenuPanelViewController
        homeMenuPanelViewController?.superViewController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSideCorner(target: backgroundView, side: "all", radius: backgroundView.bounds.width / 20)
        setSideCorner(target: mainView, side: "all", radius: mainView.bounds.width / 20)
        setSideCorner(target: selectedMenubar, side: "all", radius: selectedMenubar.bounds.height / 2)
        setViewShadow(target: selectedMenubar, radius: 5, opacity: 0.7)
        setViewShadow(target: mainView, radius: 10, opacity: 0.3)
        selectedMenuIndex = 0
        isFirstLoad = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.superViewController.mainViewController.setLabelView(self.superViewController)
        self.superViewController.mainViewController.drawingCollectionViewCell.updateCanvasData()
        self.superViewController.mainViewController.testingCollectionViewCell.updateTestData()
        
        DispatchQueue.main.async {
            self.superViewController.mainViewController.drawingCollectionViewCell.previewImageToolBar.setOffsetForSelectedFrame()
            self.superViewController.mainViewController.drawingCollectionViewCell.previewImageToolBar.setOffsetForSelectedLayer()
        }
    }
    
    @IBAction func tappedCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchMenuButton(_ sender: UIButton) {
        let menuPanelWidth = self.homeMenuPanelViewController.homeMenuPanelCV.bounds.width
        self.selectedMenuIndex = self.menubarStackView.subviews.firstIndex(of: sender)
        self.homeMenuPanelViewController.homeMenuPanelCV.setContentOffset(
            CGPoint(x: menuPanelWidth * CGFloat(self.selectedMenuIndex), y: 0), animated: true
        )
        moveMenuToggle()
    }
    
    func moveMenuToggle() {
        self.menubarConstraint.constant = (self.button.bounds.width + 10) * CGFloat(self.selectedMenuIndex)
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}




//
//  RefreshView.swift
//  PullToRefresh
//
//  Created by Gerry on 8/16/16.
//  Copyright © 2016 gaoyve. All rights reserved.
//

import UIKit

protocol RefreshViewDelegate: class {
    func refreshViewDidRefresh(refreshView: RefreshView)
}

private let sceneHeight: CGFloat = 120

class RefreshView: UIView {
    
    private weak var scrollView: UIScrollView!
    var progressPercentage: CGFloat = 0.0
    weak var delegate: RefreshViewDelegate?
    
    var isRefreshing = false
    var refreshItems = [RefreshItem]()
    var signRefreshItem: RefreshItem!
    var isSignVisible = false
    var cloudViews: (UIView, UIView)!
    
    required init?(coder aDecoder: NSCoder) {
        scrollView = UIScrollView()
        assert(false, "use init (frame:scrollView:)")
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init(frame: frame)
        
        updateBackgroundColor()
        setupRefreshItems()
    }
    
    func setupRefreshItems() {
        let groundImageView = UIImageView(image: UIImage(named: "ground"))
        let buildingImageView = UIImageView(image: UIImage(named: "buildings"))
        let sunImageView = UIImageView(image: UIImage(named: "sun"))
        let catImageView = UIImageView(image: UIImage(named: "cat"))
        let capeBackImageView = UIImageView(image: UIImage(named: "cape_back"))
        let capeFrontImageView = UIImageView(image: UIImage(named: "cape_front"))
        
        refreshItems = [
            RefreshItem.init(view: buildingImageView, centerEnd: CGPoint(x: bounds.midX, y: bounds.height - groundImageView.bounds.height - buildingImageView.bounds.height/2), parallaxRatio: 1.5, sceneHeight: sceneHeight),
            RefreshItem.init(view: sunImageView, centerEnd: CGPoint(x: bounds.width * 0.1, y: bounds.height - groundImageView.bounds.height - sunImageView.bounds.height), parallaxRatio: 3.0, sceneHeight: sceneHeight),
            RefreshItem.init(view: groundImageView, centerEnd: CGPoint(x: bounds.midX, y: bounds.height - groundImageView.bounds.height/2), parallaxRatio: 0.5, sceneHeight: sceneHeight),
            RefreshItem.init(view: capeBackImageView, centerEnd: CGPoint(x: bounds.midX, y: bounds.height - groundImageView.bounds.height/2 - capeBackImageView.bounds.height/2), parallaxRatio: -1, sceneHeight: sceneHeight),
            RefreshItem.init(view: catImageView, centerEnd: CGPoint(x: bounds.midX, y: bounds.height - groundImageView.bounds.height/2 - catImageView.bounds.height/2), parallaxRatio: 1, sceneHeight: sceneHeight),
            RefreshItem.init(view: capeFrontImageView, centerEnd: CGPoint(x: bounds.midX, y: bounds.height - groundImageView.bounds.height/2 - capeFrontImageView.bounds.height/2), parallaxRatio: -1, sceneHeight: sceneHeight)
        ]
        
        for refreshItem in refreshItems {
            addSubview(refreshItem.view!)
        }
        
        let signImageView = UIImageView(image: UIImage(named: "sign"))
        signRefreshItem = RefreshItem(view: signImageView, centerEnd: CGPoint(x: bounds.midX, y: bounds.height - signImageView.bounds.height/2), parallaxRatio: 0.5, sceneHeight: sceneHeight)
        
        addSubview(signImageView)
        
        cloudViews = (createCloudView(), createCloudView())
        cloudViews.0.alpha = 0
        cloudViews.1.alpha = 0
        insertSubview(cloudViews.0, atIndex: 0)
        insertSubview(cloudViews.1, atIndex: 0)
        
    }
    
    func updateBackgroundColor() {
        let value = progressPercentage * 0.7 + 0.2
        backgroundColor = UIColor.init(red: value, green: value, blue: value, alpha: 1.0)
    }
    
    func updateRefreshItemsPositions() {
        for refreshItem in refreshItems {
            refreshItem.updateViewPositionForPercentage(progressPercentage)
        }
    }
    
    func beginRefreshing() {
        isRefreshing = true
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseInOut, animations: { 
            self.scrollView.contentInset.top += sceneHeight
            }) { (_) in
        }
        showSign(false)
        
        let cape = refreshItems[5].view!
        let cat = refreshItems[4].view!
        cape.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/32))
        cat.transform = CGAffineTransformMakeTranslation(1.0, 0)
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: [.Repeat, .Autoreverse], animations: {
            cape.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/32))
            cat.transform = CGAffineTransformMakeTranslation(-1.0, 0)
            }, completion: nil)
        
        let buildings = refreshItems[0].view!
        let ground = refreshItems[2].view!
        UIView.animateWithDuration(0.2, delay: 0.0, options: [.CurveEaseInOut], animations: { 
            ground.center.y += sceneHeight
            buildings.center.y += sceneHeight
            }, completion: nil)
        
        let bounds = self.bounds
        cloudViews.0.center = CGPoint(x: bounds.midX, y: -bounds.midY)
        cloudViews.0.alpha = 1
        cloudViews.1.center = CGPoint(x: bounds.midX, y: -bounds.midY)
        cloudViews.1.alpha = 1
        
        UIView.animateWithDuration(2.0, delay: 0.25, options: .Repeat, animations: {
            self.cloudViews.0.center.y = bounds.midY + bounds.height
            }, completion: { (_) in
                self.cloudViews.0.center.y = -bounds.midY
        })
        
        UIView.animateWithDuration(2.0, delay: 1.25, options: .Repeat, animations: {
            self.cloudViews.1.center.y = bounds.midY + bounds.height
            }, completion: { (_) in
                self.cloudViews.1.center.y = -bounds.midY
        })
        
    }
    
    func endRefreshing() {
        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.scrollView.contentInset.top -= sceneHeight
        }) { (_) in
            self.isRefreshing = false
        }
        
        let cape = refreshItems[5].view!
        let cat = refreshItems[4].view!
        cape.transform = CGAffineTransformIdentity
        cat.transform = CGAffineTransformIdentity
        cape.layer.removeAllAnimations()
        cat.layer.removeAllAnimations()
    }
    
    func showSign(show: Bool) {
        if isSignVisible == show {
            return
        }
        
        isSignVisible = show
        UIView.animateWithDuration(0.2, delay: 0.0, options: [.CurveEaseInOut, .BeginFromCurrentState], animations: { 
            self.signRefreshItem.updateViewPositionForPercentage(show ? 1 : 0)
            }, completion: nil)
    }
    
    func createCloudView() -> UIView {
        let cloudView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        
        let width = cloudView.bounds.width
        let height = cloudView.bounds.height
        let centerPoints = [
            CGPoint(x: width * 0.2, y: height * 0.2),
            CGPoint(x: width * 0.5, y: height * 0.5),
            CGPoint(x: width * 0.8, y: height * 0.8),
            CGPoint(x: width * 0.3, y: height * 0.4),
            CGPoint(x: width * 0.7, y: height * 0.3),
            CGPoint(x: width * 0.1, y: height * 0.8),
            ]
        
        for (index, centerPoint) in centerPoints.enumerate() {
            let imageIndex = (index % 3) + 1
            let cloud = UIImageView(image: UIImage(named: "cloud_\(imageIndex)"))
            cloud.center = centerPoint
            cloudView.addSubview(cloud)
        }
        
        return cloudView
    }
    
    
}

extension RefreshView: UIScrollViewDelegate {
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !isRefreshing && progressPercentage == 1.0 {
            beginRefreshing()
            
            targetContentOffset.memory.y = -scrollView.contentInset.top
            delegate?.refreshViewDidRefresh(self)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if isRefreshing {
            return
        }
        
        let refreshViewVisibleHeight = max(0, -(scrollView.contentOffset.y + scrollView.contentInset.top))
        progressPercentage = min(1.0, refreshViewVisibleHeight / sceneHeight)
        
        updateBackgroundColor()
        updateRefreshItemsPositions()
        showSign(progressPercentage == 1.0)
    }
}
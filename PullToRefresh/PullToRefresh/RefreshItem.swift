//
//  RefreshItem.swift
//  PullToRefresh
//
//  Created by Gerry on 8/16/16.
//  Copyright © 2016 gaoyve. All rights reserved.
//

import UIKit

class RefreshItem {
    private var centerStart: CGPoint
    private var centerEnd: CGPoint
    weak var view: UIView?
    
    init(view: UIView, centerEnd: CGPoint, parallaxRatio: CGFloat, sceneHeight: CGFloat) {
        self.view = view
        self.centerEnd = centerEnd
        centerStart = CGPoint(x: centerEnd.x, y: centerEnd.y + parallaxRatio * sceneHeight)
        self.view?.center =  self.centerStart
    }
    
    func updateViewPositionForPercentage(percentage: CGFloat) {
        self.view?.center = CGPoint(
            x: centerStart.x + (centerEnd.x - centerStart.x) * percentage,
            y: centerStart.y + (centerEnd.y - centerStart.y) * percentage
        )
    }
}

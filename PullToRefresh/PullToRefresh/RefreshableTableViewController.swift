//
//  RefreshableTableViewController.swift
//  PullToRefresh
//
//  Created by Gerry on 8/16/16.
//  Copyright © 2016 gaoyve. All rights reserved.
//

import UIKit

private let refreshViewHeight: CGFloat = 200.0

func delayBySeconds(seconds: Double, delayCode:()->()) {
    let tagertTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * seconds))
    
    dispatch_after(tagertTime, dispatch_get_main_queue()) { 
        delayCode()
    }
}

class RefreshableTableViewController: UITableViewController {

    var refreshView: RefreshView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Pull To Refresh"
        
        refreshView = RefreshView.init(frame: CGRect(x: 0, y: -refreshViewHeight, width: view.bounds.width, height: refreshViewHeight), scrollView: tableView)
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        refreshView.delegate = self
        view.insertSubview(refreshView, atIndex: 0)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        refreshView.scrollViewDidScroll(scrollView)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = "Cell \(indexPath.row)"
        
        return cell
    }
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        refreshView.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}

extension RefreshableTableViewController: RefreshViewDelegate {
    func refreshViewDidRefresh(refreshView: RefreshView) {
        delayBySeconds(3) { 
            self.refreshView.endRefreshing()
        }
    }
}
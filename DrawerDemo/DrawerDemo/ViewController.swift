//
//  ViewController.swift
//  DrawerDemo
//
//  Created by Ken Myers on 2017/07/13.
//  Copyright © 2017 Coiney. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CYDrawerViewDataSource, CYDrawerViewDelegate {

    @IBOutlet var drawerView: CYDrawerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.drawerView.dataSource = self
        self.drawerView.delegate = self
    }
    
    // MARK: Drawer view data source
    
    func numberOfRows(in aDrawerView: CYDrawerView) -> Int {
        return 5
    }
    
    func drawerView(_ aDrawerView: CYDrawerView, titleForItem aIndex: Int) -> String {
        return String(format: "Item %d", aIndex)
    }
    
    // MARK: Drawer view delegate
    
    func drawerView(_ aDrawerView: CYDrawerView, didSelectItemAt aIndex: Int) {
        self.drawerView.isOpen = false
    }

}


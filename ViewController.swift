//
//  ViewController.swift
//  AutoPlayVideoTableView
//
//  Created by Dhruv Patel on 10/09/18.
//  Copyright © 2018 Dhruv Patel. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! videoPlayerClassTableViewCell
        cell.videoPlayerItem = AVPlayerItem.init(url: URL(string: "https://www.quirksmode.org/html5/videos/big_buck_bunny.mp4")!)
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPaths = self.tableView.indexPathsForVisibleRows
       //print(indexPaths?.last as Any)
        let cellCount = indexPaths?.count
        if cellCount == 0 {return}
        if cellCount == 1{
            print ("visible = \(String(describing: indexPaths?[0]))")
        }
        if cellCount! >= 2 {
            let iP = indexPaths?.last
            let videoCell = self.tableView.cellForRow(at: iP!) as? videoPlayerClassTableViewCell
            videoCell?.startPlayback()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
 //       print("end = \(indexPath)")
        if let videoCell = cell as? videoPlayerClassTableViewCell{
            videoCell.stopPlayback()
        }
//
//        paused = true
    }
}


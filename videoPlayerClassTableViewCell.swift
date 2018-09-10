//
//  videoPlayerClassTableViewCell.swift
//  AutoPlayVideoTableView
//
//  Created by Dhruv Patel on 11/09/18.
//  Copyright © 2018 Dhruv Patel. All rights reserved.
//

import UIKit
import AVFoundation

class videoPlayerClassTableViewCell: UITableViewCell {

    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    
    @IBOutlet weak var videoPlayerSuperView: UIImageView!
    
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            /*
             If needed, configure player item here before associating it with a player.
             (example: adding outputs, setting text style rules, selecting media options)
             */
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupMoviePlayer()
    }

    func setupMoviePlayer(){
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        avPlayer?.volume = 3
        avPlayer?.actionAtItemEnd = .none
        
        avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: 320, height: 250)

  
        self.videoPlayerSuperView.layer.insertSublayer(avPlayerLayer!, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer?.currentItem)
    }
    
    func stopPlayback(){
        self.avPlayer?.pause()
    }
    
    func startPlayback(){
        self.avPlayer?.play()
    }
    
    // A notification is fired and seeker is sent to the beginning to loop the video again
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
  //      p.seek(to: kCMTimeZero)
        p.seek(to: kCMTimeZero, completionHandler: nil)
    }
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}

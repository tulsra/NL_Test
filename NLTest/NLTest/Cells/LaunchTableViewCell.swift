//
//  LaunchTableViewCell.swift
//  NLTest
//
//  Created by Tulasi on 01/08/19.
//  Copyright © 2019 Assignment. All rights reserved.
//

import UIKit

class LaunchTableViewCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var launchTitleLabel: UILabel!
    @IBOutlet weak var launchedDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgView?.layer.cornerRadius = 16
        self.imgView?.layer.masksToBounds = true
        self.imgView.contentMode = .scaleToFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(launch:LaunchesAPIResponse) {
        self.launchTitleLabel.text = launch.mission_name
        self.launchedDateLabel.text = launch.launch_date_unix?.date.displayDate
        self.imgView.image = nil
        //Set image 
        if (launch.links?.flickr_images?.first) != nil {
            DispatchQueue.global(qos: .background).async {
                do
                {
                    let data = try Data.init(contentsOf: URL.init(string:launch.links?.flickr_images?.first ?? "")!)
                    DispatchQueue.main.async {
                        let image: UIImage = UIImage(data: data) ?? UIImage()
                        self.imgView.image = image
                    }
                }
                catch {
                    // Handle Error
                }
            }
        }
        else {
            self.imgView.image = UIImage(named: "no_image")
        }
    }
}

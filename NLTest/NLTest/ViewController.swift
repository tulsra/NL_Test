//
//  ViewController.swift
//  NLTest
//
//  Created by Tulasi on 01/08/19.
//  Copyright © 2019 Assignment. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var launchedBgView: UIView!
    @IBOutlet weak var totalLaunchesLabel: UILabel!
    @IBOutlet weak var noOfLaunchesLabel: UILabel!
    lazy var launches: [String:[LaunchesAPIResponse]] = [:]
    lazy var launchYears:[String] = []
    let cellReuseIdendifier = "LaunchTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Setup UI
        self.setupUI()
        //Get all launches from API
        self.getLaunches()
    }
    
    func getLaunches() {
        
        let parm = ParameterDetail()
        if let dict = parm.dictionary {
            NetworkManager().req(method: .launches, parameters: dict) { (response, error) in
                if error == nil {
                    if let result = response {
                        DispatchQueue.main.async {
                            //Group all Results as per requirement
                            if let seq = (result as? [LaunchesAPIResponse]) {
                                let filteredSeq = seq.filter{Int(($0.launch_year ?? "2100")) ?? 2100 <= 2014}
                                let kResult =  Dictionary.init(grouping: filteredSeq.reversed(), by: {$0.launch_year})
                                print(kResult)
                                self.launches = kResult as! [String : [LaunchesAPIResponse]]
                                self.launchYears = self.launches.keys.sorted().reversed()
                                self.tableView.reloadData()
                                self.noOfLaunchesLabel.text = "\(filteredSeq.count)"
                            }
                            else {
                                //Handle Error
                            }
                        }
                    }
                    else {
                        //Handle Error
                    }
                }
                else {
                    //Handle Error
                }
            }
        }
    }
    
    func setupUI() {
        self.launchedBgView.layer.cornerRadius = 30.0
        self.launchedBgView.layer.masksToBounds = true
        self.totalLaunchesLabel.text = "Total Launches"
        self.noOfLaunchesLabel.text = "0"
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(UINib.init(nibName: cellReuseIdendifier, bundle: nil), forCellReuseIdentifier: cellReuseIdendifier)
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return launchYears.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.launches[self.launchYears[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 60))
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        let titleLabel = UILabel(frame: CGRect(x: 30, y: 0, width: UIScreen.main.bounds.size.width - 60, height: 60))
        titleLabel.text = self.launchYears[section]
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel.backgroundColor = UIColor.clear
        view.addSubview(titleLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdendifier, for: indexPath) as! LaunchTableViewCell
        
        if let launch = self.launches[self.launchYears[indexPath.section]]?[indexPath.row] {
            cell.setupCell(launch: launch)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let launch = self.launches[self.launchYears[indexPath.section]]?[indexPath.row]
        let message = "flight_number = \(launch?.flight_number ?? 0)\nmission_name = \(launch?.mission_name ?? "")\nmission_id = \(launch?.mission_id?.first ?? "")"
        let alert = UIAlertController(title: "Launch Details", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
         
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

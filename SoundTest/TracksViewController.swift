 //
//  TracksViewController.swift
//  SoundTest
//
//  Created by Maksim Avksentev on 05.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit

enum ControllerState {

    case favorites
    case all
    case none
}

class TracksViewController: BaseViewController, UITableViewDelegate, TrackDataSourceProtocol {

    @IBOutlet weak var tableView: UITableView!
    
    weak var refreshControl:UIRefreshControl!
    
    var dataSource: TracksDataSource = TracksDataSource(withState: .none)
    
    //MARK: Init
    init() {
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.dataSource.delegate = self
        self.configureTableView()
        self.setupRefreshControl()
        
        self.update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    //MARK: - Private
    private func configureTableView() {
    
        self.tableView.register(SoundTableViewCell.nib(), forCellReuseIdentifier: SoundTableViewCell.reuseIdentifier)
        self.tableView.delegate = self
        self.dataSource.initialize()
        self.tableView.dataSource = self.dataSource
    }
    
    @objc private func update() {
        
        self.dataSource.update { [weak self] (success, error) in
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
            }
            
            switch success {
            case true:
                DispatchQueue.main.async {
                    
                    self?.tableView.reloadData()
                }
                break
            case false:
                DispatchQueue.main.async {
                    
                    self?.presentErrorAlert(message: error?.localizedDescription, animated: true)
                }
                break
            }
        }
    }
    
    private func setupRefreshControl() {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(update), for: .valueChanged)
        
        self.tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
    }
    
    //MARK: - TrackDataSourceProtocol
    func addToFavorites(itemAtIndexPath indexPath: IndexPath) {
        
        if let sound = dataSource.soundItem(forIndexPath: indexPath) {
            
            sound.favorite = !sound.favorite
            CoreDataManager.shared.saveContext()
        }
        
        TracksStore.shared.updateFavorites { (success, error) in
            
        }
        
        self.tableView.reloadData()
    }
    
    func typeForTrackDataSource() -> ControllerState {
        
        return .none
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let sound = dataSource.soundItem(forIndexPath: indexPath) else {
        
            return
        }
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PlayMusicAtIndexPath"), object: nil, userInfo: ["sound":sound, "state":self.dataSource.state])
    }
}

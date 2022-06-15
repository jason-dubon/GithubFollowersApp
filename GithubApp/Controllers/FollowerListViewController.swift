//
//  FollowerListViewController.swift
//  GithubApp
//
//  Created by Jason Dubon on 6/13/22.
//

import UIKit

class FollowerListViewController: UIViewController {

    enum Section {
        case main
        
    }
    
    var username: String!
    var followers: [Follower] = []
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
        configureCollectionView()
        getFollowers()
        
        configureDataSource()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    
    }
    
    func configureViewController() {
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        
        collectionView.backgroundColor = .systemMint
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.identifier)
        
        
    }
    
    
    func getFollowers() {
        // need to use a switch statment to handle result/error
        NetworkManager.shared.getFollowers(for: username, page: 1) { [weak self] result in
            
            guard let self = self else {return}
            
            switch result {
            case .success(let followers):
                self.followers = followers
                self.updateData()
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Network Error", message: error.rawValue, buttonTitle: "Ok")
            }
    
            
        }

    }
    
    func configureDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { collectionView, indexPath, follower in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.identifier, for: indexPath) as? FollowerCell else {return UICollectionViewCell()}
            cell.set(follower: follower)
            
            return cell
        })
        
    }

    func updateData() {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
        
        
        
    }
    
}

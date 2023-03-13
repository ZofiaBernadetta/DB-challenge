//
//  ViewController.swift
//  DB challenge
//
//  Created by Zofia Drabek on 06.03.23.
//

import UIKit
import CoreData

class TimelineViewController: UIViewController {
    let postsManager: PostsManager
    let performLogout: () -> Void

    let segmentedControl = UISegmentedControl(items: ["All", "Favorite"])
    let tableView = UITableView()
    let spinner = UIActivityIndicatorView(style: .large)

    var dataSource: UITableViewDiffableDataSource<Section, Post.ID>!

    enum Section {
        case main
    }

    var posts = [Post]()
    var favoritePosts: [Post] {
        posts.filter(\.isFavorite)
    }
    var currentPosts: [Post] {
        if segmentedControl.selectedSegmentIndex == 0 {
            return posts
        } else {
            return favoritePosts
        }
    }

    init(postsManager: PostsManager, performLogout: @escaping () -> Void) {
        self.postsManager = postsManager
        self.performLogout = performLogout
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setUpTableView()
        setupSegmentedController()
        setupDataSource()
        setupSpinner()
        setupNavigationBar()

        NotificationCenter.default.addObserver(self, selector: #selector(postsUpdated), name: postsManager.notificationName, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        postsManager.fetchPosts()
    }

    private func setUpTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "cell")

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupSegmentedController() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(self.segmentedValueChanged(_:)), for: .valueChanged)
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Post.ID>(tableView: tableView) { [weak self] tableView, indexPath, postID in
            guard
                let self,
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PostTableViewCell
            else {
                return UITableViewCell()
            }

            cell.setup(with: self.posts[indexPath.row])
            cell.toggleFavourite = { [weak self] id, isFavorite in
                if isFavorite {
                    self?.postsManager.addFavorite(postID: id)
                } else {
                    self?.postsManager.removeFavorite(postID: id)
                }
            }
            return cell
        }

        tableView.dataSource = dataSource
        applySnapshot()
    }

    private func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    private func setupNavigationBar() {
        let segmentBarItem = UIBarButtonItem(customView: segmentedControl)
        navigationItem.rightBarButtonItem = segmentBarItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
    }

    @objc func postsUpdated() {
        spinner.isHidden = true
        let diff = postsManager.posts.difference(from: posts)
        var insertedIDs = Set<Post.ID>()
        var removedIDs = Set<Post.ID>()

        for change in diff {
            switch change {
            case .insert(offset: _, element: let element, associatedWith: _):
                insertedIDs.insert(element.id)
            case .remove(offset: _, element: let element, associatedWith: _):
                removedIDs.insert(element.id)
            }
        }

        let updateIDs = insertedIDs.intersection(removedIDs)

        posts = postsManager.posts
        applySnapshot(updatedIDs: updateIDs)
    }

    @objc func segmentedValueChanged(_ sender: UISegmentedControl!) {
        applySnapshot()
    }

    @objc func logoutTapped(_ sender: UIBarButtonItem) {
        performLogout()
    }
    
    private func applySnapshot(updatedIDs: Set<Post.ID> = []) {
        dataSource.apply(snapshot(updatedIDs: []))
        dataSource.apply(snapshot(updatedIDs: updatedIDs), animatingDifferences: false)
    }
    
    private func snapshot(updatedIDs: Set<Post.ID>) -> NSDiffableDataSourceSnapshot<Section, Post.ID> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Post.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(currentPosts.map(\.id), toSection: .main)
        snapshot.reloadItems(Array(updatedIDs.intersection(currentPosts.map(\.id))))
        return snapshot
    }

}

//
//  PostTableViewCell.swift
//  DB challenge
//
//  Created by Zofia Drabek on 08.03.23.
//

import Foundation
import UIKit

class PostTableViewCell: UITableViewCell {
    var post: Post?
    
    let titleLabel = UILabel()
    let bodyLabel = UILabel()
    let favouriteButton = UIButton()
    
    var toggleFavourite: ((Int, Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        bodyLabel.text = ""
        favouriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }

    private func setViews() {
        favouriteButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        titleLabel.numberOfLines = 0
        bodyLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(favouriteButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        favouriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            favouriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favouriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favouriteButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            favouriteButton.heightAnchor.constraint(equalToConstant: 44),
            favouriteButton.widthAnchor.constraint(equalToConstant: 44),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func setup(with post: Post) {
        self.post = post
        titleLabel.text = post.title
        bodyLabel.text = post.body
        let imageName = post.isFavorite ? "heart.fill" : "heart"
        favouriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc
    func buttonTapped(_ sender: UIButton) {
        post?.isFavorite.toggle()
        guard let post else { return }
        let imageName = post.isFavorite ? "heart.fill" : "heart"
        favouriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        toggleFavourite?(post.id, post.isFavorite)
    }
}

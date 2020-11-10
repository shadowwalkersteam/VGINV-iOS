//
//  MovieGridCollectionViewCell.swift
//  CollectionViewResponsiveLayout
//
//  Created by Alfian Losari on 2/8/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit

class MovieLayoutGridCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var view: UIView!
    
    func setup(with movie: Movie) {
        stackView.backgroundColor = UIColor.dashboardBackground()
        view.backgroundColor = UIColor.dashboardBackground()
        posterImage.shadow()
        posterImage.image = movie.posterImage
        title.text = movie.title
    }
}

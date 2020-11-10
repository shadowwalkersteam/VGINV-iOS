//
//  NewsCell.swift
//  TheNews
//
//  Created by Daniel on 4/22/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit
import Kingfisher

class NewsCell: UICollectionViewCell {
    var identifier: String?
    var imageSize: CGSize?
    
    let imageView = UIImageView()
    let source = UILabel()
    let title = UILabel()
    let content = UILabel()
    let ago = UILabel()
    let line = UIView()
    let bduget = UILabel()
    let investment = UILabel()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        ago.attributedText = nil
        ago.text = nil
        
        content.text = nil
        content.attributedText = nil
        
        identifier = nil
        
        imageView.image = nil
        
        source.text = nil
        source.attributedText = nil
        
        title.attributedText = nil
        title.text = nil
        
        bduget.attributedText = nil
        bduget.text = nil
        
        investment.attributedText = nil
        investment.text = nil
    }

    var imageSizeUnwrapped: CGSize {
        guard let unwrapped = imageSize else { return CGSize.zero }
        
        return unwrapped
    }

    func configureProjects(_ article: ProjectsCatalog) {
        identifier = article.id?.description
    }
    
    func configureNews(_ article: NewsDetails) {
           identifier = article.id?.description
       }
    
    func configureDeals(_ article: DealsCatalog) {
        identifier = article.id?.description
    }

    func update(image: UIImage?, matchingIdentifier: String?) {        
        guard identifier == matchingIdentifier else { return }

        imageView.image = image
        imageView.clipsToBounds = true;
        imageView.contentMode = .scaleAspectFit
    }
    
    func updateWithURL(url: URL?, matchingIdentifier: String?, size: CGSize) {
        let processor = DownsamplingImageProcessor(size: size)
        let resizingProcessor = ResizingImageProcessor(referenceSize: CGSize(width: size.width * UIScreen.main.scale, height: size.height * UIScreen.main.scale))
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            options: [
                .processor(processor),
                .transition(.fade(1)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
//                imageView?.image = self.resizeImage(image: image!, newWidth: 40.0)
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

//
//  WashingtonCell.swift
//  TheNews
//
//  Created by Daniel on 4/23/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class WashingtonCell: NewsCell {
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
        config()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configureDeals(_ article: DealsCatalog) {
        super.configureDeals(article)
        title.text = article.title
        content.text = article.description
        source.text = "Business"
        
        let invest = article.investment?.description ?? ""
        let bud = article.budget?.description ?? ""
        bduget.text = "budget".l10n() + ": SAR " + bud
        investment.text = "Total_Investment".l10n() + ": SAR " + invest
    }
    
    override func configureNews(_ article: NewsDetails) {
        super.configureNews(article)

        title.text = article.title
        content.text = article.content?.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil).replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
        source.text = "Business"
    }
    
    override func configureProjects(_ article: ProjectsCatalog) {
        super.configureProjects(article)
        title.text = article.title
        content.text = article.description
        source.text = "Business"

        let invest = article.investment?.description ?? ""
        let bud = article.budget?.description ?? ""
        bduget.text = "budget".l10n() + ": SAR " + bud
        investment.text = "Total_Investment".l10n() + ": SAR " + invest
    }
}

extension WashingtonCell: Configurable {
    func setup() {
        imageSize = CGSize(width: 390, height: 230)

        line.backgroundColor = .lineGray

        imageView.contentMode = .scaleAspectFit

        title.numberOfLines = 0
        title.font = UIFont(name: "Georgia", size: 20)

        content.numberOfLines = 0
        content.font = UIFont(name: "AppleSDGothicNeo-UltraLight", size: 16)

        source.textColor = .bottomTextGray
        source.font = UIFont(name: "AppleSDGothicNeo-UltraLight", size: 14)
        
        bduget.textColor =  UIColor.red()
        bduget.font = UIFont(name: "AppleSDGothicNeo-UltraLight", size: 14)
        
        investment.textColor = UIColor.colorPrimary()
        investment.font = UIFont(name: "AppleSDGothicNeo-UltraLight", size: 14)
    }

    func config() {
        [line, title, content, imageView, ago, source, bduget, investment].forEach { contentView.addSubviewForAutoLayout($0) }

        NSLayoutConstraint.activate([
            line.topAnchor.constraint(equalTo: contentView.topAnchor),
            line.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            line.heightAnchor.constraint(equalToConstant: 1),

            imageView.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 15),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            contentView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 15),
            imageView.heightAnchor.constraint(equalToConstant: imageSizeUnwrapped.height),

            title.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            title.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),

            content.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            content.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),

            source.topAnchor.constraint(equalTo: content.bottomAnchor, constant: 10),
            source.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            source.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: source.bottomAnchor, constant: 3),
            
            bduget.topAnchor.constraint(equalTo: source.bottomAnchor, constant: 10),
            bduget.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            bduget.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            
            investment.topAnchor.constraint(equalTo: bduget.bottomAnchor, constant: 10),
            investment.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            investment.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: investment.bottomAnchor, constant: 3),
        ])
    }
}

private extension Article {
    var bottom: String? {
        var str = ""

        if let author = author, author.count > 0 {
            str = "By \(author) • "
        }

        if let date = publishedAt {
            str = "\(str)\(date.timeAgoSinceDate)"
        }

        return str
    }
}

private extension UIColor {
    static let lineGray = UIColor.colorForSameRgbValue(210)
    static let bottomTextGray = UIColor.colorForSameRgbValue(80)
}

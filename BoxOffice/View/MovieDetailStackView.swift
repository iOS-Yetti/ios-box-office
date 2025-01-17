//
//  MovieDetailStackView.swift
//  BoxOffice
//
//  Created by Yetti, Maxhyunm on 2023/08/08.
//

import UIKit

final class MovieDetailStackView: UIStackView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        
        return label
    }()
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        
        return label
    }()
    
    init() {
        super.init(frame: .init())
        setUpUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        self.axis = .horizontal
        self.addArrangedSubview(titleLabel)
        self.addArrangedSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.22),
            valueLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.78),
        ])
    }
    
    func setUpLabelText(title: String, value: String) {
        self.titleLabel.text = title
        self.valueLabel.text = value
    }
}

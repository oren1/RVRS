//
//  SpidReferenceView.swift
//  RVRS
//
//  Created by oren shalev on 30/07/2025.
//

import UIKit
import FirebaseRemoteConfig

class SpidReferenceView: UIView {
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(imageView)
        addSubview(titleLabel)
        let spidLinkText = RemoteConfig.remoteConfig().configValue(forKey: "spidLinkText").stringValue!

        // Appearance
        imageView.image = UIImage(named: "spid-1")
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 6
        
        titleLabel.text = spidLinkText
        titleLabel.font = UIFont(name: "Avenir-Heavy", size: 20)
        titleLabel.adjustsFontSizeToFitWidth = true


        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0

        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    
        if UserDataManager.main.spidInstalled() {
            titleLabel.isHidden = true
            NSLayoutConstraint.activate([
                imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 52),
                imageView.heightAnchor.constraint(equalToConstant: 52)
            ])
        }
        else {
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
                // Label at top-left of the container view
                titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -8)
            ])
        }
       
    }
}

class SpidReferenceViewThree: UIView {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont(name: "Avenir-Heavy", size: 20)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "spid-1")
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Download Now", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
       
        titleLabel.text = "Edit Videos Instantly With Spid"
       
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(actionButton)

        NSLayoutConstraint.activate([
            // Title label at the top, centered
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
//            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            // Image view below title label
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 52),
            imageView.heightAnchor.constraint(equalToConstant: 52),

            // Button below image view
            actionButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}

class SecondSpidReferenceView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    func setup() {
        
        let label = UILabel()
        label.text = "Open Spid App"
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "spid-1")
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 6
        imageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 48).isActive = true

        // Create horizontal stack view
        let stackView = UIStackView(arrangedSubviews: [label, imageView])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(stackView)

        // Center stack view in parent
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

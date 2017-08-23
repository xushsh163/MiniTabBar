//
//  MiniTabBarItemView.swift
//  Pods
//
//  Created by Dylan Marriott on 12/01/17.
//
//

import Foundation
import UIKit

class MiniTabBarItemView: UIView {
    let item: MiniTabBarItem
    let titleLabel = UILabel()
    let iconView = UIImageView()
    let badgeLabel = UILabel()

    private var selected = false

    public weak var parent: MiniTabBar?

    override var tintColor: UIColor! {
        didSet {
            if self.selected {
                self.iconView.tintColor = self.tintColor
                self.titleLabel.textColor = self.tintColor
            }
        }
    }
    public var inactiveColor: UIColor! {
        didSet {
            if !self.selected {
                self.iconView.tintColor = self.inactiveColor
                self.titleLabel.textColor = self.inactiveColor
            }
        }
    }
    private let defaultFont = UIFont.systemFont(ofSize: 12)
    var font: UIFont? {
        didSet {
            self.titleLabel.font = self.font ?? defaultFont
        }
    }
    
    init(_ item: MiniTabBarItem, _ parent: MiniTabBar) {
        self.item = item
        self.parent = parent
        super.init(frame: CGRect.zero)
        
        if let customView = self.item.customView {
            assert(self.item.title == nil && self.item.icon == nil, "Don't set title / icon when using a custom view")
            if (customView.frame.width <= 0 || customView.frame.height <= 0) {
                customView.frame.size = CGSize(width: 50, height: 50)
            }
            self.addSubview(customView)
        } else {
            assert(self.item.title != nil && self.item.icon != nil, "Title / Icon not set")
            if let title = self.item.title {
                titleLabel.text = title
                titleLabel.font = self.defaultFont
                titleLabel.textColor = self.tintColor
                titleLabel.textAlignment = .center
                self.addSubview(titleLabel)
            }
            
            if let icon = self.item.icon {
                iconView.image = icon.withRenderingMode(.alwaysTemplate)
                self.addSubview(iconView)
            }

            if let badge = self.item.badge {
                if (badge.value != "") {
                    badgeLabel.text = badge.value
                    badgeLabel.font = UIFont.systemFont(ofSize: 8)
                    badgeLabel.textColor = badge.textColor
                    badgeLabel.backgroundColor = badge.backgroundColor
                    badgeLabel.textAlignment = .center
                    badgeLabel.layer.cornerRadius = 6
                    badgeLabel.clipsToBounds = true
                    self.addSubview(badgeLabel)
                }
            }
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let customView = self.item.customView {
            customView.center = CGPoint(x: self.frame.width / 2 + self.item.offset.horizontal,
                                        y: self.frame.height / 2 + self.item.offset.vertical)
        } else {
            self.setFrames()
        }
    }
    public func getItemBarBackgroundColor() -> UIColor {
        return self.item.barBackgroundColor!
    }
    func setFrames () {
        if let parent = self.parent {
            switch (parent.titleState) {
                case TitleState.ShowWhenActive:
                    titleLabel.frame = CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: 14)
                    iconView.frame = CGRect(x: self.frame.width / 2 - 13, y: 12, width: 25, height: 25)
                    badgeLabel.frame = CGRect(x: self.frame.width / 2 + 6, y: 6, width: 12, height: 12)
                case TitleState.AlwaysShow:
                    titleLabel.frame = CGRect(x: 0, y: 28, width: self.frame.width, height: 14)
                    iconView.frame = CGRect(x: self.frame.width / 2 - 13, y: 5, width: 25, height: 25)
                    badgeLabel.frame = CGRect(x: self.frame.width / 2 + 6, y: 2.5, width: 12, height: 12)
                case TitleState.AlwaysHide:
                    titleLabel.frame = CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: 14)
                    iconView.frame = CGRect(x: self.frame.width / 2 - 13, y: 12, width: 25, height: 25)
                    badgeLabel.frame = CGRect(x: self.frame.width / 2 + 6, y: 6, width: 12, height: 12)
            }
        }
    }
    
    func setBadge(badgeValue: String) {
        if (badgeValue != "") {
             UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                self.fadeScaleOut()
            }, completion: { finished in 
                self.badgeLabel.text = badgeValue
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                    self.fadeScaleIn();
                })
            })
        } else {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                self.badgeLabel.alpha = 0.0
            })
        }
    }

    func fadeScaleOut() {
        self.badgeLabel.alpha = 0.0
        self.badgeLabel.transform = CGAffineTransform(scaleX: -1.0, y: -1.0)
    }
    func fadeScaleIn() {
        self.badgeLabel.alpha = 1.0
        self.badgeLabel.transform = CGAffineTransform.identity
    }

    func deSelected(_ deselected: Bool, animated: Bool = true) {
        if (deselected && animated) {
            if let parent = self.parent {
                if (parent.titleState == TitleState.ShowWhenActive) {
                    /*
                    ICON
                    */
                    UIView.animate(withDuration: 0.15, delay: 0, options: UIViewAnimationOptions(), animations: {
                        self.iconView.frame.origin.y = 12
                    })
                    /*
                    BADGE
                    */
                    UIView.animate(withDuration: 0.15, delay: 0, options: UIViewAnimationOptions(), animations: {
                        self.badgeLabel.frame.origin.y = 6
                    })
                    /*
                    TEXT
                    */
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {
                        self.titleLabel.frame.origin.y = self.frame.size.height
                    })
                }
            }
        }
    }
    func setSelected(_ selected: Bool, animated: Bool = true) {
        self.selected = selected
        self.iconView.tintColor = selected ? self.tintColor : self.inactiveColor
        self.titleLabel.textColor = selected ? self.tintColor : self.inactiveColor
        if (animated && selected) {
            if let parent = self.parent {
                if (parent.titleState == TitleState.ShowWhenActive) {
                    /*
                    ICON
                    */
                    UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                        self.iconView.frame.origin.y = 5
                    })
                    /*
                    BADGE
                    */
                    UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                        self.badgeLabel.frame.origin.y = 2.5
                    })
                    
                    
                    /*
                    TEXT
                    */
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {
                        self.titleLabel.frame.origin.y = 28
                    })
                }
                if (parent.colored) {
                    UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                        parent.backgroundColor = self.item.barBackgroundColor
                    })
                } else {
                    if (parent.backgroundColor !== parent.uncoloredBackgroundColor) {
                        parent.backgroundColor = parent.uncoloredBackgroundColor
                    }
                }
            }
        }
    }
}

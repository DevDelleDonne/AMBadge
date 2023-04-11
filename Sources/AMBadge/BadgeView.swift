//
//  BadgeView.swift
//  
//
//  Created by Alberto Delle Donne on 11/04/23.
//

#if os(iOS)
import UIKit

internal final class DropView: UIView {
  required init(badge: AmBadge) {
    self.badge = badge
    super.init(frame: .zero)

    backgroundColor = .secondarySystemBackground

    addSubview(stackView)

    let constraints = createLayoutConstraints(for: badge)
    NSLayoutConstraint.activate(constraints)
    configureViews(for: badge)
  }

  required init?(coder _: NSCoder) {
    return nil
  }

  override var frame: CGRect {
    didSet { layer.cornerRadius = frame.cornerRadius }
  }

  override var bounds: CGRect {
    didSet { layer.cornerRadius = frame.cornerRadius }
  }

  let badge: AmBadge

  func createLayoutConstraints(for badge: AmBadge) -> [NSLayoutConstraint] {
    var constraints: [NSLayoutConstraint] = []

    constraints += [
      imageView.heightAnchor.constraint(equalToConstant: 25),
      imageView.widthAnchor.constraint(equalToConstant: 25)
    ]

    constraints += [
      button.heightAnchor.constraint(equalToConstant: 35),
      button.widthAnchor.constraint(equalToConstant: 35)
    ]

    var insets = UIEdgeInsets(top: 8.5, left: 9.5, bottom: 8.5, right: 9.5)

    if badge.icon == nil {
      insets.left = 40
    }

    if badge.action?.icon == nil {
      insets.right = 40
    }

    if badge.subtitle == nil {
      insets.top = 15
      insets.bottom = 15
      if badge.action?.icon != nil {
        insets.top = 10
        insets.bottom = 10
        insets.right = 10
      }
    }

    if badge.icon == nil, badge.action?.icon == nil {
      insets.left = 30
      insets.right = 30
    }

    constraints += [
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
      stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: insets.top),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom)
    ]

    return constraints
  }

  func configureViews(for badge: AmBadge) {
    clipsToBounds = true

    titleLabel.text = badge.title
    titleLabel.numberOfLines = badge.titleNumberOfLines

    subtitleLabel.text = badge.subtitle
    subtitleLabel.numberOfLines = badge.subtitleNumberOfLines
    subtitleLabel.isHidden = badge.subtitle == nil

    imageView.image = badge.icon
    imageView.isHidden = badge.icon == nil

    button.setImage(badge.action?.icon, for: .normal)
    button.isHidden = badge.action?.icon == nil

    if let action = badge.action, action.icon == nil {
      let tap = UITapGestureRecognizer(target: self, action: #selector(didTapButton))
      addGestureRecognizer(tap)
    }

    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = .zero
    layer.shadowRadius = 25
    layer.shadowOpacity = 0.15
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
    layer.masksToBounds = false
  }

  @objc
  func didTapButton() {
    badge.action?.handler()
  }

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .left
    label.textColor = .label
    label.font = UIFont.preferredFont(forTextStyle: .subheadline).bold
    label.adjustsFontForContentSizeCategory = true
    label.adjustsFontSizeToFitWidth = true
    return label
  }()

  lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .left
    label.textColor = UIAccessibility.isDarkerSystemColorsEnabled ? .label : .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: .subheadline)
    label.adjustsFontForContentSizeCategory = true
    label.adjustsFontSizeToFitWidth = true
    return label
  }()

  lazy var imageView: UIImageView = {
    let view = RoundImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFit
    view.clipsToBounds = true
    view.tintColor = UIAccessibility.isDarkerSystemColorsEnabled ? .white : .black
    return view
  }()

  lazy var button: UIButton = {
    let button = RoundButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    button.clipsToBounds = true
    button.backgroundColor = .link
    button.tintColor = .white
    button.imageView?.contentMode = .scaleAspectFit
    button.contentEdgeInsets = .init(top: 7.5, left: 7.5, bottom: 7.5, right: 7.5)
    return button
  }()

  lazy var labelsStackView: UIStackView = {
    let view = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .vertical
    view.alignment = .leading
    view.distribution = .fill
    view.spacing = -1
    return view
  }()

  lazy var stackView: UIStackView = {
    let view = UIStackView(arrangedSubviews: [imageView, labelsStackView, button])
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .horizontal
    view.alignment = .center
    view.distribution = .fill
    if badge.icon != nil, badge.action?.icon != nil {
      view.spacing = 5
    } else {
      view.spacing = 10
    }
    return view
  }()
}

final class RoundButton: UIButton {
  override var bounds: CGRect {
    didSet { layer.cornerRadius = frame.cornerRadius }
  }
}

final class RoundImageView: UIImageView {
  override var bounds: CGRect {
    didSet { layer.cornerRadius = frame.cornerRadius }
  }
}

extension UIFont {
  var bold: UIFont {
    guard let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) else { return self }
    return UIFont(descriptor: descriptor, size: pointSize)
  }
}

extension CGRect {
  var cornerRadius: CGFloat {
    return 12
  }
}
#endif


//
//  BadgeView.swift
//
//
//  Created by Alberto Delle Donne on 11/04/23.
//

#if os(iOS)
import UIKit

/// An object representing a drop.
@available(iOSApplicationExtension, unavailable)
public struct AmBadge: ExpressibleByStringLiteral {
  /// Create a new drop.
  /// - Parameters:
  ///   - title: Title.
  ///   - titleNumberOfLines: Maximum number of lines that `title` can occupy. Defaults to `1`.
  ///   A value of 0 means no limit.
  ///   - subtitle: Optional subtitle. Defaults to `nil`.
  ///   - subtitleNumberOfLines: Maximum number of lines that `subtitle` can occupy. Defaults to `1`.
  ///   A value of 0 means no limit.
  ///   - icon: Optional icon.
  ///   - action: Optional action.
  ///   - position: Position. Defaults to `Drop.Position.top`.
  ///   - duration: Duration. Defaults to `Drop.Duration.recommended`.
  ///   - accessibility: Accessibility options. Defaults to `nil` which will use "title, subtitle" as its message.
  public init(
    title: String,
    titleNumberOfLines: Int = 1,
    subtitle: String? = nil,
    subtitleNumberOfLines: Int = 1,
    icon: UIImage? = nil,
    action: Action? = nil,
    position: Position = .bottom,
    duration: Duration = .recommended,
    accessibility: Accessibility? = nil
  ) {
    self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
    self.titleNumberOfLines = titleNumberOfLines
    if let subtitle = subtitle?.trimmingCharacters(in: .whitespacesAndNewlines), !subtitle.isEmpty {
      self.subtitle = subtitle
    }
    self.subtitleNumberOfLines = subtitleNumberOfLines
    self.icon = icon
    self.action = action
    self.position = position
    self.duration = duration
    self.accessibility = accessibility
    ?? .init(message: [title, subtitle].compactMap { $0 }.joined(separator: ", "))
  }

  /// Create a new accessibility object.
  /// - Parameter message: Message to be announced when the drop is shown. Defaults to drop's "title, subtitle"
  public init(stringLiteral title: String) {
    self.title = title
    titleNumberOfLines = 1
    subtitleNumberOfLines = 1
    position = .bottom
    duration = .recommended
    accessibility = .init(message: title)
  }

  /// Title.
  public var title: String

  /// Maximum number of lines that `title` can occupy. A value of 0 means no limit.
  public var titleNumberOfLines: Int

  /// Subtitle.
  public var subtitle: String?

  /// Maximum number of lines that `subtitle` can occupy. A value of 0 means no limit.
  public var subtitleNumberOfLines: Int

  /// Icon.
  public var icon: UIImage?

  /// Action.
  public var action: Action?

  /// Position.
  public var position: Position

  /// Duration.
  public var duration: Duration

  /// Accessibility.
  public var accessibility: Accessibility
}

public extension AmBadge {
  /// An enum representing drop presentation position.
  enum Position: Equatable {
    case bottom
  }
}

public extension AmBadge {
  /// An enum representing a drop duration on screen.
  enum Duration: Equatable, ExpressibleByFloatLiteral {
    /// Hides the drop after 2.0 seconds.
    case recommended
    /// Hides the drop after the specified number of seconds.
    case seconds(TimeInterval)

    /// Create a new duration object.
    /// - Parameter value: Duration in seconds
    public init(floatLiteral value: TimeInterval) {
      self = .seconds(value)
    }

    internal var value: TimeInterval {
      switch self {
      case .recommended:
        return 2.0
      case let .seconds(custom):
        return abs(custom)
      }
    }
  }
}

public extension AmBadge {
  /// An object representing a drop action.
  struct Action {
    /// Create a new action.
    /// - Parameters:
    ///   - icon: Optional icon image.
    ///   - handler: Handler to be called when the drop is tapped.
    public init(icon: UIImage? = nil, handler: @escaping () -> Void) {
      self.icon = icon
      self.handler = handler
    }

    /// Icon.
    public var icon: UIImage?

    /// Handler.
    public var handler: () -> Void
  }
}

public extension AmBadge {
  /// An object representing accessibility options.
  struct Accessibility: ExpressibleByStringLiteral {
    /// Create a new accessibility object.
    /// - Parameter message: Message to be announced when the drop is shown. Defaults to drop's "title, subtitle"
    public init(message: String) {
      self.message = message
    }

    /// Create a new accessibility object.
    /// - Parameter message: Message to be announced when the drop is shown. Defaults to drop's "title, subtitle"
    public init(stringLiteral message: String) {
      self.message = message
    }

    /// Accessibility message to be announced when the drop is shown.
    public let message: String
  }
}
#endif

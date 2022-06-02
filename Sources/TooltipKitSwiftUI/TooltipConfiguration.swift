/*
 * FILE:	TooltipConfiguration.swift
 * DESCRIPTION:	TooltipKitSwiftUI: Configuration for Balloon Shape
 * DATE:	Mon, May 30 2022
 * UPDATED:	Thu, Jun  2 2022
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		https://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2022 阿部康一／Kouichi ABE (WALL)
 * LICENSE:	The 2-Clause BSD License (See LICENSE.txt)
 */

import SwiftUI

public final class TooltipConfiguration
{
  let arrowHeight: CGFloat = 15.0
  let borderWidth: CGFloat = 4.0 // Should be less or equal to the 'radius'
  let cornerRadius: CGFloat = 10.0

  private let baseContentSize: CGSize
  private(set) var arrowDirection: TooltipArrowDirection
  private(set) var arrowPosition: TooltipArrowPosition
  private(set) var tintColor: Color

  public init(contentSize: CGSize, arrowDirection: ArrowDirection = .down, arrowPosition: ArrowPosition = .center, tintColor: Color = .pink) {
    self.baseContentSize = contentSize
    self.arrowDirection = arrowDirection
    self.arrowPosition = arrowPosition
    self.tintColor = tintColor
  }

  /*
   * If you want to set the direction and position of the arrow,
   * change the flag to "false".
   */
  public var isAutoConfigurationEnabled: Bool = true
}

extension TooltipConfiguration
{
  public static var small: TooltipConfiguration {
    return .init(contentSize: .init(width: 80, height: 50))
  }

  public static var `default`: TooltipConfiguration {
    return .init(contentSize: .init(width: 130, height: 80))
  }

  public static var large: TooltipConfiguration {
    return .init(contentSize: .init(width: 180, height: 110))
  }

  public func tintColor(_ color: Color) -> Self {
    self.tintColor = color
    return self
  }
}

extension TooltipConfiguration
{
  func updateArrowDirection(_ direction: TooltipArrowDirection) {
    self.arrowDirection = direction
  }

  func updateArrowPosition(_ position: TooltipArrowPosition) {
    self.arrowPosition = position
  }

  // 表示元の中心座標に位置を調整する
  func arrowOffset() -> CGSize {
    let w_2: CGFloat = contentRect.size.width * 0.5
    let h_2: CGFloat = contentRect.size.height * 0.5
    let len: CGFloat = arrowHeight
    let dL2: CGFloat = len + borderWidth + cornerRadius
    var offset: CGPoint = .zero
    switch self.arrowDirection {
      case    .up: offset.y += (len + h_2)
      case  .down: offset.y -= (len + h_2)
      case  .left: offset.x += (len + w_2)
      case .right: offset.x -= (len + w_2)
    }
    switch self.arrowPosition {
      case      .top: offset.y += (h_2 - dL2)
      case   .bottom: offset.y -= (h_2 - dL2)
      case  .leading: offset.x += (w_2 - dL2)
      case .trailing: offset.x -= (w_2 - dL2)
      case   .center: break
    }
    return .init(width: offset.x, height: offset.y)
  }
}

extension TooltipConfiguration
{
  var balloonSize: CGSize {
    let m: CGFloat =  borderWidth * 2.0
    var w: CGFloat = contentSize.width + m
    var h: CGFloat = contentSize.height + m
    switch arrowDirection {
      case   .up,  .down: h += arrowHeight
      case .left, .right: w += arrowHeight
    }
    return CGSize(width: w, height: h)
  }

  var contentRect: CGRect {
    let m: CGFloat = borderWidth * 2.0
    let w: CGFloat = contentSize.width + m
    let h: CGFloat = contentSize.height + m
    return CGRect(origin: .zero, size: CGSize(width: w, height: h))
  }

  var contentSize: CGSize {
    let m: CGFloat = cornerRadius * 2.0
    let w: CGFloat = baseContentSize.width + m
    let h: CGFloat = baseContentSize.height + m
    return CGSize(width: w, height: h)
  }

  var contentOffset: CGSize {
    return .init(width: borderWidth, height: borderWidth)
  }

  var contentPosition: CGPoint {
    let x = borderWidth + contentSize.width * 0.5
    let y = borderWidth + contentSize.height * 0.5
    return .init(x: x, y: y)
  }

  var contentCornerRadius: CGFloat {
    let radius = cornerRadius - borderWidth
    return radius > 0 ? radius : cornerRadius
  }
}

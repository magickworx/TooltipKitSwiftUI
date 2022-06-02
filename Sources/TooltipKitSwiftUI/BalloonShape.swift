/*
 * FILE:	BalloonShape.swift
 * DESCRIPTION:	TooltipKitSwiftUI: Balloon Shape
 * DATE:	Sun, May 29 2022
 * UPDATED:	Tue, May 31 2022
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		https://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2022 阿部康一／Kouichi ABE (WALL)
 * LICENSE:	The 2-Clause BSD License (See LICENSE.txt)
 */

import SwiftUI

struct BalloonShape: Shape
{
  private let configuration: TooltipConfiguration

  private let arrowDirection: TooltipArrowDirection
  private let arrowPosition: TooltipArrowPosition

  init(configuration: TooltipConfiguration) {
    self.configuration = configuration
    self.arrowDirection = configuration.arrowDirection
    self.arrowPosition = configuration.arrowPosition
  }

  func path(in rect: CGRect) -> Path {
    let contentRect = configuration.contentRect
    var balloonPath: Path = .init(roundedRect: contentRect, cornerRadius: configuration.cornerRadius)
    let arrowPath = makeArrowPath(with: contentRect)
    balloonPath.addPath(arrowPath)
    return balloonPath
  }
}

extension BalloonShape
{
  private func makeArrowPath(with rect: CGRect) -> Path {
    let borderWidth = configuration.borderWidth
    let cornerRadius = configuration.cornerRadius
    let arrowHeight = configuration.arrowHeight
    let arrowBaseSide = arrowHeight * 2.0

    return Path { path in
      var x: CGFloat = {
        switch self.arrowDirection {
          case .up, .down:
            switch self.arrowPosition {
              case .trailing:
                return rect.maxX - (arrowBaseSide + borderWidth + cornerRadius)
              case .center:
                return rect.midX - arrowHeight
              case .leading:
                fallthrough
              default:
                return rect.minX + (borderWidth + cornerRadius)
            }
          case .left:
            return rect.minX
          case .right:
            return rect.maxX
        }
      }()

      var y: CGFloat = {
        switch self.arrowDirection {
          case .up:
            return rect.minY
          case .down:
            return rect.maxY
          case .left, .right:
            switch self.arrowPosition {
              case .bottom:
                return rect.maxY - (arrowBaseSide + borderWidth + cornerRadius)
              case .center:
                return rect.midY - arrowHeight
              case .top:
                fallthrough
              default:
                return rect.minY + (borderWidth + cornerRadius)
            }
        }
      }()

      switch self.arrowDirection {
        case .up:
          path.move(to: CGPoint(x: x, y: y))
          x += arrowHeight
          y -= arrowHeight
          path.addLine(to: CGPoint(x: x, y: y))
          x += arrowHeight
          y += arrowHeight
          path.addLine(to: CGPoint(x: x, y: y))
        case .down:
          path.move(to: CGPoint(x: x, y: y))
          x += arrowHeight
          y += arrowHeight
          path.addLine(to: CGPoint(x: x, y: y))
          x += arrowHeight
          y -= arrowHeight
          path.addLine(to: CGPoint(x: x, y: y))
        case .left:
          path.move(to: CGPoint(x: x, y: y))
          x -= arrowHeight
          y += arrowHeight
          path.addLine(to: CGPoint(x: x, y: y))
          x += arrowHeight
          y += arrowHeight
          path.addLine(to: CGPoint(x: x, y: y))
        case .right:
          path.move(to: CGPoint(x: x, y: y))
          x += arrowHeight
          y += arrowHeight
          path.addLine(to: CGPoint(x: x, y: y))
          x -= arrowHeight
          y += arrowHeight
          path.addLine(to: CGPoint(x: x, y: y))
      }
    }
  }
}

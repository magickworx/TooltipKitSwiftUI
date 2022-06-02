/*
 * FILE:	ArrowSupplement.swift
 * DESCRIPTION:	TooltipKitSwiftUI: Protocol for Preparing Balloon Arrow
 * DATE:	Tue, May 31 2022
 * UPDATED:	Tue, May 31 2022
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		https://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2022 阿部康一／Kouichi ABE (WALL)
 * LICENSE:	The 2-Clause BSD License (See LICENSE.txt)
 */

import SwiftUI

public enum ArrowDirection
{
  case up
  case down
  case left
  case right
}

public enum ArrowPosition
{
  case top
  case bottom
  case center
  case leading
  case trailing
}

public typealias TooltipArrowDirection = ArrowDirection
public typealias TooltipArrowPosition = ArrowPosition

protocol ArrowSupplement
{
  func guessArrowDirection(at point: CGPoint, with contentSize: CGSize, sourceRect: CGRect, screenBounds: CGRect) -> ArrowDirection
  func guessArrowHorizontalPosition(with contentSize: CGSize, sourceRect: CGRect, screenBounds: CGRect) -> ArrowPosition
  func guessArrowVerticalPosition(with contentSize: CGSize, sourceRect: CGRect, screenBounds: CGRect) -> ArrowPosition
}

// MARK: - Defaults
extension ArrowSupplement
{
  /*
   * +---+---+---+---+
   * |U/L| U | U |U/R|
   * +---+---+---+---+
   * |U/L| U | U |U/R|
   * +---+---+---+---+
   * |D/L| D | D |D/R|
   * +---+---+---+---+
   * |D/L| D | D |D/R|
   * +---+---+---+---+
   */
  func guessArrowDirection(at point: CGPoint, with contentSize: CGSize, sourceRect: CGRect, screenBounds: CGRect) -> ArrowDirection {
    let   origin: CGPoint = screenBounds.origin
    let     size: CGSize  = screenBounds.size
    let    width: CGFloat = size.width
    let   height: CGFloat = size.height
    let  width_2: CGFloat = width * 0.5
    let height_2: CGFloat = height * 0.5
    let  width_4: CGFloat = width_2 * 0.5

    let rectUL: CGRect = {
      let x: CGFloat = origin.x
      let y: CGFloat = origin.y
      let w: CGFloat = width_4
      let h: CGFloat = height_2
      return CGRect(x: x, y: y, width: w, height: h)
    }()

    let rectDL: CGRect = {
      let x: CGFloat = origin.x
      let y: CGFloat = height_2
      let w: CGFloat = width_4
      let h: CGFloat = height_2
      return CGRect(x: x, y: y, width: w, height: h)
    }()

    let rectU: CGRect = {
      let x: CGFloat = origin.x + width_4
      let y: CGFloat = origin.y
      let w: CGFloat = width_2
      let h: CGFloat = height_2
      return CGRect(x: x, y: y, width: w, height: h)
    }()

    let rectD: CGRect = {
      let x: CGFloat = origin.x + width_4
      let y: CGFloat = origin.y + height_2
      let w: CGFloat = width_2
      let h: CGFloat = height_2
      return CGRect(x: x, y: y, width: w, height: h)
    }()

    let rectUR: CGRect = {
      let x: CGFloat = origin.x + (width - width_4)
      let y: CGFloat = origin.y
      let w: CGFloat = width_4
      let h: CGFloat = height_2
      return CGRect(x: x, y: y, width: w, height: h)
    }()

    let rectDR: CGRect = {
      let x: CGFloat = origin.x + (width - width_4)
      let y: CGFloat = height_2
      let w: CGFloat = width_4
      let h: CGFloat = height_2
      return CGRect(x: x, y: y, width: w, height: h)
    }()

    if rectU.contains(point) { return .up }
    if rectD.contains(point) { return .down }

    if rectUL.contains(point) {
      if sourceRect.maxX + contentSize.width < width { return .left }
      return .up
    }
    if rectUR.contains(point) {
      if sourceRect.maxX < width { return .right }
      return .up
    }

    if rectDL.contains(point) {
      if sourceRect.maxX + contentSize.width < width { return .left }
      return .down
    }
    if rectDR.contains(point) {
      if sourceRect.maxX < width { return .right }
      return .down
    }

    return .up
  }

  func guessArrowHorizontalPosition(with contentSize: CGSize, sourceRect: CGRect, screenBounds: CGRect) -> ArrowPosition {
    let     size: CGSize  = screenBounds.size
    let    width: CGFloat = size.width
    let  width_2: CGFloat = width * 0.5
    let  width_4: CGFloat = width_2 * 0.5

    if sourceRect.minX > width_4 && sourceRect.maxX < (width - width_4) {
      let contentWidth_2: CGFloat = contentSize.width * 0.5
      if (sourceRect.midX + contentWidth_2) > width { return .trailing }
      if (sourceRect.midX - contentWidth_2) < 0     { return .leading }
      return .center
    }
    if (sourceRect.maxX + contentSize.width) > width { return .trailing }
    return .leading
  }

  func guessArrowVerticalPosition(with contentSize: CGSize, sourceRect: CGRect, screenBounds: CGRect) -> ArrowPosition {
    let     size: CGSize  = screenBounds.size
    let   height: CGFloat = size.height
    let height_2: CGFloat = height * 0.5
    let height_4: CGFloat = height_2 * 0.5

    if (sourceRect.minY + contentSize.height) > height {
      return .bottom
    }
    if sourceRect.minY > height_4 &&
       (sourceRect.minY + contentSize.height) < (height - height_4) {
      return .center
    }
    return .top
  }
}

/*
 * FILE:	Extension_View.swift
 * DESCRIPTION:	TooltipKitSwiftUI: Custom View Extensions
 * DATE:	Mon, May 30 2022
 * UPDATED:	Tue, May 31 2022
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		https://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2022 阿部康一／Kouichi ABE (WALL)
 * LICENSE:	The 2-Clause BSD License (See LICENSE.txt)
 */

import SwiftUI

struct Hidden: ViewModifier
{
  let hidden: Bool

  func body(content: Content) -> some View {
    if hidden { Color.clear }
    else { content }
  }
}

extension View
{
  func hidden(_ isHidden: Bool) -> some View {
    self.modifier(Hidden(hidden: isHidden))
  }
}

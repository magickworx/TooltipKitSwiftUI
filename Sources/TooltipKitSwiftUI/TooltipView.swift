/*
 * FILE:	TooltipView.swift
 * DESCRIPTION:	TooltipKitSwiftUI: Tooltip View with Balloon-style
 * DATE:	Sun, May 29 2022
 * UPDATED:	Wed, Jun  1 2022
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		https://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2022 阿部康一／Kouichi ABE (WALL)
 * LICENSE:	The 2-Clause BSD License (See LICENSE.txt)
 */

import SwiftUI

public struct TooltipView<Content>: View where Content: View
{
  private let sourceRect: CGRect
  private let screenBounds: CGRect
  private let content: Content

  private let hidden: Bool

  private let configuration: TooltipConfiguration

  public init(configuration: TooltipConfiguration, sourceRect: CGRect, screenBounds: CGRect, hidden: Bool = false, @ViewBuilder content: @escaping () -> Content) {
    self.sourceRect = sourceRect
    self.screenBounds = screenBounds
    self.hidden = hidden
    self.content = content()

    self.configuration = configuration
    self.updateConfiguration()
  }

  public init(configuration: TooltipConfiguration, at point: CGPoint, screenBounds: CGRect, hidden: Bool = false, @ViewBuilder content: @escaping () -> Content) {
    self.init(configuration: configuration, sourceRect: .init(origin: point, size: .init(width: 1, height: 1)), screenBounds: screenBounds, hidden: hidden, content: content)
  }

  public var body: some View {
    if hidden { Color.clear }
    else      { tooltipBody() }
  }

  @ViewBuilder
  private func tooltipBody() -> some View {
    GeometryReader { proxy in
      VStack {
        self.content
      }
      .padding(.all, 2)
      .position(configuration.contentPosition)
      .frame(width: configuration.contentSize.width, height: configuration.contentSize.height)
      .background {
        RoundedRectangle(cornerRadius: configuration.contentCornerRadius)
          .fill(Color.white)
          .offset(configuration.contentOffset)
      }
    }
    .background(alignment: .center) {
      BalloonShape(configuration: configuration)
        .frame(width: configuration.balloonSize.width, height: configuration.balloonSize.height)
        .foregroundColor(configuration.tintColor)
    }
    .frame(width: configuration.balloonSize.width, height: configuration.balloonSize.height)
    .position(sourceRect.origin)
    .offset(configuration.arrowOffset())
  }
}

extension TooltipView: ArrowSupplement
{
  private func updateConfiguration() {
    guard configuration.isAutoConfigurationEnabled else { return }

    let point = sourceRect.origin

    let direction = guessArrowDirection(at: point, with: configuration.contentSize, sourceRect: sourceRect, screenBounds: screenBounds)

    let position: TooltipArrowPosition = {
      switch direction {
        case .up, .down:
          return guessArrowHorizontalPosition(with: configuration.contentSize, sourceRect: sourceRect, screenBounds: screenBounds)
        case .left, .right:
          return guessArrowVerticalPosition(with: configuration.contentSize, sourceRect: sourceRect, screenBounds: screenBounds)
      }
    }()

    configuration.updateArrowDirection(direction)
    configuration.updateArrowPosition(position)
  }
}

// MARK: - Preview
#if DEBUG
private struct PreviewContentView: View
{
  @State private var status: String = "b(^_^)"

  @State private var tapLocation: CGPoint = .zero
  @State private var dragLocation: CGPoint = .zero

  @State private var isHidden: Bool = true

  private let configuration: TooltipConfiguration = .init(contentSize: CGSize(width: 200, height: 100))

  private var tap: some Gesture {
    let tap = TapGesture().onEnded { _ in
      tapLocation = dragLocation
      self.status = String(format: "(%.1f,%.1f)",tapLocation.x,tapLocation.y)
      isHidden = false
    }
    return DragGesture(minimumDistance: 0, coordinateSpace: .named("screen")).onChanged { value in
      dragLocation = value.location
    }.sequenced(before: tap)
  }

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        VStack {
          Rectangle()
            .foregroundColor(.teal)
            .overlay(alignment: .topTrailing) {
              Text(status).font(.title)
            }
        }
        .frame(width: proxy.size.width, height: proxy.size.height)
        TooltipView(configuration: configuration, at: tapLocation, screenBounds: proxy.frame(in: .named("screen")), hidden: isHidden) {
          Text("Balloon Tips").font(.title)
          Text("The direction and position of the arrows are set automatically.")
          Text(String(format: "(%.1f, %.1f)", tapLocation.x, tapLocation.y))
        }
      }
      .frame(width: proxy.size.width, height: proxy.size.height)
      .coordinateSpace(name: "screen")
      .gesture(tap)
    }
    .background(Color.mint)
  }
}

struct TooltipView_Previews: PreviewProvider
{
  static var previews: some View {
    PreviewContentView()
  }
}
#endif

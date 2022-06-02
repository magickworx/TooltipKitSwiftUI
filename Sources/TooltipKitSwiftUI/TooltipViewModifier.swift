/*
 * FILE:	TooltipViewModifier.swift
 * DESCRIPTION:	TooltipKitSwiftUI: Custom ViewModifier to Display Tooltip
 * DATE:	Mon, May 30 2022
 * UPDATED:	Thu, Jun  2 2022
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		https://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2022 阿部康一／Kouichi ABE (WALL)
 * LICENSE:	The 2-Clause BSD License (See LICENSE.txt)
 */

import SwiftUI

public struct Tooltip<TooltipContent>: ViewModifier where TooltipContent: View
{
  private let configuration: TooltipConfiguration
  private let hidden: Bool
  private let content: TooltipContent

  public init(configuration: TooltipConfiguration, hidden: Bool, @ViewBuilder content: @escaping () -> TooltipContent) {
    self.configuration = configuration
    self.hidden = hidden
    self.content = content()
  }

  private func tooltipBody(_ geometry: GeometryProxy) -> some View {
    GeometryReader { proxy in
      VStack {
        self.content
#if DEBUG_GEOMETRY
        Text(String(format: "(%.1f, %.1f)", geometry.frame(in: .global).origin.x, geometry.frame(in: .global).origin.y))
        Text(String(format: "(%.1f x %.1f)", geometry.size.width, geometry.size.height))
        Text(String(format: "(%.1f, %.1f)", configuration.arrowOffset().width, configuration.arrowOffset().height))
#endif
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
    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
    .offset(configuration.arrowOffset())
  }

  /*
   * How to display a SwiftUI View frame size for debugging
   * https://swiftwombat.com/how-to-display-a-view-frame-size-for-debugging/
   */
  // XXX: 呼び出し元の frame を取得する仕組み
  private func overlay(for geometry: GeometryProxy) -> some View {
    ZStack {
      tooltipBody(updateConfiguration(with: geometry))
        .offset(balloonOffset(with: geometry))
    }
  }

  public func body(content: Content) -> some View {
    content
      .overlay(hidden ? nil : GeometryReader(content: overlay(for:)))
  }
}

extension Tooltip: ArrowSupplement
{
  private func updateConfiguration(with geometry: GeometryProxy) -> GeometryProxy {
    guard configuration.isAutoConfigurationEnabled else { return  geometry }

    let origin: CGPoint = geometry.frame(in: .global).origin
    let sourceRect: CGRect = .init(origin: origin, size: geometry.size)
    let screenBounds = UIScreen.main.bounds
    let point: CGPoint = {
      var point = origin
      point.x += geometry.size.width * 0.5
      point.y += geometry.size.height * 0.5
      return point
    }()

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

    return geometry
  }

  // XXX: 計算式は実地計測結果から求めた
  private func balloonOffset(with geometry: GeometryProxy) -> CGSize {
    var offset: CGSize = .zero
    let arrowHeight_2 = configuration.arrowHeight * 0.5
    let size = geometry.size
    let h_2 = size.height * 0.5
    let w_2 = size.width * 0.5

    switch configuration.arrowDirection {
      case    .up: offset.height += (h_2 + arrowHeight_2)
      case  .down: offset.height -= (h_2 - arrowHeight_2)
      case  .left: offset.width  += (w_2 + arrowHeight_2)
      case .right: offset.width  -= (w_2 - arrowHeight_2)
    }
    return offset
  }
}

extension View
{
  public func tooltip<TooltipContent: View>(configuration: TooltipConfiguration, hidden: Bool = true, @ViewBuilder content: @escaping () -> TooltipContent) -> some View {
    self.modifier(Tooltip(configuration: configuration, hidden: hidden, content: content))
  }
}


// MARK: - Preview
#if DEBUG
private struct PreviewContentView: View
{
  private enum Hearts: Int
  {
    case none
    case bolt
    case arrowUp
    case clockwise
    case arrowDown

    var color: Color {
      switch self {
        case .none:      return .gray
        case .bolt:      return .pink
        case .arrowUp:   return .indigo
        case .clockwise: return .blue
        case .arrowDown: return .orange
      }
    }
  }
  @State private var selection: Hearts = .none

  private let configuration: TooltipConfiguration = .small

  private let helloConfiguration: TooltipConfiguration = .init(contentSize: CGSize(width: 160, height: 70), tintColor: .blue)

  @State private var isPowered: Bool = false

  var body: some View {
    VStack {
      HStack {
        Spacer()
        Button {
          self.isPowered.toggle()
        } label: {
          Image(systemName: "power")
            .resizable()
            .frame(width: 36, height: 36)
        }
        .foregroundColor(isPowered ? .green : .red)
        .tooltip(configuration: .small.tintColor(.green), hidden: !isPowered) {
          Text("Power On")
        }
        .padding()
      }
      HStack {
        Spacer()
        Image(systemName: "bolt.heart.fill")
          .resizable()
          .frame(width: 64, height: 64)
          .foregroundStyle(Color.yellow,Color.pink)
          .tooltip(configuration: configuration.tintColor(selection.color), hidden: (selection != .bolt)) {
            Text("Heart Breaker")
              .foregroundColor(selection.color)
          }
          .onTapGesture {
            self.selection = (selection == .bolt ? .none : .bolt)
          }
          .zIndex(selection == .bolt ? 1 : 0)
        Spacer()
      }
      Spacer()
      HStack {
        Rectangle()
          .frame(width: 128, height: 128)
          .foregroundColor(.yellow)
          .tooltip(configuration: helloConfiguration, hidden: false) {
            Text("Hello TooltipKit").font(.title3)
            Text("Tap the heart icon to display a tool tip.")
              .lineLimit(nil)
          }
      }
      Spacer()
      HStack {
        Spacer()
        Image(systemName: "arrow.up.heart.fill")
          .resizable()
          .frame(width: 64, height: 64)
          .foregroundStyle(Color.white,Color.indigo)
          .tooltip(configuration: configuration.tintColor(selection.color), hidden: (selection != .arrowUp)) {
            Text("Heart Up")
              .foregroundColor(selection.color)
          }
          .onTapGesture {
            self.selection = (selection == .arrowUp ? .none : .arrowUp)
          }
          .zIndex(selection == .arrowUp ? 1 : 0)
        Spacer()
        Image(systemName: "arrow.clockwise.heart.fill")
          .resizable()
          .frame(width: 64, height: 64)
          .foregroundStyle(Color.white,Color.blue)
          .tooltip(configuration: configuration.tintColor(selection.color), hidden: (selection != .clockwise)) {
            Text("Heart Clockwise")
              .foregroundColor(selection.color)
          }
          .onTapGesture {
            self.selection = (selection == .clockwise ? .none : .clockwise)
          }
          .zIndex(selection == .clockwise ? 1 : 0)
        Spacer()
        Image(systemName: "arrow.down.heart.fill")
          .resizable()
          .frame(width: 64, height: 64)
          .foregroundStyle(Color.white,Color.orange)
          .tooltip(configuration: configuration.tintColor(selection.color), hidden: (selection != .arrowDown)) {
            Text("Heart Down")
              .foregroundColor(selection.color)
          }
          .onTapGesture {
            self.selection = (selection == .arrowDown ? .none : .arrowDown)
          }
          .zIndex(selection == .arrowDown ? 1 : 0)
        Spacer()
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.teal)
  }
}

struct Tooltip_Previews: PreviewProvider
{
  static var previews: some View {
    PreviewContentView()
  }
}
#endif

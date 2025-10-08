////
////  TertiaryPositiveButtonStyle 2.swift
////  EvelityUI
////
////  Created by Léa Dukaez on 09/06/2025.
////
//
//import SwiftUI
//import EvelityImages
//
//public struct TextTertiaryNegativeButtonStyle: ButtonStyle {
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .textOnlyNegativeTertiary(size: size)
//    }
//}
//
//extension ButtonStyle where Self == TextTertiaryNegativeButtonStyle {
//    public static func tertiaryNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct LeftIconTertiaryNegativeButtonStyle: ButtonStyle {
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.leftIconNegativeTertiary(size: size))
//    }
//}
//
//extension ButtonStyle where Self == LeftIconTertiaryNegativeButtonStyle {
//    public static func leftIconTertiaryNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconTertiaryNegativeButtonStyle: ButtonStyle {
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.rightIconNegativeTertiary(size: size))
//    }
//}
//
//extension ButtonStyle where Self == RightIconTertiaryNegativeButtonStyle {
//    public static func rightIconTertiaryNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct IconOnlyTertiaryNegativeButtonStyle: PrimitiveButtonStyle {
//    var size: ButtonSizeStyle
//
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.iconOnlyTertiaryNegative(size: size))
//    }
//}
//
//extension PrimitiveButtonStyle where Self == IconOnlyTertiaryNegativeButtonStyle {
//    public static func iconOnlyTertiaryNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//#Preview("Right icon") {
//    Button(
//        title: "rightIconTertiaryNegative small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryNegative(size: .small))
//    
//    Button(
//        title: "rightIconTertiaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryNegative(size: .medium))
//    
//    Button(
//        title: "rightIconTertiaryNegative large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryNegative(size: .large))
//    
//    Button(
//        title: "rightIconTertiaryNegative xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryNegative(size: .xLarge()))
//    
//    Button(
//        title: "rightIconTertiaryNegative small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryNegative(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconTertiaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryNegative(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconTertiaryNegative large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryNegative(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconTertiaryNegative xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryNegative(size: .xLarge()))
//    .disabled(true)
//
//}
//
//#Preview("Left icon") {
//    Button(
//        title: "leftIconTertiaryNegative small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryNegative(size: .small))
//    
//    Button(
//        title: "leftIconTertiaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryNegative(size: .medium))
//
//    Button(
//        title: "leftIconTertiaryNegative large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryNegative(size: .large))
//    
//    Button(
//        title: "leftIconTertiaryNegative xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryNegative(size: .xLarge()))
//    
//    Button(
//        title: "leftIconTertiaryNegative small disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryNegative(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconTertiaryNegative medium disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryNegative(size: .medium))
//    .disabled(true)
//
//    Button(
//        title: "leftIconTertiaryNegative large disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryNegative(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconTertiaryNegative xLarge disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryNegative(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Text only") {
//    
//    Button("textOnlyTertiaryNegative small", action: {})
//    .buttonStyle(.tertiaryNegative(size: .small))
//    
//    Button("textOnlyTertiaryNegative medium", action: {})
//    .buttonStyle(.tertiaryNegative(size: .medium))
//    
//    Button("textOnlyTertiaryNegative large", action: {})
//    .buttonStyle(.tertiaryNegative(size: .large))
//    
//    Button("textOnlyTertiaryNegative xLarge", action: {})
//    .buttonStyle(.tertiaryNegative(size: .xLarge()))
//    
//    Button("textOnlyTertiaryNegative small disable", action: {})
//    .buttonStyle(.tertiaryNegative(size: .small))
//    .disabled(true)
//    
//    Button("textOnlyTertiaryNegative medium", action: {})
//    .buttonStyle(.tertiaryNegative(size: .medium))
//    .disabled(true)
//    
//    Button("textOnlyTertiaryNegative large disable", action: {})
//    .buttonStyle(.tertiaryNegative(size: .large))
//    .disabled(true)
//    
//    Button("textOnlyTertiaryNegative xLarge disable", action: {})
//    .buttonStyle(.tertiaryNegative(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Icon only") {
//    
//    Button(
//        title: "iconOnlyTertiaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyTertiaryNegative(size: .medium))
//    
//    Button(
//        title: "iconOnlyTertiaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyTertiaryNegative(size: .xLarge(shouldFitFrameToLabel: true)))
//    
//    Button(
//        title: "iconOnlyTertiaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyTertiaryNegative(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "iconOnlyTertiaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyTertiaryNegative(size: .xLarge(shouldFitFrameToLabel: true)))
//    .disabled(true)
//}

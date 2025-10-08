////
////  EvelityUI
////
////  Created by Léa Dukaez on 09/06/2025.
////
//
//import SwiftUI
//import EvelityImages
//
//public struct TextTertiaryDefaultButtonStyle: ButtonStyle {
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .textOnlyTertiary(size: size)
//    }
//}
//
//extension ButtonStyle where Self == TextTertiaryDefaultButtonStyle {
//    public static func tertiary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct LeftIconTertiaryDefaultButtonStyle: ButtonStyle {
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.leftIconTertiary(size: size))
//    }
//}
//
//extension ButtonStyle where Self == LeftIconTertiaryDefaultButtonStyle {
//    public static func leftIconTertiary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconTertiaryDefaultButtonStyle: ButtonStyle {
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.rightIconTertiary(size: size))
//    }
//}
//
//extension ButtonStyle where Self == RightIconTertiaryDefaultButtonStyle {
//    public static func rightIconTertiary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct IconOnlyTertiaryDefaultButtonStyle: PrimitiveButtonStyle {
//    var size: ButtonSizeStyle
//
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.iconOnlyTertiary(size: size))
//    }
//}
//
//extension PrimitiveButtonStyle where Self == IconOnlyTertiaryDefaultButtonStyle {
//    public static func iconOnlyTertiary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//#Preview("Right icon") {
//    Button(
//        title: "rightIconTertiaryPositive small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryPositive(size: .small))
//    
//    Button(
//        title: "rightIconTertiaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryPositive(size: .medium))
//    
//    Button(
//        title: "rightIconTertiaryPositive large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryPositive(size: .large))
//    
//    Button(
//        title: "rightIconTertiaryPositive xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryPositive(size: .xLarge()))
//    
//    Button(
//        title: "rightIconTertiaryPositive small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryPositive(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconTertiaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryPositive(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconTertiaryPositive large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryPositive(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconTertiaryPositive xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconTertiaryPositive(size: .xLarge()))
//    .disabled(true)
//
//}
//
//#Preview("Left icon") {
//    Button(
//        title: "leftIconTertiaryPositive small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryPositive(size: .small))
//    
//    Button(
//        title: "leftIconTertiaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryPositive(size: .medium))
//
//    Button(
//        title: "leftIconTertiaryPositive large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryPositive(size: .large))
//    
//    Button(
//        title: "leftIconTertiaryPositive xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryPositive(size: .xLarge()))
//    
//    Button(
//        title: "leftIconTertiaryPositive small disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryPositive(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconTertiaryPositive medium disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryPositive(size: .medium))
//    .disabled(true)
//
//    Button(
//        title: "leftIconTertiaryPositive large disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryPositive(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconTertiaryPositive xLarge disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconTertiaryPositive(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Text only") {
//    
//    Button("textOnlyTertiaryPositive small", action: {})
//    .buttonStyle(.tertiaryPositive(size: .small))
//    
//    Button("textOnlyTertiaryPositive medium", action: {})
//    .buttonStyle(.tertiaryPositive(size: .medium))
//    
//    Button("textOnlyTertiaryPositive large", action: {})
//    .buttonStyle(.tertiaryPositive(size: .large))
//    
//    Button("textOnlyTertiaryPositive xLarge", action: {})
//    .buttonStyle(.tertiaryPositive(size: .xLarge()))
//    
//    Button("textOnlyTertiaryPositive small disable", action: {})
//    .buttonStyle(.tertiaryPositive(size: .small))
//    .disabled(true)
//    
//    Button("textOnlyTertiaryPositive medium", action: {})
//    .buttonStyle(.tertiaryPositive(size: .medium))
//    .disabled(true)
//    
//    Button("textOnlyTertiaryPositive large disable", action: {})
//    .buttonStyle(.tertiaryPositive(size: .large))
//    .disabled(true)
//    
//    Button("textOnlyTertiaryPositive xLarge disable", action: {})
//    .buttonStyle(.tertiaryPositive(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Icon only") {
//    
//    Button(
//        title: "iconOnlyTertiaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyTertiaryPositive(size: .medium))
//    
//    Button(
//        title: "iconOnlyTertiaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyTertiaryPositive(size: .xLarge(shouldFitFrameToLabel: true)))
//    
//    Button(
//        title: "iconOnlyTertiaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyTertiaryPositive(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "iconOnlyTertiaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyTertiaryPositive(size: .xLarge(shouldFitFrameToLabel: true)))
//    .disabled(true)
//}

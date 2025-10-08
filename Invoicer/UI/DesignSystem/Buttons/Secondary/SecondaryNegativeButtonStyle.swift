////
////  EvelityUI
////
////  Created by Léa Dukaez on 09/06/2025.
////
//
//import SwiftUI
//import EvelityImages
//
//public struct TextSecondaryNegativeButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .textOnlyNegativeSecondary(size: size)
//            .background(backgroundColor())
//            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
//            .overlay(
//                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
//                    .strokeBorder(borderColor(), lineWidth: size.isXLarge ? 3 : 1)
//            )
//            .shadow(.extraSmall)
//            .hapticFeedback(.impact(.light), configuration: configuration)
//    }
//    
//    private func backgroundColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.backgroundElevated : NewEvelityColors.Colors.backgroundNeutral
//    }
//    
//    private func borderColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.borderInteractive : NewEvelityColors.Colors.backgroundNeutral
//    }
//}
//
//extension PrimitiveButtonStyle where Self == TextSecondaryNegativeButtonStyle {
//    public static func secondaryNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct LeftIconSecondaryNegativeButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.leftIconNegativeSecondary(size: size))
//            .background(backgroundColor())
//            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
//            .overlay(
//                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
//                    .strokeBorder(borderColor(), lineWidth: size.isXLarge ? 3 : 1)
//            )
//            .shadow(.extraSmall)
//            .hapticFeedback(.impact(.light), configuration: configuration)
//    }
//    
//    private func backgroundColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.backgroundElevated : NewEvelityColors.Colors.backgroundNeutral
//    }
//    
//    private func borderColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.borderInteractive : NewEvelityColors.Colors.backgroundNeutral
//    }
//}
//
//extension PrimitiveButtonStyle where Self == LeftIconSecondaryNegativeButtonStyle {
//    public static func leftIconSecondaryNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconSecondaryNegativeButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.rightIconNegativeSecondary(size: size))
//            .background(backgroundColor())
//            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
//            .overlay(
//                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
//                    .strokeBorder(borderColor(), lineWidth: size.isXLarge ? 3 : 1)
//            )
//            .shadow(.extraSmall)
//            .hapticFeedback(.impact(.light), configuration: configuration)
//    }
//    
//    private func backgroundColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.backgroundElevated : NewEvelityColors.Colors.backgroundNeutral
//    }
//    
//    private func borderColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.borderInteractive : NewEvelityColors.Colors.backgroundNeutral
//    }
//}
//
//extension PrimitiveButtonStyle where Self == RightIconSecondaryNegativeButtonStyle {
//    public static func rightIconSecondaryNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct IconOnlySecondaryNegativeButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.iconOnlySecondaryNegative(size: size))
//            .background(backgroundColor)
//            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
//            .overlay(
//                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
//                    .strokeBorder(borderColor, lineWidth: strokeBorder)
//            )
//            .shadow(.extraSmall)
//            .hapticFeedback(.impact(.medium), configuration: configuration)
//    }
//    
//    private var backgroundColor: Color {
//        isEnabled ? NewEvelityColors.Colors.backgroundElevated : NewEvelityColors.Colors.backgroundNeutral
//    }
//    
//    private var borderColor: Color {
//        isEnabled ? NewEvelityColors.Colors.borderInteractive : NewEvelityColors.Colors.backgroundNeutral
//    }
//    
//    private var strokeBorder: CGFloat {
//        let isXLarge: CGFloat = size.isXLarge ? 3 : 1
//        return isEnabled ? isXLarge : 0
//    }
//}
//
//extension PrimitiveButtonStyle where Self == IconOnlySecondaryNegativeButtonStyle {
//    public static func iconOnlySecondaryNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//#Preview("Right icon") {
//    Button(
//        title: "rightIconSecondaryNegative small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryNegative(size: .small))
//    
//    Button(
//        title: "rightIconSecondaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryNegative(size: .medium))
//    
//    Button(
//        title: "rightIconSecondaryNegative large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryNegative(size: .large))
//    
//    Button(
//        title: "rightIconSecondaryNegative xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryNegative(size: .xLarge()))
//    
//    Button(
//        title: "rightIconSecondaryNegative small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryNegative(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconSecondaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryNegative(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconSecondaryNegative large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryNegative(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconSecondaryNegative xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryNegative(size: .xLarge()))
//    .disabled(true)
//
//}
//
//#Preview("Left icon") {
//    Button(
//        title: "leftIconSecondaryNegative small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryNegative(size: .small))
//    
//    Button(
//        title: "leftIconSecondaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryNegative(size: .medium))
//
//    Button(
//        title: "leftIconSecondaryNegative large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryNegative(size: .large))
//    
//    Button(
//        title: "leftIconSecondaryNegative xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryNegative(size: .xLarge()))
//    
//    Button(
//        title: "leftIconSecondaryNegative small disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryNegative(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconSecondaryNegative medium disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryNegative(size: .medium))
//    .disabled(true)
//
//    Button(
//        title: "leftIconSecondaryNegative large disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryNegative(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconSecondaryNegative xLarge disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryNegative(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Text only") {
//    
//    Button("textOnlySecondaryNegative small", action: {})
//    .buttonStyle(.secondaryNegative(size: .small))
//    
//    Button("textOnlySecondaryNegative medium", action: {})
//    .buttonStyle(.secondaryNegative(size: .medium))
//    
//    Button("textOnlySecondaryNegative large", action: {})
//    .buttonStyle(.secondaryNegative(size: .large))
//    
//    Button("textOnlySecondaryNegative xLarge", action: {})
//    .buttonStyle(.secondaryNegative(size: .xLarge()))
//    
//    Button("textOnlySecondaryNegative small disable", action: {})
//    .buttonStyle(.secondaryNegative(size: .small))
//    .disabled(true)
//    
//    Button("textOnlySecondaryNegative medium", action: {})
//    .buttonStyle(.secondaryNegative(size: .medium))
//    .disabled(true)
//    
//    Button("textOnlySecondaryNegative large disable", action: {})
//    .buttonStyle(.secondaryNegative(size: .large))
//    .disabled(true)
//    
//    Button("textOnlySecondaryNegative xLarge disable", action: {})
//    .buttonStyle(.secondaryNegative(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Icon only") {
//    
//    Button(
//        title: "iconOnlySecondaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlySecondaryNegative(size: .medium))
//    
//    Button(
//        title: "iconOnlySecondaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlySecondaryNegative(size: .xLarge(shouldFitFrameToLabel: true)))
//    
//    Button(
//        title: "iconOnlySecondaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlySecondaryNegative(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "iconOnlySecondaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlySecondaryNegative(size: .xLarge(shouldFitFrameToLabel: true)))
//    .disabled(true)
//}

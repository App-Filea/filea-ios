////
////  EvelityUI
////
////  Created by Léa Dukaez on 09/06/2025.
////
//
//import SwiftUI
//import EvelityImages
//
//public struct TextSecondaryPositiveButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .textOnlyPositiveSecondary(size: size)
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
//extension PrimitiveButtonStyle where Self == TextSecondaryPositiveButtonStyle {
//    public static func secondaryPositive(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct LeftIconSecondaryPositiveButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.leftIconPositiveSecondary(size: size))
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
//extension PrimitiveButtonStyle where Self == LeftIconSecondaryPositiveButtonStyle {
//    public static func leftIconSecondaryPositive(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconSecondaryPositiveButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.rightIconPositiveSecondary(size: size))
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
//extension PrimitiveButtonStyle where Self == RightIconSecondaryPositiveButtonStyle {
//    public static func rightIconSecondaryPositive(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct IconOnlySecondaryPositiveButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.iconOnlySecondaryPositive(size: size))
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
//extension PrimitiveButtonStyle where Self == IconOnlySecondaryPositiveButtonStyle {
//    public static func iconOnlySecondaryPositive(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//#Preview("Right icon") {
//    Button(
//        title: "rightIconSecondaryPositive small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryPositive(size: .small))
//    
//    Button(
//        title: "rightIconSecondaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryPositive(size: .medium))
//    
//    Button(
//        title: "rightIconSecondaryPositive large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryPositive(size: .large))
//    
//    Button(
//        title: "rightIconSecondaryPositive xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryPositive(size: .xLarge()))
//    
//    Button(
//        title: "rightIconSecondaryPositive small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryPositive(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconSecondaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryPositive(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconSecondaryPositive large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryPositive(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconSecondaryPositive xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondaryPositive(size: .xLarge()))
//    .disabled(true)
//
//}
//
//#Preview("Left icon") {
//    Button(
//        title: "leftIconSecondaryPositive small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryPositive(size: .small))
//    
//    Button(
//        title: "leftIconSecondaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryPositive(size: .medium))
//
//    Button(
//        title: "leftIconSecondaryPositive large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryPositive(size: .large))
//    
//    Button(
//        title: "leftIconSecondaryPositive xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryPositive(size: .xLarge()))
//    
//    Button(
//        title: "leftIconSecondaryPositive small disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryPositive(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconSecondaryPositive medium disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryPositive(size: .medium))
//    .disabled(true)
//
//    Button(
//        title: "leftIconSecondaryPositive large disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryPositive(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconSecondaryPositive xLarge disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondaryPositive(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Text only") {
//    
//    Button("textOnlySecondaryPositive small", action: {})
//    .buttonStyle(.secondaryPositive(size: .small))
//    
//    Button("textOnlySecondaryPositive medium", action: {})
//    .buttonStyle(.secondaryPositive(size: .medium))
//    
//    Button("textOnlySecondaryPositive large", action: {})
//    .buttonStyle(.secondaryPositive(size: .large))
//    
//    Button("textOnlySecondaryPositive xLarge", action: {})
//    .buttonStyle(.secondaryPositive(size: .xLarge()))
//    
//    Button("textOnlySecondaryPositive small disable", action: {})
//    .buttonStyle(.secondaryPositive(size: .small))
//    .disabled(true)
//    
//    Button("textOnlySecondaryPositive medium", action: {})
//    .buttonStyle(.secondaryPositive(size: .medium))
//    .disabled(true)
//    
//    Button("textOnlySecondaryPositive large disable", action: {})
//    .buttonStyle(.secondaryPositive(size: .large))
//    .disabled(true)
//    
//    Button("textOnlySecondaryPositive xLarge disable", action: {})
//    .buttonStyle(.secondaryPositive(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Icon only") {
//    
//    Button(
//        title: "iconOnlySecondaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlySecondaryPositive(size: .medium))
//    
//    Button(
//        title: "iconOnlySecondaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlySecondaryPositive(size: .xLarge(shouldFitFrameToLabel: true)))
//    
//    Button(
//        title: "iconOnlySecondaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlySecondaryPositive(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "iconOnlySecondaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlySecondaryPositive(size: .xLarge(shouldFitFrameToLabel: true)))
//    .disabled(true)
//}

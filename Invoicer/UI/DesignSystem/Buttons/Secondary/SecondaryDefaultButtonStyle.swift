////
////  EvelityUI
////
////  Created by Léa Dukaez on 09/06/2025.
////
//
//import SwiftUI
//import EvelityImages
//
//public struct TextSecondaryDefaultButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .textOnlySecondary(size: size)
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
//extension PrimitiveButtonStyle where Self == TextSecondaryDefaultButtonStyle {
//    public static func secondary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct LeftIconSecondaryDefaultButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.leftIconSecondary(size: size))
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
//extension PrimitiveButtonStyle where Self == LeftIconSecondaryDefaultButtonStyle {
//    public static func leftIconSecondary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconSecondaryDefaultButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.rightIconSecondary(size: size))
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
//extension PrimitiveButtonStyle where Self == RightIconSecondaryDefaultButtonStyle {
//    public static func rightIconSecondary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct IconOnlySecondaryDefaultButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.iconOnlySecondary(size: size))
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
//extension PrimitiveButtonStyle where Self == IconOnlySecondaryDefaultButtonStyle {
//    public static func iconOnlySecondary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//#Preview("Right icon") {
//    Button(
//        title: "rightIconSecondary small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondary(size: .small))
//    
//    Button(
//        title: "rightIconSecondary medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondary(size: .medium))
//    
//    Button(
//        title: "rightIconSecondary large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondary(size: .large))
//    
//    Button(
//        title: "rightIconSecondary xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondary(size: .xLarge()))
//    
//    Button(
//        title: "rightIconSecondary small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondary(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconSecondary medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondary(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconSecondary large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondary(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconSecondary xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconSecondary(size: .xLarge()))
//    .disabled(true)
//
//}
//
//#Preview("Left icon") {
//    Button(
//        title: "leftIconSecondary small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondary(size: .small))
//    
//    Button(
//        title: "leftIconSecondary medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondary(size: .medium))
//
//    Button(
//        title: "leftIconSecondary large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondary(size: .large))
//    
//    Button(
//        title: "leftIconSecondary xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondary(size: .xLarge()))
//    
//    Button(
//        title: "leftIconSecondary small disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondary(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconSecondary medium disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondary(size: .medium))
//    .disabled(true)
//
//    Button(
//        title: "leftIconSecondary large disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondary(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconSecondary xLarge disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconSecondary(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Text only") {
//    
//    Button("textOnlySecondary small", action: {})
//    .buttonStyle(.secondary(size: .small))
//    
//    Button("textOnlySecondary medium", action: {})
//    .buttonStyle(.secondary(size: .medium))
//    
//    Button("textOnlySecondary large", action: {})
//    .buttonStyle(.secondary(size: .large))
//    
//    Button("textOnlySecondary xLarge", action: {})
//    .buttonStyle(.secondary(size: .xLarge()))
//    
//    Button("textOnlySecondary small disable", action: {})
//    .buttonStyle(.secondary(size: .small))
//    .disabled(true)
//    
//    Button("textOnlySecondary medium", action: {})
//    .buttonStyle(.secondary(size: .medium))
//    .disabled(true)
//    
//    Button("textOnlySecondary large disable", action: {})
//    .buttonStyle(.secondary(size: .large))
//    .disabled(true)
//    
//    Button("textOnlySecondary xLarge disable", action: {})
//    .buttonStyle(.secondary(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Icon only") {
//    
//    Button(
//        title: "iconOnlySecondary medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlySecondary(size: .medium))
//    
//    Button(
//        title: "iconOnlySecondary medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlySecondary(size: .xLarge(shouldFitFrameToLabel: true)))
//    
//    Button(
//        title: "iconOnlySecondary medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlySecondary(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "iconOnlySecondary medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlySecondary(size: .xLarge(shouldFitFrameToLabel: true)))
//    .disabled(true)
//}

////
////  EvelityUI
////
////  Created by Léa Dukaez on 09/06/2025.
////
//
//import SwiftUI
//
//public struct TextPrimaryPositiveButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .textOnlyPositivePrimary(size: size)
//            .background(backgroundColor())
//            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
//            .overlay(
//                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
//                    .strokeBorder(NewEvelityColors.Colors.borderNeutral, lineWidth: size.isXLarge ? 3 : 0)
//            )
//            .shadow(.extraSmall)
//            .hapticFeedback(.impact(.medium), configuration: configuration)
//    }
//    
//    private func backgroundColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.sentimentPositive : NewEvelityColors.Colors.backgroundNeutral
//    }
//}
//
//extension PrimitiveButtonStyle where Self == TextPrimaryPositiveButtonStyle {
//    public static func primaryPositive(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct LeftIconPrimaryPositiveButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.leftIconPositivePrimary(size: size))
//            .background(backgroundColor())
//            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
//            .overlay(
//                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
//                    .strokeBorder(NewEvelityColors.Colors.borderNeutral, lineWidth: size.isXLarge ? 3 : 0)
//            )
//            .shadow(.extraSmall)
//            .hapticFeedback(.impact(.medium), configuration: configuration)
//    }
//    
//    private func backgroundColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.sentimentPositive : NewEvelityColors.Colors.backgroundNeutral
//    }
//}
//
//extension PrimitiveButtonStyle where Self == LeftIconPrimaryPositiveButtonStyle {
//    public static func leftIconPrimaryPositive(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconPrimaryPositiveButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.rightIconPositivePrimary(size: size))
//            .background(backgroundColor())
//            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
//            .overlay(
//                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
//                    .strokeBorder(NewEvelityColors.Colors.borderNeutral, lineWidth: size.isXLarge ? 3 : 0)
//            )
//            .shadow(.extraSmall)
//            .hapticFeedback(.impact(.medium), configuration: configuration)
//    }
//    
//    private func backgroundColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.sentimentPositive : NewEvelityColors.Colors.backgroundNeutral
//    }
//}
//
//extension PrimitiveButtonStyle where Self == RightIconPrimaryPositiveButtonStyle {
//    public static func rightIconPrimaryPositive(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct IconOnlyPrimaryPositiveButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.iconOnlyPositivePrimary(size: size))
//            .background(backgroundColor)
//            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
//            .overlay(
//                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
//                    .strokeBorder(NewEvelityColors.Colors.borderNeutral, lineWidth: size.isXLarge && isEnabled ? 3 : 0)
//            )
//            .shadow(.extraSmall)
//            .hapticFeedback(.impact(.medium), configuration: configuration)
//    }
//    
//    private var backgroundColor: Color {
//        isEnabled ? NewEvelityColors.Colors.sentimentPositive : NewEvelityColors.Colors.backgroundNeutral
//    }
//}
//
//extension PrimitiveButtonStyle where Self == IconOnlyPrimaryPositiveButtonStyle {
//    public static func iconOnlyPrimaryPositive(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//import EvelityImages
//
//#Preview("Right icon") {
//    Button(
//        title: "rightIconPrimaryPositive small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryPositive(size: .small))
//    
//    Button(
//        title: "rightIconPrimaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryPositive(size: .medium))
//    
//    Button(
//        title: "rightIconPrimaryPositive large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryPositive(size: .large))
//    
//    Button(
//        title: "rightIconPrimaryPositive xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryPositive(size: .xLarge()))
//    
//    Button(
//        title: "rightIconPrimaryPositive small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryPositive(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconPrimaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryPositive(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconPrimaryPositive large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryPositive(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconPrimaryPositive xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryPositive(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Left icon") {
//    Button(
//        title: "leftIconPrimaryPositive small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryPositive(size: .small))
//    
//    Button(
//        title: "leftIconPrimaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryPositive(size: .medium))
//
//    Button(
//        title: "leftIconPrimaryPositive large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryPositive(size: .large))
//    
//    Button(
//        title: "leftIconPrimaryPositive xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryPositive(size: .xLarge()))
//    
//    Button(
//        title: "leftIconPrimaryPositive small disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryPositive(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconPrimaryPositive medium disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryPositive(size: .medium))
//    .disabled(true)
//
//    Button(
//        title: "leftIconPrimaryPositive large disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryPositive(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconPrimaryPositive xLarge disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryPositive(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Text only") {
//    
//    Button("textOnlyPrimaryPositive small", action: {})
//    .buttonStyle(.primaryPositive(size: .small))
//    
//    Button("textOnlyPrimaryPositive medium", action: {})
//    .buttonStyle(.primaryPositive(size: .medium))
//    
//    Button("textOnlyPrimaryPositive large", action: {})
//    .buttonStyle(.primaryPositive(size: .large))
//    
//    Button("textOnlyPrimaryPositive xLarge", action: {})
//    .buttonStyle(.primaryPositive(size: .xLarge()))
//    
//    Button("textOnlyPrimaryPositive small disable", action: {})
//    .buttonStyle(.primaryPositive(size: .small))
//    .disabled(true)
//    
//    Button("textOnlyPrimaryPositive medium", action: {})
//    .buttonStyle(.primaryPositive(size: .medium))
//    .disabled(true)
//    
//    Button("textOnlyPrimaryPositive large disable", action: {})
//    .buttonStyle(.primaryPositive(size: .large))
//    .disabled(true)
//    
//    Button("textOnlyPrimaryPositive xLarge disable", action: {})
//    .buttonStyle(.primaryPositive(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Icon only") {
//    
//    Button(
//        title: "iconOnlyPrimaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyPrimaryPositive(size: .medium))
//    
//    Button(
//        title: "iconOnlyPrimaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyPrimaryPositive(size: .xLarge(shouldFitFrameToLabel: true)))
//    
//    Button(
//        title: "iconOnlyPrimaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyPrimaryPositive(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "iconOnlyPrimaryPositive medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyPrimaryPositive(size: .xLarge(shouldFitFrameToLabel: true)))
//    .disabled(true)
//}

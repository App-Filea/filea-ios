////
////  EvelityUI
////
////  Created by Léa Dukaez on 09/06/2025.
////
//
//import SwiftUI
//import EvelityImages
//
//public struct TextPrimaryNegativeButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .textOnlyNegativePrimary(size: size)
//            .background(backgroundColor)
//            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
//            .overlay(
//                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
//                    .strokeBorder(NewEvelityColors.Colors.borderNeutral, lineWidth: size.isXLarge ? 3 : 0)
//            )
//            .shadow(.extraSmall)
//            .hapticFeedback(.impact(.medium), configuration: configuration)
//    }
//    
//    private var backgroundColor: Color {
//        guard isEnabled else {
//            return NewEvelityColors.Colors.backgroundNeutral
//        }
//        return size.isXLarge ? NewEvelityColors.Colors.sentimentNegative : NewEvelityColors.Colors.interactiveNegative
//    }
//}
//
//extension PrimitiveButtonStyle where Self == TextPrimaryNegativeButtonStyle {
//    public static func primaryNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct LeftIconPrimaryNegativeButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.leftIconNegativePrimary(size: size))
//            .background(backgroundColor)
//            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
//            .overlay(
//                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
//                    .strokeBorder(NewEvelityColors.Colors.borderNeutral, lineWidth: size.isXLarge ? 3 : 0)
//            )
//            .shadow(.extraSmall)
//            .hapticFeedback(.impact(.medium), configuration: configuration)
//    }
//    
//    private var backgroundColor: Color {
//        guard isEnabled else {
//            return NewEvelityColors.Colors.backgroundNeutral
//        }
//        return size.isXLarge ? NewEvelityColors.Colors.sentimentNegative : NewEvelityColors.Colors.interactiveNegative
//    }
//}
//
//extension PrimitiveButtonStyle where Self == LeftIconPrimaryNegativeButtonStyle {
//    public static func leftIconPrimaryNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconPrimaryNegativeButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.rightIconNegativePrimary(size: size))
//            .background(backgroundColor)
//            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
//            .overlay(
//                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
//                    .strokeBorder(NewEvelityColors.Colors.borderNeutral, lineWidth: size.isXLarge ? 3 : 0)
//            )
//            .shadow(.extraSmall)
//            .hapticFeedback(.impact(.medium), configuration: configuration)
//    }
//    
//    private var backgroundColor: Color {
//        guard isEnabled else {
//            return NewEvelityColors.Colors.backgroundNeutral
//        }
//        return size.isXLarge ? NewEvelityColors.Colors.sentimentNegative : NewEvelityColors.Colors.interactiveNegative
//    }
//}
//
//extension PrimitiveButtonStyle where Self == RightIconPrimaryNegativeButtonStyle {
//    public static func rightIconPrimaryNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct IconOnlyPrimaryNegativeButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.iconOnlyNegativePrimary(size: size))
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
//        guard isEnabled else {
//            return NewEvelityColors.Colors.backgroundNeutral
//        }
//        return size.isXLarge ? NewEvelityColors.Colors.sentimentNegative : NewEvelityColors.Colors.interactiveNegative
//    }
//}
//
//extension PrimitiveButtonStyle where Self == IconOnlyPrimaryNegativeButtonStyle {
//    public static func iconOnlyPrimaryNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//#Preview("Right icon") {
//    Button(
//        title: "rightIconPrimaryNegative small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryNegative(size: .small))
//    
//    Button(
//        title: "rightIconPrimaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryNegative(size: .medium))
//    
//    Button(
//        title: "rightIconPrimaryNegative large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryNegative(size: .large))
//    
//    Button(
//        title: "rightIconPrimaryNegative xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryNegative(size: .xLarge()))
//    
//    Button(
//        title: "rightIconPrimaryNegative small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryNegative(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconPrimaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryNegative(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconPrimaryNegative large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryNegative(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconPrimaryNegative xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimaryNegative(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Left icon") {
//    Button(
//        title: "leftIconPrimaryNegative small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryNegative(size: .small))
//    
//    Button(
//        title: "leftIconPrimaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryNegative(size: .medium))
//
//    Button(
//        title: "leftIconPrimaryNegative large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryNegative(size: .large))
//    
//    Button(
//        title: "leftIconPrimaryNegative xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryNegative(size: .xLarge()))
//    
//    Button(
//        title: "leftIconPrimaryNegative small disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryNegative(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconPrimaryNegative medium disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryNegative(size: .medium))
//    .disabled(true)
//
//    Button(
//        title: "leftIconPrimaryNegative large disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryNegative(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconPrimaryNegative xLarge disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimaryNegative(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Text only") {
//    
//    Button("textOnlyPrimaryNegative small", action: {})
//    .buttonStyle(.primaryNegative(size: .small))
//    
//    Button("textOnlyPrimaryNegative medium", action: {})
//    .buttonStyle(.primaryNegative(size: .medium))
//    
//    Button("textOnlyPrimaryNegative large", action: {})
//    .buttonStyle(.primaryNegative(size: .large))
//    
//    Button("textOnlyPrimaryNegative xLarge", action: {})
//    .buttonStyle(.primaryNegative(size: .xLarge()))
//    
//    Button("textOnlyPrimaryNegative small disable", action: {})
//    .buttonStyle(.primaryNegative(size: .small))
//    .disabled(true)
//    
//    Button("textOnlyPrimaryNegative medium", action: {})
//    .buttonStyle(.primaryNegative(size: .medium))
//    .disabled(true)
//    
//    Button("textOnlyPrimaryNegative large disable", action: {})
//    .buttonStyle(.primaryNegative(size: .large))
//    .disabled(true)
//    
//    Button("textOnlyPrimaryNegative xLarge disable", action: {})
//    .buttonStyle(.primaryNegative(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Icon only") {
//    
//    Button(
//        title: "iconOnlyPrimaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyPrimaryNegative(size: .medium))
//    
//    Button(
//        title: "iconOnlyPrimaryNegative xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyPrimaryNegative(size: .xLarge(shouldFitFrameToLabel: true)))
//    
//    Button(
//        title: "iconOnlyPrimaryNegative medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyPrimaryNegative(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "iconOnlyPrimaryNegative xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyPrimaryNegative(size: .xLarge(shouldFitFrameToLabel: true)))
//    .disabled(true)
//}

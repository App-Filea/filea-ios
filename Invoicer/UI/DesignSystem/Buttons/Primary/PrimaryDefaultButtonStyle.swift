//
//  EvelityUI
//
//  Created by Léa Dukaez on 09/06/2025.
//

//import SwiftUI
//
//public struct TextPrimaryDefaultButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .textOnlyPrimary(size: size)
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
//        isEnabled ? NewEvelityColors.Colors.interactivePrimary : NewEvelityColors.Colors.backgroundNeutral
//    }
//}
//
//extension PrimitiveButtonStyle where Self == TextPrimaryDefaultButtonStyle {
//    public static func primary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}

//public struct LeftIconPrimaryDefaultButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.leftIconPrimary(size: size))
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
//        isEnabled ? NewEvelityColors.Colors.interactivePrimary : NewEvelityColors.Colors.backgroundNeutral
//    }
//}
//
//extension PrimitiveButtonStyle where Self == LeftIconPrimaryDefaultButtonStyle {
//    public static func leftIconPrimary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconPrimaryDefaultButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.rightIconPrimary(size: size))
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
//        isEnabled ? NewEvelityColors.Colors.interactivePrimary : NewEvelityColors.Colors.backgroundNeutral
//    }
//}
//
//extension PrimitiveButtonStyle where Self == RightIconPrimaryDefaultButtonStyle {
//    public static func rightIconPrimary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct IconOnlyPrimaryDefaultButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.iconOnlyPrimary(size: size))
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
//        isEnabled ? NewEvelityColors.Colors.interactivePrimary : NewEvelityColors.Colors.backgroundNeutral
//    }
//}
//
//extension PrimitiveButtonStyle where Self == IconOnlyPrimaryDefaultButtonStyle {
//    public static func iconOnlyPrimary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}

//#Preview("Right icon") {
//    Button(
//        title: "rightIconPrimary small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimary(size: .small))
//    
//    Button(
//        title: "rightIconPrimary medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimary(size: .medium))
//    
//    Button(
//        title: "rightIconPrimary large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimary(size: .large))
//    
//    Button(
//        title: "rightIconPrimary xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimary(size: .xLarge()))
//    
//    Button(
//        title: "rightIconPrimary small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimary(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconPrimary medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimary(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconPrimary large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimary(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "rightIconPrimary xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.rightIconPrimary(size: .xLarge()))
//    .disabled(true)
//
//}
//
//#Preview("Left icon") {
//    Button(
//        title: "leftIconPrimary small",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimary(size: .small))
//    
//    Button(
//        title: "leftIconPrimary medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimary(size: .medium))
//
//    Button(
//        title: "leftIconPrimary large",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimary(size: .large))
//    
//    Button(
//        title: "leftIconPrimary xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimary(size: .xLarge()))
//    
//    Button(
//        title: "leftIconPrimary small disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimary(size: .small))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconPrimary medium disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimary(size: .medium))
//    .disabled(true)
//
//    Button(
//        title: "leftIconPrimary large disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimary(size: .large))
//    .disabled(true)
//    
//    Button(
//        title: "leftIconPrimary xLarge disable",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.leftIconPrimary(size: .xLarge()))
//    .disabled(true)
//}

//#Preview("Text only") {
//    
//    Button("textOnlyPrimary small", action: {})
//    .buttonStyle(.primary(size: .small))
//    
//    Button("textOnlyPrimary medium", action: {})
//    .buttonStyle(.primary(size: .medium))
//    
//    Button("textOnlyPrimary large", action: {})
//    .buttonStyle(.primary(size: .large))
//    
//    Button("textOnlyPrimary xLarge", action: {})
//    .buttonStyle(.primary(size: .xLarge()))
//    
//    Button("textOnlyPrimary small disable", action: {})
//    .buttonStyle(.primary(size: .small))
//    .disabled(true)
//    
//    Button("textOnlyPrimary medium", action: {})
//    .buttonStyle(.primary(size: .medium))
//    .disabled(true)
//    
//    Button("textOnlyPrimary large disable", action: {})
//    .buttonStyle(.primary(size: .large))
//    .disabled(true)
//    
//    Button("textOnlyPrimary xLarge disable", action: {})
//    .buttonStyle(.primary(size: .xLarge()))
//    .disabled(true)
//}
//
//#Preview("Icon only") {
//    
//    Button(
//        title: "iconOnlyPrimary medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyPrimary(size: .medium))
//    
//    Button(
//        title: "iconOnlyPrimary xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyPrimary(size: .xLarge(shouldFitFrameToLabel: true)))
//    
//    Button(
//        title: "iconOnlyPrimary medium",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyPrimary(size: .medium))
//    .disabled(true)
//    
//    Button(
//        title: "iconOnlyPrimary xLarge",
//        image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//        action: {}
//    )
//    .buttonStyle(.iconOnlyPrimary(size: .xLarge(shouldFitFrameToLabel: true)))
//    .disabled(true)
//}

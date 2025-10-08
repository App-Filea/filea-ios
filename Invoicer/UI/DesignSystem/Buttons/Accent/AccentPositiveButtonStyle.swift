//
////  EvelityUI
////
////  Created by Léa Dukaez on 09/06/2025.
////
//
//import SwiftUI
//
//public struct AccentPositiveButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .textOnlyPositiveAccent(size: size)
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
//        isEnabled ? NewEvelityColors.Colors.backgroundPositive : NewEvelityColors.Colors.backgroundNeutral
//    }
//    
//    private func borderColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.borderNeutral : .clear
//    }
//}
//
//extension PrimitiveButtonStyle where Self == AccentPositiveButtonStyle {
//    public static func accentPositive(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct LeftIconAccentPositiveButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.leftIconPositiveAccent(size: size))
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
//        isEnabled ? NewEvelityColors.Colors.backgroundPositive : NewEvelityColors.Colors.backgroundNeutral
//    }
//    
//    private func borderColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.borderNeutral : .clear
//    }
//}
//
//extension PrimitiveButtonStyle where Self == LeftIconAccentPositiveButtonStyle {
//    public static func leftIconAccentPositive(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconAccentPositiveButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.rightIconPositiveAccent(size: size))
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
//        isEnabled ? NewEvelityColors.Colors.backgroundPositive : NewEvelityColors.Colors.backgroundNeutral
//    }
//    
//    private func borderColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.borderNeutral : .clear
//    }
//}
//
//extension PrimitiveButtonStyle where Self == RightIconAccentPositiveButtonStyle {
//    public static func rightIconAccentPositive(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//import EvelityImages
//
//struct AccentPositiveButtonStyle_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            Button(
//                title: "leftIconAccentPositive",
//                image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//                action: {}
//            )
//            .buttonStyle(.leftIconAccentPositive(size: .large))
//            
//            Button(
//                title: "leftIconAccentPositive",
//                image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//                action: {}
//            )
//            .buttonStyle(.leftIconAccentPositive(size: .xLarge()))
//            
//            Button(
//                title: "rightIconAccentPositive",
//                image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//                action: {}
//            )
//            .buttonStyle(.rightIconAccentPositive(size: .medium))
//            
//            Button(
//                title: "rightIconAccentPositive disabled",
//                image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//                action: {}
//            )
//            .buttonStyle(.rightIconAccentPositive(size: .medium))
//            .disabled(true)
//
//            Button("textOnlyAccentPositive", action: {})
//            .buttonStyle(.accentPositive(size: .small))
//        }
//        .padding(20)
//    }
//}

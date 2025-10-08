////
////  EvelityUI
////
////  Created by Léa Dukaez on 09/06/2025.
////
//
//import SwiftUI
//
//public struct AccentNegativeButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .textOnlyNegativeAccent(size: size)
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
//        isEnabled ? NewEvelityColors.Colors.backgroundNegative : NewEvelityColors.Colors.backgroundNeutral
//    }
//    
//    private func borderColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.borderNeutral : .clear
//    }
//}
//
//extension PrimitiveButtonStyle where Self == AccentNegativeButtonStyle {
//    public static func accentNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct LeftIconAccentNegativeButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.leftIconNegativeAccent(size: size))
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
//        isEnabled ? NewEvelityColors.Colors.backgroundNegative : NewEvelityColors.Colors.backgroundNeutral
//    }
//    
//    private func borderColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.borderNeutral : .clear
//    }
//}
//
//extension PrimitiveButtonStyle where Self == LeftIconAccentNegativeButtonStyle {
//    public static func leftIconAccentNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconAccentNegativeButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.rightIconNegativeAccent(size: size))
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
//        isEnabled ? NewEvelityColors.Colors.backgroundNegative : NewEvelityColors.Colors.backgroundNeutral
//    }
//    
//    private func borderColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.borderNeutral : .clear
//    }
//}
//
//extension PrimitiveButtonStyle where Self == RightIconAccentNegativeButtonStyle {
//    public static func rightIconAccentNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//import EvelityImages
//
//struct AccentNegativeButtonStyle_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            Button(
//                title: "leftIconAccentNegative",
//                image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//                action: {}
//            )
//            .buttonStyle(.leftIconAccentNegative(size: .large))
//            
//            Button(
//                title: "leftIconAccentNegative",
//                image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//                action: {}
//            )
//            .buttonStyle(.leftIconAccentNegative(size: .xLarge()))
//            
//            Button(
//                title: "rightIconAccentNegative",
//                image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//                action: {}
//            )
//            .buttonStyle(.rightIconAccentNegative(size: .medium))
//            
//            Button(
//                title: "rightIconAccentNegative disabled",
//                image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//                action: {}
//            )
//            .buttonStyle(.rightIconAccentNegative(size: .medium))
//            .disabled(true)
//
//            Button("textOnlyAccentNegative", action: {})
//            .buttonStyle(.accentNegative(size: .small))
//        }
//        .padding(20)
//    }
//}

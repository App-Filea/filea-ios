////
////  EvelityUI
////
////  Created by Léa Dukaez on 09/06/2025.
////
//
//import SwiftUI
//
//public struct AccentDefaultButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .textOnlyAccent(size: size)
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
//        isEnabled ? NewEvelityColors.Colors.buttonAccentBackgroundDefault : NewEvelityColors.Colors.backgroundNeutral
//    }
//    
//    private func borderColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.borderNeutral : .clear
//    }
//}
//
//extension PrimitiveButtonStyle where Self == AccentDefaultButtonStyle {
//    public static func accent(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct LeftIconAccentDefaultButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.leftIconAccent(size: size))
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
//        isEnabled ? NewEvelityColors.Colors.buttonAccentBackgroundDefault : NewEvelityColors.Colors.backgroundNeutral
//    }
//    
//    private func borderColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.borderNeutral : .clear
//    }
//}
//
//extension PrimitiveButtonStyle where Self == LeftIconAccentDefaultButtonStyle {
//    public static func leftIconAccent(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconAccentDefaultButtonStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .labelStyle(.rightIconAccent(size: size))
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
//        isEnabled ? NewEvelityColors.Colors.buttonAccentBackgroundDefault : NewEvelityColors.Colors.backgroundNeutral
//    }
//    
//    private func borderColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.borderNeutral : .clear
//    }
//}
//
//extension PrimitiveButtonStyle where Self == RightIconAccentDefaultButtonStyle {
//    public static func rightIconAccent(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//import EvelityImages
//
//struct AccentDefaultButtonStyle_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            Button(
//                title: "leftIconAccent large",
//                image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//                action: {}
//            )
//            .buttonStyle(.leftIconAccent(size: .large))
//            
//            Button(
//                title: "rightIconAccent small",
//                image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//                action: {}
//            )
//            .buttonStyle(.rightIconAccent(size: .small))
//
//            Button("textOnlyAccent medium", action: {})
//            .buttonStyle(.accent(size: .medium))
//            
//            Button(
//                title: "leftIconAccentPositive Disable",
//                image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//                action: {}
//            )
//            .buttonStyle(.leftIconAccentPositive(size: .medium))
//            .disabled(true)
//            
//            Button(
//                title: "rightIconAccent Disable",
//                image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//                action: {}
//            )
//            .buttonStyle(.rightIconAccent(size: .medium))
//            .disabled(true)
//            
//            Button(
//                title: "leftIconAccent xLarge",
//                image: EvelityExternalImages.arrowCircleBrokenRight.swiftUIImage,
//                action: {}
//            )
//            .buttonStyle(.leftIconAccent(size: .xLarge()))
//        }
//        .padding(20)
//    }
//}

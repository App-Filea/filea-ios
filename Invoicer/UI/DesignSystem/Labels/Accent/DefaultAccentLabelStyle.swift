////
////  EvelityUI
////
////  Created by Léa Dukaez on 11/06/2025.
////
//
//import SwiftUI
//
//public struct LeftIconTextAccentLabelStyle: LabelStyle {
//    
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        HStack(spacing: size.spacing) {
//            configuration.icon
//                .accessibleFrame(size: size.iconSize)
//                .foregroundColor(iconColor())
//                .accessibilityHidden(true)
//            
//            switch size {
//            case .large, .medium:
//                configuration.title
//                    .foregroundStyle(textColor())
//                    .labelLarge()
//            case .small:
//                configuration.title
//                    .foregroundStyle(textColor())
//                    .labelMedium()
//            case .xLarge:
//                configuration.title
//                    .foregroundStyle(textColor())
//                    .labelXLarge()
//            }
//        }
//        .padding(.horizontal, size.horizontalPadding)
//        .padding(.vertical, size.verticalPadding)
//        .frame(maxWidth: size.maxWidthFrame)
//    }
//    
//    private func iconColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.buttonAccentIconDefault : NewEvelityColors.Colors.interactiveTertiary
//    }
//    
//    private func textColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.buttonAccentTextDefault : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == LeftIconTextAccentLabelStyle {
//    public static func leftIconAccent(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconTextAccentLabelStyle: LabelStyle {
//    
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        HStack(spacing: size.spacing) {
//            switch size {
//            case .large, .medium:
//                configuration.title
//                    .foregroundStyle(textColor())
//                    .labelLarge()
//            case .small:
//                configuration.title
//                    .foregroundStyle(textColor())
//                    .labelMedium()
//            case .xLarge:
//                configuration.title
//                    .foregroundStyle(textColor())
//                    .labelXLarge()
//            }
//            
//            configuration.icon
//                .accessibleFrame(size: size.iconSize)
//                .foregroundColor(iconColor())
//                .accessibilityHidden(true)
//        }
//        .padding(.horizontal, size.horizontalPadding)
//        .padding(.vertical, size.verticalPadding)
//        .frame(maxWidth: size.maxWidthFrame)
//    }
//    
//    private func iconColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.buttonAccentIconDefault : NewEvelityColors.Colors.interactiveTertiary
//    }
//    
//    private func textColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.buttonAccentTextDefault : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == RightIconTextAccentLabelStyle {
//    public static func rightIconAccent(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//struct TextOnlyAccentLabelStyle: ViewModifier {
//    
//    @Environment(\.isEnabled) var isEnabled
//    private(set) var size: ButtonSizeStyle
//    
//    func body(content: Content) -> some View {
//        HStack(spacing: size.spacing) {
//            switch size {
//            case .large, .medium:
//                content
//                    .foregroundStyle(color())
//                    .labelLarge()
//            case .small:
//                content
//                    .foregroundStyle(color())
//                    .labelMedium()
//            case .xLarge:
//                content
//                    .foregroundStyle(color())
//                    .labelXLarge()
//            }
//        }
//        .padding(.horizontal, size.horizontalPadding)
//        .padding(.vertical, size.verticalPadding)
//        .frame(maxWidth: size.maxWidthFrame)
//    }
//    
//    private func color() -> Color {
//        isEnabled ? NewEvelityColors.Colors.buttonAccentTextDefault : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension View {
//    public func textOnlyAccent(size: ButtonSizeStyle) -> some View {
//        return self.modifier(TextOnlyAccentLabelStyle(size: size))
//    }
//}

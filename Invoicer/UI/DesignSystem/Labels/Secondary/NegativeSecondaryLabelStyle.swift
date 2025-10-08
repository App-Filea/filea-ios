////
////  EvelityUI
////
////  Created by Léa Dukaez on 11/06/2025.
////
//
//import SwiftUI
//
//public struct LeftIconTextNegativeSecondaryLabelStyle: LabelStyle {
//    
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        HStack(spacing: size.spacing) {
//            configuration.icon
//                .accessibleFrame(size: size.iconSize)
//                .foregroundColor(color())
//                .accessibilityHidden(true)
//            
//            switch size {
//            case .large, .medium:
//                configuration.title
//                    .foregroundStyle(color())
//                    .labelLarge()
//            case .small:
//                configuration.title
//                    .foregroundStyle(color())
//                    .labelMedium()
//            case .xLarge:
//                configuration.title
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
//        isEnabled ? NewEvelityColors.Colors.interactiveNegative : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == LeftIconTextNegativeSecondaryLabelStyle {
//    public static func leftIconNegativeSecondary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconTextNegativeSecondaryLabelStyle: LabelStyle {
//    
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        HStack(spacing: size.spacing) {
//            switch size {
//            case .large, .medium:
//                configuration.title
//                    .foregroundStyle(color())
//                    .labelLarge()
//            case .small:
//                configuration.title
//                    .foregroundStyle(color())
//                    .labelMedium()
//            case .xLarge:
//                configuration.title
//                    .foregroundStyle(color())
//                    .labelXLarge()
//            }
//            
//            configuration.icon
//                .accessibleFrame(size: size.iconSize)
//                .foregroundColor(color())
//                .accessibilityHidden(true)
//        }
//        .padding(.horizontal, size.horizontalPadding)
//        .padding(.vertical, size.verticalPadding)
//        .frame(maxWidth: size.maxWidthFrame)
//    }
//    
//    private func color() -> Color {
//        isEnabled ? NewEvelityColors.Colors.interactiveNegative : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == RightIconTextNegativeSecondaryLabelStyle {
//    public static func rightIconNegativeSecondary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//struct TextOnlyNegativeSecondaryLabelStyle: ViewModifier {
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
//        isEnabled ? NewEvelityColors.Colors.interactiveNegative : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension View {
//    public func textOnlyNegativeSecondary(size: ButtonSizeStyle) -> some View {
//        return self.modifier(TextOnlyNegativeSecondaryLabelStyle(size: size))
//    }
//}
//
//public struct IconOnlySecondaryNegativeLabelStyle: LabelStyle {
//    
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        HStack(spacing: size.spacing) {
//            configuration.icon
//                .accessibleFrame(size: size.iconSize)
//                .foregroundColor(color())
//                .accessibilityHidden(true)
//        }
//        .padding(size.horizontalPadding)
//        .frame(maxWidth: size.maxWidthFrame)
//    }
//    
//    private func color() -> Color {
//        isEnabled ? NewEvelityColors.Colors.interactiveNegative : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == IconOnlySecondaryNegativeLabelStyle {
//    public static func iconOnlySecondaryNegative(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}

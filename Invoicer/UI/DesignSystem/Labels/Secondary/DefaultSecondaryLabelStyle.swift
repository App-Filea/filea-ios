////
////  EvelityUI
////
////  Created by Léa Dukaez on 11/06/2025.
////
//
//import SwiftUI
//
//public struct LeftIconTextSecondaryLabelStyle: LabelStyle {
//    
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        HStack(spacing: size.spacing) {
//            configuration.icon
//                .foregroundColor(iconColor())
//                .accessibleFrame(size: size.iconSize)
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
//        isEnabled ? NewEvelityColors.Colors.interactivePrimary : NewEvelityColors.Colors.interactiveTertiary
//    }
//    
//    private func textColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.contentPrimary : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == LeftIconTextSecondaryLabelStyle {
//    public static func leftIconSecondary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconTextSecondaryLabelStyle: LabelStyle {
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
//        isEnabled ? NewEvelityColors.Colors.interactivePrimary : NewEvelityColors.Colors.interactiveTertiary
//    }
//    
//    private func textColor() -> Color {
//        isEnabled ? NewEvelityColors.Colors.contentPrimary : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == RightIconTextSecondaryLabelStyle {
//    public static func rightIconSecondary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//struct TextOnlySecondaryLabelStyle: ViewModifier {
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
//        isEnabled ? NewEvelityColors.Colors.contentPrimary : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension View {
//    public func textOnlySecondary(size: ButtonSizeStyle) -> some View {
//        return self.modifier(TextOnlySecondaryLabelStyle(size: size))
//    }
//}
//
//public struct IconOnlySecondaryLabelStyle: LabelStyle {
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
//        isEnabled ? NewEvelityColors.Colors.interactivePrimary : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == IconOnlySecondaryLabelStyle {
//    public static func iconOnlySecondary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}

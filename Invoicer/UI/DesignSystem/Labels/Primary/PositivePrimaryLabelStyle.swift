////
////  EvelityUI
////
////  Created by Léa Dukaez on 11/06/2025.
////
//
//import SwiftUI
//
//public struct LeftIconTextPositivePrimaryLabelStyle: LabelStyle {
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
//        isEnabled ? NewEvelityColors.Colors.baseContrast : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == LeftIconTextPositivePrimaryLabelStyle {
//    public static func leftIconPositivePrimary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconTextPositivePrimaryLabelStyle: LabelStyle {
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
//        isEnabled ? NewEvelityColors.Colors.baseContrast : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == RightIconTextPositivePrimaryLabelStyle {
//    public static func rightIconPositivePrimary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//struct TextOnlyPositivePrimaryLabelStyle: ViewModifier {
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
//        isEnabled ? NewEvelityColors.Colors.baseContrast : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension View {
//    public func textOnlyPositivePrimary(size: ButtonSizeStyle) -> some View {
//        return self.modifier(TextOnlyPositivePrimaryLabelStyle(size: size))
//    }
//}
//
//public struct IconOnlyPositivePrimaryLabelStyle: LabelStyle {
//    
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.icon
//            .accessibleFrame(size: size.iconSize)
//            .foregroundColor(color())
//            .accessibilityHidden(true)
//            .padding(size.horizontalPadding)
//            .frame(maxWidth: size.maxWidthFrame)
//    }
//    
//    private func color() -> Color {
//        guard isEnabled else {
//            return NewEvelityColors.Colors.interactiveTertiary
//        }
//        return size.isXLarge ? NewEvelityColors.Colors.baseContrast : NewEvelityColors.Colors.baseLight
//    }
//}
//
//extension LabelStyle where Self == IconOnlyPrimaryLabelStyle {
//    public static func iconOnlyPositivePrimary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}

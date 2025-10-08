////
////  EvelityUI
////
////  Created by Léa Dukaez on 11/06/2025.
////
//
//import SwiftUI
//
//public struct LeftIconTextNegativePrimaryLabelStyle: LabelStyle {
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
//        guard isEnabled else {
//            return NewEvelityColors.Colors.interactiveTertiary
//        }
//        return size.isXLarge ? NewEvelityColors.Colors.baseLight : NewEvelityColors.Colors.baseContrast
//    }
//}
//
//extension LabelStyle where Self == LeftIconTextNegativePrimaryLabelStyle {
//    public static func leftIconNegativePrimary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconTextNegativePrimaryLabelStyle: LabelStyle {
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
//        guard isEnabled else {
//            return NewEvelityColors.Colors.interactiveTertiary
//        }
//        return size.isXLarge ? NewEvelityColors.Colors.baseLight : NewEvelityColors.Colors.baseContrast
//    }
//}
//
//extension LabelStyle where Self == RightIconTextNegativePrimaryLabelStyle {
//    public static func rightIconNegativePrimary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//struct TextOnlyNegativePrimaryLabelStyle: ViewModifier {
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
//        guard isEnabled else {
//            return NewEvelityColors.Colors.interactiveTertiary
//        }
//        return size.isXLarge ? NewEvelityColors.Colors.baseLight : NewEvelityColors.Colors.baseContrast
//    }
//}
//
//extension View {
//    public func textOnlyNegativePrimary(size: ButtonSizeStyle) -> some View {
//        return self.modifier(TextOnlyNegativePrimaryLabelStyle(size: size))
//    }
//}
//
//public struct IconOnlyNegativePrimaryLabelStyle: LabelStyle {
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
//        return size.isXLarge ? NewEvelityColors.Colors.baseLight : NewEvelityColors.Colors.baseContrast
//    }
//}
//
//extension LabelStyle where Self == IconOnlyNegativePrimaryLabelStyle {
//    public static func iconOnlyNegativePrimary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct MapIconOnlyNegativePrimaryLabelStyle: LabelStyle {
//    
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.icon
//            .accessibleFrame(size: 24)
//            .foregroundColor(color())
//            .accessibilityHidden(true)
//            .padding(12)
//            .frame(maxWidth: size.maxWidthFrame)
//    }
//    
//    private func color() -> Color {
//        isEnabled ? NewEvelityColors.Colors.mapButtonNegativeIconDefault : NewEvelityColors.Colors.mapButtonPrimaryIconDisabled
//    }
//}
//
//extension LabelStyle where Self == MapIconOnlyNegativePrimaryLabelStyle {
//    public static func mapIconOnlyNegativePrimary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}

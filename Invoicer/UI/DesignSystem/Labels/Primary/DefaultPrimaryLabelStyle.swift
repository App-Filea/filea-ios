//
//  Invoicer
//
//  Created by Nicolas on 08/10/2025.
//

import SwiftUI

//public struct LeftIconTextPrimaryLabelStyle: LabelStyle {
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
//extension LabelStyle where Self == LeftIconTextPrimaryLabelStyle {
//    public static func leftIconPrimary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconTextPrimaryLabelStyle: LabelStyle {
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
//extension LabelStyle where Self == RightIconTextPrimaryLabelStyle {
//    public static func rightIconPrimary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//struct TextOnlyPrimaryLabelStyle: ViewModifier {
//    
//    @Environment(\.isEnabled) var isEnabled
//    private(set) var size: ButtonSizeStyle
//    
//    func body(content: Content) -> some View {
//        HStack(spacing: size.spacing) {
//            switch size {
//            case .large, .medium:
//                content
//                    .foregroundStyle(Color.)
////                    .labelLarge()
//            case .small:
//                content
//                    .foregroundStyle(Color.)
////                    .labelMedium()
//            case .xLarge:
//                content
//                    .foregroundStyle(Color.)
////                    .labelXLarge()
//            }
//        }
//        .padding(.horizontal, size.horizontalPadding)
//        .padding(.vertical, size.verticalPadding)
//        .frame(maxWidth: size.maxWidthFrame)
//    }
//}

//extension View {
//    public func textOnlyPrimary(size: ButtonSizeStyle) -> some View {
//        return self.modifier(TextOnlyPrimaryLabelStyle(size: size))
//    }
//}
//
//public struct IconOnlyPrimaryLabelStyle: LabelStyle {
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
//        isEnabled ? NewEvelityColors.Colors.baseContrast : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == IconOnlyPrimaryLabelStyle {
//    public static func iconOnlyPrimary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct MapIconOnlyPrimaryLabelStyle: LabelStyle {
//    
//    @Environment(\.isEnabled) var isEnabled
//    
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
//        isEnabled ? NewEvelityColors.Colors.mapButtonPrimaryIconDefault : NewEvelityColors.Colors.mapButtonPrimaryIconDisabled
//    }
//}
//
//extension LabelStyle where Self == MapIconOnlyPrimaryLabelStyle {
//    public static func mapIconOnlyPrimary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct MapTextOnlyPrimaryLabelStyle: LabelStyle {
//    
//    @Environment(\.isEnabled) var isEnabled
//    
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.title
//            .accessibleFrame(size: 24)
//            .foregroundColor(color())
//            .accessibilityHidden(true)
//            .padding(12)
//            .frame(maxWidth: size.maxWidthFrame)
//    }
//    
//    private func color() -> Color {
//        isEnabled ? NewEvelityColors.Colors.mapButtonPrimaryIconDefault : NewEvelityColors.Colors.mapButtonPrimaryIconDisabled
//    }
//}
//
//extension LabelStyle where Self == MapTextOnlyPrimaryLabelStyle {
//    public static func mapTextOnlyPrimary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct HeaderIconLabelStyle: LabelStyle {
//    
//    @Environment(\.isEnabled) var isEnabled
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        configuration.icon
//            .accessibleFrame(size: 24)
//            .foregroundColor(NewEvelityColors.Colors.headerButtonIconDefault)
//            .accessibilityHidden(true)
//            .padding(4)
//            .accessibleFrame(size: 32)
//    }
//}
//
//extension LabelStyle where Self == HeaderIconLabelStyle {
//    public static func headerIconLabel() -> Self {
//        .init()
//    }
//}

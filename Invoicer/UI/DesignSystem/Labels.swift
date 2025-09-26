//
//  Labels.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 26/09/2025.
//

import SwiftUI

struct TitleScreen: ViewModifier {

    func body(content: Content) -> some View {
        content
            .kerning(-0.75)
//            .foregroundColor(NewEvelityColors.Colors.contentPrimary)
    }
}

//struct TitleSection: ViewModifier {
//    
//    func body(content: Content) -> some View {
//        content
//            .kerning(-0.39)
//            .accessibleFont(.titleSection())
//            .foregroundColor(NewEvelityColors.Colors.contentPrimary)
//            .fixedSize(horizontal: false, vertical: true)
//            .multilineTextAlignment(.center)
//    }
//}
//
//struct TitleSubsection: ViewModifier {
//    
//    func body(content: Content) -> some View {
//        content
//            .kerning(-0.33)
//            .accessibleFont(.titleSubsection())
//            .foregroundColor(NewEvelityColors.Colors.contentPrimary)
//            .fixedSize(horizontal: false, vertical: true)
//            .multilineTextAlignment(.center)
//    }
//}
//
//struct TitleBody: ViewModifier {
//
//    func body(content: Content) -> some View {
//        content
//            .kerning(-0.18)
//            .accessibleFont(.titleBody())
//            .foregroundColor(NewEvelityColors.Colors.contentPrimary)
//            .fixedSize(horizontal: false, vertical: true)
//            .multilineTextAlignment(.center)
//    }
//}
//
//struct TitleGroup: ViewModifier {
//
//    func body(content: Content) -> some View {
//        content
//            .kerning(0.21)
//            .accessibleFont(.titleGroup())
//            .foregroundColor(NewEvelityColors.Colors.contentPrimary)
//            .fixedSize(horizontal: false, vertical: true)
//            .multilineTextAlignment(.center)
//    }
//}
//
//struct BodyDefaultBold: ViewModifier {
//
//    func body(content: Content) -> some View {
//        content
//            .kerning(0.17)
//            .accessibleFont(.bodyDefaultBold())
//            .fixedSize(horizontal: false, vertical: true)
//            .foregroundColor(NewEvelityColors.Colors.baseLight)
//    }
//}
//
//struct BodyDefaultMedium: ViewModifier {
//    
//    func body(content: Content) -> some View {
//        content
//            .kerning(0.175)
//            .accessibleFont(.bodyDefaultMedium())
//            .fixedSize(horizontal: false, vertical: true)
//            .foregroundColor(NewEvelityColors.Colors.contentTertiary)
//    }
//}
//
//struct BodyDefault: ViewModifier {
//
//    func body(content: Content) -> some View {
//        content
//            .kerning(0.14)
//            .accessibleFont(.bodyDefault())
//            .foregroundColor(NewEvelityColors.Colors.contentSecondary)
//            .fixedSize(horizontal: false, vertical: true)
//            .multilineTextAlignment(.leading)
//    }
//}
struct BodyXLargeBlack: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title)
            .fontWeight(.black)
            .kerning(-1)
    }
}

struct BodyDefaultSemibold: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body)
            .fontWeight(.semibold)
    }
}

struct BodyDefaultLight: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body)
            .fontWeight(.light)
    }
}

struct BodySmallSemibold: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .fontWeight(.semibold)
    }
}

struct BodySmallRegular: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .fontWeight(.regular)
    }
}

//struct BodyLargeMedium: ViewModifier {
//    
//    func body(content: Content) -> some View {
//        content
//            .kerning(0.08)
//            .accessibleFont(.bodyLargeMedium())
//            .fixedSize(horizontal: false, vertical: true)
//            .foregroundColor(NewEvelityColors.Colors.contentPrimary)
//    }
//}
//
//struct BodyXLarge: ViewModifier {
//
//    func body(content: Content) -> some View {
//        content
//            .kerning(0.08)
//            .accessibleFont(.bodyXLarge())
//            .foregroundColor(NewEvelityColors.Colors.contentPrimary)
//            .fixedSize(horizontal: false, vertical: true)
//    }
//}
//
//struct BodyLarge: ViewModifier {
//    
//    func body(content: Content) -> some View {
//        content
//            .kerning(0.08)
//            .accessibleFont(.bodyLarge())
//            .foregroundColor(NewEvelityColors.Colors.contentPrimary)
//            .fixedSize(horizontal: false, vertical: true)
//            .multilineTextAlignment(.center)
//    }
//}
//
//struct LinkDefault: ViewModifier {
//
//    func body(content: Content) -> some View {
//        content
//            .kerning(0.17)
//            .accessibleFont(.linkDefault())
//            .foregroundColor(NewEvelityColors.Colors.contentPrimary)
//            .fixedSize(horizontal: false, vertical: true)
//    }
//}
//
//struct LinkLarge: ViewModifier {
//
//    func body(content: Content) -> some View {
//        content
//            .kerning(0.16)
//            .accessibleFont(.linkLarge())
//            .foregroundColor(NewEvelityColors.Colors.contentPrimary)
//            .fixedSize(horizontal: false, vertical: true)
//    }
//}
//
//struct Marker: ViewModifier {
//
//    func body(content: Content) -> some View {
//        content
//            .kerning(0.16)
//            .accessibleFont(.marker())
//            .foregroundColor(NewEvelityColors.Colors.contentPrimary)
//            .fixedSize(horizontal: false, vertical: true)
//    }
//}
//
//struct InstructionText: ViewModifier {
//
//    func body(content: Content) -> some View {
//        content
//            .kerning(0)
//            .accessibleFont(.instructionText())
//            .foregroundColor(NewEvelityColors.Colors.contentPrimary)
//            .fixedSize(horizontal: false, vertical: true)
//    }
//}
//
//struct LabelLarge: ViewModifier {
//    
//    func body(content: Content) -> some View {
//        content
//            .kerning(0.08)
//            .accessibleFont(.labelLarge())
//            .foregroundColor(NewEvelityColors.Colors.contentPrimary)
//            .fixedSize(horizontal: false, vertical: true)
//    }
//}
//
//struct LabelXLarge: ViewModifier {
//    
//    func body(content: Content) -> some View {
//        content
//            .kerning(-0.18)
//            .accessibleFont(.labelXLarge())
//            .foregroundColor(NewEvelityColors.Colors.contentPrimary)
//            .fixedSize(horizontal: false, vertical: true)
//            .multilineTextAlignment(.leading)
//    }
//}
//
//struct LabelMedium: ViewModifier {
//    
//    func body(content: Content) -> some View {
//        content
//            .kerning(0.17)
//            .accessibleFont(.labelMedium())
//            .foregroundColor(NewEvelityColors.Colors.contentPrimary)
//            .fixedSize(horizontal: false, vertical: true)
//    }
//}

extension View {
    public func titleScreen() -> some View {
        return self.modifier(TitleScreen())
    }
//    public func titleSection() -> some View {
//        return self.modifier(TitleSection())
//    }
//    public func titleSubsection() -> some View {
//        return self.modifier(TitleSubsection())
//    }
//    public func titleBody() -> some View {
//        return self.modifier(TitleBody())
//    }
//    public func titleGroup() -> some View {
//        return self.modifier(TitleGroup())
//    }
//    public func bodyDefaultBold() -> some View {
//        return self.modifier(BodyDefaultBold())
//    }
//    public func bodyDefaultMedium() -> some View {
//        return self.modifier(BodyDefaultMedium())
//    }
//    public func bodyDefault() -> some View {
//        return self.modifier(BodyDefault())
//    }
    public func bodyXLargeBlack() -> some View {
        return self.modifier(BodyXLargeBlack())
    }
    public func bodyDefaultSemibold() -> some View {
        return self.modifier(BodyDefaultSemibold())
    }
    public func bodyDefaultLight() -> some View {
        return self.modifier(BodyDefaultLight())
    }
    public func bodySmallSemibold() -> some View {
        return self.modifier(BodySmallSemibold())
    }
    public func bodySmallRegular() -> some View {
        return self.modifier(BodySmallRegular())
    }
//    public func bodyLargeMedium() -> some View {
//        return self.modifier(BodyLargeMedium())
//    }
//    public func bodyXLarge() -> some View {
//        return self.modifier(BodyXLarge())
//    }
//    public func bodyLarge() -> some View {
//        return self.modifier(BodyLarge())
//    }
//    public func linkDefault() -> some View {
//        return self.modifier(LinkDefault())
//    }
//    public func linkLarge() -> some View {
//        return self.modifier(LinkLarge())
//    }
//    public func marker() -> some View {
//        return self.modifier(Marker())
//    }
//    public func instructionText() -> some View {
//        return self.modifier(InstructionText())
//    }
//    public func labelLarge() -> some View {
//        return self.modifier(LabelLarge())
//    }
//    public func labelXLarge() -> some View {
//        return self.modifier(LabelXLarge())
//    }
//    public func labelMedium() -> some View {
//        return self.modifier(LabelMedium())
//    }
}

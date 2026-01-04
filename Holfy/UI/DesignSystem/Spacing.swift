//
//  Spacing.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 08/10/2025.
//

import SwiftUI

extension CGFloat {
    // MARK: - Inset - Padding interne des composants

    /// 4px - Badges, pills, tags
    static let insetXS: CGFloat = 4

    /// 8px - Petits boutons, chips
    static let insetSM: CGFloat = 8

    /// 12px - Inputs, cards internes
    static let insetMD: CGFloat = 12

    /// 16px - Boutons standards, cards
    static let insetLG: CGFloat = 16

    /// 24px - Grands conteneurs, sections
    static let insetXL: CGFloat = 24

    // MARK: - Stack - Espacement vertical

    /// 4px - Label et valeur très proche
    static let stackXS: CGFloat = 4

    /// 8px - Titre et sous-titre
    static let stackSM: CGFloat = 8

    /// 12px - Entre inputs de formulaire
    static let stackMD: CGFloat = 12

    /// 16px - Entre cards dans une liste
    static let stackLG: CGFloat = 16

    /// 24px - Entre groupes de contenu
    static let stackXL: CGFloat = 24

    /// 32px - Entre sections majeures
    static let stack2XL: CGFloat = 32

    // MARK: - Inline - Espacement horizontal

    /// 4px - Icône et texte très proche
    static let inlineXS: CGFloat = 4

    /// 8px - Icône et texte standard
    static let inlineSM: CGFloat = 8

    /// 12px - Entre badges, entre boutons
    static let inlineMD: CGFloat = 12

    /// 16px - Entre action cards
    static let inlineLG: CGFloat = 16

    // MARK: - Gutter - Marges de page

    /// 16px - Marges standard iOS
    static let gutterMD: CGFloat = 16

    /// 24px - Marges larges, contenus spacieux
    static let gutterLG: CGFloat = 24

    // MARK: - Tokens spécifiques aux composants

    /// 14px - Padding vertical des boutons standards
    static let buttonPaddingVertical: CGFloat = 14

    /// 24px - Padding horizontal des boutons
    static let buttonPaddingHorizontal: CGFloat = 24

    /// 16px - Padding interne des cards
    static let cardPadding: CGFloat = 16

    /// 12px - Padding des champs de formulaire
    static let inputPadding: CGFloat = 12

    /// 8px - Espace entre icône et texte
    static let iconTextGap: CGFloat = 8

    /// 32px - Espace entre sections majeures
    static let sectionGap: CGFloat = 32
}

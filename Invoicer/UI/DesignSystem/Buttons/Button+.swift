//
//  Button+.swift
//  EvelityUI
//
//  Created by Léa Dukaez on 11/06/2025.
//

import SwiftUI

public extension Button where Label == SwiftUI.Label<Text?, AnyView?> {
    init(title: String? = nil, image: Image? = nil, action: @escaping () -> Void) {
        self.init(action: action) {
            Label {
                if let title = title {
                    Text(title)
                }
            } icon: {
                if let image = image {
                    AnyView(
                        image
                            .resizable()
                            .scaledToFit()
                    )
                }
            }
        }
    }
}

public extension Button {
    init<Content: View, Icon: View>(
        @ViewBuilder text: () -> Content,
        @ViewBuilder image: () -> Icon,
        action: @escaping () -> Void
    ) where Label == SwiftUI.Label<Content, Icon> {
        self.init(action: action) {
            Label {
                text()
            } icon: {
                image()
            }
        }
    }
}

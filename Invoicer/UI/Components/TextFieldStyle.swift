//
//  TextFieldStyle.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 08/10/2025.
//

import SwiftUI

struct OutlinedTextField<Field: Hashable>: View {
    @FocusState.Binding var focusedField: Field?
    let field: Field
    let placeholder: String
    @Binding var text: String
    var hasError: Bool = false
    var suffix: String? = nil
    var horizontalPadding: CGFloat = 14
    var verticalPadding: CGFloat = 12
    var cornerRadius: CGFloat = 10

    private var borderColor: Color {
        if hasError {
            return Color("error")
        } else if focusedField == field {
            return Color("primary")
        } else {
            return Color("outline")
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color("onBackgroundSecondary"))
                    .padding(.leading)
            }

            Group {
                if let suffix = suffix {
                    HStack {
                        TextField("", text: $text)
                            .bodyDefaultRegular()
                            .foregroundColor(Color("onSurface"))
                            .accentColor(Color("primary"))
                            .textFieldStyle(.plain)

                        Text(suffix)
                            .bodyDefaultRegular()
                            .foregroundColor(Color("onBackgroundSecondary"))
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, verticalPadding)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: 2)
                            .animation(.easeInOut(duration: 0.3), value: borderColor)
                    )
                } else {
                    TextField("", text: $text)
                        .bodyDefaultRegular()
                        .foregroundColor(Color("onSurface"))
                        .accentColor(Color("primary"))
                        .textFieldStyle(.plain)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.vertical, verticalPadding)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(borderColor, lineWidth: 2)
                                .animation(.easeInOut(duration: 0.3), value: borderColor)
                        )
                }
            }
        }
    }
}

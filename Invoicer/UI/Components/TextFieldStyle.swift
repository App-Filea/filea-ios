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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 2)
                            .animation(.easeInOut(duration: 0.3), value: borderColor)
                    )
                } else {
                    TextField("", text: $text)
                        .bodyDefaultRegular()
                        .foregroundColor(Color("onSurface"))
                        .accentColor(Color("primary"))
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(borderColor, lineWidth: 2)
                                .animation(.easeInOut(duration: 0.3), value: borderColor)
                        )
                }
            }
        }
    }
}

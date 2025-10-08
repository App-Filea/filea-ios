//
//  StepTextField.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 03/10/2025.
//

import SwiftUI

struct StepTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .bodyDefaultRegular()
            .textFieldStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

struct StepTextFieldWithSuffix: View {
    let placeholder: String
    @Binding var text: String
    let suffix: String
    
    var body: some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: $text)
                .bodyDefaultRegular()
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            
            Text(suffix)
                .bodyDefaultRegular()
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                )
        }
    }
}

#Preview {
    VStack {
        StepTextField(placeholder: "Test", text: .constant(""))
        StepTextFieldWithSuffix(placeholder: "120000", text: .constant(""), suffix: "KM")
    }
    .padding()
}

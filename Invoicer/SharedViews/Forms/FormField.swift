//
//  FormField.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 29/12/2025.
//

import SwiftUI

struct FormField<Content: View>: View {
    var titleLabel: LocalizedStringKey?
    var infoLabel: LocalizedStringKey?
    var isError: Bool
    var content: Content
    
    init(
        titleLabel: LocalizedStringKey? = nil,
        infoLabel: LocalizedStringKey? = nil,
        isError: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.titleLabel = titleLabel
        self.infoLabel = infoLabel
        self.isError = isError
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let titleLabel = titleLabel {
                Text(titleLabel)
                    .formFieldTitle()
                    .padding(.horizontal, 4)
            }
            
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    content
                        .frame(minHeight: 35, maxHeight: 35)
                        .padding(.horizontal, 16)
                }
                .padding(.vertical, 8)
                
                if let infoLabel = infoLabel {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                        Text(infoLabel)
                        
                        Spacer()
                    }
                    .formFieldInfoLabel()
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.gray.quinary)
                }
            }
            .fieldCard(isError: isError)
            
            if isError {
                Text("vehicle_form_empty_field_error")
                    .font(.caption)
                    .italic()
                    .lineLimit(1)
                    .foregroundStyle(Color.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
            }
        }
    }
}

#Preview("MenuPicker") {
    FormField(content: {
        HStack {
            Text("Type")
                .font(.system(size: 17))
                .foregroundColor(.primary)
            
            Spacer()
            
            Picker("Type", selection: .constant(DocumentType.repair)) {
                ForEach(DocumentType.allCases) { type in
                    Text(type.displayName)
                        .tag(type)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    })
    .padding()
}

#Preview("Error Textfield") {
    FormField(titleLabel: "TitleLabel",
              infoLabel: "InfoLabel",
              isError: true,
              content: {
        TextField("placeholder", text: .constant("test"))
            .font(.system(size: 17))
            .multilineTextAlignment(.leading)
    })
    .padding()
}

#Preview("Textfield") {
    FormField(titleLabel: "TitleLabel",
              infoLabel: "InfoLabel",
              content: {
        TextField("placeholder", text: .constant("test"))
            .font(.system(size: 17))
            .multilineTextAlignment(.leading)
    })
    .padding()
}

#Preview("DatePicker") {
    FormField(titleLabel: "TitleLabel",
              infoLabel: "InfoLabel",
              content: {
        HStack {
            Text("Date")
                .font(.system(size: 17))
                .foregroundColor(.primary)
            
            Spacer()
            
            DatePicker("", selection: .constant(.now), displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
        }
    })
    .padding()
}

#Preview("Decimal textfield") {
    FormField(titleLabel: "TitleLabel",
              infoLabel: "InfoLabel",
              content: {
        HStack(spacing: 12) {
            Text("Kilométrage")
                .font(.system(size: 17))
                .foregroundColor(.primary)
            
            Spacer()
            
            TextField("0.00", text: .constant("0.00"))
                .font(.system(size: 17))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
            
            Text("KM")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
        }
    })
    .padding()
}

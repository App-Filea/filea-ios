//
//  FormField.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 29/12/2025.
//

import SwiftUI

struct FormField<Content: View>: View {
    var titleLabel: String?
    var infoLabel: String?
    var content: Content
    
    init(
        titleLabel: String? = nil,
        infoLabel: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.titleLabel = titleLabel
        self.infoLabel = infoLabel
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let titleLabel = titleLabel {
                Text(titleLabel)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            VStack(spacing: 0) {
                content
                    .frame(minHeight: 35, maxHeight: 35)
                    .padding(16)
                
                if let infoLabel = infoLabel {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Text(infoLabel)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    .padding(12)
                    .padding(.horizontal, 4)
                    .background(Color(.systemGray6))
                }
            }
            .fieldCard()
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

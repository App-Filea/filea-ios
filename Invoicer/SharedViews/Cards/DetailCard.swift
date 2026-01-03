//
//  DetailCard.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 30/12/2025.
//

import SwiftUI

struct DetailCard: View {
    let icon: String
    let label: LocalizedStringKey
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(Color.secondary)
                }
                
                Text(label)
                    .caption()

                Spacer()
            }
            
            Text(value)
                .title()
        }
        .padding(16)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
}

#Preview {
    DetailCard(icon: "person.fill", label: "Client Name", value: "John Doe")
}

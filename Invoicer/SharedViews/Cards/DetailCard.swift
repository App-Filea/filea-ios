//
//  DetailCard.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 30/12/2025.
//

import SwiftUI

struct DetailCard: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
}

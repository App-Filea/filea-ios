//
//  DatePickerSheet.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 01/10/2025.
//

import SwiftUI

struct DatePickerSheet: View {
    @Binding var date: Date
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DatePicker(
                    "Date de mise en circulation",
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .accentColor(Color("primary"))
                .padding()
                
                Spacer()
            }
            .navigationTitle("Date de mise en circulation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler", action: onCancel)
                        .foregroundStyle(Color("onBackgroundSecondary"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Valider", action: onSave)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("primary"))
                }
            }
        }
    }
}

#Preview {
    DatePickerSheet(date: .constant(.now), onSave: {}, onCancel: {})
}

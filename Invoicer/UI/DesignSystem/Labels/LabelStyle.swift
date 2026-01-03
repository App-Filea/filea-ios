//
//  LabelStyle.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 02/01/2026.
//

import SwiftUI

extension View {
    
    func largeTitle() -> some View {
        self
            .font(.largeTitle)
            .bold()
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.center)
    }
    
    func subLargeTitle() -> some View {
        self
            .font(.headline)
            .fontWeight(.regular)
            .foregroundStyle(Color.secondary)
            .multilineTextAlignment(.center)
    }
    
    func title() -> some View {
        self
            .font(.title2)
            .bold()
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.leading)
    }
    
    func caption() -> some View {
        self
            .font(.caption)
            .foregroundStyle(Color.secondary)
    }
    
    func callout() -> some View {
        self
            .font(.callout)
            .foregroundStyle(Color.secondary)
    }
    
    func headline() -> some View {
        self
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(Color.primary)
    }
    
    func primarySubheadline() -> some View {
        self
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(Color.primary)
    }
    
    func secondarySubheadline() -> some View {
        self
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(Color.secondary)
    }
    
    func primaryBody() -> some View {
        self
            .font(.body)
            .foregroundStyle(Color.primary)
    }
    
    func secondaryBody() -> some View {
        self
            .font(.body)
            .foregroundStyle(Color.secondary)
    }
    
    func formFieldTitle() -> some View {
        self
            .font(.callout)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
    }
    
    func formFieldLeadingTitle() -> some View {
        self
            .font(.headline)
            .fontWeight(.regular)
            .foregroundColor(.primary)
    }
    
    func formFieldInfoLabel() -> some View {
        self
            .font(.footnote)
            .fontWeight(.regular)
            .foregroundColor(.secondary)
    }
}

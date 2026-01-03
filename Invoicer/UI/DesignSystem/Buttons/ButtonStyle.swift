//
//  ButtonStyle.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 02/01/2026.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let systemImage: String?
    let isLoading: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        systemImage: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .frame(maxWidth: .infinity)
            .opacity(isLoading ? 0 : 1)
            .overlay {
                if isLoading {
                    ProgressView()
                        .controlSize(.regular)
                        .tint(.primary)
                }
            }
        }
        .disabled(isLoading)
        .primaryButtonStyle()
    }
}

struct SecondaryButton: View {
    let title: String
    let systemImage: String?
    let isLoading: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        systemImage: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .frame(maxWidth: .infinity)
            .opacity(isLoading ? 0 : 1)
            .overlay {
                if isLoading {
                    ProgressView()
                        .controlSize(.regular)
                        .tint(.primary)
                }
            }
        }
        .disabled(isLoading)
        .secondaryButtonStyle()
    }
}

struct TertiaryButton: View {
    let title: String
    let action: () -> Void
    
    init(
        _ title: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Group {
                    Text(title)
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(Color.primary)
            .buttonStyle(.plain)
        }
    }
}

struct DestructiveButton: View {
    let title: String
    let systemImage: String?
    let isLoading: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        systemImage: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(role: .destructive, action: action) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .frame(maxWidth: .infinity)
            .opacity(isLoading ? 0 : 1)
            .overlay {
                if isLoading {
                    ProgressView()
                        .controlSize(.regular)
                        .tint(.primary)
                }
            }
        }
        .disabled(isLoading)
        .destructiveButtonStyle()
    }
}

struct PrimaryCircleButton: View {
    let systemImage: String
    let isLoading: Bool
    let action: () -> Void
    
    init(
        systemImage: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Group {
                Image(systemName: systemImage)
            }
            .font(.system(size: 17, weight: .semibold))
            .opacity(isLoading ? 0 : 1)
            .overlay {
                if isLoading {
                    ProgressView()
                        .controlSize(.regular)
                        .tint(.primary)
                }
            }
        }
        .frame(width: 40, height: 40)
        .disabled(isLoading)
        .primaryCircleButtonStyle()
    }
}

extension View {
    func primaryButtonStyle() -> some View {
        self
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .buttonBorderShape(.roundedRectangle(radius: 16))
    }
    
    func primaryCircleButtonStyle() -> some View {
        self
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .buttonBorderShape(.circle)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .buttonStyle(.bordered)
            .controlSize(.large)
            .buttonBorderShape(.roundedRectangle(radius: 16))
    }
    
    func destructiveButtonStyle() -> some View {
        self
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .buttonBorderShape(.roundedRectangle(radius: 16))
            .tint(Color.red.tertiary)
            .foregroundStyle(Color.red)
    }
}

#Preview {
    Group {
        PrimaryButton("Button", action: {})
        SecondaryButton("Button", action: {})
        TertiaryButton("Button", action: {})
        DestructiveButton("Button", action: {})
    }
}

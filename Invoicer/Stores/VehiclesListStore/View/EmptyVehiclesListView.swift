//
//  EmptyVehiclesListView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 19/10/2025.
//

import SwiftUI

struct EmptyVehiclesListView: View {
    @State private var activeCard: VehicleType? = VehicleType.allCases.first
    @State private var scrollView: UIScrollView?
    @State private var initialAnimation: Bool = false
    @State private var timer = Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()
    private var onButtonTapped: () -> Void
    
    init(onButtonTapped: @escaping () -> Void) {
        self.onButtonTapped = onButtonTapped
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            InfiniteScrollView(collection: VehicleType.allCases) { card in
                CarouselCardView(card)
            } uiScrollView: {
                scrollView = $0
            } onScroll: {
                updateActiveCard()
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .frame(height: 120)
            .visualEffect { [initialAnimation] content, proxy in
                content
                    .offset(y: !initialAnimation ? -(proxy.size.height + 200) : 0)
            }
            
            VStack(spacing: Spacing.listItemSpacing) {
                Text("Votre garage est vide")
                    .font(.headline)
                    .foregroundStyle(Color(.label))
                Text("Ajoutez votre premier véhicule pour suivre son historique, ses factures et ses documents au même endroit.")
                    .font(.subheadline)
                    .foregroundStyle(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 100)
            .padding(.bottom, 40)
            // Floating action button
            Button(action: onButtonTapped) {
                Text("Ajouter votre premier véhicule")
            }
            .buttonStyle(.primaryTextOnly())
            Spacer()
        }
        .padding(16)
        .onReceive(timer) { _ in
            if let scrollView = scrollView {
                scrollView.contentOffset.x += 0.35
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(0.35))
            
            withAnimation(.smooth(duration: 0.75, extraBounce: 0)) {
                initialAnimation = true
            }
        }
    }
    
    private func updateActiveCard() {
        if let currentScrollOffset = scrollView?.contentOffset.x {
            let activeIndex = Int((currentScrollOffset / 220).rounded()) % VehicleType.allCases.count
            guard activeCard?.id != VehicleType.allCases[activeIndex].id else { return }
            activeCard = VehicleType.allCases[activeIndex]
        }
    }
    
    @ViewBuilder
    private func CarouselCardView(_ card: VehicleType) -> some View {
        Image(systemName: card.iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .padding()
            .background(ColorTokens.surface)
            .scaleEffect(x: card.shouldFlipIcon ? -1 : 1, y: 1)
            .clipShape(.rect(cornerRadius: Radius.lg))
            .shadow(color: ColorTokens.shadow, radius: Spacing.xs, x: 0, y: 4)
            .scrollTransition(.interactive.threshold(.centered), axis: .horizontal) { content, phase in
                content
                    .offset(y: phase == .identity ? -10 : 0)
                    .rotationEffect(.degrees(phase.value * 5), anchor: .bottom)
            }
    }
}

#Preview {
    EmptyVehiclesListView(onButtonTapped: {})
}

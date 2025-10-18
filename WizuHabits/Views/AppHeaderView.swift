//
//  AppHeaderView.swift
//  WizuHabits
//
//  Created by DAMY on 17/10/2025.
//

import SwiftUI

struct AppHeaderView: View {
    var title: String
    var subtitle: String? = nil

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.indigo, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 150)
            .ignoresSafeArea(edges: .top)

            HStack(spacing: 20) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                }

                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    AppHeaderView(title: "Get It Done")
}

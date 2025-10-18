import SwiftUI

struct AppHeaderView: View {
    var title: String

    var body: some View {
        ZStack(alignment: .top) {
            // Background gradient
            LinearGradient(
                colors: [.indigo, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)
            .frame(height: 200)

            // Content
            VStack(spacing: 5) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 3)

                Text(title.uppercased())
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)

                Text("Stay focused. Get things done.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 55)

            // Rounded white overlay at bottom edge
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(.systemBackground))
                .frame(height: 50)
                .offset(y: 180) // Push down slightly for a clean overlap
        }
    }
}

#Preview {
    AppHeaderView(title: "Get It Done")
        .previewLayout(.sizeThatFits)
        .background(Color(.systemBackground))
}

import SwiftUI

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 10)
                
                // Progress
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 10)
                    .animation(.spring(), value: progress)
            }
        }
        .frame(height: 10)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBar(progress: 0.3)
        ProgressBar(progress: 0.7)
        ProgressBar(progress: 1.0)
    }
    .padding()
} 
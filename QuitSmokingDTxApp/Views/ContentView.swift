import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        @Bindable var appState = appState
        
        TabView(selection: $appState.selectedTab) {
            HomeScreen()
                .tabItem {
                    Label("干预", systemImage: "heart.text.square")
                }
                .tag(AppState.Tab.home)
            
            TrendsScreen()
                .tabItem {
                    Label("趋势", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(AppState.Tab.trends)
            
            InsightsScreen()
                .tabItem {
                    Label("洞察", systemImage: "lightbulb")
                }
                .tag(AppState.Tab.insights)
            
            EconomyScreen()
                .tabItem {
                    Label("经济", systemImage: "dollarsign.circle")
                }
                .tag(AppState.Tab.economy)
        }
        .overlay {
            if appState.isLoading {
                LoadingOverlay()
            }
        }
        .alert("错误", isPresented: .constant(appState.error != nil)) {
            Button("确定") { appState.error = nil }
        } message: {
            if let error = appState.error {
                Text(error.localizedDescription)
            }
        }
    }
}

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 10)
                )
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
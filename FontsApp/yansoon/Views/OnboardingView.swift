import SwiftUI

struct OnboardingView: View {
    
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    
    var body: some View {
        
        ZStack {
            
            Color("Background")
                .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                TabView(selection: $currentPage) {
                    
                    OnboardingPage(
                        image: "yansoonFlower",
                        title: "Get Started",
                        description: "Plan your tasks based on how you feel not how pressured you are.",
                        buttonTitle: "Continue"
                    ) {
                        withAnimation {
                            currentPage = 1
                        }
                    }
                    .tag(0)
                    
                    OnboardingPage(
                        image: "yansoonFlower",
                        title: "Full Energy",
                        description: "You're at your peak today. Perfect time for deep work and big tasks.",
                        buttonTitle: "Next"
                    ) {
                        withAnimation {
                            currentPage = 2
                        }
                    }
                    .tag(1)
                    
                    OnboardingPage(
                        image: "yansoonFlower",
                        title: "Medium Energy",
                        description: "You're steady and productive. Great for balanced tasks.",
                        buttonTitle: "Next"
                    ) {
                        withAnimation {
                            currentPage = 3
                        }
                    }
                    .tag(2)
                    
                    OnboardingPage(
                        image: "yansoonFlower",
                        title: "Low Energy",
                        description: "It's okay to slow down. Light tasks help protect your energy.",
                        buttonTitle: "Start"
                    ) {
                        hasSeenOnboarding = true
                    }
                    .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                
                PageIndicator(currentPage: currentPage)
                    .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage: View {
    
    let image: String
    let title: String
    let description: String
    let buttonTitle: String
    let action: () -> Void
    
    var body: some View {
        
        VStack(spacing: 30) {
            
            Spacer()
            
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
            
            VStack(spacing: 12) {
                
                Text(title)
                    .font(AppFont.main(size: 24)) // same as screen titles
                    .foregroundColor(Color("PrimaryText"))
                
                Text(description)
                    .font(AppFont.main(size: 16)) // same as body text
                    .foregroundColor(Color("SecondaryText"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            Button(action: action) {
                Text(buttonTitle)
                    .font(AppFont.main(size: 18)) // same as buttons in your app
                    .foregroundColor(.black)
                    .frame(width: 140, height: 44)
                    .background(Color("PrimaryButtons"))
                    .cornerRadius(12)
            }
            
            Spacer()
        }
    }
}

struct PageIndicator: View {
    
    var currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            
            ForEach(0..<4) { index in
                
                Circle()
                    .fill(index == currentPage ? Color("PrimaryButtons") : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

#Preview {
    OnboardingView()
}

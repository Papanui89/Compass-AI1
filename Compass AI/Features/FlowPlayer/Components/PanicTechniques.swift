import SwiftUI

// MARK: - 5-4-3-2-1 Grounding Technique
struct GroundingTechniqueView: View {
    @State private var currentStep = 5
    @State private var items: [String: [String]] = [:]
    @State private var showingInput = false
    @State private var currentInput = ""
    @State private var timeRemaining = 30
    
    let prompts = [
        5: "Name 5 things you can SEE",
        4: "Name 4 things you can TOUCH", 
        3: "Name 3 things you can HEAR",
        2: "Name 2 things you can SMELL",
        1: "Name 1 thing you can TASTE"
    ]
    
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Progress indicator
            HStack {
                ForEach(1...5, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .scaleEffect(step == currentStep ? 1.2 : 1.0)
                        .animation(.spring(), value: currentStep)
                }
            }
            .padding(.top)
            
            // Current step content
            VStack(spacing: 16) {
                Text("Step \(6 - currentStep) of 5")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(prompts[currentStep] ?? "")
                    .font(.system(size: 24, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                // Timer
                Text("\(timeRemaining)s")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
            }
            
            // Items list for current step
            if let currentItems = items[String(currentStep)], !currentItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("You identified:")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    ForEach(currentItems, id: \.self) { item in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(item)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Input section
            if showingInput {
                VStack(spacing: 12) {
                    TextField("Type what you notice...", text: $currentInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 16))
                    
                    HStack(spacing: 12) {
                        Button("Add") {
                            if !currentInput.isEmpty {
                                if items[String(currentStep)] == nil {
                                    items[String(currentStep)] = []
                                }
                                items[String(currentStep)]?.append(currentInput)
                                currentInput = ""
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(currentInput.isEmpty)
                        
                        Button("Next") {
                            nextStep()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
            }
            
            Spacer()
            
            // Navigation
            HStack {
                if currentStep < 5 {
                    Button("Skip") {
                        nextStep()
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if currentStep == 1 {
                    Button("Complete") {
                        onComplete()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            startTimer()
            showingInput = true
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                nextStep()
            }
        }
    }
    
    private func nextStep() {
        if currentStep > 1 {
            currentStep -= 1
            timeRemaining = 30
            showingInput = true
            startTimer()
        }
    }
}

// MARK: - Box Breathing Technique
struct BoxBreathingView: View {
    @State private var phase = "Inhale"
    @State private var count = 4
    @State private var cycle = 1
    @State private var isActive = false
    
    let totalCycles = 5
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Cycle indicator
            HStack {
                ForEach(1...totalCycles, id: \.self) { cycleNum in
                    Circle()
                        .fill(cycleNum <= cycle ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
            
            // Breathing visualization
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .scaleEffect(phase == "Inhale" ? 1.0 : 0.6)
                    .animation(.easeInOut(duration: 4), value: phase)
                
                VStack(spacing: 8) {
                    Text(phase)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("\(count)")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.primary)
                }
            }
            
            // Instructions
            VStack(spacing: 12) {
                Text("Follow the rhythm:")
                    .font(.system(size: 18, weight: .medium))
                
                HStack(spacing: 16) {
                    VStack {
                        Text("4")
                            .font(.system(size: 16, weight: .medium))
                        Text("Inhale")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("4")
                            .font(.system(size: 16, weight: .medium))
                        Text("Hold")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("4")
                            .font(.system(size: 16, weight: .medium))
                        Text("Exhale")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("4")
                            .font(.system(size: 16, weight: .medium))
                        Text("Hold")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            
            Spacer()
            
            // Controls
            HStack(spacing: 20) {
                Button(isActive ? "Pause" : "Start") {
                    isActive.toggle()
                    if isActive {
                        startBreathing()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Complete") {
                    onComplete()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
    
    private func startBreathing() {
        guard isActive else { return }
        
        let phases = ["Inhale", "Hold", "Exhale", "Hold"]
        var phaseIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { timer in
            if !isActive {
                timer.invalidate()
                return
            }
            
            phase = phases[phaseIndex]
            count = 4
            
            // Countdown within each phase
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { countTimer in
                if count > 1 {
                    count -= 1
                } else {
                    countTimer.invalidate()
                }
            }
            
            phaseIndex = (phaseIndex + 1) % phases.count
            
            if phaseIndex == 0 {
                cycle += 1
                if cycle > totalCycles {
                    timer.invalidate()
                    onComplete()
                }
            }
            
            // Haptic feedback
            HapticService.shared.impact(.light)
        }
    }
}

// MARK: - Ice Diving Response
struct IceDivingView: View {
    @State private var timeRemaining = 60
    @State private var isActive = false
    @State private var showingInstructions = true
    
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            if showingInstructions {
                VStack(spacing: 16) {
                    Image(systemName: "snowflake")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    Text("Ice Diving Response")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("This technique activates your body's natural calming mechanism by triggering the mammalian dive reflex.")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions:")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("• If you have ice, hold it to your cheeks")
                        Text("• If you have cold water, splash it on your face")
                        Text("• If neither is available, imagine cold water")
                        Text("• Hold for 30-60 seconds")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Button("Start") {
                    showingInstructions = false
                    isActive = true
                    startTimer()
                }
                .buttonStyle(.borderedProminent)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "snowflake")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                        .scaleEffect(isActive ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isActive)
                    
                    Text("\(timeRemaining)s")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Keep the cold sensation on your face")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                
                Button("Complete Early") {
                    onComplete()
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                onComplete()
            }
        }
    }
}

// MARK: - TIPP Technique
struct TIPPTechniqueView: View {
    @State private var currentStep = 0
    @State private var showingTechnique = false
    
    let techniques = [
        ("Temperature", "Hold ice cubes or splash cold water on your face", "thermometer"),
        ("Intense Exercise", "Do 20 jumping jacks or run in place", "figure.run"),
        ("Paced Breathing", "Follow the breathing guide", "lungs.fill"),
        ("Paired Muscle Relaxation", "Tense and release muscle groups", "hand.raised.fill")
    ]
    
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            if !showingTechnique {
                VStack(spacing: 16) {
                    Text("TIPP Technique")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("TIPP helps regulate your nervous system quickly through physiological interventions.")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 12) {
                        ForEach(Array(techniques.enumerated()), id: \.offset) { index, technique in
                            HStack {
                                Image(systemName: technique.2)
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading) {
                                    Text(technique.0)
                                        .font(.system(size: 16, weight: .medium))
                                    Text(technique.1)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if index == currentStep {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(index == currentStep ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Button("Start TIPP") {
                    showingTechnique = true
                }
                .buttonStyle(.borderedProminent)
            } else {
                let technique = techniques[currentStep]
                
                VStack(spacing: 20) {
                    Image(systemName: technique.2)
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    Text(technique.0)
                        .font(.system(size: 24, weight: .bold))
                    
                    Text(technique.1)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    if currentStep == 2 { // Paced Breathing
                        BoxBreathingView(onComplete: {
                            nextStep()
                        })
                    }
                }
                
                HStack(spacing: 20) {
                    Button("Skip") {
                        nextStep()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Complete") {
                        onComplete()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func nextStep() {
        if currentStep < techniques.count - 1 {
            currentStep += 1
        } else {
            onComplete()
        }
    }
}

// MARK: - Cognitive Restructuring
struct CognitiveRestructuringView: View {
    @State private var currentThought = ""
    @State private var showingQuestions = false
    @State private var currentQuestion = 0
    
    let questions = [
        "Is this thought helpful or true?",
        "What would I tell a friend in this situation?",
        "What's the evidence for and against this thought?",
        "Will this matter in a week?",
        "What's a more balanced way to think about this?"
    ]
    
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            if !showingQuestions {
                VStack(spacing: 16) {
                    Text("Cognitive Restructuring")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("Let's examine your thoughts and find more helpful perspectives.")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What thought is causing you distress?")
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("I'm thinking...", text: $currentThought, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    Button("Continue") {
                        showingQuestions = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(currentThought.isEmpty)
                }
            } else {
                VStack(spacing: 20) {
                    Text("Question \(currentQuestion + 1) of \(questions.count)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(questions[currentQuestion])
                        .font(.system(size: 20, weight: .semibold))
                        .multilineTextAlignment(.center)
                    
                    Text("Take a moment to reflect on this question.")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                HStack(spacing: 20) {
                    Button("Previous") {
                        if currentQuestion > 0 {
                            currentQuestion -= 1
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(currentQuestion == 0)
                    
                    if currentQuestion < questions.count - 1 {
                        Button("Next") {
                            currentQuestion += 1
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Complete") {
                            onComplete()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Anchoring Phrases
struct AnchoringPhrasesView: View {
    @State private var selectedPhrase = ""
    @State private var showingPhrase = false
    @State private var repeatCount = 0
    
    let phrases = [
        "This will pass",
        "I am safe",
        "I can handle this",
        "This is temporary",
        "I am stronger than this feeling",
        "I am not alone",
        "I have survived this before",
        "My body is trying to protect me"
    ]
    
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            if !showingPhrase {
                VStack(spacing: 16) {
                    Text("Anchoring Phrases")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("Choose a phrase that resonates with you and repeat it to yourself.")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(phrases, id: \.self) { phrase in
                            Button(phrase) {
                                selectedPhrase = phrase
                                showingPhrase = true
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Text("Repeat this phrase:")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(selectedPhrase)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    
                    Text("Repeat \(repeatCount) times")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    
                    Button("Repeat") {
                        repeatCount += 1
                        HapticService.shared.impact(.light)
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Button("Complete") {
                    onComplete()
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .padding()
    }
} 
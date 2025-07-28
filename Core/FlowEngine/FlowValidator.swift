import Foundation

/// Validates flow execution and user inputs for safety and compliance
class FlowValidator {
    
    /// Validates if a node can be executed
    func canExecute(_ node: FlowNode) -> Bool {
        // Check if node is valid
        guard !node.id.isEmpty && !node.title.isEmpty else {
            return false
        }
        
        // Check if actions are valid
        for action in node.actions {
            guard isValidAction(action) else {
                return false
            }
        }
        
        return true
    }
    
    /// Validates user input for a node
    func validateUserInput(_ input: String, for node: FlowNode) -> ValidationResult {
        // Check for empty input
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ValidationResult(isValid: false, error: .emptyInput)
        }
        
        // Check for potentially harmful content
        if containsHarmfulContent(input) {
            return ValidationResult(isValid: false, error: .harmfulContent)
        }
        
        // Check input length
        if input.count > 1000 {
            return ValidationResult(isValid: false, error: .inputTooLong)
        }
        
        // Node-specific validation
        switch node.type {
        case .question:
            return validateQuestionInput(input)
        case .decision:
            return validateDecisionInput(input)
        case .emergency:
            return validateEmergencyInput(input)
        default:
            return ValidationResult(isValid: true)
        }
    }
    
    /// Validates flow configuration
    func validateFlow(_ flow: Flow) -> [ValidationError] {
        var errors: [ValidationError] = []
        
        // Check for required fields
        if flow.id.isEmpty {
            errors.append(.missingFlowId)
        }
        
        if flow.title.isEmpty {
            errors.append(.missingFlowTitle)
        }
        
        if flow.startNode == nil {
            errors.append(.missingStartNode)
        }
        
        // Check for circular references
        if hasCircularReferences(flow) {
            errors.append(.circularReference)
        }
        
        // Check for orphaned nodes
        if hasOrphanedNodes(flow) {
            errors.append(.orphanedNodes)
        }
        
        return errors
    }
    
    /// Validates emergency actions for safety
    func validateEmergencyAction(_ action: FlowAction) -> Bool {
        switch action.type {
        case .call:
            return validateEmergencyCall(action)
        case .text:
            return validateEmergencyText(action)
        case .location:
            return validateLocationSharing(action)
        default:
            return true
        }
    }
    
    // MARK: - Private Methods
    
    private func isValidAction(_ action: FlowAction) -> Bool {
        guard !action.id.isEmpty && !action.title.isEmpty else {
            return false
        }
        
        // Validate action-specific parameters
        switch action.type {
        case .call:
            return action.parameters["phone_number"] != nil
        case .text:
            return action.parameters["message"] != nil
        case .location:
            return true // Location sharing is always valid
        case .haptic, .audio, .notification:
            return true
        }
    }
    
    private func validateQuestionInput(_ input: String) -> ValidationResult {
        // Questions should have meaningful responses
        let words = input.components(separatedBy: .whitespacesAndNewlines)
        guard words.count >= 1 else {
            return ValidationResult(isValid: false, error: .insufficientResponse)
        }
        
        return ValidationResult(isValid: true)
    }
    
    private func validateDecisionInput(_ input: String) -> ValidationResult {
        // Decisions should be yes/no or specific choices
        let normalized = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let validChoices = ["yes", "no", "y", "n", "true", "false", "1", "0"]
        
        guard validChoices.contains(normalized) else {
            return ValidationResult(isValid: false, error: .invalidChoice)
        }
        
        return ValidationResult(isValid: true)
    }
    
    private func validateEmergencyInput(_ input: String) -> ValidationResult {
        // Emergency inputs should be validated more strictly
        let normalized = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for emergency keywords
        let emergencyKeywords = ["help", "emergency", "danger", "urgent", "911"]
        let containsEmergencyKeyword = emergencyKeywords.contains { keyword in
            normalized.contains(keyword)
        }
        
        if containsEmergencyKeyword {
            return ValidationResult(isValid: true, isEmergency: true)
        }
        
        return ValidationResult(isValid: true)
    }
    
    private func containsHarmfulContent(_ input: String) -> Bool {
        // Check for potentially harmful content
        let harmfulPatterns = [
            "script",
            "javascript:",
            "data:text/html",
            "vbscript:",
            "onload=",
            "onerror="
        ]
        
        let lowercased = input.lowercased()
        return harmfulPatterns.contains { pattern in
            lowercased.contains(pattern)
        }
    }
    
    private func validateEmergencyCall(_ action: FlowAction) -> Bool {
        guard let phoneNumber = action.parameters["phone_number"] else {
            return false
        }
        
        // Validate phone number format
        let phoneRegex = #"^\+?[1-9]\d{1,14}$"#
        return phoneNumber.range(of: phoneRegex, options: .regularExpression) != nil
    }
    
    private func validateEmergencyText(_ action: FlowAction) -> Bool {
        guard let message = action.parameters["message"] else {
            return false
        }
        
        // Check message length
        return message.count <= 160 // SMS limit
    }
    
    private func validateLocationSharing(_ action: FlowAction) -> Bool {
        // Location sharing is always valid for emergency actions
        return true
    }
    
    private func hasCircularReferences(_ flow: Flow) -> Bool {
        // Implementation to detect circular references in flow
        // This would traverse the flow graph to detect cycles
        return false // Placeholder
    }
    
    private func hasOrphanedNodes(_ flow: Flow) -> Bool {
        // Implementation to detect orphaned nodes
        // This would check if all nodes are reachable from start node
        return false // Placeholder
    }
}

struct ValidationResult {
    let isValid: Bool
    let error: ValidationError?
    let isEmergency: Bool
    
    init(isValid: Bool, error: ValidationError? = nil, isEmergency: Bool = false) {
        self.isValid = isValid
        self.error = error
        self.isEmergency = isEmergency
    }
}

enum ValidationError: Error, CaseIterable {
    case emptyInput
    case harmfulContent
    case inputTooLong
    case insufficientResponse
    case invalidChoice
    case missingFlowId
    case missingFlowTitle
    case missingStartNode
    case circularReference
    case orphanedNodes
    case invalidPhoneNumber
    case invalidMessage
} 
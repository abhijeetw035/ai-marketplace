import Foundation

// MARK: - Trust Score Result

struct TrustScoreResult {
    let score: Int          // 0 – 100
    let grade: TrustGrade
    let breakdown: TrustBreakdown
    let flags: [TrustFlag]
    let explanation: String
}

enum TrustGrade: String {
    case high    = "Trusted"
    case medium  = "Moderate"
    case low     = "Caution"
    case suspect = "Suspicious"
    
    var icon: String {
        switch self {
        case .high:    return "checkmark.shield.fill"
        case .medium:  return "shield.lefthalf.filled"
        case .low:     return "exclamationmark.shield.fill"
        case .suspect: return "xmark.shield.fill"
        }
    }
    
    var colorHex: String {
        switch self {
        case .high:    return "#22C55E"   // green
        case .medium:  return "#F59E0B"   // amber
        case .low:     return "#EF4444"   // red
        case .suspect: return "#7C3AED"   // violet
        }
    }
}

struct TrustBreakdown {
    var titleScore: Int           // 0–25
    var descriptionScore: Int     // 0–25
    var priceScore: Int           // 0–25
    var imageScore: Int           // 0–25
    
    var total: Int { titleScore + descriptionScore + priceScore + imageScore }
}

struct TrustFlag: Identifiable {
    let id = UUID()
    let severity: FlagSeverity
    let message: String
}

enum FlagSeverity {
    case info, warning, critical
    
    var icon: String {
        switch self {
        case .info:     return "info.circle"
        case .warning:  return "exclamationmark.triangle"
        case .critical: return "xmark.octagon"
        }
    }
}

// MARK: - Trust Score Engine

class TrustScoreEngine {
    
    // MARK: - Public
    
    static func evaluate(listing: Listing) -> TrustScoreResult {
        var flags: [TrustFlag] = []
        
        let titleScore    = scoreTitle(listing.title,       flags: &flags)
        let descScore     = scoreDescription(listing.description, flags: &flags)
        let priceScore    = scorePrice(listing.price, category: listing.category, flags: &flags)
        let imageScore    = scoreImages(listing.images, flags: &flags)
        
        let breakdown = TrustBreakdown(
            titleScore:       titleScore,
            descriptionScore: descScore,
            priceScore:       priceScore,
            imageScore:       imageScore
        )
        
        let total = breakdown.total
        let grade = gradeFor(score: total, flags: flags)
        let explanation = buildExplanation(grade: grade, breakdown: breakdown, flags: flags)
        
        return TrustScoreResult(
            score:       total,
            grade:       grade,
            breakdown:   breakdown,
            flags:       flags,
            explanation: explanation
        )
    }
    
    // MARK: - Scoring subsystems
    
    private static func scoreTitle(_ title: String, flags: inout [TrustFlag]) -> Int {
        var score = 25
        let lower = title.lowercased()
        
        // Too short
        if title.count < 5 {
            score -= 15
            flags.append(.init(severity: .warning, message: "Title is very short — buyers trust detailed titles."))
        }
        
        // Suspicious keywords
        let spamWords = ["free", "guaranteed", "act now", "limited offer", "scam", "fake"]
        for word in spamWords where lower.contains(word) {
            score -= 10
            flags.append(.init(severity: .critical, message: "Title contains suspicious word: '\(word)'."))
        }
        
        // ALL CAPS
        if title == title.uppercased(), title.count > 3 {
            score -= 5
            flags.append(.init(severity: .warning, message: "Title is written in ALL CAPS — common in spam listings."))
        }
        
        return max(score, 0)
    }
    
    private static func scoreDescription(_ desc: String, flags: inout [TrustFlag]) -> Int {
        var score = 25
        let words = desc.split(separator: " ")
        
        // Too short
        if words.count < 10 {
            score -= 10
            flags.append(.init(severity: .info, message: "Description is brief — more detail builds buyer trust."))
        }
        
        // Phone numbers or external links (risky)
        let digitSequence = desc.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if digitSequence.count >= 10 {
            score -= 12
            flags.append(.init(severity: .critical, message: "Description may contain a phone number — avoid off-platform contact."))
        }
        
        let linkPatterns = ["http", "www.", ".com", ".in", "t.me", "wa.me"]
        for pattern in linkPatterns where desc.lowercased().contains(pattern) {
            score -= 8
            flags.append(.init(severity: .critical, message: "External link detected in description — exercise caution."))
            break
        }
        
        // Spam keywords
        let spamPhrases = ["whatsapp me", "call me", "pay advance", "upi", "bank transfer"]
        for phrase in spamPhrases where desc.lowercased().contains(phrase) {
            score -= 8
            flags.append(.init(severity: .warning, message: "Off-platform payment or contact request detected."))
        }
        
        return max(score, 0)
    }
    
    private static func scorePrice(_ price: Double, category: String, flags: inout [TrustFlag]) -> Int {
        var score = 25
        
        // Category-based expected ranges
        let ranges: [String: ClosedRange<Double>] = [
            "Electronics": 500...200000,
            "Furniture":   500...100000,
            "Vehicles":    5000...1000000,
            "Clothing":    50...20000,
            "Books":       10...5000
        ]
        
        if let range = ranges[category] {
            if price < range.lowerBound {
                score -= 15
                flags.append(.init(severity: .critical, message: "Price (₹\(Int(price))) is unusually low for \(category). Possible scam."))
            } else if price > range.upperBound {
                score -= 5
                flags.append(.init(severity: .warning, message: "Price is higher than the typical range for \(category)."))
            }
        }
        
        // Round-number suspicion (₹1, ₹10 etc.)
        if price < 100 && price > 0 {
            score -= 8
            flags.append(.init(severity: .warning, message: "Price seems unrealistically low."))
        }
        
        return max(score, 0)
    }
    
    private static func scoreImages(_ images: [String], flags: inout [TrustFlag]) -> Int {
        var score = 25
        
        if images.isEmpty {
            score -= 20
            flags.append(.init(severity: .warning, message: "No images uploaded — listings with photos sell faster and are more trustworthy."))
        } else if images.count < 2 {
            score -= 5
            flags.append(.init(severity: .info, message: "Only 1 image — multiple photos help buyers decide."))
        }
        
        return max(score, 0)
    }
    
    // MARK: - Grade & Explanation
    
    private static func gradeFor(score: Int, flags: [TrustFlag]) -> TrustGrade {
        let hasCritical = flags.contains(where: { $0.severity == .critical })
        if hasCritical && score < 50 { return .suspect }
        if score >= 75 { return .high }
        if score >= 50 { return .medium }
        if score >= 30 { return .low }
        return .suspect
    }
    
    private static func buildExplanation(grade: TrustGrade, breakdown: TrustBreakdown, flags: [TrustFlag]) -> String {
        var parts: [String] = []
        
        switch grade {
        case .high:    parts.append("This listing looks legitimate and well-described.")
        case .medium:  parts.append("This listing is mostly trustworthy, but has a few areas to review.")
        case .low:     parts.append("Proceed carefully — this listing has several trust concerns.")
        case .suspect: parts.append("⚠️ This listing shows multiple signs of being suspicious or a scam.")
        }
        
        if breakdown.imageScore < 15 { parts.append("Adding photos would improve trust significantly.") }
        if breakdown.descriptionScore < 15 { parts.append("A more detailed description would help.") }
        
        return parts.joined(separator: " ")
    }
}

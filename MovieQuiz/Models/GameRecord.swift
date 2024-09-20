import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
                return lhs.correct < rhs.correct
            }
}

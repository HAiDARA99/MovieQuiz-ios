import UIKit

final class StatisticServiceImplementation: StatisticService {
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        userDefaults.set(total + amount, forKey: Keys.total.rawValue)
        userDefaults.set(count + correct, forKey: Keys.correct.rawValue)
        
        if bestGame < GameRecord(correct: count, total: amount, date: Date()) {
            bestGame = GameRecord(correct: count, total: amount, date: Date())
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    var correct: Int {
        return userDefaults.integer(forKey: Keys.correct.rawValue)
    }
    
    var total: Int {
        return userDefaults.integer(forKey: Keys.total.rawValue)
    }
    
    var totalAccuracy: Double {
        return 100 * (Double(correct)) / (Double(total))
    }
    
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        
        set {
            return userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }

            return record
        }

        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }

            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
}

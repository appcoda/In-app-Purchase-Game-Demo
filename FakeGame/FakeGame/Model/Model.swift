//
//  Model.swift
//  FakeGame
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation
import StoreKit

class Model {
    
    struct GameData: Codable, SettingsManageable {
        var extraLives: Int = 0
        
        var superPowers: Int = 0
        
        var didUnlockAllMaps = false
    }
    
    var gameData = GameData()
    
    var products = [SKProduct]()
    
    
    init() {
        _ = gameData.load()
    }
    
    
    func getProduct(containing keyword: String) -> SKProduct? {
        return products.filter { $0.productIdentifier.contains(keyword) }.first
    }
}

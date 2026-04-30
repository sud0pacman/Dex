//
//  PokemonExt.swift
//  Dex
//
//  Created by Muhammad on 30/04/26.
//

import SwiftUI

extension Pokemon {
    var backgroundImage: ImageResource {
        switch types![0] {
        case "rock", "ground", "steel", "fighting", "ghost", "dark", "psychic":
                .rockgroundsteelfightingghostdarkpsychic
        case "fire", "dragon":
                .firedragon
        case "flying", "bug":
                .flyingbug
        case "ice":
                .ice
        case "water":
                .water
        default:
                .normalgrasselectricpoisonfairy
        }
    }
    
    var typeColor: Color {
        Color(types![0].capitalized)
    }
    
    var stats : [Stat] {
        [
            Stat(id: 1, name: "HP", value: Int16(hp)),
            Stat(id: 2, name: "Attack", value: Int16(attack)),
            Stat(id: 3, name: "Defense", value: Int16(defense)),
            Stat(id: 4, name: "Special Attack", value: Int16(specialAttack)),
            Stat(id: 5, name: "Special Defense", value: Int16(specialDefense)),
            Stat(id: 6, name: "Speed", value: Int16(speed))
        ]
    }
    
    var highestStat: Stat {
        stats.max { $0.value < $1.value }!
    }
}

struct Stat: Identifiable {
    var id: Int
    var name: String
    var value: Int16
}

//
//  PokemonType.swift
//  Dex
//
//  Created by Muhammad on 15/05/26.
//

enum PokemonFilterType: String, CaseIterable {
    var id: PokemonFilterType { self }
    
    case all, bug, dark, dragon, electric, fairy, fighting, fire, flying, ghost, grass, ground, ice, normal, poison, psychic, rock, steel, water
    
    var icon: String {
        switch self {
        case .all: return "🌎"
        case .bug: return "🐛"
        case .dark: return "🌑"
        case .dragon: return "🐉"
        case .electric: return "⚡️"
        case .fairy: return "🌈"
        case .fighting: return "🗡️"
        case .fire: return "🔥"
        case .flying: return "✈️"
        case .ghost: return "👻"
        case .grass: return "🌱"
        case .ground: return "🌾"
        case .ice: return "❄️"
        case .normal: return "🤖"
        case .poison: return "💉"
        case .psychic: return "🧠"
        case .rock: return "🪨"
        case .steel: return "🧩"
        case .water: return "💦"
        }
    }
}

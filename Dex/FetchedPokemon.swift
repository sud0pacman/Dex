//
//  FetchedPokemon.swift
//  Dex
//
//  Created by Muhammad on 28/04/26.
//

import Foundation

struct FetchedPokemon : Decodable {
    let id: Int16
    let name: String
    let types: [String]
    let hp: Int
    let attack: Int
    let defense: Int
    let specialAttack: Int
    let specialDefense: Int
    let speed: Int
    let sprite: URL
    let shiny: URL
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case types
        case stats
        case sprites
        
        enum TypeDictionaryKeys: CodingKey {
            case type
            
            enum TypeKeys: CodingKey {
                case name
            }
        }
        
        enum StatsDictionaryKeys: CodingKey {
            case baseStat
        }
        
        enum SpriteKeys: String, CodingKey {
            case sprite = "fronDefault"
            case shiny = "frontShiny"
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int16.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.types = try container.decode([String].self, forKey: .types)
        self.hp = try container.decode(Int.self, forKey: .hp)
        self.attack = try container.decode(Int.self, forKey: .attack)
        self.defense = try container.decode(Int.self, forKey: .defense)
        self.specialAttack = try container.decode(Int.self, forKey: .specialAttack)
        self.specialDefense = try container.decode(Int.self, forKey: .specialDefense)
        self.speed = try container.decode(Int.self, forKey: .speed)
        self.sprite = try container.decode(URL.self, forKey: .sprite)
        self.shiny = try container.decode(URL.self, forKey: .shiny)
    }
}

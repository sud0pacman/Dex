//
//  FetchService.swift
//  Dex
//
//  Created by Muhammad on 28/04/26.
//

import Foundation

struct FetchService {
    enum FetchError: Error {
        case badResponse
    }
    
    private let baseURL: URL = URL(string: "https://pokeapi.co/api/v2/pokemon")!
    
    func fetchPokemon(_ id: Int) async throws -> Pokemon {
        let url = baseURL.appending(path: "\(id)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        let decocder = JSONDecoder()
        decocder.keyDecodingStrategy = .convertFromSnakeCase
        
        let pokemon = try decocder.decode(Pokemon.self, from: data)
        
        print("Fetched pokemon: \(pokemon.id): \(pokemon.name.capitalized)")
        
        return pokemon
    }
}

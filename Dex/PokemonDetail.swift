//
//  PokemonDetail.swift
//  Dex
//
//  Created by Muhammad on 30/04/26.
//

import SwiftUI
import SwiftData

struct PokemonDetail: View {
    @Environment(\.modelContext) private var modelContext
    
    var pokemon: Pokemon
    
    @State private var showShiny: Bool = false
    @State private var currentImageType: PokemonImageType = .frontDefault
    
    var body: some View {
        ScrollView {
            ZStack {
                Image(pokemon.backgroundImage)
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .black, radius: 6)
                
                PokemonRandmonImage(pokemon: pokemon, pokemonImageType: currentImageType)
            }
            
            HStack {
                ForEach(pokemon.types, id: \.self) { type in
                    Text(type.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .shadow(color: .black, radius: 1)
                        .padding(.vertical, 7)
                        .padding(.horizontal)
                        .background(Color(type.capitalized))
                        .clipShape(.capsule)
                }
                
                Spacer()
                
                Button {
                    pokemon.favorite.toggle()
                    
                    do {
                        try modelContext.save()
                    } catch {
                        print("PokemonDeatil: \(error)")
                    }
                } label: {
                    Image(systemName: pokemon.favorite ? "star.fill" : "star")
                        .font(.largeTitle )
                        .tint(.yellow)
                }
            }
            .padding()
            
            Text("Stats")
                .font(.title)
                .padding(.bottom, -7)
            
            Stats(pokemon: pokemon)
            
             
        }
        .navigationTitle(pokemon.name.capitalized)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Image Options", selection: $currentImageType) {
                        ForEach(PokemonImageType.allCases, id: \.self) { type in
                            Text(type.title.capitalized)
                                .tag(type)
                        }
                    }
                } label: {
                    Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                }
            }
        }
    }
}

struct PokemonRandmonImage : View {
    let pokemon: Pokemon
    let pokemonImageType: PokemonImageType
    
    private var showImageURL: URL? = nil
    private var showImage: Image? = nil
    
    init(pokemon: Pokemon, pokemonImageType: PokemonImageType) {
        print("PokemonRandmonImage init: \(pokemonImageType.rawValue)")
        self.pokemon = pokemon
        self.pokemonImageType = pokemonImageType
        
        switch pokemonImageType {
        case .frontDefault:
            if pokemon.frontDefault == nil {
                showImageURL = pokemon.frontDefaultURL
            } else {
                showImage = pokemon.frontDefaultImage
            }
        case .backDefault:
            if pokemon.backDefault == nil {
                showImageURL = pokemon.backDefaultURL
            } else {
                showImage = pokemon.backDefaultImage
            }
        case .frontShiny:
            if pokemon.frontShiny == nil {
                showImageURL = pokemon.frontShinyURL
            } else {
                showImage = pokemon.frontShinyImage
            }
        case .backShiny:
            if pokemon.backShiny == nil {
                showImageURL = pokemon.backShinyURL
            } else {
                showImage = pokemon.backShinytImage
            }
        }
    }
    
    var body: some View {
        if showImage == nil {
            AsyncImage(url: pokemon.frontDefaultURL) { image in
                image
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding(.top, 50)
                    .shadow(color: .black, radius: 6)
            } placeholder: {
                ProgressView()
            }
        } else {
            showImage!
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .padding(.top, 50)
                .shadow(color: .black, radius: 6)
        }
    }
}

#Preview {
    NavigationStack {
        PokemonDetail(pokemon: PersistenceController.previewPokemon)
    }
}

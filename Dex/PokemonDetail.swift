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
            
//            ToolbarItem(placement: .topBarTrailing) {
//                Button {
//                    showShiny.toggle()
//                } label: {
//                    Image(systemName: showShiny ? "wand.and.stars" : "wand.and.stars.inverse")
//                        .foregroundStyle(showShiny ? .yellow : .primary)
//                }
//            }
        }
    }
}

struct PokemonRandmonImage : View {
    let pokemon: Pokemon
    let pokemonImageType: PokemonImageType
    
    var body: some View {
        switch pokemonImageType {
        case .frontDefault:
            if pokemon.frontDefault == nil {
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
                pokemon.frontDefaultImage
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding(.top, 50)
                    .shadow(color: .black, radius: 6)
            }
        case .backDefault:
            if pokemon.backDefault == nil {
                AsyncImage(url: pokemon.backDefaultURL) { image in
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
                pokemon.backDefaultImage
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding(.top, 50)
                    .shadow(color: .black, radius: 6)
            }
        case .backShiny:
            if pokemon.backShiny == nil {
                AsyncImage(url: pokemon.backShinyURL) { image in
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
                pokemon.backShinytImage
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding(.top, 50)
                    .shadow(color: .black, radius: 6)
            }
        case .frontShiny:
            if pokemon.frontShiny == nil {
                AsyncImage(url: pokemon.frontShinyURL) { image in
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
                pokemon.frontShinyImage
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding(.top, 50)
                    .shadow(color: .black, radius: 6)
            }
        }
        
        
//        if pokemon.shiny == nil || pokemon.sprite == nil {
//            AsyncImage(url: showShiny ? pokemon.shinyURL : pokemon.spriteURL) { image in
//                image
//                    .interpolation(.none)
//                    .resizable()
//                    .scaledToFit()
//                    .padding(.top, 50)
//                    .shadow(color: .black, radius: 6)
//                
//            } placeholder: {
//                ProgressView()
//            }
//        } else {
//            (showShiny ? pokemon.shinyImage : pokemon.spriteImage)
//                .interpolation(.none)
//                .resizable()
//                .scaledToFit()
//                .padding(.top, 50)
//                .shadow(color: .black, radius: 6)
//        }
//    }
    }
}

#Preview {
    NavigationStack {
        PokemonDetail(pokemon: PersistenceController.previewPokemon)
    }
}

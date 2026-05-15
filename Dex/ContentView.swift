//
//  ContentView.swift
//  Dex
//
//  Created by Muhammad on 24/04/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Pokemon.id, animation: .default) private var pokedex: [Pokemon]
    
    @State private var searchText: String = ""
    @State private var filterByFavorite: Bool = false
  
    private var fetcher = FetchService()
    
    private var dynamicPredicate: Predicate<Pokemon> {
        #Predicate<Pokemon> { pokemon in
            if filterByFavorite && !searchText.isEmpty {
                pokemon.favorite && pokemon.name.localizedStandardContains(searchText)
            } else if !searchText.isEmpty {
                pokemon.name.localizedStandardContains(searchText)
            } else if filterByFavorite {
                pokemon.favorite
            } else {
                true
            }
        }
    }
    
    @State private var showShiny: Bool = false

    var body: some View {
        if pokedex.isEmpty {
            ContentUnavailableView {
                Label("No Pokemon", image: .nopokemon)
            } description: {
                Text("There aren't any Pokemons yet\nFetch some Pokemon to get started!")
            }  actions: {
                Button("Fetch pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                    getPokemon(from: 1)
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            NavigationStack {
                List {
                    Section {
                        ForEach((try? pokedex.filter(dynamicPredicate)) ?? pokedex) { pokemon in
                            NavigationLink(value: pokemon) {
                                if pokemon.sprite == nil {
                                    AsyncImage(url: showShiny ? pokemon.shinyURL : pokemon.spriteURL) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 100, height: 100)
                                } else {
                                    (showShiny ? pokemon.shinyImage : pokemon.spriteImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                }
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(pokemon.name.capitalized)
                                            .fontWeight(.bold)
                                        
                                        if pokemon.favorite {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                    
                                    HStack {
                                        ForEach(pokemon.types, id: \.self) { type in
                                            Text(type)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.black)
                                                .padding(.horizontal, 13)
                                                .padding(.vertical, 5)
                                                .background(Color(type.capitalized))
                                                .clipShape(.capsule)
                                        }
                                    }
                                }
                            }
                            .swipeActions(edge: .leading) {
                                let buttonTitle = pokemon.favorite ? "Remove from Favorites" : "Add to Favorites"
                                let iconName = pokemon.favorite ? "star.fill" : "star"

                                Button(buttonTitle, systemImage: iconName) {
                                    pokemon.favorite.toggle()
                                    
                                    do {
                                        try modelContext.save()
                                    } catch {
                                        print(error)
                                    }
                                }
                                .tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    } footer: {
                        if pokedex.count < 151 {
                            ContentUnavailableView {
                                Label("Missing Pokemon", image: .nopokemon)
                            } description: {
                                Text("The fetch war interrupted\nFetch the rest of the Pokemon.")
                            }  actions: {
                                Button("Fetch pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                                    getPokemon(from: pokedex.count + 1)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
                .navigationTitle(Text("Pokédex"))
                .searchable(text: $searchText, prompt: "Find a Pokemon")
                .autocorrectionDisabled(true)
                .animation(.default, value: searchText)
                .navigationDestination(for: Pokemon.self) { pokemon in
                    PokemonDetail(pokemon: pokemon)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation {
                                filterByFavorite.toggle()
                            }
                        } label: {
                            Label("Filter by Favorite", systemImage: filterByFavorite ? "star.fill" : "star")
                        }
                        .tint(.yellow)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showShiny.toggle()
                        } label: {
                            Image(systemName: showShiny ? "wand.and.stars" : "wand.and.stars.inverse")
                                .foregroundStyle(showShiny ? .yellow : .primary)
                        }
                    }
                }
            }
        }
    }
    
    private func getPokemon(from id: Int) {
        Task {
            for i in id..<152 {
                do {
                    let fetchedPokemon = try await fetcher.fetchPokemon(i)
                    
                    modelContext.insert(fetchedPokemon)
                } catch {
                    print("UI Error fetch pokemon: \(error)")
                }
            }
            
            storeSprites()
        }
    }
    
    private func storeSprites() {
        Task {
            do {
                for pokemon in pokedex {
                    pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL).0
                    pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL).0
                    
                    try modelContext.save()
                    
                    print("Sprites stored: \(pokemon.id) : \(pokemon.name.capitalized)")
                }
            } catch {
                print("❌ Error: \(error)")
            }
        }
    }
}

#Preview {
    ContentView().modelContainer(PersistenceController.preview)
}

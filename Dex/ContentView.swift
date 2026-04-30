//
//  ContentView.swift
//  Dex
//
//  Created by Muhammad on 24/04/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    ) private var all: FetchedResults<Pokemon>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        animation: .default)
    private var pokedex: FetchedResults<Pokemon>
    
    @State private var searchText: String = ""
    @State private var filterByFavorite: Bool = false
  
    private var fetcher = FetchService()
    
    private var dynamicPredicate: NSPredicate {
        var predicates: [NSPredicate] = []
        
        // search predicate
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name contains[c] %@", searchText))
        }
        
        // filter by favourite predicate
        if filterByFavorite {
            predicates.append(NSPredicate(format: "favorite == %d", true))
        }
        
        // combine predicates
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    var body: some View {
        if all.isEmpty {
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
                        ForEach(pokedex) { pokemon in
                            NavigationLink(value: pokemon) {
                                if pokemon.sprite == nil {
                                    AsyncImage(url: pokemon.spriteURL) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 100, height: 100)
                                } else {
                                    pokemon.spriteImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                }
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(pokemon.name!.capitalized)
                                            .fontWeight(.bold)
                                        
                                        if pokemon.favorite {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                    
                                    HStack {
                                        ForEach(pokemon.types!, id: \.self) { type in
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
                                Button(pokemon.favorite ? "Remove from Favorites" : "Add to Favorites", systemImage: "star") {
                                    pokemon.favorite.toggle()
                                    
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        print("❌ Failed to update favorite: \(error)")
                                    }
                                }
                                .tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    } footer: {
                        if all.count < 151 {
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
                .onChange(of: searchText) {
                    pokedex.nsPredicate = dynamicPredicate
                }
                .onChange(of: filterByFavorite) {
                    pokedex.nsPredicate = dynamicPredicate
                }
                .navigationDestination(for: Pokemon.self) { pokemon in
                    PokemonDetail()
                        .environmentObject(pokemon)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            filterByFavorite.toggle()
                        } label: {
                            Label("Filter by Favorite", systemImage: filterByFavorite ? "star.fill" : "star")
                        }
                        .tint(.yellow)
                    }
                }
            }
        }
    }
    
    private func getPokemon(from id: Int) {
        Task {
            for id in id..<152 {
                do {
                    let fetchedPokemon = try await fetcher.fetchPokemon(id)
                    let pokemon = Pokemon(context: viewContext)
                    pokemon.id = fetchedPokemon.id
                    pokemon.name = fetchedPokemon.name
                    pokemon.types = fetchedPokemon.types
                    pokemon.hp = fetchedPokemon.hp
                    pokemon.attack = fetchedPokemon.attack
                    pokemon.defense = fetchedPokemon.defense
                    pokemon.specialAttack = fetchedPokemon.specialAttack
                    pokemon.specialDefense = fetchedPokemon.specialDefense
                    pokemon.speed = fetchedPokemon.speed
                    pokemon.spriteURL = fetchedPokemon.spriteURL
                    pokemon.shinyURL = fetchedPokemon.shinyURL
                    
                    try viewContext.save()
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
                for pokemon in all {
                    pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL!).0
                    pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL!).0
                    
                    try viewContext.save()
                    
                    print("Sprites stored: \(pokemon.id) : \(pokemon.name?.capitalized ?? "no name")")
                }
            } catch {
                print("❌ Error: \(error)")
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

import SwiftUI

struct Trail: Identifiable {
    var id = UUID()
    var name: String
    var location: String
    var distance: Double
}

struct TrailRow: View {
    var trail: Trail
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(trail.name)
                Text(trail.location).font(.subheadline).foregroundColor(.gray)
            }
            Spacer()
            Text(String(format: "%.1f miles", trail.distance))
        }
    }
}

struct DetailView: View {
    var trail: Trail
    
    var body: some View {
        VStack {
            Text(trail.name).font(.title)
            
            HStack {
                Text("\(trail.location) - \(String(format: "%.1f miles", trail.distance))")
            }
            
            Spacer()
        }
    }
}

struct ContentViewsss: View {
    let hikingTrails = [
        Trail(name: "Stanford Dish", location: "Palo Alto", distance: 3.9),
        Trail(name: "Edgewood", location: "Redwood City", distance: 3.2),
        Trail(name: "Mission Peak", location: "Fremont", distance: 7.1),
        Trail(name: "Big Basin", location: "Boulder Creek", distance: 4.3),
        Trail(name: "Alum Rock", location: "Milpitas", distance: 5.7),
    ]
    
    var body: some View {
        NavigationView {
            List(hikingTrails) { trail in
                NavigationLink(destination: DetailView(trail: trail)) {
                    TrailRow(trail: trail)
                }
            }
        }
    }
}

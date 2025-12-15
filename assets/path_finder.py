import json
import math
from sklearn.neighbors import NearestNeighbors
import networkx as nx

# -------------------------------------------------------
# CONFIGURATION
# -------------------------------------------------------
K_NEIGHBORS = 10  # Increased for better connectivity
LOCATION_FILE = "location.json"

# -------------------------------------------------------
# 1. LOAD AND VALIDATE LOCATIONS
# -------------------------------------------------------
def load_locations(filename):
    """Load and validate locations from JSON file."""
    with open(filename, "r") as f:
        locations = json.load(f)
    
    names = []
    coords = []
    skipped = 0
    
    for loc in locations:
        coord = loc.get("coordinates")
        name = loc.get("name", "Unknown")
        
        # Skip invalid coordinates
        if not coord or coord is None:
            skipped += 1
            continue
        
        # Skip string indicators of missing data
        if isinstance(coord, str):
            coord_clean = coord.strip()
            if not coord_clean or "Not" in coord_clean or coord_clean == ",":
                skipped += 1
                continue
        
        # Parse coordinates
        try:
            parts = coord.split(",")
            if len(parts) != 2:
                skipped += 1
                continue
            lat, lon = map(float, parts)
            
            # Validate coordinate ranges
            if not (-90 <= lat <= 90) or not (-180 <= lon <= 180):
                skipped += 1
                continue
                
            names.append(name)
            coords.append([lat, lon])
        except (ValueError, AttributeError):
            skipped += 1
            continue
    
    print(f"Loaded {len(names)} valid locations ({skipped} skipped)")
    return names, coords

# -------------------------------------------------------
# 2. BUILD KNN GRAPH
# -------------------------------------------------------
def build_knn_graph(names, coords, k):
    """Build a weighted graph using KNN with haversine distance."""
    # Convert to radians for haversine
    coords_rad = [[math.radians(lat), math.radians(lon)] for lat, lon in coords]
    
    # Fit KNN model
    n_neighbors = min(k, len(coords))
    knn = NearestNeighbors(n_neighbors=n_neighbors, metric='haversine')
    knn.fit(coords_rad)
    
    # Get neighbors
    distances, indices = knn.kneighbors(coords_rad)
    
    # Build graph
    G = nx.Graph()
    R = 6371  # Earth radius in km
    
    # Add nodes with metadata
    for i, (name, coord) in enumerate(zip(names, coords)):
        G.add_node(i, name=name, lat=coord[0], lon=coord[1])
    
    # Add edges
    for i in range(len(names)):
        for j, d in zip(indices[i], distances[i]):
            if i != j:
                distance_km = d * R
                G.add_edge(i, j, weight=distance_km)
    
    print(f"Graph built: {G.number_of_nodes()} nodes, {G.number_of_edges()} edges")
    return G

# -------------------------------------------------------
# 3. FIND SHORTEST PATH
# -------------------------------------------------------
def find_shortest_path(G, names, source_name, destination_name):
    """Find shortest path between two locations."""
    # Validate locations exist
    if source_name not in names:
        return {"error": f"Source '{source_name}' not found"}
    if destination_name not in names:
        return {"error": f"Destination '{destination_name}' not found"}
    
    src_idx = names.index(source_name)
    dst_idx = names.index(destination_name)
    
    # Check if locations are the same
    if src_idx == dst_idx:
        return {
            "path": [source_name],
            "distance_km": 0.0,
            "num_stops": 1
        }
    
    # Find path
    try:
        path_indices = nx.dijkstra_path(G, src_idx, dst_idx, weight='weight')
        total_distance = nx.dijkstra_path_length(G, src_idx, dst_idx, weight='weight')
        
        # Build detailed path
        path_names = [names[i] for i in path_indices]
        
        # Calculate segment distances
        segments = []
        for i in range(len(path_indices) - 1):
            edge_dist = G[path_indices[i]][path_indices[i+1]]['weight']
            segments.append({
                "from": names[path_indices[i]],
                "to": names[path_indices[i+1]],
                "distance_km": round(edge_dist, 2)
            })
        
        return {
            "path": path_names,
            "total_distance_km": round(total_distance, 2),
            "num_stops": len(path_names),
            "segments": segments
        }
    
    except nx.NetworkXNoPath:
        return {"error": "No path found between locations (disconnected graph)"}
    except Exception as e:
        return {"error": f"Unexpected error: {str(e)}"}

# -------------------------------------------------------
# 4. PRETTY PRINT RESULTS
# -------------------------------------------------------
def print_route(result):
    """Print route in a readable format."""
    if "error" in result:
        print(f"\n❌ ERROR: {result['error']}\n")
        return
    
    print("\n" + "="*70)
    print("SHORTEST PATH FOUND")
    print("="*70)
    print(f"\nTotal Distance: {result['total_distance_km']} km")
    print(f"Number of Stops: {result['num_stops']}")
    print(f"\nRoute:\n")
    
    for i, stop in enumerate(result['path'], 1):
        print(f"{i}. {stop}")
        if i < len(result['path']):
            segment = result['segments'][i-1]
            print(f"   ↓ {segment['distance_km']} km\n")
    
    print("="*70 + "\n")

# -------------------------------------------------------
# 5. MAIN EXECUTION
# -------------------------------------------------------
if __name__ == "__main__":
    # Load locations
    names, coords = load_locations(LOCATION_FILE)
    
    if len(names) < 2:
        print("Error: Need at least 2 valid locations")
        exit(1)
    
    # Build graph
    G = build_knn_graph(names, coords, K_NEIGHBORS)
    
    # Find path
    result = find_shortest_path(G, names,"KARNAL","GHRAUNDA",)
    print_route(result)
    
    # Optional: Check graph connectivity
    if not nx.is_connected(G):
        print("⚠️  Warning: Graph is not fully connected.")
        print(f"   Number of components: {nx.number_connected_components(G)}")
        print("   Consider increasing K_NEIGHBORS for better connectivity.\n")

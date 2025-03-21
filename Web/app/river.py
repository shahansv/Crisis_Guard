
import requests
import math


def haversine(lat1, lon1, lat2, lon2):
    # Radius of the Earth in kilometers
    R = 6371.0

    # Convert degrees to radians
    lat1_rad = math.radians(lat1)
    lon1_rad = math.radians(lon1)
    lat2_rad = math.radians(lat2)
    lon2_rad = math.radians(lon2)

    # Differences in coordinates
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad

    # Haversine formula
    a = math.sin(dlat / 2) ** 2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    # Distance in kilometers
    distance = R * c
    return distance


def get_rivers_near_location(lat, lon, radius=10000):
    # Overpass API endpoint
    overpass_url = "http://overpass-api.de/api/interpreter"

    # Overpass QL query to find rivers within a radius (default 10km) of the given lat, lon
    overpass_query = f"""
    [out:json];
    (
      way(around:{radius}, {lat}, {lon})["natural"="water"]["water"="river"];
      relation(around:{radius}, {lat}, {lon})["natural"="water"]["water"="river"];
    );
    out body geom;
    """

    # Make the request to the Overpass API
    response = requests.get(overpass_url, params={'data': overpass_query})

    # Check if the response is successful
    if response.status_code == 200:
        data = response.json()

        # Extract the river details
        rivers = []
        for element in data.get("elements", []):
            river_info = {}
            # Check if the river has a 'name' tag
            if "tags" in element and "name" in element["tags"]:
                river_info["name"] = element["tags"]["name"]
            else:
                river_info["name"] = "Unnamed river"

            # Default distance as None to show that it wasn't calculated
            river_info["distance_km"] = None

            # Debugging: Print the raw geometry data for each element
            print("Element:", element)

            # Check if geometry exists and has valid lat/lon values
            if "geometry" in element and len(element["geometry"]) > 0:
                lat_river = element["geometry"][0]["lat"]
                lon_river = element["geometry"][0]["lon"]

                # Calculate the distance if geometry exists
                river_info["distance_km"] = haversine(lat, lon, lat_river, lon_river)
            else:
                # In case geometry is missing, set distance as None and continue
                river_info["distance_km"] = "Distance not available"

            # Store other river information
            river_info["id"] = element["id"]
            river_info["type"] = element.get("type", "unknown")
            rivers.append(river_info)

        return rivers
    else:
        return {'error': 'Failed to fetch river data'}


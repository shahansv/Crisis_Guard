import requests
import math


def get_elevation(lat, lon, api_key):
    url = f'https://maps.googleapis.com/maps/api/elevation/json?locations={lat},{lon}&key={api_key}'
    response = requests.get(url)
    data = response.json()

    if data['status'] == 'OK':
        elevation = data['results'][0]['elevation']
        return elevation
    else:
        print("Error fetching elevation data:", data['status'])
        return None


def calculate_slope_angle(elevation1, elevation2, distance=50):
    # Calculate the slope angle in degrees
    rise = elevation2 - elevation1
    slope_angle = math.atan(rise / distance) * (180 / math.pi)  # Convert from radians to degrees
    return slope_angle


def get_elevation(lat, lon, api_key):
    """Get elevation for a specific latitude and longitude."""
    url = f'https://maps.googleapis.com/maps/api/elevation/json?locations={lat},{lon}&key={api_key}'
    response = requests.get(url)
    data = response.json()

    if data['status'] == 'OK':
        elevation = data['results'][0]['elevation']
        return elevation
    else:
        print("Error fetching elevation data:", data['status'])
        return None

from .st import fetch_soil_data_with_retries

import time
from httpx import Client, Timeout, HTTPStatusError


# Set a higher timeout value (in seconds)
timeout = Timeout(10.0, read=15.0)  # Timeout for connection (10s) and read operation (15s)

def get_soil_type(lat, lon):
    """Placeholder for getting soil type. Replace with actual API or dataset."""
    # Since soil type data might not be available from a public API,
    # you'll need to replace this with your own logic.
    # Here we return a placeholder value.
    soil_info = fetch_soil_data_with_retries(lat, lon)

    # Fetch top 3 soil types with probabilities
    if soil_info:
        with Client(timeout=timeout) as client:
            response = client.get(
                url="https://api.openepi.io/soil/type",
                params={"lat": lat, "lon": lon, "top_k": 3},
            )
            try:
                response.raise_for_status()
                json = response.json()
                if "properties" in json and "probabilities" in json["properties"]:
                    for idx, prob in enumerate(json["properties"]["probabilities"]):
                        soil_type = prob.get("soil_type")
                        return soil_type
                        probability = prob.get("probability")
                        print(f"Rank {idx + 1}: Soil type: {soil_type}, Probability: {probability}")
                else:
                    print("No probabilities found.")
            except Exception as e:
                print(f"Error fetching top K soil types: {e}")
    return "Clay"  # This is a placeholder. You should implement your logic.


def getmaindata(lat,lon):


    # API keys
    elevation_api_key = 'AIzaSyB3y0szjZmNj_w2q9Vnc08ZL_FU6Z4VTFE'  # Replace with your Google Elevation API key
    weather_api_key = 'AIzaSyB3y0szjZmNj_w2q9Vnc08ZL_FU6Z4VTFE'  # Replace with your OpenWeatherMap API key

    # Get elevation
    elevation = get_elevation(lat, lon, elevation_api_key)

    # Get weather data

    # Get soil type (This is a placeholder implementation)
    soil_type = get_soil_type(lat, lon)

    # Display results
    if elevation is not None:
        print(f"Altitude: {elevation:.2f} meters")

    if soil_type:
        print(f"Soil Type: {soil_type}")

    elevation1 = get_elevation(lat, lon, elevation_api_key)

    # Assuming you want to check the slope to a point a certain distance away
    # You can specify the distance in meters
    distance = 50

    # Calculate the latitude and longitude of the second point
    # Here, we use a small change in latitude for a distance. Adjust this as needed.
    delta_lat = distance / 111320  # Approximate meters per degree latitude
    second_lat = lat + delta_lat
    second_lon = lon  # Keeping the longitude the same for simplicity

    # Get elevation at the second point
    elevation2 = get_elevation(second_lat, second_lon, elevation_api_key)

    if elevation1 is not None and elevation2 is not None:
        slope_angle = calculate_slope_angle(elevation1, elevation2, distance)
        print(f"The slope angle is: {slope_angle:.2f} degrees")
    else:
        slope_angle=0
        print("Could not calculate the slope angle due to elevation data retrieval issues.")

    return elevation,soil_type,slope_angle


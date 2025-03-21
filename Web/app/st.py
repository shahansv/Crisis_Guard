# import requests
# from requests.auth import HTTPBasicAuth
#
# def get_smap_soil_data(lat, lon):
#     # Replace with the correct URL and API endpoint for SMAP soil moisture data
#     api_url = f"https://api.nasa.gov/smap/soil-moisture?lat={lat}&lon={lon}"
#
#     # Replace with your Earthdata credentials
#     username = "your_earthdata_username"
#     password = "your_earthdata_password"
#
#     # Send the GET request with Earthdata credentials for authentication
#     response = requests.get(api_url, auth=HTTPBasicAuth(username, password))
#
#     if response.status_code == 200:
#         soil_data = response.json()
#         return soil_data
#     else:
#         return {'error': 'Failed to fetch SMAP data'}
#
# # Example usage
# lat = 37.7749  # Latitude of San Francisco
# lon = -122.4194  # Longitude of San Francisco
# soil_info = get_smap_soil_data(lat, lon)
# print(soil_info)
#
#
# from httpx import Client
#
# with Client() as client:
#     # Get the most probable soil type at the queried location
#     response = client.get(
#         url="https://api.openepi.io/soil/type",
#         params={"lat": 60.1, "lon": 9.58},
#     )
#
#     json = response.json()
#
#     # Get the most probable soil type
#     most_probable_soil_type = json["properties"]["most_probable_soil_type"]
#
#     print(f"Most probable soil type: {most_probable_soil_type}")
#
#     # Get the most probable soil type at the queried location
#     # and the probability of the top 3 most probable soil types
#     response = client.get(
#         url="https://api.openepi.io/soil/type",
#         params={"lat": 60.1, "lon": 9.58, "top_k": 3},
#     )
#
#     json = response.json()
#
#     # Get the soil type and probability for the second most probable soil type
#     soil_type = json["properties"]["probabilities"][1]["soil_type"]
#     probability = json["properties"]["probabilities"][1]["probability"]
#
#     print(f"Soil type: {soil_type}, Probability: {probability}")

import time
from httpx import Client, Timeout, HTTPStatusError

# Replace with the desired latitude and longitude
latitude = 11.2577658  # Example latitude (Change to your location)
longitude = 75.7845125  # Example longitude (Change to your location)

# Set a higher timeout value (in seconds)
timeout = Timeout(10.0, read=15.0)  # Timeout for connection (10s) and read operation (15s)

# Retry mechanism with up to 3 retries
def fetch_soil_data_with_retries(lat, lon, retries=3):
    with Client(timeout=timeout) as client:
        for attempt in range(retries):
            try:
                # Get the most probable soil type at the queried location
                response = client.get(
                    url="https://api.openepi.io/soil/type",
                    params={"lat": lat, "lon": lon},
                )

                # Check for a successful response
                response.raise_for_status()  # Raise error for bad responses (non-2xx status codes)

                json = response.json()

                # Check if the response contains the 'properties' field
                if "properties" in json:
                    most_probable_soil_type = json["properties"].get("most_probable_soil_type", "No soil type found")
                    print(f"Most probable soil type: {most_probable_soil_type}")
                    return json  # Successful response
                else:
                    print(f"Error: {json.get('error', 'Unknown error')}")
                    return None

            except HTTPStatusError as e:
                print(f"HTTP error occurred: {e.response.status_code} - {e.response.text}")
                break  # Break the loop if a non-2xx response is returned
            except timeouts.ReadTimeout:
                print(f"Attempt {attempt + 1}: Timeout occurred. Retrying...")
                time.sleep(2)  # Wait before retrying
            except Exception as e:
                print(f"An error occurred: {e}")
                break  # Break the loop on any other error

        print("Max retries reached or error occurred.")
        return None  # If all retries fail

# Example usage


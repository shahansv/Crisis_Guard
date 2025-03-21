import json
import joblib
from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
import requests
from .sample import getmaindata
from .river import get_rivers_near_location

API_KEY = '59066fda027f4b7ea3d64384a7b32ede'


def get_weather(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            lat = data.get('latitude')
            lon = data.get('longitude')
            distance_str = "1000"

            # Get river data
            river_data = get_rivers_near_location(lat, lon)
            if "error" in river_data:
                print(river_data["error"])
            else:
                print(f"Rivers near location ({lat}, {lon}):")
                for river in river_data:
                    if isinstance(river["distance_km"], (float, int)):
                        distance_str = float(river['distance_km'])
                        break
                    else:
                        distance_str = "Distance not available"
                        break

            # Fetch elevation, soil type, and slope angle data
            elevation, soil_type, slope_angle = getmaindata(float(lat), float(lon))
            print(elevation, soil_type, slope_angle, distance_str)

            if lat is None or lon is None:
                return JsonResponse({'error': 'Invalid coordinates'}, status=400)

            # Fetch weather data
            api_url = f'https://api.weatherbit.io/v2.0/current?lat={lat}&lon={lon}&key={API_KEY}'
            response = requests.get(api_url)
            weather_data = response.json()
            print(weather_data)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)

    # Load the KNN model
    knn = joblib.load(r"C:\Users\DELL\PycharmProjects\landslide\app\knn-model.joblib")

    # Ensure the input data matches the expected dimensions
    try:
        # Adjust the row to have the correct number of features
        st = [
            'Fluvisols',
            'Andosols',
            'Arenosols',
            'Chernozem',
            'Gleysols',
            'Histosols',
            'Kastanozems',
            'Luvisols',
            'Nitisols',
            'Regosols',
            'Vertisols',
            'Solonchaks',
            'Podzols',
            'Alisols',
            'Cambisols',
            'Calcisols',
            'Phaeozems',
            'Acrisols',
            'Plinthosols'
        ]
        row = [float(lat), float(lon), float(elevation), float(distance_str), float(slope_angle),weather_data['data'][0]['precip'],st.index(soil_type),weather_data['data'][0]['rh'],weather_data['data'][0]['rh']]  # Adjust as necessary
        if len(row) != knn.n_features_in_:
            raise ValueError(f"Expected {knn.n_features_in_} features, but got {len(row)}")

        # Make the prediction
        res = knn.predict([row])
        print(res, "++++++++++++++++++")

        if res[0] == 0:
            return JsonResponse({'status': 'ok', 'val': 'Non-landslide','weather_data':weather_data,'st':soil_type,'river':distance_str,'altitude':elevation,'rainfall':weather_data['data'][0]['precip']})
        else:
            return JsonResponse({'status': 'not ok', 'val': 'Landslide','weather_data':weather_data,'st':soil_type,'river':distance_str,'altitude':elevation,'rainfall':weather_data['data'][0]['precip']})

    except ValueError as e:
        print("Error in prediction:", str(e))
        return JsonResponse({'error': 'Prediction failed', 'details': str(e)}, status=500)

    return JsonResponse({'status': 'not ok', 'val': 'Landslide','weather_data':weather_data})




def loadpredictpage(request):
    return render(request,'mappp.html')


def loadpr_post(request):
    lat=request.POST['lat']
    lon=request.POST['lon']
    altitude=request.POST['altitude']
    slope=request.POST['slope']
    soil_type=request.POST['soil_type']
    humidity=request.POST['humidity']
    temperature=request.POST['temperature']
    wind_speed=request.POST['wind_speed']
    rainfall=request.POST['rainfall']






def map_start(request):
    return render(request,'map_start.html')

def get_predicttt(request):
    if request.method == 'POST':
        try:

            lat = float(request.POST['lat'])
            lon = float(request.POST['lon'])
            distance_str = "1000"

            # Get river data
            river_data = get_rivers_near_location(lat, lon)
            if "error" in river_data:
                print(river_data["error"])
            else:
                print(f"Rivers near location ({lat}, {lon}):")
                for river in river_data:
                    if isinstance(river["distance_km"], (float, int)):
                        distance_str = float(river['distance_km'])
                        break
                    else:
                        distance_str = "Distance not available"
                        break

            # Fetch elevation, soil type, and slope angle data
            elevation, soil_type, slope_angle = getmaindata(float(lat), float(lon))
            print(elevation, soil_type, slope_angle, distance_str)

            if lat is None or lon is None:
                return render(request,"result.html",{"val":"invalid"})
            # Fetch weather data
            api_url = f'https://api.weatherbit.io/v2.0/current?lat={lat}&lon={lon}&key={API_KEY}'
            response = requests.get(api_url)
            weather_data = response.json()
            print(weather_data)

        except json.JSONDecodeError as e:
            print(e)
            return render(request, "result.html", {"val": "invalid"})

            # return JsonResponse({'error': 'Invalid JSON'}, status=400)

    # Load the KNN model
    knn = joblib.load(r"C:\Users\USER\Downloads\landslide (1)\landslide\app\knn-model.joblib")

    # Ensure the input data matches the expected dimensions
    try:
        # Adjust the row to have the correct number of features
        st = [
            'Fluvisols',
            'Andosols',
            'Arenosols',
            'Chernozem',
            'Gleysols',
            'Histosols',
            'Kastanozems',
            'Luvisols',
            'Nitisols',
            'Regosols',
            'Vertisols',
            'Solonchaks',
            'Podzols',
            'Alisols',
            'Cambisols',
            'Calcisols',
            'Phaeozems',
            'Acrisols',
            'Plinthosols'
        ]
        try:
            row = [float(lat), float(lon), float(elevation), float(distance_str), float(slope_angle),weather_data['data'][0]['precip'],st.index(soil_type),weather_data['data'][0]['rh'],weather_data['data'][0]['rh']]  # Adjust as necessary
        except:
            row = [float(lat), float(lon), float(elevation), float(distance_str), float(slope_angle),1,st.index(soil_type),1,1]  # Adjust as necessary
        if len(row) != knn.n_features_in_:
            raise ValueError(f"Expected {knn.n_features_in_} features, but got {len(row)}")

        # Make the prediction
        res = knn.predict([row])
        print(res, "++++++++++++++++++")

        if res[0] == 0:
            try:
                return render(request,"result.html",{'status': 'ok', 'val': 'Non-landslide','weather_data':weather_data,'st':soil_type,'river':distance_str,'altitude':elevation,'rainfall':weather_data['data'][0]['precip'],'city_name':weather_data['data'][0]['city_name']})
            except:
                return render(request,"result.html",{'status': 'ok', 'val': 'Non-landslide','weather_data':weather_data,'st':soil_type,'river':distance_str,'altitude':elevation,'rainfall':5,'city_name':""})
        else:
            try:
                return HttpResponse({'status': 'not ok', 'val': 'Landslide','weather_data':weather_data,'st':soil_type,'river':distance_str,'altitude':elevation,'rainfall':weather_data['data'][0]['precip'],'city_name':weather_data['data'][0]['city_name']})
            except:
                return HttpResponse({'status': 'not ok', 'val': 'Landslide','weather_data':weather_data,'st':soil_type,'river':distance_str,'altitude':elevation,'rainfall':5,'city_name':""})

    except ValueError as e:
        print("Error in prediction:", str(e))
        return JsonResponse({'error': 'Prediction failed', 'details': str(e)}, status=500)

    return JsonResponse({'status': 'not ok', 'val': 'Landslide','weather_data':weather_data})
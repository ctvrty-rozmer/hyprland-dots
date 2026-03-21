#!/usr/bin/env python3

import datetime
import json
import requests
import statistics
import sys
from apikeys import OPENWEATHERMAP_API_KEY
from apikeys import LATITUDE_ENV
from apikeys import LONGITUDE_ENV


# TODO

# - snow
# - warnings
# - emojis

# import env variables from apikeys.py
API_KEY = OPENWEATHERMAP_API_KEY
LATITUDE = LATITUDE_ENV
LONGITUDE = LONGITUDE_ENV


# helper functions
def print_error(msg: str):
    print('err', msg)

def print_help():
    print('usage: \x1b[33m./weather.py <subcommand> [options]\x1b[0m')
    print()
    print('available subcommands:')
    print(' - \x1b[32mgeocoding\x1b[0m <city[,state][,country]> : search for city to get its coordinates')
    print(' - \x1b[32mcurrent\x1b[0m                            : print current weather information')
    print(' - \x1b[32mwaybar\x1b[0m                             : get output for usage with waybar')

# makes a request to the OpenWeatherMap API and returns the response as a dict
def make_request(call: str) -> dict:
    try:
        req = requests.get(f'https://api.openweathermap.org/{call}&appid={API_KEY}')
        return req.json()

    except: 
        print_error(f'request failed to `/{call}`')
        quit(1)

# prints an entry with a label and content, with optional indentation and label width for alignment
def print_entry(label: str, content: str, indent: int = 0, label_width: int = 8):
    label_with_whitespace = label.ljust(label_width)
    print(f'{" " * indent}{label_with_whitespace}  {content}')

# takes a date in the format 'MM/DD/YYYY' and returns the corresponding weekday as a lowercase string (e.g. 'monday')
def get_weekday(date: str) -> str:
    return datetime.datetime.strptime(date, '%m/%d/%Y').strftime('%A').lower()

# formats a label and content for waybar output
def waybar_entry(label: str, content: str, indent: int = 2, label_width: int = 9):
    label_with_whitespace = label.ljust(label_width)
    return f'{" " * indent}{label_with_whitespace}  {content}\n'

# performs geocoding using the OpenWeatherMap API to find coordinates for a given city, state, and/or country search query, and prints the results in a formatted manner
def geocoding(search: str):
    res = make_request(f'geo/1.0/direct?q={search}&limit=5')
    num_results = len(res)

    if (num_results == 0):
        print_error('no results found, L bozo')
    else:
        print(f'found {num_results} result{"" if num_results == 1 else "s"}:')
        for entry in res:
            name = entry['name']
            state = entry['state'] if 'state' in entry.keys() else None
            country = entry['country']
            latitude = entry['lat']
            longitude = entry['lon']

            print(f' - {name}',
                f'({f"{state}, " if state else ""}{country}):',
                f'latitude = {latitude},',
                f'longitude = {longitude}')

# fetches current weather data from the OpenWeatherMap API for the specified latitude and longitude, ensuring that the 'rain' field is present in the response (defaulting to 0.0 mm if not) before returning the data as a dictionary
def get_current_weather_data() -> dict:
    res = make_request(f'data/2.5/weather?lat={LATITUDE}&lon={LONGITUDE}&units=metric')

    if 'rain' not in res.keys():
        res['rain'] = {'1h': 0.0}
    return res

def weather_icon(weather: str) -> str:
    return {
    'clear': '',
    'clouds': '',
    'rain': '',
    'drizzle': '',
    'thunderstorm': '',
    'snow': '',
    'mist': '󰖑',
    'smoke': '',
    'haze': '',
    'dust': '',
    'fog': '󰖑',
    'squall': '',
    'tornado': '󰼸',
    }.get(weather.lower(), '') # default to clear if unknown weather condition

# fetches current weather data and prints formatted information about the weather, temperature (in Fahrenheit), humidity, wind speed, and rainfall
def current_weather():

    data = get_current_weather_data()

    weather = data['weather'][0]['description'].lower()
    temperature = round(data['main']['temp'])
    temp_f = round((temperature * 1.8) + 32)
    temperature_feels_like = round(data['main']['feels_like'])
    feels_like_f = round((temperature_feels_like * 1.8) + 32)
    humidity = data['main']['humidity']
    wind_speed = round(data['wind']['speed'])
    rainfall = data['rain']['1h']

    print_entry('weather', f'{weather}')
    print_entry('temp', f'{temp_f} °F, feels like {feels_like_f} °F')
    print_entry('humidity', f'{humidity} % RH')
    print_entry('wind', f'{wind_speed} m/s')
    print_entry('rain', f'{rainfall} mm')


# current weather for waybar widget and tooltip
def waybar_widget(data: dict):
    weather = data['weather'][0]['main'].lower()
    temperature = round(data['main']['temp'])
    temp_f = round((temperature * 1.8) + 32)
    emoji = weather_icon(weather)
    return f'{emoji} {weather} {temp_f}°F'

# current weather for waybar tooltip with more deetz
def waybar_current(data: dict):
    weather = data['weather'][0]['description'].lower()
    temperature = round(data['main']['temp'])
    temp_f = round((temperature * 1.8) + 32)
    temperature_feels_like = round(data['main']['feels_like'])
    feels_like_f = round((temperature_feels_like * 1.8) + 32)
    humidity = data['main']['humidity']
    wind_speed = round(data['wind']['speed'])
    rainfall = data['rain']['1h']
    emoji = weather_icon(weather)

    output = ''
    output += waybar_entry('weather', f'{emoji}{weather}')
    output += waybar_entry(
        'temp',
        f"{temp_f}°F" + ", feels like " + f"{feels_like_f}°F"
    )
    output += waybar_entry('humidity', f'{humidity} % RH')
    output += waybar_entry('wind', f'{wind_speed} m/s')
    output += waybar_entry('rain', f'{rainfall} mm')

    return output
def waybar():

    current_data = get_current_weather_data()

    widget = waybar_widget(current_data)
    current = waybar_current(current_data)
    tooltip = ('current weather') + '\n' + current

    print(json.dumps({
        'text': widget,
        'tooltip': tooltip,
        }))


def main():
    if len(sys.argv) == 1 or sys.argv[1] in ('help', '-h', '--help'):
        print_help()

    else: 

        #geogoding
        if sys.argv[1] == 'geocoding':
            if len(sys.argv) == 3:
                geocoding(sys.argv[2])
            else:
                print_error('expected argument `<city[,state][,country]>`')
                print_help()

        elif API_KEY is None or LATITUDE is None or LONGITUDE is None:
            print_error('please change constants in this script before use')

        elif sys.argv[1] == 'current':
            current_weather()
        
        elif sys.argv[1] == 'waybar':
            waybar()

        else: 
            print_error('unknown command `{sys.argv[1]}`')
            print_help()

if __name__ == '__main__':
    main()

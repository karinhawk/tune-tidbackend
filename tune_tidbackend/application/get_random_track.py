"""Docstring."""

import os
import math
import random
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials


class GetRandomTrackFunction(BaseHandler):

    def getCredentials(self):
        if "SPOTIFY_CLIENT_ID" in os.environ:
            client_id = os.environ["SPOTIFY_CLIENT_ID"]
        if "SPOTIFY_CLIENT_SECRET" in os.environ:
            client_secret = os.environ["SPOTIFY_CLIENT_SECRET"]

    def getRandomQuery():
        # A list of all characters that can be chosen.
        characters = 'abcdefghijklmnopqrstuvwxyz'
        
        # Gets a random character from the characters string.
        randomCharacter = characters[(math.floor(random.randint(0, len(characters) -1)))]

        # Places the wildcard character at the beginning, or both beginning and end, randomly.
        num = random.randint(1, 2)
        return randomCharacter + '%' if num == 1 else '%' + randomCharacter + '%'


    def getRandomOffset():
        return math.floor(random.randint(0, 10000))
    
    def validateCredentials():
        return spotipy.Spotify(client_credentials_manager=SpotifyClientCredentials())



    def getRandomTrack(self):
        # GET https://api.spotify.com/v1/searchtype=track
        # q=getRandomSearch()
        # offset=randomOffset
        query = self.getRandomQuery()
        offset = self.getRandomOffset()
        try:
            spotify = self.validateCredentials()
            return spotify.search(q=query, limit=1, offset=offset, type="track")
        except Exception as e:
            raise e


    def execute(self):
        try:
            self.getRandomTrack(self)
        except Exception as e:
            raise e


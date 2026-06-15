from decouple import config
from google import genai

api_key = config("GEMINI_API_KEY", default=None)
client = genai.Client(api_key=api_key)

for model in client.models.list():
    if 'flash' in model.name and 'vision' not in model.name and 'audio' not in model.name:
        print(model.name)

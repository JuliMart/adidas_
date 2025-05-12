from pydantic import BaseModel

class TextureRequest(BaseModel):
    color_name: str

def generate_texture_response(color_name: str):
    # Podés implementar lógica real más adelante
    return {
        "status": "ok",
        "message": f"Texture for color {color_name} generated successfully",
        "color": color_name
    }

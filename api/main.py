import cv2
import numpy as np
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from starlette.responses import JSONResponse
import mediapipe as mp
import time
from generate_texture import TextureRequest, generate_texture_response


last_gesture_time = 0
gesture_cooldown = 1.0  # segundos


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://flutter-adidas-web.onrender.com"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Modelos edad
age_list = ['(0-2)', '(4-6)', '(8-12)', '(15-20)', '(25-32)', '(38-43)', '(48-53)', '(60-100)']
prototxt = "models/age_deploy.prototxt"
caffemodel = "models/age_net.caffemodel"
age_net = cv2.dnn.readNetFromCaffe(prototxt, caffemodel)

# MediaPipe manos
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(
    static_image_mode=False,       # seguimiento en tiempo real
    max_num_hands=2,               # permite detectar ambas manos
    min_detection_confidence=0.7,
    min_tracking_confidence=0.5    # mejora el seguimiento
)


def map_age(age_label):
    return "Joven" if age_label in age_list[:5] else "Adulto"


def detect_age(frame):
    blob = cv2.dnn.blobFromImage(frame, 1.0, (227, 227), (78.4, 87.8, 114.9), swapRB=False)
    age_net.setInput(blob)
    preds = age_net.forward()
    return map_age(age_list[preds[0].argmax()])


def get_dominant_color(image):
    img = cv2.resize(image, (100, 100))  # reduce tamaño para acelerar
    img = img.reshape((-1, 3)).astype(np.float32)

    k = 3
    _, labels, centers = cv2.kmeans(
        img, k, None,
        (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 10, 1.0),
        10, cv2.KMEANS_RANDOM_CENTERS
    )

    brightness = [np.mean(c) for c in centers]
    best_idx = np.argmax(brightness)
    r, g, b = map(int, centers[best_idx])

    return '#{:02x}{:02x}{:02x}'.format(b, g, r)



def get_finger_states(landmarks):
    tips = [4, 8, 12, 16, 20]
    fingers = []
    if landmarks[tips[0]].x < landmarks[tips[0] - 2].x:
        fingers.append(1)
    else:
        fingers.append(0)
    for i in range(1, 5):
        fingers.append(1 if landmarks[tips[i]].y < landmarks[tips[i] - 2].y else 0)
    return fingers


def recognize_sign(fingers):
    if fingers == [1, 1, 1, 1, 1]: return "sign_hello"
    if fingers == [0, 1, 0, 0, 1]: return "sign_help"
    if fingers == [0, 0, 0, 0, 0]: return "thumbs_down"
    if fingers == [0, 1, 1, 0, 0]: return "sign_continue"
    if fingers == [1, 0, 0, 0, 0]: return "thumbs_up"

    return "waiting"

@app.post("/generate-texture/")
def generate_texture(req: TextureRequest):
    return generate_texture_response(req.color_name)

@app.post("/analyze")
async def analyze_image(image: UploadFile = File(...)):
    contents = await image.read()
    np_img = np.frombuffer(contents, np.uint8)
    frame = cv2.imdecode(np_img, cv2.IMREAD_COLOR)
    if frame is None:
        return JSONResponse(content={"error": "Imagen inválida"}, status_code=400)

    # Edad
    age = detect_age(frame)

    # Color
    h, w, _ = frame.shape

    cx, cy = w // 2, h // 2
    roi = frame[cy - 40:cy + 40, cx - 50:cx + 50]

    color = get_dominant_color(roi)

    # Gestos
    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)  # usa frame entero
    result = hands.process(rgb)
    gesture = "waiting"

    global last_gesture_time
    now = time.time()

    if result.multi_hand_landmarks:
        for hand in result.multi_hand_landmarks:
            fingers = get_finger_states(hand.landmark)
            detected = recognize_sign(fingers)

            # Solo si ha pasado el tiempo de espera
            if detected != "waiting" and now - last_gesture_time > gesture_cooldown:
                gesture = detected
                last_gesture_time = now
            break

    return {"age_range": age, "color": color, "gesture": gesture}

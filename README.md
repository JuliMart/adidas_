# 👟 adidas_ – Flutter Web + WebSocket Color Detection Demo

**Proyecto interactivo en Flutter Web que cambia el color del fondo en tiempo real según lo que ve la cámara.**  
La comunicación con el backend se realiza mediante WebSocket, lo que permite una experiencia fluida y responsiva.  

Inspirado en una posible campaña para Adidas, el sistema simula cómo la IA puede responder al usuario en entornos de retail o pantallas interactivas.

---

## 🚀 Funcionalidades principales

✅ Interfaz web desarrollada en **Flutter Web**  
✅ Acceso a cámara en el navegador  
✅ Comunicación en tiempo real vía **WebSocket**  
✅ El fondo de la interfaz cambia dinámicamente según el **color dominante detectado por la cámara**  
✅ Integración con backend hecho en **FastAPI** (detección por IA con MediaPipe / OpenCV)

---

## 🔧 Tecnologías utilizadas

- 🎯 **Flutter Web** (Dart)
- ⚡ **FastAPI** (Python)
- 📸 WebCamera API + HTML video access
- 🧠 Procesamiento de imagen (MediaPipe / OpenCV)
- 🔗 WebSockets (para detección en tiempo real)

---


---

## ▶️ Cómo ejecutar

### 🔹 Ejecutar la interfaz (Flutter Web)

```bash
cd ui
flutter pub get
flutter run -d chrome

BACKEND
cd api
uvicorn main:app --reload


🎨 Ejemplo visual
📷 Si la cámara ve mucho rojo → fondo rojo
📷 Si detecta verde → fondo verde
📷 Si cambia el entorno → la interfaz reacciona automáticamente

📌 Estado del proyecto
🔄 En desarrollo activo.
🎯 Diseñado como demostración interactiva para campañas visuales inteligentes, retail, y señalética IA-responsive.

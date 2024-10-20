from confluent_kafka import Consumer, Producer, KafkaException, KafkaError
from fastapi import FastAPI, UploadFile, File
import cv2
import numpy as np
import uvicorn
from mtcnn.mtcnn import MTCNN
from keras_vggface.vggface import VGGFace
from keras_vggface.utils import preprocess_input
from PIL import Image
from scipy.spatial.distance import hamming
import pandas as pd
import os
from fastapi.middleware.cors import CORSMiddleware
import requests

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Kafka configuration
consumer_conf = {
    'bootstrap.servers': 'localhost:9092',
    'group.id': 'image-consumer-group',
    'auto.offset.reset': 'earliest'
}

producer_conf = {
    'bootstrap.servers': 'localhost:9092'
}

consumer = Consumer(consumer_conf)
producer = Producer(producer_conf)

# Subscribe to Kafka topic
consumer.subscribe(['facial_recognition_results'])

# VGGFace model initialization
model = VGGFace(model='senet50', include_top=False, input_shape=(224, 224, 3), pooling='avg')

def encode_images(faces):
    encoding = []
    for i in faces:
        prediction = model.predict(i)
        encoding.append(prediction.flatten())
    return encoding

def to_hash_code(encoding, hash_size=64):
    threshold = np.mean(encoding)
    binary_encoding = (encoding > threshold).astype(int)
    return binary_encoding[:hash_size]

def extract_face(image, required_size=(224, 224)):
    pixels = np.array(image)
    detector = MTCNN()
    results = detector.detect_faces(pixels)
    if not results:
        return None
    x1, y1, width, height = results[0]['box']
    x2, y2 = x1 + width, y1 + height
    face = pixels[y1:y2, x1:x2]
    image = Image.fromarray(face)
    image = image.resize(required_size)
    face_array = np.asarray(image)
    return face_array

def load_database(excel_path):
    data = pd.read_excel(excel_path)
    faces = []
    dictionary = {}
    for index, row in data.iterrows():
        img_path = row['url']
        img = Image.open(img_path)
        
        img = extract_face(img)
        if img is None:
            continue
        img = img.astype('float32')
        img = np.expand_dims(img, axis=0)
        faces.append(img)
        samples = np.asarray(faces, 'float32')
        samples = preprocess_input(samples, version=2)
        encoding = encode_images(samples)[-1]
        dictionary[row['nom']] = (to_hash_code(encoding), row['prenom'], row['age'])
    return samples, dictionary

def match_hash(known_hash, check_hash):
    score = hamming(known_hash, check_hash)
    return score

@app.on_event("startup")
async def startup_event():
    global real_database_dict
    excel_path = 'C:/Users/PC/Desktop/dataProjetAfdel.xlsx'
    _, real_database_dict = load_database(excel_path)

@app.post("/uploadImage/")
async def upload_image(file: UploadFile = File(...)):
    try:
        image_bytes = await file.read()
        producer.produce('facial_recognition_results', image_bytes)
        producer.flush()
        return {"message": "Image uploaded successfully!"}
    except Exception as e:
        return {"error": str(e)}

@app.post("/match_faces/")
async def match_faces_endpoint(file: UploadFile = File(...)):
    image = Image.open(file.file)
    face = extract_face(image)
    if face is None:
        return {"error": "Face extraction failed"}
    face = face.astype('float32')
    face = np.expand_dims(face, axis=0)
    face = preprocess_input(face, version=2)
    encoding = encode_images([face])[0]
    hash_code = to_hash_code(encoding)

    min_score = float('inf')
    best_match = None
    threshold = 0.2  # Define a suitable threshold

    for nom, (known_hash, prenom, age) in real_database_dict.items():
        score = match_hash(known_hash, hash_code)
        if score < min_score:
            min_score = score
            best_match = {"nom": nom, "prenom": prenom, "age": age}

    if min_score <= threshold:
        return {"match": best_match, "score": min_score}
    else:
        return {"match": "No Match Found"}

def consume_images():
    while True:
        msg = consumer.poll(timeout=1.0)
        if msg is None:
            continue
        if msg.error():
            if msg.error().code() == KafkaError._PARTITION_EOF:
                continue
            else:
                print(msg.error())
                break

        print("Received message with size:", len(msg.value()))

        try:
            nparr = np.frombuffer(msg.value(), np.uint8)
            img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            if img is None or img.size == 0:
                print("Failed to decode image")
                continue

            print("Image decoded successfully with shape:", img.shape)
            
            # Save the image temporarily to send it to FastAPI
            temp_image_path = 'temp_image.jpg'
            cv2.imwrite(temp_image_path, img)

            # Send the image to FastAPI to get the matched person information
            with open(temp_image_path, 'rb') as f:
                response = requests.post('http://localhost:8000/match_faces/', files={'file': f})
                result = response.json()
            
            if 'match' in result and result['match'] != "No Match Found":
                match_info = result['match']
                info_text = f"{match_info['nom']} {match_info['prenom']}, Age: {match_info['age']}, Score: {result['score']}"
            else:
                info_text = "No Match Found"

            # Print the person information
            print(info_text)

            # Send the person information to the new Kafka topic
            producer.produce('facial_recognition_results_display', info_text.encode('utf-8'))
            producer.flush()

        except Exception as e:
            print(f"Error processing image: {e}")

    consumer.close()

if __name__ == "__main__":
    from threading import Thread

    # Run the Kafka consumer in a separate thread
    consumer_thread = Thread(target=consume_images)
    consumer_thread.start()

    # Run the FastAPI app
    uvicorn.run(app, host="0.0.0.0", port=8000)
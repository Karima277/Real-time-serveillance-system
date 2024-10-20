**Real-Time Surveillance System**
This project is a real-time face detection and recognition system that utilizes a combination of Spring Boot, Kafka, and FastAPI. The system is designed to capture frames from a live video feed, process them, and identify faces based on a pre-trained model.
heres the link of presentation if you want to understand the projct more : https://www.canva.com/design/DAGC25bnf30/Zx7mKvnzo9-tNl9gu4KdRA/edit?utm_content=DAGC25bnf30&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton
**Features**
Real-time video capture: Streams video from a web camera and processes the frames.
Face recognition: Identifies faces in the captured frames using an AI model integrated into the system.
Kafka Integration: Uses Kafka to stream and handle the real-time data between components (producer and consumer).
API for processing: The FastAPI backend processes each frame, extracting faces and matching them against the known data.

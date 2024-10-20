<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Camera Feed</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
        }
        video {
            border: 2px solid #333;
            border-radius: 8px;
        }
        button {
            margin-top: 20px;
            background-color: #007bff;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background-color: #0056b3;
        }
        #matchInfo {
            margin-top: 20px;
            font-size: 1.2em;
            color: #333;
            width: 640px;
            border: 1px solid #ccc;
            padding: 10px;
            border-radius: 8px;
            background-color: #fff;
            text-align: center;
        }
    </style>
</head>
<body>
    <video id="video" width="640" height="480" autoplay></video>
    <button id="capture">Detect Face</button>
    <div id="matchInfo">${matchInfo}</div>

    <script src="https://cdn.jsdelivr.net/npm/@tensorflow/tfjs"></script>
    <script src="https://cdn.jsdelivr.net/npm/@tensorflow-models/mobilenet"></script>
    <script src="https://cdn.jsdelivr.net/npm/@tensorflow-models/coco-ssd"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.0/sockjs.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
    <script>
        const video = document.getElementById('video');
        const captureButton = document.getElementById('capture');
        const matchInfo = document.getElementById('matchInfo');

        // Get access to the camera
        if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
            navigator.mediaDevices.getUserMedia({ video: true }).then(function(stream) {
                video.srcObject = stream;
                video.play();
            }).catch(function(error) {
                console.error('Error accessing the camera:', error);
            });
        } else {
            console.error('getUserMedia not supported on your browser');
        }

        // Establish WebSocket connection
        const socket = new SockJS('/websocket-endpoint');
        const stompClient = Stomp.over(socket);

        stompClient.connect({}, function(frame) {
            console.log('Connected: ' + frame);
            
            // Subscribe to the topic
            stompClient.subscribe('/topic/camera', function(message) {
                const matchData = JSON.parse(message.body);
                if (matchData && matchData !== "No Match Found") {
                    matchInfo.innerText = `${matchData.nom} ${matchData.prenom}, Age: ${matchData.age}, Score: ${matchData.score}`;
                } else {
                    matchInfo.innerText = "No match information yet.";
                }
            });
        });

        // Capture photo and send to Kafka
        captureButton.addEventListener('click', () => {
            const canvas = document.createElement('canvas');
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            canvas.getContext('2d').drawImage(video, 0, 0, canvas.width, canvas.height);
            canvas.toBlob(blob => {
                const formData = new FormData();
                formData.append('file', blob, 'captured.jpg');
                fetch('http://localhost:8000/uploadImage/', {
                    method: 'POST',
                    body: formData
                }).then(response => response.json())
                  .then(data => console.log(data))
                  .catch(error => console.error('Error:', error));
            }, 'image/jpeg');
        });
    </script>
</body>
</html>

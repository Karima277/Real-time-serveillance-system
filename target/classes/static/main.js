// main.js
document.addEventListener('DOMContentLoaded', (event) => {
    const video = document.getElementById('video');
    const startButton = document.getElementById('startButton');
    
    navigator.mediaDevices.getUserMedia({ video: true })
        .then((stream) => {
            video.srcObject = stream;
        })
        .catch((err) => {
            console.error('Error accessing webcam: ', err);
        });

    startButton.addEventListener('click', () => {
        const canvas = document.createElement('canvas');
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        const context = canvas.getContext('2d');
        
        setInterval(() => {
            context.drawImage(video, 0, 0, canvas.width, canvas.height);
            canvas.toBlob((blob) => {
                const formData = new FormData();
                formData.append('file', blob, 'frame.jpg');
                
                fetch('http://127.0.0.1:8000/stream_video/', {
                    method: 'POST',
                    body: formData,
                })
                .then(response => response.json())
                .then(data => {
                    console.log(data);
                })
                .catch(error => {
                    console.error('Error:', error);
                });
            }, 'image/jpeg');
        }, 100); // Send frame every 100ms
    });
});

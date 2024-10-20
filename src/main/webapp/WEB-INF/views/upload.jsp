<!DOCTYPE html>
<html>
<head>
    <title>Upload Image</title>
    <style>
		body {
		    font-family: Arial, sans-serif;
		    background-image: url('/mg.jpeg');
		    background-size: cover;
		    background-position: center;
		    background-repeat: no-repeat;
		    background-attachment: fixed;
		    display: flex;
		    flex-direction: column;
		    align-items: center;
		    justify-content: center;
		    height: 100vh;
		    margin: 0;
		    color: #fff; /* Adjust the text color to contrast with the background */
		}

        h1 {
            color: #333;
        }
        form {
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        input[type="file"] {
            margin-bottom: 20px;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        button {
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
        p {
            margin-top: 20px;
            color: #666;
        }
        h2 {
            color: #333;
            margin-top: 40px;
        }
        #matchInfo {
            background: #fff;
            padding: 10px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            width: 80%;
            text-align: center;
            color: #007bff;
        }
    </style>
    <script type="text/javascript">
        let webSocket;

        function connectWebSocket() {
            webSocket = new WebSocket("app://localhost:8080/app");

            webSocket.onmessage = function(event) {
                document.getElementById("matchInfo").innerText = event.data;
            };

            webSocket.onopen = function() {
                console.log("WebSocket connection established");
            };

            webSocket.onclose = function() {
                console.log("WebSocket connection closed");
                setTimeout(connectWebSocket, 1000); // Reconnect after 1 second
            };

            webSocket.onerror = function(error) {
                console.log("WebSocket error: " + error.message);
            };
        }

        window.onload = function() {
            connectWebSocket();
        };
    </script>
</head>
<body>
    <h1>Upload Image</h1>
    <form method="post" enctype="multipart/form-data" action="/uploadImage">
        <input type="file" name="image" />
        <button type="submit">Upload</button>
    </form>
    <p>${message}</p>
    <h2>Person Information</h2>
    <p id="matchInfo">${matchInfo}</p>
</body>
</html>
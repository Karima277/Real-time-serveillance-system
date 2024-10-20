package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.Base64;

public class VideoWebSocketHandler extends TextWebSocketHandler {

    @Autowired
    private KafkaTemplate<String, byte[]> kafkaTemplate;

    private static final String UPLOAD_TOPIC = "facial_recognition_results";

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String base64Image = message.getPayload();

        // Check if the payload is in the expected format
        if (base64Image != null && base64Image.startsWith("data:image/jpeg;base64,")) {
            String[] parts = base64Image.split(",");
            if (parts.length > 1) {
                byte[] imageBytes = Base64.getDecoder().decode(parts[1]);
                kafkaTemplate.send(UPLOAD_TOPIC, imageBytes);
            } else {
                System.err.println("Invalid Base64 image data: " + base64Image);
            }
        } else {
            System.err.println("Invalid message payload: " + base64Image);
        }
    }
}
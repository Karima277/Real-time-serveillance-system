/*package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CameraController {

    @Autowired
    private WebSocketHandler webSocketHandler;

    @GetMapping("/camera")
    public String cameraPage(Model model) {
        model.addAttribute("matchInfo", "");
        return "camera"; // Assuming camera.jsp is in /WEB-INF/views/ directory
    }

    @KafkaListener(topics = "facial_recognition_results_display", groupId = "image-consumer-group")
    public void listen(String message) {
        System.out.println("Received message: " + message); // Logging for debugging
        try {
            webSocketHandler.sendMessage(message);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}*/

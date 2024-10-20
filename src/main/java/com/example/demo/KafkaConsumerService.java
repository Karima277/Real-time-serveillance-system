package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

//KafkaConsumerService.java
@Service
public class KafkaConsumerService {
 @Autowired
 private WebSocketHandler webSocketHandler;

 @KafkaListener(topics = "facial_recognition_results_display", groupId = "websocket-consumer-group")
 public void listen(String message) {
     try {
         webSocketHandler.sendMessage(message, message);
     } catch (Exception e) {
         e.printStackTrace();
     }
 }
}


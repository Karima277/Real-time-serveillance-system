//package com.example.demo.controller;

/*import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

//import com.example.demo.service.Producer;

@RestController
@RequestMapping("/rest/api")
public class RestControllerForKafkaMsg {
	
	@Autowired
    Producer producer;
	
	@GetMapping("/producerMsg")
	public String getMessageFromClient(@RequestParam("message") String message) {
		
		producer.sendMsgToTopic(message);
		return "Message sent Successfully to the your code decode topic ";
	}
}*/

package com.example.homepage;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/")
    public String home() {
        return "home.html";
    }
    public String index() {
        return "index.html";
    }
    public String index1() {
        return "index1.html";
    }
}

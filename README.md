# Spring Boot WebSocket Demo Project

This project is a simple Spring Boot application designed to demonstrate WebSocket capabilities. It provides a real-time chat application using **Java 17**, **Spring Boot 3.3**, **Gradle**, and **SockJS** with the **STOMP** protocol.

## Table of Contents

- [Introduction](#introduction)
- [Project Structure](#project-structure)
- [Development Guide](#development-guide)
    - [1. Project Configuration](#1-project-configuration)
    - [2. Managing Dependencies](#2-managing-dependencies)
    - [3. Writing Code](#3-writing-code)
    - [4. Using WebSocket](#4-using-websocket)

## Introduction

This project serves as a starting point for developing Spring Boot applications with integrated WebSocket support. It demonstrates how to set up a basic real-time chat application, manage dependencies, and structure your codebase for efficient development.

## Project Structure

```bash
websocket-demo/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── example/
│   │   │           └── websocketdemo/
│   │   │               ├── WebsocketDemoApplication.java
│   │   │               ├──  WebSocketConfig.java
│   │   │               ├──  ChatController.java
      
│   │   │                   └── ChatMessage.java
│   │   └── resources/
│   │       └── static/
│   │           └── index.html
│   └── test/
│       └── java/
│           └── com/
│               └── example/
│                   └── websocketdemo/
│                       └── WebsocketDemoApplicationTests.java
├── build.gradle
├── settings.gradle
├── Dockerfile
├── .dockerignore
└── README.md
```

## Development Guide
### 1. Project Configuration

- **Package Structure**

  The main package for the application is `com.example.websocketdemo`. All your Java classes should reside under this package or its sub-packages.

  - **Application Entry Point**

The main class is `WebsocketDemoApplication.java,` located at `src/main/java/com/example/websocketdemo/`.

- **Application Properties**

Configuration properties are located in `src/main/resources/application.properties`. Here you can configure settings like server port and other application-specific properties.

### 2. Managing Dependencies

Dependencies are managed in the `build.gradle` file located in the root directory of the project.

- **Adding a Dependency**

To add a new dependency, open `build.gradle` and add your `dependency` under the dependencies section. For example:

```groovy
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-websocket'
    implementation 'org.springframework.boot:spring-boot-starter-web'
    // Add your dependency here
    implementation 'org.springframework.boot:spring-boot-starter-security'
}
```

- **Updating Dependencies**

To update existing dependencies, modify the version numbers in the build.gradle file or update the plugin versions as needed.

### 3. Writing Code

- **Configuration**

WebSocket configuration classes should be placed under `src/main/java/com/example/websocketdemo/`.

Example: `WebSocketConfig.java`

- **Controllers**

Controllers handling WebSocket messages should be placed under `src/main/java/com/example/websocketdemo/`.

Example: `ChatController.java`

- **Models**

Model classes representing the data structures used in WebSocket communication should be placed under `src/main/java/com/example/websocketdemo/`.

Example: `ChatMessage.java`

- **Static Resources**

Client-side HTML, JavaScript, and CSS files should be placed under `src/main/resources/static/`.

Example: `index.html`

### 4. Using WebSocket
This section provides a guide on how to use WebSocket in this application, including setting up server-side configuration and implementing client-side code.

#### Step 1: WebSocket Configuration

Enable WebSocket message handling and configure message broker options.

File: `src/main/java/com/example/websocketdemo/WebSocketConfig.java`

Content:

```java
package com.example.websocketdemo.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

      @Override
      public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic");
        config.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws").withSockJS();
    }
}
```
Explanation:

- `@EnableWebSocketMessageBroker`: Enables WebSocket message handling.
- `configureMessageBroker`: Configures message broker options.
  - `enableSimpleBroker("/topic")`: Enables a simple in-memory message broker for destinations prefixed with `/topic`.
- `setApplicationDestinationPrefixes("/app")`: Prefixes for messages bound for methods annotated with `@MessageMapping`.
- `registerStompEndpoints`: Registers STOMP over WebSocket endpoints.

  #### Step 2: Creating Message Models
Define the data structures used for messaging between client and server.

File: `src/main/java/com/example/websocketdemo/ChatMessage.java`

Content:

```java
package com.example.websocketdemo.model;

public class ChatMessage {

    private String content;
    private String sender;
    private MessageType type;

    public enum MessageType {
        CHAT,
        JOIN,
        LEAVE
    }

    // Getters and Setters

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getSender() {
        return sender;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public MessageType getType() {
        return type;
    }

    public void setType(MessageType type) {
        this.type = type;
    }
}
```

#### Step 3: Implementing the Controller
Create a controller to handle incoming WebSocket messages and broadcast them to connected clients.

File: `src/main/java/com/example/websocketdemo/ChatController.java`

Content:

```java
package com.example.websocketdemo.controller;

import com.example.websocketdemo.model.ChatMessage;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.stereotype.Controller;

@Controller
public class ChatController {

    @MessageMapping("/chat.sendMessage")
    @SendTo("/topic/public")
    public ChatMessage sendMessage(@Payload ChatMessage chatMessage) {
        return chatMessage;
    }

    @MessageMapping("/chat.addUser")
    @SendTo("/topic/public")
    public ChatMessage addUser(@Payload ChatMessage chatMessage,
                               SimpMessageHeaderAccessor headerAccessor) {
        // Add username to WebSocket session attributes
        headerAccessor.getSessionAttributes().put("username", chatMessage.getSender());
        return chatMessage;
    }
}
```

Explanation:

- `@Controller`: Marks the class as a Spring MVC controller.
- `@MessageMapping`: Maps incoming messages to the methods.
- `@SendTo`: Specifies the destination to send messages to.
- `SimpMessageHeaderAccessor`: Allows access to message headers, such as session attributes.

  #### Step 4: Developing the Client-Side Code
Implement the client-side logic to interact with the WebSocket server.

File: `src/main/resources/static/index.html`

Content:

```html
<!DOCTYPE html>
<html>
<head>
    <title>WebSocket Chat</title>
    <meta charset="UTF-8"/>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        #messageArea {
            height: 400px;
            overflow-y: scroll;
            border: 1px solid #ccc;
            padding: 10px;
        }
        .chat-message {
            margin-bottom: 10px;
        }
        .event-message {
            font-style: italic;
            color: #888;
        }
    </style>
</head>
<body>
    <div class="container">
        <div id="username-page">
            <h2 class="mt-5">Enter your username</h2>
            <form id="usernameForm" class="mt-3">
                <div class="form-group">
                    <input type="text" id="name" placeholder="Username" class="form-control" required/>
                </div>
                <button type="submit" class="btn btn-primary">Start Chat</button>
            </form>
        </div>
        <div id="chat-page" style="display:none;">
            <div id="messageArea" class="mt-5"></div>
            <form id="messageForm" class="mt-3">
                <div class="form-group">
                    <input type="text" id="message" placeholder="Type a message..." class="form-control" required/>
                </div>
                <button type="submit" class="btn btn-primary">Send</button>
            </form>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.1/sockjs.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
    <script>
        (function() {
            var usernamePage = document.querySelector('#username-page');
            var chatPage = document.querySelector('#chat-page');
            var usernameForm = document.querySelector('#usernameForm');
            var messageForm = document.querySelector('#messageForm');
            var messageInput = document.querySelector('#message');
            var messageArea = document.querySelector('#messageArea');
            var stompClient = null;
            var username = null;

            function connect(event) {
                username = document.querySelector('#name').value.trim();
                if (username) {
                    usernamePage.style.display = 'none';
                    chatPage.style.display = 'block';

                    var socket = new SockJS('/ws');
                    stompClient = Stomp.over(socket);

                    stompClient.connect({}, onConnected, onError);
                }
                event.preventDefault();
            }

            function onConnected() {
                // Subscribe to the Public Topic
                stompClient.subscribe('/topic/public', onMessageReceived);

                // Tell your username to the server
                stompClient.send("/app/chat.addUser",
                    {},
                    JSON.stringify({sender: username, type: 'JOIN'})
                );
            }

            function onError(error) {
                alert('Could not connect to WebSocket server. Please refresh this page to try again!');
            }

            function sendMessage(event) {
                var messageContent = messageInput.value.trim();
                if (messageContent && stompClient) {
                    var chatMessage = {
                        sender: username,
                        content: messageContent,
                        type: 'CHAT'
                    };
                    stompClient.send("/app/chat.sendMessage", {}, JSON.stringify(chatMessage));
                    messageInput.value = '';
                }
                event.preventDefault();
            }

            function onMessageReceived(payload) {
                var message = JSON.parse(payload.body);

                var messageElement = document.createElement('div');

                if (message.type === 'JOIN') {
                    messageElement.classList.add('event-message');
                    messageElement.textContent = message.sender + ' joined!';
                } else if (message.type === 'LEAVE') {
                    messageElement.classList.add('event-message');
                    messageElement.textContent = message.sender + ' left!';
                } else {
                    messageElement.classList.add('chat-message');

                    var usernameElement = document.createElement('strong');
                    usernameElement.textContent = message.sender + ': ';
                    messageElement.appendChild(usernameElement);

                    var textElement = document.createElement('span');
                    textElement.textContent = message.content;
                    messageElement.appendChild(textElement);
                }

                messageArea.appendChild(messageElement);
                messageArea.scrollTop = messageArea.scrollHeight;
            }

            usernameForm.addEventListener('submit', connect, true);
            messageForm.addEventListener('submit', sendMessage, true);
        })();
    </script>
</body>
</html>
```

Explanation:

- `HTML Structure`: Provides a simple UI for entering a username and sending messages.
- `SockJS and STOMP.js`: Used for establishing the WebSocket connection.
- `JavaScript Functions`:
  -  `connect()`: Establishes the WebSocket connection.
  -  ` onConnected()`: Subscribes to the topic and notifies the server of a new user.
- `sendMessage()`: Sends messages to the server.
    - `onMessageReceived()`: Handles incoming messages and displays them.

    #### Step 5: Running the Application
*Build and Run the Application*

Use Gradle to build and run the application:

```bash
./gradlew bootRun
```

*Access the Application*

Open your browser and navigate to `http://localhost:8080`. Enter a username and start chatting in real-time.

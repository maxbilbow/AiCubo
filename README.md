# AiCubo

v0.6.x now works for both iOS and OSX
v0.4.2 (stable) is available for download: https://github.com/maxbilbow/RMSGameEngine/releases/tag/v0.4.2

TODO:
• Port OpenGLES back to OpenGL using preprocessing flags and moden OpenGL calls
• Add a user interface for toggling options
• Create a user interface for inputing custom behaviours
• Create simplified scipt processor for users to enter behavior scripts

Slowly building physics fromt the ground up.

• Started in C/C++ at uni (2007)

• Re-coded in C++ (Vesion: OpenGL 2.0)

• Translated into Objective-C for use on iOS (Version: RattleGL 3.3 https://www.youtube.com/watch?v=Wz75gmL7uVQ)

• Translated into Swift for better performance alround (Version 4.1)

Controls:
```Swift
class RMSKeys {
    
    var keys: [ RMKey ]?
    init(){
        self.keys = [
            RMKey(action: "forward", key: "w"),
            RMKey(action: "back", key: "s"),
            RMKey(action: "left", key: "a"),
            RMKey(action: "right", key: "d"),
            RMKey(action: "up", key: "e"),
            RMKey(action: "down", key: "q"),
            RMKey(action: "jump", key: " "),
            RMKey(action: "toggleGravity", key: "g"),
            RMKey(action: "toggleAllGravity", key: "G")
            RMKey(action: "toggleMouseLock", key: "m")//,
            RMKey(action: "grab", key: "Mouse 1"),
            RMKey(action: "throw", key: "Mouse 2"),
            RMKey(action: "extendArm", key: "Arrow-Up"),
            RMKey(action: "retractArm", key: "Arrow-Down"),
            RMKey(action: "shrinkItem", key: "-"),
            RMKey(action: "enlargeItem", key: "="),
            RMKey(action: "toggleFog", key: "f")
        ]
    }
    
  ```

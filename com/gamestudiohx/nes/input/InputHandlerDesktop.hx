package com.gamestudiohx.nes.input;

import com.gamestudiohx.nes.NES;


/**
 * ...
 * @author Krtolica Vujadin
 */
class InputHandlerDesktop {
	
	var nes:NES;
	
	public static inline var KEY_A:Int = 0;
	public static inline var KEY_B:Int = 1;
	public static inline var KEY_SELECT:Int = 2;
	public static inline var KEY_START:Int = 3;
	public static inline var KEY_UP:Int = 4;
	public static inline var KEY_DOWN:Int = 5;
	public static inline var KEY_LEFT:Int = 6;
	public static inline var KEY_RIGHT:Int = 7;
	
	public var state1:Array<Int>;
	public var state2:Array<Int>;

	public function new(nes:NES) {
		state1 = [];
		state2 = [];
		
		for (i in 0...8) { 
			state1[i] = 0x40;
			state2[i] = 0x40;
		}
		
		//Lib.current.stage.addEventListener(JoystickEvent.AXIS_MOVE, handleMovement);
		//Lib.current.stage.addEventListener(JoystickEvent.BUTTON_DOWN, handleButtons);
		
		//Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyboardDown);
		//Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyboardUp);
	}
	
	//function handleMovement(e:JoystickEvent) {
	//	trace(e);
	//}
	
	//function handleButtons(e:JoystickEvent) {
	//	trace(e);
	//}
	
	/*function handleKeyboardDown(e:KeyboardEvent) {
		keyDown(e.keyCode);
	}
	
	function handleKeyboardUp(e:KeyboardEvent) {
		keyUp(e.keyCode);
	}*/
	
	public function setKey(key:Int, value:Int) {
        switch (key) {
            case 120: this.state1[InputHandlerDesktop.KEY_A] = value;       // X
            case 122: this.state1[InputHandlerDesktop.KEY_B] = value;       // Y (Central European keyboard)
            case 121: this.state1[InputHandlerDesktop.KEY_B] = value;       // Z
            case 1073742048: this.state1[InputHandlerDesktop.KEY_SELECT] = value;  // Right Ctrl
            case 13: this.state1[InputHandlerDesktop.KEY_START] = value;   // Enter
            case 1073741906, 38: this.state1[InputHandlerDesktop.KEY_UP] = value;      // Up
            case 1073741905, 40: this.state1[InputHandlerDesktop.KEY_DOWN] = value;    // Down
            case 1073741904, 37: this.state1[InputHandlerDesktop.KEY_LEFT] = value;    // Left
            case 1073741903, 39: this.state1[InputHandlerDesktop.KEY_RIGHT] = value;   // Right
        }
    }

    public function keyDown(key:Int) {
        this.setKey(key, 0x41);
    }
    
	public function keyUp(key:Int) {
        this.setKey(key, 0x40);
    }
	
}

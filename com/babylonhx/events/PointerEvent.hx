package com.babylonhx.events;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PointerEvent {
	
	public var x:Int;
	public var y:Int;
	public var button:Int = -1;
	public var type:Int = PointerEventTypes.POINTERMOVE;
	
	/*pointerId:Null<Int>,
	pointerType:Null<Int>*/
	

	inline public function new(x:Int = 0, y:Int = 0, button:Int = -1, type:Int = PointerEventTypes.POINTERMOVE) {
		this.x = x;
		this.y = y;
		this.button = button;
		this.type = type;
	}
	
}

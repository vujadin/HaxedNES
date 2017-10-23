package;

import haxe.Timer;
import lime.app.Application;
import lime.Assets;
import lime.graphics.GLRenderContext;
import lime.graphics.opengl.WebGL2Context;
import lime.graphics.opengl.WebGLContext;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.graphics.RenderContext;
import lime.graphics.Renderer;
import lime.ui.Touch;
import lime.ui.Window;

import com.babylonhx.engine.Engine;
import com.babylonhx.Scene;


/**
 * ...
 * @author Krtolica Vujadin
 */
class Main extends Application {
	
	var scene:Scene;
	var engine:Engine;

	public function new() {
		super();
	}
	
	override public function onWindowCreate(window:Window) {
		switch (window.renderer.context) {
			case OPENGL (gl):
				var gl:WebGL2Context = gl;
				engine = new Engine(window, gl, true);	
				scene = new Scene(engine);
				
				engine.width = window.width;
				engine.height = window.height;
				
			default:
				//
		}
	}
	
	override public function onPreloadComplete() {	
		new HaxedNES(scene);
	}
	
	override function onMouseDown(window:Window, x:Float, y:Float, button:Int) {
		for(f in engine.mouseDown) {
			f(x, y, button);
		}
		
	}
	
	override function onMouseUp(window:Window, x:Float, y:Float, button:Int) {
		for(f in engine.mouseUp) {
			f(x, y, button);
		}
	}
	
	override function onMouseMove(window:Window, x:Float, y:Float) {
		for(f in engine.mouseMove) {
			f(x, y);
		}
	}
	
	override function onMouseWheel(window:Window, deltaX:Float, deltaY:Float) {
		for (f in engine.mouseWheel) {
			f(deltaY);
		}
	}
	
	override function onTouchStart(touch:Touch) {
		for (f in engine.touchDown) {
			f(touch.x, touch.y, touch.id);
		}
	}
	
	override function onTouchEnd(touch:Touch) {
		for (f in engine.touchUp) {
			f(touch.x, touch.y, touch.id);
		}
	}
	
	override function onTouchMove(touch:Touch) {
		for (f in engine.touchMove) {
			f(touch.x, touch.y, touch.id);
		}
	}

	override function onKeyUp(window:Window, keycode:Int, modifier:KeyModifier) {
		for(f in engine.keyUp) {
			f(keycode);
		}
	}
	
	override function onKeyDown(window:Window, keycode:Int, modifier:KeyModifier) {
		for(f in engine.keyDown) {
			f(keycode);
		}
	}
	
	override public function onWindowResize(window:Window, width:Int, height:Int) {
		if (engine != null) {
			engine.width = width;
			engine.height = height;
			engine.resize();
		}
	}
	
	override function update(deltaTime:Int) {
		engine._renderLoop();
	}
	
}

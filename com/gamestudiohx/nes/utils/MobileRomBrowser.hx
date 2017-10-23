package com.gamestudiohx.nes.utils;

import com.gamestudiohx.nes.NES;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.Lib;

import sys.FileSystem;


/**
 * ...
 * @author Krtolica Vujadin
 */
class MobileRomBrowser extends Sprite {
	
	static inline var itemHeight:Int = #if mobile 100 #else 40 #end ;
	static inline var fontSize:Int = #if mobile 30 #else 15 #end ;
	
	// smooth drag vars ...
	static inline var dragSmoothness:Float = 0.92;	
	var newY:Float;
	var oldY:Float;
	var ySpeed:Float;
	var updateY:Float;
	
	var nes:NES;
	var _parent:Sprite;
	
	var closeBtn:Sprite;
	var entries:Array<Sprite>;
	var entriesContainer:Sprite;
	var errorMsg:Sprite;
	var errorMsgText:TextField;
	var stageW:Int;
	var stageH:Int;
	var isPointerDown:Bool = false;
	var isClickDirty:Bool = false;
	var isMoving:Bool = false;
	var scrollPos:Float = 0;
	var initPos:Float = 0;
	var initPosCopy:Float = 0;
	
	var initDir:String;
	var onRomSelect:String->Void;

	
	public function new(initDir:String, nes:NES = null, parent:Sprite, onRomSelect:String->Void) {
		super();
		
		this._parent = parent;
		this.nes = nes;
		this.onRomSelect = onRomSelect;
		this.initDir = initDir;
		
		newY = oldY = ySpeed = 0;		
		
		closeBtn = new Sprite();
		closeBtn.graphics.lineStyle(1, 0xffffff);
		closeBtn.graphics.beginFill(0x4d5df3, 0.4);
		closeBtn.graphics.drawRect(itemHeight / 10, itemHeight / 10, itemHeight * 2, itemHeight - (itemHeight / 10) * 2);
		closeBtn.graphics.endFill();
		closeBtn.addEventListener(MouseEvent.CLICK, function(_) {
			this.hide();
		});
		addChild(closeBtn);
		
		var txtClose = new flash.text.TextField();
		txtClose.defaultTextFormat = new flash.text.TextFormat("Arial", fontSize, 0xffffff, true);
		txtClose.text = "CLOSE";
		txtClose.y = closeBtn.height / 3.5;
		txtClose.x = closeBtn.width / 2 - txtClose.width / 4;
		txtClose.selectable = false;
		closeBtn.addChild(txtClose);		
		
		entries = [];
		entriesContainer = new Sprite();
		var entriesContainerParent = new Sprite();
		entriesContainerParent.scrollRect = new Rectangle(0, 0, 10000, 10000);
		entriesContainerParent.y = itemHeight + (itemHeight / 10) / 2;
		entriesContainerParent.addChild(entriesContainer);
		addChild(entriesContainerParent);
		
		stageW = Lib.current.stage.stageWidth;
		stageH = Lib.current.stage.stageHeight;
		
		if (initDir != "" && FileSystem.isDirectory(initDir)) {
			var dirContent = FileSystem.readDirectory(initDir);
			
			var txtFormat = new flash.text.TextFormat("Arial", fontSize, 0xFFFFFF, true);
			
			var count:Int = 0;
			for (entry in dirContent) {
				if (StringTools.endsWith(entry, ".nes")) {
					trace(entry);
					var entrySprite = new Sprite();	
					entrySprite.name = entry;
					entrySprite.graphics.beginFill(count % 2 == 0 ? 0xffffff : 0x4d5df3, 0.3);
					entrySprite.graphics.drawRect(0, 0, stageW, itemHeight);
					entrySprite.graphics.endFill();
					entrySprite.graphics.lineStyle(1, 0xffffff);
					entrySprite.graphics.moveTo(0, itemHeight - 1);
					entrySprite.graphics.lineTo(stageW, itemHeight - 1);
					entrySprite.y = count * itemHeight;
					entrySprite.buttonMode = true;
					
					var txt = new ETextField();
					txt.defaultTextFormat = txtFormat;
					txt.text = entry;
					txt.rom = entry;
					txt.x = 10;
					txt.y = #if mobile 30 #else 10 #end ;
					txt.width = stageW;
					txt.selectable = false;
					entrySprite.addChild(txt);
					
					entries.push(entrySprite);
					entriesContainer.addChild(entrySprite);
					
					++count;
				}
			}
		}
		
		render();
		
		show();		
	}
	
	function render(?e:Event) {
		stageW = Lib.current.stage.stageWidth;
		stageH = Lib.current.stage.stageHeight;
		
		var g:Graphics = this.graphics;
		g.clear();
		g.beginFill(0, 0.8);
		g.drawRect(0, 0, stageW, stageH);
		g.endFill();
				
		var count:Int = 0;
		for (entry in entries) {
			entry.graphics.clear();
			entry.graphics.beginFill(count++ % 2 == 0 ? 0xffffff : 0x4d5df3, 0.3);
			entry.graphics.drawRect(0, 0, stageW, itemHeight);
			entry.graphics.endFill();
			entry.graphics.lineStyle(1, 0xffffff);
			entry.graphics.moveTo(0, itemHeight - 1);
			entry.graphics.lineTo(stageW, itemHeight - 1);		
		}
	}
	
	function smoothScroll(e:Event) {
		if(!isMoving) {
			entriesContainer.y += updateY;
			updateY *= dragSmoothness;
			if (entriesContainer.y > 0) {
				entriesContainer.y = 0;
			}
			if (entriesContainer.y < stageH - entries.length * itemHeight) {
				entriesContainer.y = stageH - entries.length * itemHeight;
			}
		}
	}
	
	function calculateDragSpeed(e:Event) {	
		newY = this.mouseY;
		ySpeed = newY - oldY;
		oldY = newY;
	}
	
	function mouseWheel(e:MouseEvent) {
		var mvt = e.delta < 0 ? -15 : 15;
		entriesContainer.y += mvt;
		if (entriesContainer.y > 0) {
			entriesContainer.y = 0;
		}
		if (entriesContainer.y < stageH - entries.length * itemHeight) {
			entriesContainer.y = stageH - entries.length * itemHeight;
		}
	}
	
	function mouseDown(e:MouseEvent) {
		if(entries.length * itemHeight > stageH) {
			isPointerDown = true;
		}
		initPos = initPosCopy = e.stageY;
		isMoving = true;
		ySpeed = updateY = 0;
		
		isClickDirty = false;
	}
	
	function mouseUp(e:MouseEvent) {
		isPointerDown = false;
		isMoving = false;
		updateY = ySpeed;
		
	#if mobile
		if (initPos == initPosCopy) {		// hack for mobiles, no movement happened
	#else
		if (!isClickDirty) {
	#end			
			onRomSelect(initDir + e.target.rom);
		}
	}
	
	function mouseMove(e:MouseEvent) {
		if (isPointerDown && isMoving) {
			entriesContainer.y += e.stageY - initPos;
			if (entriesContainer.y > 0) {
				entriesContainer.y = 0;
			}
			if (entriesContainer.y < stageH - entries.length * itemHeight) {
				entriesContainer.y = stageH - entries.length * itemHeight;
			}
			initPos = e.stageY;					
		}
	#if desktop
		isClickDirty = true;
	#end
	}
	
	public function show() {
		_parent.addChild(this);
		
		Lib.current.stage.addEventListener(Event.RESIZE, render);
	#if desktop
		entriesContainer.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
	#end
		entriesContainer.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		entriesContainer.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		entriesContainer.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		entriesContainer.addEventListener(Event.ENTER_FRAME, smoothScroll);
		addEventListener(Event.ENTER_FRAME, calculateDragSpeed);
		this.nes.stop();
	}
	
	public function hide() {
		_parent.removeChild(this);
		
		Lib.current.stage.removeEventListener(Event.RESIZE, render);
	#if desktop
		entriesContainer.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
	#end
		entriesContainer.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		entriesContainer.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
		entriesContainer.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		entriesContainer.removeEventListener(Event.ENTER_FRAME, smoothScroll);
		removeEventListener(Event.ENTER_FRAME, calculateDragSpeed);
		this.nes.start();
	}
	
}

class ETextField extends TextField {
	
	public var rom:String = "";
	
	
	public function new() {
		super();
	}
	
}

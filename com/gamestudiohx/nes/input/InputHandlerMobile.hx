package com.gamestudiohx.nes.input;

import com.gamestudiohx.nes.NES;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.Lib;

/**
 * ...
 * @author Krtolica Vujadin
 */
class InputHandlerMobile extends Sprite {
	
	public static inline var KEY_A:Int = 0;
	public static inline var KEY_B:Int = 1;
	public static inline var KEY_SELECT:Int = 2;
	public static inline var KEY_START:Int = 3;
	public static inline var KEY_UP:Int = 4;
	public static inline var KEY_DOWN:Int = 5;
	public static inline var KEY_LEFT:Int = 6;
	public static inline var KEY_RIGHT:Int = 7;
	
	var nes:NES;	
	public var state1:Array<Int>;
	public var state2:Array<Int>;
	
	var stageW:Int;
	var stageH:Int;
	
	var dirBtn:Sprite;
	var dirBtnLeft:Sprite;
	var dirBtnTop:Sprite;
	var dirBtnRight:Sprite;
	var dirBtnBottom:Sprite;
	
	var btnSelect:Sprite;
	var btnStart:Sprite;
	
	var btnA:Sprite;
	var btnB:Sprite;	
	
	var bmpDir:Bitmap;
	var bmpA:Bitmap;
	var bmpB:Bitmap;
	var bmpSelect:Bitmap;
	var bmpStart:Bitmap;	
	

	public function new(nes:NES) {
		super();
		
		this.nes = nes;
		state1 = [];
		state2 = [];
		
		for (i in 0...8) { 
			state1[i] = 0x40;
			state2[i] = 0x40;
		}
		
		bmpDir = new Bitmap(openfl.Assets.getBitmapData("img/btndir.png"));
		bmpA = new Bitmap(openfl.Assets.getBitmapData("img/btna.png"));
		bmpB = new Bitmap(openfl.Assets.getBitmapData("img/btnb.png"));
		bmpSelect = new Bitmap(openfl.Assets.getBitmapData("img/btnselect.png"));
		bmpStart = new Bitmap(openfl.Assets.getBitmapData("img/btnstart.png"));
		
				
		dirBtn = new Sprite();
		dirBtn.alpha = .4;
		dirBtn.addChild(bmpDir);		
		
		dirBtnLeft = new Sprite();
		dirBtnLeft.addEventListener(TouchEvent.TOUCH_BEGIN, function(_) { keyDown(37); dirBtn.alpha = .6; } );
		dirBtnLeft.addEventListener(TouchEvent.TOUCH_END, function(_) { keyUp(37); dirBtn.alpha = .4; } );
		dirBtnLeft.addEventListener(TouchEvent.TOUCH_OUT, function(_) { keyUp(37); dirBtn.alpha = .4; } );
		dirBtn.addChild(dirBtnLeft);
		
		dirBtnTop = new Sprite();
		dirBtnTop.addEventListener(TouchEvent.TOUCH_BEGIN, function(_) { keyDown(38); dirBtn.alpha = .6; } );
		dirBtnTop.addEventListener(TouchEvent.TOUCH_END, function(_) { keyUp(38); dirBtn.alpha = .4; } );
		dirBtnTop.addEventListener(TouchEvent.TOUCH_OUT, function(_) { keyUp(38); dirBtn.alpha = .4; } );
		dirBtn.addChild(dirBtnTop);
		
		dirBtnRight = new Sprite();
		dirBtnRight.addEventListener(TouchEvent.TOUCH_BEGIN, function(_) { keyDown(39); dirBtn.alpha = .6; } );
		dirBtnRight.addEventListener(TouchEvent.TOUCH_END, function(_) { keyUp(39); dirBtn.alpha = .4; } );
		dirBtnRight.addEventListener(TouchEvent.TOUCH_OUT, function(_) { keyUp(39); dirBtn.alpha = .4; } );
		dirBtn.addChild(dirBtnRight);
		
		dirBtnBottom = new Sprite();
		dirBtnBottom.addEventListener(TouchEvent.TOUCH_BEGIN, function(_) { keyDown(40); dirBtn.alpha = .6; } );
		dirBtnBottom.addEventListener(TouchEvent.TOUCH_END, function(_) { keyUp(40); dirBtn.alpha = .4; } );
		dirBtnBottom.addEventListener(TouchEvent.TOUCH_OUT, function(_) { keyUp(40); dirBtn.alpha = .4; } );
		dirBtn.addChild(dirBtnBottom);
		
		btnA = new Sprite();
		btnA.alpha = .4;
		btnA.addEventListener(TouchEvent.TOUCH_BEGIN, function(_) { keyDown(89); btnA.alpha = .6; } );
		btnA.addEventListener(TouchEvent.TOUCH_END, function(_) { keyUp(89); btnA.alpha = .4; } );
		btnA.addEventListener(TouchEvent.TOUCH_OUT, function(_) { keyUp(89); btnA.alpha = .4; } );
		btnA.addChild(bmpA);
		
		btnB = new Sprite();
		btnB.alpha = .4;
		btnB.addEventListener(TouchEvent.TOUCH_BEGIN, function(_) { keyDown(88); btnB.alpha = .6; } );
		btnB.addEventListener(TouchEvent.TOUCH_END, function(_) { keyUp(88); btnB.alpha = .4; } );
		btnB.addEventListener(TouchEvent.TOUCH_OUT, function(_) { keyUp(88); btnB.alpha = .4; } );
		btnB.addChild(bmpB);		
		
		btnSelect = new Sprite();
		btnSelect.alpha = .4;
		btnSelect.addEventListener(TouchEvent.TOUCH_BEGIN, function(_) { keyDown(17); btnSelect.alpha = .6; } );
		btnSelect.addEventListener(TouchEvent.TOUCH_END, function(_) { keyUp(17); btnSelect.alpha = .4; } );
		btnSelect.addEventListener(TouchEvent.TOUCH_OUT, function(_) { keyUp(17); btnSelect.alpha = .4; } );
		btnSelect.addChild(bmpSelect);
		
		btnStart = new Sprite();
		btnStart.alpha = .4;
		btnStart.addEventListener(TouchEvent.TOUCH_BEGIN, function(_) { keyDown(13); btnStart.alpha = .6; } );
		btnStart.addEventListener(TouchEvent.TOUCH_END, function(_) { keyUp(13); btnStart.alpha = .4; } );
		btnStart.addEventListener(TouchEvent.TOUCH_OUT, function(_) { keyUp(13); btnStart.alpha = .4; } );
		btnStart.addChild(bmpStart);	
				
		addChild(dirBtn);
		addChild(btnA);
		addChild(btnB);
		addChild(btnStart);
		addChild(btnSelect);		
		
		resize();
		
		Lib.current.stage.addEventListener(Event.RESIZE, resize);
	}
	
	function resize(?e:Event) {
		stageW = Lib.current.stage.stageWidth;
		stageH = Lib.current.stage.stageHeight;
		
		bmpDir.width = stageW > stageH ? stageH / 4 : stageW / 4;
		bmpDir.height = bmpDir.width;
		bmpA.width = bmpA.height = bmpB.width = bmpB.height = bmpDir.width / 2;
		bmpSelect.width = bmpStart.width = bmpA.width / 1.8;
		bmpSelect.height = bmpStart.height = bmpStart.width / 2.5;
		
		dirBtn.x = dirBtn.width / 4;
		dirBtn.y = stageH - dirBtn.height - (dirBtn.width / 4);
		
		btnB.x = stageW - btnB.width - (dirBtn.width / 4);
		btnB.y = btnA.y = stageH - btnB.height - (dirBtn.width / 4);
		btnA.x = btnB.x - btnA.width - (btnA.width / 4);
		
		btnStart.y = btnSelect.y = stageH - (btnStart.height * 3) - (dirBtn.width / 4);
		btnSelect.x = (stageW / 2) - btnSelect.width - (btnSelect.width / 6);
		btnStart.x = (stageW / 2) + btnSelect.width - (btnSelect.width / 6);
		
		dirBtnLeft.graphics.clear();
		dirBtnLeft.graphics.beginFill(0, 0);
		dirBtnLeft.graphics.drawRect(0, bmpDir.width / 3, bmpDir.width / 3, bmpDir.width / 3);
		dirBtnLeft.graphics.endFill();
		
		dirBtnRight.graphics.clear();
		dirBtnRight.graphics.beginFill(0, 0);
		dirBtnRight.graphics.drawRect((bmpDir.width / 3) * 2, bmpDir.width / 3, bmpDir.width / 3, bmpDir.width / 3);
		dirBtnRight.graphics.endFill();
		
		dirBtnTop.graphics.clear();
		dirBtnTop.graphics.beginFill(0, 0);
		dirBtnTop.graphics.drawRect(bmpDir.width / 3, 0, bmpDir.width / 3, bmpDir.width / 3);
		dirBtnTop.graphics.endFill();
		
		dirBtnBottom.graphics.clear();
		dirBtnBottom.graphics.beginFill(0, 0);
		dirBtnBottom.graphics.drawRect(bmpDir.width / 3, (bmpDir.width / 3) * 2, bmpDir.width / 3, bmpDir.width / 3);
		dirBtnBottom.graphics.endFill();
	}
	
	public function setKey(key:Int, value:Int) {
        switch (key) {
            case 88: this.state1[InputHandlerDesktop.KEY_A] = value;       
            case 89: this.state1[InputHandlerDesktop.KEY_B] = value;       
            case 90: this.state1[InputHandlerDesktop.KEY_B] = value;       
            case 17: this.state1[InputHandlerDesktop.KEY_SELECT] = value;  
            case 13: this.state1[InputHandlerDesktop.KEY_START] = value;   
            case 38: this.state1[InputHandlerDesktop.KEY_UP] = value;      
            case 40: this.state1[InputHandlerDesktop.KEY_DOWN] = value;    
            case 37: this.state1[InputHandlerDesktop.KEY_LEFT] = value;    
            case 39: this.state1[InputHandlerDesktop.KEY_RIGHT] = value;   
        }
    }

    public function keyDown(key:Int) {
        this.setKey(key, 0x41);
    }
    
	public function keyUp(key:Int) {
        this.setKey(key, 0x40);
    }
	
}

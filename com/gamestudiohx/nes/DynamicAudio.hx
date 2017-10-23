package com.gamestudiohx.nes;

import openfl.media.Sound;
import openfl.events.SampleDataEvent;
import openfl.media.SoundChannel;
import openfl.Assets;
import openfl.media.SoundTransform;

/**
 * ...
 * @author Krtolica Vujadin
 */
class DynamicAudio {
	
	public static inline var bufferSize:Int = 2048; // In samples
	public var sound:Sound;
	public var channel:SoundChannel;
	public var buffer:Array<Float>;
	

	public function new() {
		buffer = [];
		
		sound = new Sound(); 
		sound.addEventListener(SampleDataEvent.SAMPLE_DATA, soundGenerator);
		channel = sound.play();	
	}
	
	public function write(s:Array<Int>) {		
		var multiplier:Float = 1 / 32768;
		for (sample in s) {
			buffer.push(sample * multiplier);
		}
	}

	function soundGenerator(event:SampleDataEvent) {
		trace("sound generated");
		// If we haven't got enough data, write 2048 samples of silence to 
		// both channels, the minimum Flash allows
		if (buffer.length < DynamicAudio.bufferSize * 2) {
			for (i in 0...4096) {
				event.data.writeFloat(0.0);
			}
			return;
		}
		
		var count = Std.int(Math.min(this.buffer.length, 16384));
		
		for (sample in buffer.slice(0, count)) {
			event.data.writeFloat(sample);
		}
		
		buffer.splice(0, count);
	}
	
	public function destroy() {				
		sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, soundGenerator);
		channel.stop();
		channel = null;
		sound = null;	
		channel = null;
		buffer = null;
	}
	
}

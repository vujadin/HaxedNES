package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper034 extends MapperDefault {

	public function new(nes:NES) {
		super(nes);
	}
	
	override public function write(address:Int, value:Int) {
        if (address < 0x8000) {
            super.write(address, value);
        } else {
            load32kRomBank(value, 0x8000);
        }
    }
	
}

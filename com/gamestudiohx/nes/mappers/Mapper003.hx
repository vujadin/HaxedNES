package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper003 extends MapperDefault {

	public function new(nes:NES) {
		super(nes);
	}
	
	override public function write(address:Int, value:Int) {
        if (address < 0x8000) {
            // Let the base mapper take care of it.
            super.write(address, value);

        } else {
            // This is a VROM bank select command.
            // Swap in the given VROM bank at 0x0000:
            var bank = Std.int((value % (nes.rom.vromCount / 2)) * 2);
            loadVromBank(bank, 0x0000);
            loadVromBank(bank + 1, 0x1000);
            load8kVromBank(value * 2, 0x0000);
        }
    }
	
}

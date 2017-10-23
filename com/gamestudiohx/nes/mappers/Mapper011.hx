package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper011 extends MapperDefault {

	public function new(nes:NES) {
		super(nes);
	}
	
	override public function write(address:Int, value:Int) {

        if (address < 0x8000) {
            // Let the base mapper take care of it.
            super.write(address, value);

        } else {
            // Swap in the given PRG-ROM bank:
            var prgbank1 = ((value & 0xF) * 2) % nes.rom.romCount;
            var prgbank2 = ((value & 0xF) * 2 + 1) % nes.rom.romCount;

            loadRomBank(prgbank1, 0x8000);
            loadRomBank(prgbank2, 0xC000);


            if (nes.rom.romCount > 0) {
                // Swap in the given VROM bank at 0x0000:
                var bank = ((value >> 4) * 2) % nes.rom.romCount;
                loadVromBank(bank, 0x0000);
                loadVromBank(bank + 1, 0x1000);
            }
        }
    }
	
}

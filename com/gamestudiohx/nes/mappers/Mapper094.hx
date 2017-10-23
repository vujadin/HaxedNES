package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper094 extends MapperDefault {

	public function new(nes:NES) {
		super(nes);
	}
	
	override public function write(address:Int, value:Int) {
        if (address < 0x8000) {
            // Let the base mapper take care of it.
            super.write(address, value);
        } else {
            if ((address & 0xFFF0) == 0xFF00) {
                var bank = (value & 0x1C) >> 2;
                loadRomBank(bank, 0x8000);
            }
        }
    }

    override public function loadROM() {
        if (!nes.rom.valid) {
            trace("Invalid ROM! Unable to load.");
            return;
        }
		
        var num_banks = nes.rom.romCount;

        // Load PRG-ROM:
        loadRomBank(0, 0x8000);
        loadRomBank(num_banks - 1, 0xC000);

        // Load CHR-ROM:
        loadCHRROM();

        // Do Reset-Interrupt:
        nes.cpu.requestIrq(CPU.IRQ_RESET);
    }
	
}

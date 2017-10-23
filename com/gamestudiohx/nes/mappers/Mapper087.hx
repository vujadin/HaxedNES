package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper087 extends MapperDefault {

	public function new(nes:NES) {
		super(nes);
	}
	
	override public function writelow(address:Int, value:Int) {
        if (address < 0x6000) {
            // Let the base mapper take care of it.
            super.writelow(address, value);
        } else if (address == 0x6000) {
            var chr_bank = (value & 0x02) >> 1;
            load8kVromBank(chr_bank * 8, 0x0000);
        }
    }

    override public function loadROM() {
        if (!nes.rom.valid) {
            trace("Invalid ROM! Unable to load.");
            return;
        }

        // Get number of 8K banks:
        var num_8k_banks = nes.rom.romCount * 2;

        // Load PRG-ROM:
        load8kRomBank(0, 0x8000);
        load8kRomBank(1, 0xA000);
        load8kRomBank(2, 0xC000);
        load8kRomBank(3, 0xE000);

        // Load CHR-ROM:
        loadCHRROM();

        // Load Battery RAM (if present):

        // Do Reset-Interrupt:
        nes.cpu.requestIrq(CPU.IRQ_RESET);
    }
	
}
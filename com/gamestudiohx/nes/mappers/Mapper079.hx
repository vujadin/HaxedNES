package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper079 extends MapperDefault {

	public function new(nes:NES) {
		super(nes);
	}
	
	override public function writelow(address:Int, value:Int) {
        if (address < 0x4000) {
            super.writelow(address, value);
        }

        if (address < 0x6000 && address >= 0x4100) {
            var prg_bank = (value & 0x08) >> 3;
            var chr_bank = value & 0x07;

            load32kRomBank(prg_bank, 0x8000);
            load8kVromBank(chr_bank, 0x0000);
        }
    }

    override public function loadROM() {
        if (!nes.rom.valid) {
            trace("Invalid ROM! Unable to load.");
            return;
        }

        // Initial Load:
        loadPRGROM();
        loadCHRROM();

        // Do Reset-Interrupt:
        nes.cpu.requestIrq(CPU.IRQ_RESET);
    }
	
}
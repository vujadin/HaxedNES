package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.ROM;
import com.gamestudiohx.nes.CPU;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper140 extends MapperDefault {

	public function new(nes:NES) {
		super(nes);
	}
	
	override public function loadROM() {
        if (!nes.rom.valid || nes.rom.romCount < 1) {
            trace("Mapper 140: Invalid ROM! Unable to load.");
            return;
        }
		
        // Initial Load:
        loadPRGROM();
        loadCHRROM();
		
        // Do Reset-Interrupt:
        nes.cpu.requestIrq(CPU.IRQ_RESET);
    }

    override public function write(address:Int, value:Int) {
        if (address < 0x8000) {
            // Handle normally:
            super.write(address, value);
        }
		
        if (address >= 0x6000 && address < 0x8000) {
            var prg_bank = (value & 0xF0) >> 4;
            var chr_bank = value & 0x0F;
			
            load32kRomBank(prg_bank, 0x8000);
            load8kVromBank(chr_bank, 0x0000);
        }
    }
	
}

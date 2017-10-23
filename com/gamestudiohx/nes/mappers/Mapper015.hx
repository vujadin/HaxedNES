package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;
import com.gamestudiohx.nes.ROM;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper015 extends MapperDefault {

	public function new(nes:NES) {
		super(nes);
	}
	
	override public function write(address:Int, value:Int) {

        if (address < 0x8000) {
            super.write(address, value);
        } else {
            switch (address) {
                case 0x8000:                     
					if ((value & 0x80) != 0) {
						load8kRomBank((value & 0x3F) * 2 + 1, 0x8000);
						load8kRomBank((value & 0x3F) * 2 + 0, 0xA000);
						load8kRomBank((value & 0x3F) * 2 + 3, 0xC000);
						load8kRomBank((value & 0x3F) * 2 + 2, 0xE000);
					} else {
						load8kRomBank((value & 0x3F) * 2 + 0, 0x8000);
						load8kRomBank((value & 0x3F) * 2 + 1, 0xA000);
						load8kRomBank((value & 0x3F) * 2 + 2, 0xC000);
						load8kRomBank((value & 0x3F) * 2 + 3, 0xE000);
					}
					if ((value & 0x40) != 0) {
						nes.ppu.setMirroring(ROM.HORIZONTAL_MIRRORING);
					} else {
						nes.ppu.setMirroring(ROM.VERTICAL_MIRRORING);
					}
                   
                case 0x8001:                     
					if ((value & 0x80) != 0) {
						load8kRomBank((value & 0x3F) * 2 + 1, 0xC000);
						load8kRomBank((value & 0x3F) * 2 + 0, 0xE000);
					} else {
						load8kRomBank((value & 0x3F) * 2 + 0, 0xC000);
						load8kRomBank((value & 0x3F) * 2 + 1, 0xE000);
					}
                  
                case 0x8002:                     
					if ((value & 0x80) != 0) {
						load8kRomBank((value & 0x3F) * 2 + 1, 0x8000);
						load8kRomBank((value & 0x3F) * 2 + 1, 0xA000);
						load8kRomBank((value & 0x3F) * 2 + 1, 0xC000);
						load8kRomBank((value & 0x3F) * 2 + 1, 0xE000);
					} else {
						load8kRomBank((value & 0x3F) * 2, 0x8000);
						load8kRomBank((value & 0x3F) * 2, 0xA000);
						load8kRomBank((value & 0x3F) * 2, 0xC000);
						load8kRomBank((value & 0x3F) * 2, 0xE000);
					}
                    
                case 0x8003:                     
					if ((value & 0x80) != 0) {
						load8kRomBank((value & 0x3F) * 2 + 1, 0xC000);
						load8kRomBank((value & 0x3F) * 2 + 0, 0xE000);
					} else {
						load8kRomBank((value & 0x3F) * 2 + 0, 0xC000);
						load8kRomBank((value & 0x3F) * 2 + 1, 0xE000);
					}
					if ((value & 0x40) != 0) {
						nes.ppu.setMirroring(ROM.HORIZONTAL_MIRRORING);
					} else {
						nes.ppu.setMirroring(ROM.VERTICAL_MIRRORING);
					}
                    
            }
        }
    }

    override public function loadROM() {
        if (!nes.rom.valid) {
            trace("015: Invalid ROM! Unable to load.");
            return;
        }

        // Load PRG-ROM:
        load8kRomBank(0, 0x8000);
        load8kRomBank(1, 0xA000);
        load8kRomBank(2, 0xC000);
        load8kRomBank(3, 0xE000);

        // Load CHR-ROM:
        loadCHRROM();

        // Load Battery RAM (if present):
        loadBatteryRam();

        // Do Reset-Interrupt:
        nes.cpu.requestIrq(CPU.IRQ_RESET);
    }
	
}

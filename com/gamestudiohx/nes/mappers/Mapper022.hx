package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;
import com.gamestudiohx.nes.ROM;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper022 extends MapperDefault {

	public function new(nes:NES) {
		super(nes);
		reset();
	}
	
	override public function write(address:Int, value:Int) {
        if (address < 0x8000) {
            super.write(address, value);
        } else {
            //VRC2 write.
            switch (address) {
                case 0x8000:
                    load8kRomBank(value, 0x8000);
                    
                case 0x9000:
                    value &= 0x03;
					if (value == 0) {
						nes.ppu.setMirroring(ROM.VERTICAL_MIRRORING);
					} else if (value == 1) {
						nes.ppu.setMirroring(ROM.HORIZONTAL_MIRRORING);
					} else if (value == 2) {
						nes.ppu.setMirroring(ROM.SINGLESCREEN_MIRRORING);
					} else {
						nes.ppu.setMirroring(ROM.SINGLESCREEN_MIRRORING2);
					}
                    
                case 0xA000:
                    load8kRomBank(value, 0xA000);
                    
                case 0xB000:
                    load1kVromBank((value >> 1), 0x0000);
                    
                case 0xB001:
                    load1kVromBank((value >> 1), 0x0400);
                    
                case 0xC000:
                    load1kVromBank((value >> 1), 0x0800);
                    
                case 0xC001:
                    load1kVromBank((value >> 1), 0x0C00);
                    
                case 0xD000:
                    load1kVromBank((value >> 1), 0x1000);
                    
                case 0xD001:
                    load1kVromBank((value >> 1), 0x1400);
                    
                case 0xE000:
                    load1kVromBank((value >> 1), 0x1800);
                    
                case 0xE001:
                    load1kVromBank((value >> 1), 0x1C00);
                    
            }
        }

    }

    override public function loadROM() {
        if (!nes.rom.valid) {
            trace("VRC2: Invalid ROM! Unable to load.");
            return;
        }

        // Get number of 8K banks:
        var num_8k_banks = nes.rom.romCount * 2;

        // Load PRG-ROM:
        load8kRomBank(0, 0x8000);
        load8kRomBank(1, 0xA000);
        load8kRomBank(num_8k_banks - 2, 0xC000);
        load8kRomBank(num_8k_banks - 1, 0xE000);

        // Load CHR-ROM:
        loadCHRROM();

        // Do Reset-Interrupt:
        nes.cpu.requestIrq(CPU.IRQ_RESET);
    }
	
}

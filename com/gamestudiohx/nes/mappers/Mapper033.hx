package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;
import com.gamestudiohx.nes.ROM;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper033 extends MapperDefault {

	public function new(nes:NES) {
		super(nes);		
	}

	override public function write(address:Int, value:Int) {
        if (address < 0x8000) {
            super.write(address, value);
        } else {
            switch (address) {
                case 0x8000:
                    if ((value & 0x40) != 0) {
						nes.ppu.setMirroring(ROM.HORIZONTAL_MIRRORING);
					} else {
						nes.ppu.setMirroring(ROM.VERTICAL_MIRRORING);
					}
					load8kRomBank(value & 0x1F, 0x8000);
                   
                case 0x8001:
                    load8kRomBank(value & 0x1F, 0xA000);
                    
                case 0x8002:
                    load2kVromBank(value, 0x0000);
                    
                case 0x8003:
                    load2kVromBank(value, 0x0800);
                    
                case 0xA000:
                    load1kVromBank(value, 0x1000);
                    
                case 0xA001:
                    load1kVromBank(value, 0x1400);
                    
                case 0xA002:
                    load1kVromBank(value, 0x1800);
                    
                case 0xA003:
                    load1kVromBank(value, 0x1C00);
                    
            }
        }
    }

    override public function loadROM() {
        if (!nes.rom.valid) {
            trace("048: Invalid ROM! Unable to load.");
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

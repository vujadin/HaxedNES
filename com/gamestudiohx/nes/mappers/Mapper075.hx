package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;
import com.gamestudiohx.nes.ROM;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper075 extends MapperDefault {
	
	var regs:Array<Int>;

	public function new(nes:NES) {
		super(nes);
		reset();
	}
	
	override public function write(address:Int, value:Int) {
        if (address < 0x8000) {
            super.write(address, value);
        } else {
            switch (address & 0xF000) {
                case 0x8000:
                    load8kRomBank(value, 0x8000);
                    
                case 0x9000:                     
					if ((value & 0x01) != 0) {
						nes.ppu.setMirroring(ROM.HORIZONTAL_MIRRORING);
					} else {
						nes.ppu.setMirroring(ROM.VERTICAL_MIRRORING);
					}

					regs[0] = (regs[0] & 0x0F) | ((value & 0x02) << 3);
					loadVromBank(regs[0], 0x0000);

					regs[1] = (regs[1] & 0x0F) | ((value & 0x04) << 2);
					loadVromBank(regs[1], 0x1000);
                   
                case 0xA000:
                    load8kRomBank(value, 0xA000);
                    
                case 0xC000:
                    load8kRomBank(value, 0xC000);
                   
                case 0xE000:
                    regs[0] = (regs[0] & 0x10) | (value & 0x0F);
                    loadVromBank(regs[0], 0x0000);
                    
                case 0xF000:
                    regs[1] = (regs[1] & 0x10) | (value & 0x0F);
                    loadVromBank(regs[1], 0x1000);
                   
            }
        }
    }

    override public function loadROM() {
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

    override public function reset() {
		regs = [];
        regs[0] = 0;
        regs[1] = 1;
    }
	
}

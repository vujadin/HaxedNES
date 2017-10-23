package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;
import com.gamestudiohx.nes.ROM;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper078 extends MapperDefault {

	public function new(nes:NES) {
		super(nes);		
	}
	
	override public function write(address:Int, value:Int) {
        var prg_bank = value & 0x0F;
        var chr_bank = (value & 0xF0) >> 4;

        if (address < 0x8000) {
            super.write(address, value);
        } else {

            loadRomBank(prg_bank, 0x8000);
            load8kVromBank(chr_bank, 0x0000);

            if ((address & 0xFE00) != 0xFE00) {
                if ((value & 0x08) != 0) {
                    nes.ppu.setMirroring(ROM.SINGLESCREEN_MIRRORING2);
                } else {
                    nes.ppu.setMirroring(ROM.SINGLESCREEN_MIRRORING);
                }
            }
        }
    }

    override public function loadROM() {
        if (!nes.rom.valid) {
            return;
        }

        var num_16k_banks = nes.rom.romCount * 4;

        // Init:
        loadRomBank(0, 0x8000);
        loadRomBank(num_16k_banks - 1, 0xC000);

        loadCHRROM();

        // Do Reset-Interrupt:
        nes.cpu.requestIrq(CPU.IRQ_RESET);
    }
	
}

package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper072 extends MapperDefault {

	public function new(nes:NES) {
		super(nes);
	}
	
	override public function write(address:Int, value:Int) {
        if (address < 0x8000) {
            super.write(address, value);
        } else {
            var bank = value & 0x0f;
            var num_banks = nes.rom.romCount;

            if ((value & 0x80) != 0) {
                loadRomBank(bank * 2, 0x8000);
                loadRomBank(num_banks - 1, 0xC000);
            }
            if ((value & 0x40) != 0) {
                load8kVromBank(bank * 8, 0x0000);
            }
        }
    }

    override public function loadROM() {
        if (!nes.rom.valid) {
            trace("048: Invalid ROM! Unable to load.");
            return;
        }

        // Get number of 8K banks:
        var num_banks = nes.rom.romCount * 2;

        // Load PRG-ROM:
        loadRomBank(1, 0x8000);
        loadRomBank(num_banks - 1, 0xC000);

        // Load CHR-ROM:
        loadCHRROM();

        // Load Battery RAM (if present):
        // loadBatteryRam();

        // Do Reset-Interrupt:
        nes.cpu.requestIrq(CPU.IRQ_RESET);
    }
	
}

package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper071 extends MapperDefault {
	
	var curBank:Int;

	public function new(nes:NES) {
		super(nes);
		reset();
	}
	
	override public function loadROM() {
        if (!nes.rom.valid) {
            trace("Camerica: Invalid ROM! Unable to load.");
            return;
        }

        // Load PRG-ROM:
        loadRomBank(0, 0x8000);
        loadRomBank(nes.rom.romCount - 1, 0xC000);

        // Load CHR-ROM:
        loadCHRROM();

        // Load Battery RAM (if present):
        loadBatteryRam();

        // Do Reset-Interrupt:
        nes.cpu.requestIrq(CPU.IRQ_RESET);
    }

    override public function write(address:Int, value:Int) {
        if (address < 0x8000) {
            // Handle normally:
            super.write(address, value);

        } else if (address < 0xC000) {
            // Unknown function.
        } else {
            // Select 16K PRG ROM at 0x8000:
            if (value != curBank) {
                curBank = value;
                loadRomBank(value, 0x8000);
            }
        }
    }

    override function reset() {
        curBank = -1;
    }
	
}

package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper002 extends MapperDefault {

	public function new(nes:NES) {
		super(nes);
	}
	
	override function write(address:Int, value:Int) {
		// Writes to addresses other than MMC registers are handled by NoMapper.
		if (address < 0x8000) {
			super.write(address, value);
			return;
		}

		// This is a ROM bank select command.
		// Swap in the given ROM bank at 0x8000:
		loadRomBank(value, 0x8000);
	}
	
	override function loadROM() {
		if (!nes.rom.valid) {
			trace("UNROM: Invalid ROM! Unable to load.");
			return;
		}

		// Load PRG-ROM:
		loadRomBank(0, 0x8000);
		loadRomBank(nes.rom.romCount - 1, 0xC000);

		// Load CHR-ROM:
		loadCHRROM();

		// Do Reset-Interrupt:
		nes.cpu.requestIrq(CPU.IRQ_RESET);
	}
	
}

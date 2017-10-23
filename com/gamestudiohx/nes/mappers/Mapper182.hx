package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;
import com.gamestudiohx.nes.ROM;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper182 extends MapperDefault {
	
	var irq_counter:Int = 0;
    var irq_enabled:Bool = false;
    var regs:Array<Int>;

	public function new(nes:NES) {
		super(nes);
		reset();
	}
	
	override public function write(address:Int, value:Int) {

        if (address < 0x8000) {
            super.write(address, value);
        } else {
            switch (address & 0xF003) {
                case 0x8001:
					if ((value & 0x01) != 0) {
						nes.ppu.setMirroring(ROM.HORIZONTAL_MIRRORING);
					} else {
						nes.ppu.setMirroring(ROM.VERTICAL_MIRRORING);
					}
                   
                case 0xA000:
                    regs[0] = value & 0x07;
                    
                case 0xC000:
					switch (regs[0]) {
						case 0x00:
							load2kVromBank(value, 0x0000);
							
						case 0x01:
							load1kVromBank(value, 0x1400);
							
						case 0x02:
							load2kVromBank(value, 0x0800);
							
						case 0x03:
							load1kVromBank(value, 0x1C00);
							
						case 0x04:
							load8kRomBank(value, 0x8000);
							
						case 0x05:
							load8kRomBank(value, 0xA000);
							
						case 0x06:
							load1kVromBank(value, 0x1000);
							
						case 0x07:
							load1kVromBank(value, 0x1800);
							
					}

                case 0xE003:
                    irq_counter = value;
                    irq_enabled = (value != 0);

            }
        }
    }

    override public function loadROM() {
        if (!nes.rom.valid) {
            trace("182: Invalid ROM! Unable to load.");
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

    public function syncH(scanline:Int):Int {
        if (irq_enabled) {
            if ((scanline >= 0) && (scanline <= 240)) {
                if ((nes.ppu.scanline & 0x18) != 0) {
                    if (0 == (--irq_counter)) {
                        irq_counter = 0;
                        irq_enabled = false;
                        return 3;
                    }
                }
            }
        }
        return 0;
    }

    override public function reset() {
		regs = [];
        irq_enabled = false;
        irq_counter = 0;
    }
	
}

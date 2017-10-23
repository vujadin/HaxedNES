package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;
import com.gamestudiohx.nes.ROM;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper032 extends MapperDefault {
	
	var regs:Array<Int>;
    var patch:Int = 0;

	public function new(nes:NES) {
		super(nes);		
	}
	
	override public function write(address:Int, value:Int) {
        if (address < 0x8000) {
            super.write(address, value);
        } else {
            switch (address & 0xF000) {
                case 0x8000:
                    if ((regs[0] & 0x02) != 0) {
						load8kRomBank(value, 0xC000);
					} else {
						load8kRomBank(value, 0x8000);
					}                   

                case 0x9000:
                    if ((value & 0x01) != 0) {
						nes.ppu.setMirroring(ROM.HORIZONTAL_MIRRORING);
					} else {
						nes.ppu.setMirroring(ROM.VERTICAL_MIRRORING);
					}
					regs[0] = value;
                    
                case 0xA000:
                    load8kRomBank(value, 0xA000);
                    
            }

            switch (address & 0xF007) {
                case 0xB000:
                    load1kVromBank(value, 0x0000);
                    
                case 0xB001:
                    load1kVromBank(value, 0x0400);
                    
                case 0xB002:
                    load1kVromBank(value, 0x0800);
                    
                case 0xB003:
                    load1kVromBank(value, 0x0C00);
                    
                case 0xB004:
                    load1kVromBank(value, 0x1000);
                    
                case 0xB005:
                    load1kVromBank(value, 0x1400);
                    
                case 0xB006:
                    if ((patch == 1) && ((value & 0x40) != 0)) {
						// nes.getPpu().setMirroring(ROM.SINGLESCREEN_MIRRORING); /* 0,0,0,1 */
					}
					load1kVromBank(value, 0x1800);                                       

                case 0xB007:
                    if ((patch == 1) && ((value & 0x40) != 0)) {
						nes.ppu.setMirroring(ROM.SINGLESCREEN_MIRRORING);
					}
					load1kVromBank(value, 0x1C00);
                    
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
        if (patch == 1) {
            nes.ppu.setMirroring(ROM.SINGLESCREEN_MIRRORING);
        }

		regs = [0];
    }
	
}

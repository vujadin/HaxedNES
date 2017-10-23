package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;
import com.gamestudiohx.nes.ROM;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper023 extends MapperDefault {
	
	var irq_counter:Int;
    var irq_latch:Int;
    var irq_enabled:Int;
    var regs:Array<Int>;
    static inline var patch:Int = 0xFFFF;

	public function new(nes:NES) {
		super(nes);
		reset();
	}
	
	override public function write(address:Int, value:Int) {

        if (address < 0x8000) {
            super.write(address, value);
        } else {
            switch (address & patch) {
                case 0x8000, 0x8004, 0x8008, 0x800C:
					if ((regs[8]) != 0) {
						load8kRomBank(value, 0xC000);
					} else {
						load8kRomBank(value, 0x8000);
					}
                    
                case 0x9000:
					if (value != 0xFF) {
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
					}
                    
                case 0x9008:
                    regs[8] = value & 0x02;
                    
                case 0xA000, 0xA004, 0xA008, 0xA00C:
                    load8kRomBank(value, 0xA000);
                    
                case 0xB000:
                    regs[0] = (regs[0] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[0], 0x0000);
                    
                case 0xB001, 0xB004:
                    regs[0] = (regs[0] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[0], 0x0000);
                    
                case 0xB002, 0xB008:
                    regs[1] = (regs[1] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[1], 0x0400);
                    
                case 0xB003, 0xB00C:
                    regs[1] = (regs[1] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[1], 0x0400);
                    
                case 0xC000:
                    regs[2] = (regs[2] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[2], 0x0800);
                    
                case 0xC001, 0xC004:
                    regs[2] = (regs[2] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[2], 0x0800);
                    
                case 0xC002, 0xC008:
                    regs[3] = (regs[3] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[3], 0x0C00);
                    
                case 0xC003, 0xC00C:
                    regs[3] = (regs[3] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[3], 0x0C00);
                    
                case 0xD000:
                    regs[4] = (regs[4] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[4], 0x1000);
                    
                case 0xD001, 0xD004:
                    regs[4] = (regs[4] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[4], 0x1000);
                    
                case 0xD002, 0xD008:
                    regs[5] = (regs[5] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[5], 0x1400);
                                        
                case 0xD003, 0xD00C:
                    regs[5] = (regs[5] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[5], 0x1400);
                    
                case 0xE000:
                    regs[6] = (regs[6] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[6], 0x1800);
                    
                case 0xE004:
                    regs[6] = (regs[6] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[6], 0x1800);
                    
                case 0xE002, 0xE008:
                    regs[7] = (regs[7] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[7], 0x1C00);
                    
                case 0xE003, 0xE00C:
                    regs[7] = (regs[7] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[7], 0x1C00);                    

                case 0xF000:
                    irq_latch = (irq_latch & 0xF0) | (value & 0x0F);
                    
                case 0xF004:
                    irq_latch = (irq_latch & 0x0F) | ((value & 0x0F) << 4);
                    
                case 0xF008:
                    irq_enabled = value & 0x03;
					if ((irq_enabled & 0x02) != 0) {
						irq_counter = irq_latch;
					}
                    
                case 0xF00C:
                    irq_enabled = (irq_enabled & 0x01) * 3;
                    
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

    public function syncH(scanline:Int) {
        if ((irq_enabled & 0x02) != 0) {
            if (irq_counter == 0xFF) {
                irq_counter = irq_latch;
                irq_enabled = (irq_enabled & 0x01) * 3;
                return 3;
            } else {
                irq_counter++;
            }
        }

        return 0;
    }

    override public function reset() {
		regs = [];
        regs[0] = 0;
        regs[1] = 1;
        regs[2] = 2;
        regs[3] = 3;
        regs[4] = 4;
        regs[5] = 5;
        regs[6] = 6;
        regs[7] = 7;
        regs[8] = 0;

        // IRQ Settings
        irq_enabled = 0;
        irq_latch = 0;
        irq_counter = 0;
    }
	
}

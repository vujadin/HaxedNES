package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;
import com.gamestudiohx.nes.ROM;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper021 extends MapperDefault {
	
	private var irq_counter:Int = 0;
    private var irq_latch:Int = 0;
    private var irq_enabled:Int = 0;
    private var regs:Array<Int>;

	public function new(nes:NES) {
		super(nes);
		reset();
	}
	
	override public function write(address:Int, value:Int) {
        if (address < 0x8000) {
            super.write(address, value);
        } else {
            switch (address & 0xF0CF) {
                case 0x8000:                    
					if ((regs[8] & 0x02) != 0) {
						load8kRomBank(value, 0xC000);
					} else {
						load8kRomBank(value, 0x8000);
					}
                    
                case 0xA000:
                    load8kRomBank(value, 0xA000);
                   
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
                    
                case 0x9002, 0x9080:
                    regs[8] = value;
                    
                case 0xB000:
                    regs[0] = (regs[0] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[0], 0x0000);
                    
                case 0xB002, 0xB040:
                    regs[0] = (regs[0] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[0], 0x0000);
                    
                case 0xB001, 0xB004, 0xB080:
                    regs[1] = (regs[1] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[1], 0x0400);
                    
                case 0xB003, 0xB006, 0xB0C0:
                    regs[1] = (regs[1] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[1], 0x0400);
                    
                case 0xC000:
                    regs[2] = (regs[2] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[2], 0x0800);
                    
                case 0xC002, 0xC040:
                    regs[2] = (regs[2] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[2], 0x0800);
                    
                case 0xC001, 0xC004, 0xC080:
                    regs[3] = (regs[3] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[3], 0x0C00);
                    
                case 0xC003, 0xC006, 0xC0C0:
                    regs[3] = (regs[3] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[3], 0x0C00);
                    
                case 0xD000:
                    regs[4] = (regs[4] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[4], 0x1000);
                    
                case 0xD040, 0xD002:
                    regs[4] = (regs[4] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[4], 0x1000);
                    
                case 0xD080, 0xD004, 0xD001:
                    regs[5] = (regs[5] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[5], 0x1400);
                    
                case 0xD0C0, 0xD006, 0xD003:
                    regs[5] = (regs[5] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[5], 0x1400);
                    
                case 0xE000:
                    regs[6] = (regs[6] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[6], 0x1800);
                    
                case 0xE040, 0xE002:
                    regs[6] = (regs[6] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[6], 0x1800);
                                        
                case 0xE080, 0xE004, 0xE001:
                    regs[7] = (regs[7] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[7], 0x1C00);
                                        
                case 0xE0C0, 0xE003, 0xE006:
                    regs[7] = (regs[7] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[7], 0x1C00);
                    
                case 0xF000:
                    irq_latch = (irq_latch & 0xF0) | (value & 0x0F);
                    
                case 0xF040, 0xF002:
                    irq_latch = (irq_latch & 0x0F) | ((value & 0x0F) << 4);
                    
                case 0xF0C0, 0xF003:
                    irq_enabled = (irq_enabled & 0x01) * 3;

                case 0xF080, 0xF004:                     
					irq_enabled = value & 0x03;
					if ((irq_enabled & 0x02) != 0) {
						irq_counter = irq_latch;
					}
                    
            }
        }
    }

    override public function loadROM() {
        if (!nes.rom.valid) {
            trace("VRC4: Invalid ROM! Unable to load.");
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

        // Load Battery RAM (if present):
        loadBatteryRam();

        // Do Reset-Interrupt:
        nes.cpu.requestIrq(CPU.IRQ_RESET);
    }

    public function syncH(scanline:Int):Int {
        if ((irq_enabled & 0x02) != 0) {
            if (irq_counter == 0) {
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

package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;
import com.gamestudiohx.nes.ROM;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper009 extends MapperDefault {
	
	var latchLo:Int;
    var latchHi:Int;
    var latchLoVal1:Int;
    var latchLoVal2:Int;
    var latchHiVal1:Int;
    var latchHiVal2:Int;

	public function new(nes:NES) {
		super(nes);
		reset();
	}
	
	override public function write(address:Int, value:Int) {
        if (address < 0x8000) {
            // Handle normally.
            super.write(address, value);
        } else {
            // MMC2 write.
            value &= 0xFF;
            address &= 0xF000;
            switch (address >> 12) {
                case 0xA: 
                    // Select 8k ROM bank at 0x8000
                    load8kRomBank(value, 0x8000);
                
                case 0xB: 
                    // Select 4k VROM bank at 0x0000, $FD mode
                    latchLoVal1 = value;
                    if (latchLo == 0xFD) {
                        loadVromBank(value, 0x0000);
                    }
                
                case 0xC: 
                    // Select 4k VROM bank at 0x0000, $FE mode
                    latchLoVal2 = value;
                    if (latchLo == 0xFE) {
                        loadVromBank(value, 0x0000);
                    }

                
                case 0xD: 
                    // Select 4k VROM bank at 0x1000, $FD mode
                    latchHiVal1 = value;
                    if (latchHi == 0xFD) {
                        loadVromBank(value, 0x1000);
                    }
                
                case 0xE: 
                    // Select 4k VROM bank at 0x1000, $FE mode
                    latchHiVal2 = value;
                    if (latchHi == 0xFE) {
                        loadVromBank(value, 0x1000);
                    }
                
                case 0xF: 
                    // Select mirroring
                    if ((value & 0x1) == 0) {
                        // Vertical mirroring
                        nes.ppu.setMirroring(ROM.VERTICAL_MIRRORING);

                    } else {
                        // Horizontal mirroring
                        nes.ppu.setMirroring(ROM.HORIZONTAL_MIRRORING);
                    }
                
            }
        }
    }

    override public function loadROM() {
        if (!nes.rom.valid) {
            trace("MMC2: Invalid ROM! Unable to load.");
            return;
        }

        // Get number of 8K banks:
        var num_8k_banks = nes.rom.romCount * 2;

        // Load PRG-ROM:
        load8kRomBank(0, 0x8000);
        load8kRomBank(num_8k_banks - 3, 0xA000);
        load8kRomBank(num_8k_banks - 2, 0xC000);
        load8kRomBank(num_8k_banks - 1, 0xE000);

        // Load CHR-ROM:
        loadCHRROM();

        // Load Battery RAM (if present):
        loadBatteryRam();

        // Do Reset-Interrupt:
        nes.cpu.requestIrq(CPU.IRQ_RESET);
    }

    override public function latchAccess(address:Int) {
        if ((address & 0x1FF0) == 0x0FD0 && latchLo != 0xFD) {
            // Set $FD mode
            loadVromBank(latchLoVal1, 0x0000);
            latchLo = 0xFD;
        } else if ((address & 0x1FF0) == 0x0FE0 && latchLo != 0xFE) {
            // Set $FE mode
            loadVromBank(latchLoVal2, 0x0000);
            latchLo = 0xFE;
        } else if ((address & 0x1FF0) == 0x1FD0 && latchHi != 0xFD) {
            // Set $FD mode
            loadVromBank(latchHiVal1, 0x1000);
            latchHi = 0xFD;
        } else if ((address & 0x1FF0) == 0x1FE0 && latchHi != 0xFE) {
            // Set $FE mode
            loadVromBank(latchHiVal2, 0x1000);
            latchHi = 0xFE;
        }
    }

    /*public void mapperInternalStateLoad(ByteBuffer buf) {

        super.mapperInternalStateLoad(buf);

        // Check version:
        if (buf.readByte() == 1) {

            latchLo = buf.readByte();
            latchHi = buf.readByte();
            latchLoVal1 = buf.readByte();
            latchLoVal2 = buf.readByte();
            latchHiVal1 = buf.readByte();
            latchHiVal2 = buf.readByte();

        }

    }

    public void mapperInternalStateSave(ByteBuffer buf) {

        super.mapperInternalStateSave(buf);

        // Version:
        buf.putByte((short) 1);

        // State:
        buf.putByte((byte) latchLo);
        buf.putByte((byte) latchHi);
        buf.putByte((byte) latchLoVal1);
        buf.putByte((byte) latchLoVal2);
        buf.putByte((byte) latchHiVal1);
        buf.putByte((byte) latchHiVal2);

    }*/

    override public function reset() {
        // Set latch to $FE mode:
        latchLo = 0xFE;
        latchHi = 0xFE;
        latchLoVal1 = 0;
        latchLoVal2 = 4;
        latchHiVal1 = 0;
        latchHiVal2 = 0;
    }
	
}

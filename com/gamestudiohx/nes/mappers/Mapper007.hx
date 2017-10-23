package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.ROM;
import com.gamestudiohx.nes.Utils;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper007 extends MapperDefault {
	
	var currentOffset:Int;
    var currentMirroring:Int;
    var prgrom:Array<Int>;

	public function new(nes:NES) {
		super(nes);
		
		currentOffset = 0;
        currentMirroring = -1;

        // Read out all PRG rom:
        var bc = nes.rom.romCount;
        prgrom = [];
        for (i in 0...bc) {
			//Utils.copyArrayElements(nes.rom.rom[i], 0, prgrom, i * 16384, 16384);
			
			for (u in 0...16384) {
				prgrom[(i * 16384) + u] = nes.rom.rom[i][u];
			}
        }
	}
	
	override public function load(address:Int):Int {
        if (address < 0x8000) {
            // Register read
            return super.load(address);
        } else {
            if ((address + currentOffset) >= 262144) {
                return prgrom[(address + currentOffset) - 262144];
            } else {
                return prgrom[address + currentOffset];
            }
        }
    }

    override public function write(address:Int, value:Int) {
        if (address < 0x8000) {
            // Let the base mapper take care of it.
            super.write(address, value);
        } else {
            // Set PRG offset:
            currentOffset = ((value & 0xF) - 1) << 15;

            // Set mirroring:
            if (currentMirroring != (value & 0x10)) {
                currentMirroring = value & 0x10;
                if (currentMirroring == 0) {
                    nes.ppu.setMirroring(ROM.SINGLESCREEN_MIRRORING);
                } else {
                    nes.ppu.setMirroring(ROM.SINGLESCREEN_MIRRORING2);
                }
            }
        }
    }

    /*public void mapperInternalStateLoad(ByteBuffer buf) {

        super.mapperInternalStateLoad(buf);

        // Check version:
        if (buf.readByte() == 1) {

            currentMirroring = buf.readByte();
            currentOffset = buf.readInt();

        }

    }

    public void mapperInternalStateSave(ByteBuffer buf) {

        super.mapperInternalStateSave(buf);

        // Version:
        buf.putByte((short) 1);

        // State:
        buf.putByte((short) currentMirroring);
        buf.putInt(currentOffset);

    }*/

    override function reset() {
        super.reset();
        currentOffset = 0;
        currentMirroring = -1;
    }
	
}

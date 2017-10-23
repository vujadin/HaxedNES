package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.CPU;
import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.ROM;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper001 extends MapperDefault {
	
	// 5-bit buffer:
    var regBuffer:Int;
    var regBufferCounter:Int;

    // Register 0:
    var mirroring:Int;
    var oneScreenMirroring:Int;
    var prgSwitchingArea:Int;
    var prgSwitchingSize:Int;
    var vromSwitchingSize:Int;

    // Register 1:
    var romSelectionReg0:Int;

    // Register 2:
    var romSelectionReg1:Int;

    // Register 3:
    var romBankSelect:Int;

	public function new(nes:NES) {
		super(nes);
		
		// 5-bit buffer:
		this.regBuffer = 0;
		this.regBufferCounter = 0;

		// Register 0:
		this.mirroring = 0;
		this.oneScreenMirroring = 0;
		this.prgSwitchingArea = 1;
		this.prgSwitchingSize = 1;
		this.vromSwitchingSize = 0;

		// Register 1:
		this.romSelectionReg0 = 0;

		// Register 2:
		this.romSelectionReg1 = 0;

		// Register 3:
		this.romBankSelect = 0;
	}
	
	public override function write(address:Int, value:Int) {
        // Writes to addresses other than MMC registers are handled by NoMapper.
		if (address < 0x8000) {
			super.write(address, value);
			return;
		}

		// See what should be done with the written value:
		if ((value & 128) != 0) {

			// Reset buffering:
			this.regBufferCounter = 0;
			this.regBuffer = 0;
		
			// Reset register:
			if (this.getRegNumber(address) == 0) {			
				this.prgSwitchingArea = 1;
				this.prgSwitchingSize = 1;			
			}
		}
		else {		
			// Continue buffering:
			//regBuffer = (regBuffer & (0xFF-(1<<regBufferCounter))) | ((value & (1<<regBufferCounter))<<regBufferCounter);
			this.regBuffer = (this.regBuffer & (0xFF - (1 << this.regBufferCounter))) | ((value & 1) << this.regBufferCounter);
			this.regBufferCounter++;
			
			if (this.regBufferCounter == 5) {
				// Use the buffered value:
				this.setReg(this.getRegNumber(address), this.regBuffer);
			
				// Reset buffer:
				this.regBuffer = 0;
				this.regBufferCounter = 0;
			}
		}
    }
	
	function setReg(reg:Int, value:Int) {
		var tmp:Int = 0;

		switch (reg) {
			case 0:
				// Mirroring:
				tmp = value & 3;
				if (tmp != this.mirroring) {
					// Set mirroring:
					this.mirroring = tmp;
					if ((this.mirroring & 2) == 0) {
						// SingleScreen mirroring overrides the other setting:
						this.nes.ppu.setMirroring(ROM.SINGLESCREEN_MIRRORING);
					}
					// Not overridden by SingleScreen mirroring.
					else if ((this.mirroring & 1) != 0) {
						this.nes.ppu.setMirroring(ROM.HORIZONTAL_MIRRORING);
					}
					else {
						this.nes.ppu.setMirroring(ROM.VERTICAL_MIRRORING);
					}
				}
		
				// PRG Switching Area;
				this.prgSwitchingArea = (value >> 2) & 1;
		
				// PRG Switching Size:
				this.prgSwitchingSize = (value >> 3) & 1;
		
				// VROM Switching Size:
				this.vromSwitchingSize = (value >> 4) & 1;			
		
			case 1:
				// ROM selection:
				this.romSelectionReg0 = (value >> 4) & 1;
		
				// Check whether the cart has VROM:
				if (this.nes.rom.vromCount > 0) {
			
					// Select VROM bank at 0x0000:
					if (this.vromSwitchingSize == 0) {
			
						// Swap 8kB VROM:
						if (this.romSelectionReg0 == 0) {
							this.load8kVromBank((value & 0xF), 0x0000);
						}
						else {
							this.load8kVromBank(
								Math.floor(this.nes.rom.vromCount / 2) +
									(value & 0xF), 
								0x0000
							);
						}
				
					}
					else {
						// Swap 4kB VROM:
						if (this.romSelectionReg0 == 0) {
							this.loadVromBank((value & 0xF), 0x0000);
						}
						else {
							this.loadVromBank(
								Math.floor(this.nes.rom.vromCount / 2) +
									(value & 0xF),
								0x0000
							);
						}
					}
				}
		
			case 2:
				// ROM selection:
				this.romSelectionReg1 = (value >> 4) & 1;
		
				// Check whether the cart has VROM:
				if (this.nes.rom.vromCount > 0) {
					
					// Select VROM bank at 0x1000:
					if (this.vromSwitchingSize == 1) {
						// Swap 4kB of VROM:
						if (this.romSelectionReg1 == 0) {
							this.loadVromBank((value & 0xF), 0x1000);
						}
						else {
							this.loadVromBank(
								Math.floor(this.nes.rom.vromCount / 2) +
									(value & 0xF),
								0x1000
							);
						}
					}
				}
		
			default:
				// Select ROM bank:
				// -------------------------
				tmp = value & 0xF;
				var bank:Int = 0;
				var baseBank:Int = 0;
		
				if (this.nes.rom.romCount >= 32) {
					// 1024 kB cart
					if (this.vromSwitchingSize == 0) {
						if (this.romSelectionReg0 == 1) {
							baseBank = 16;
						}
					}
					else {
						baseBank = (this.romSelectionReg0 
									| (this.romSelectionReg1 << 1)) << 3;
					}
				}
				else if (this.nes.rom.romCount >= 16) {
					// 512 kB cart
					if (this.romSelectionReg0 == 1) {
						baseBank = 8;
					}
				}
		
				if (this.prgSwitchingSize == 0) {
					// 32kB
					bank = baseBank + (value & 0xF);
					this.load32kRomBank(bank, 0x8000);
				}
				else {
					// 16kB
					bank = baseBank * 2 + (value & 0xF);
					if (this.prgSwitchingArea == 0) {
						this.loadRomBank(bank, 0xC000);
					}
					else {
						this.loadRomBank(bank, 0x8000);
					}
				}  
		}
	}
	
	inline function getRegNumber(address:Int):Int {
		var ret:Int = 0;
		if (address >= 0x8000 && address <= 0x9FFF) {
			ret = 0;
		}
		else if (address >= 0xA000 && address <= 0xBFFF) {
			ret = 1;
		}
		else if (address >= 0xC000 && address <= 0xDFFF) {
			ret = 2;
		} else {
			ret = 3;
		}
		
		return ret;
	}
	
	override function loadROM() {
		if (!this.nes.rom.valid) {
			trace("MMC1: Invalid ROM! Unable to load.");
			return;
		}

		// Load PRG-ROM:
		this.loadRomBank(0, 0x8000);                         //   First ROM bank..
		this.loadRomBank(this.nes.rom.romCount - 1, 0xC000); // ..and last ROM bank.

		// Load CHR-ROM:
		this.loadCHRROM();

		// Load Battery RAM (if present):
		this.loadBatteryRam();

		// Do Reset-Interrupt:
		this.nes.cpu.requestIrq(CPU.IRQ_RESET);
	}
	
	function switchLowHighPrgRom(oldSetting:Dynamic) {
		// not yet.
	}

	function switch16to32() {
		// not yet.
	}

	function switch32to16() {
		// not yet.
	}

	override function toJSON():Dynamic {
		var s = super.toJSON();
		s.mirroring = this.mirroring;
		s.oneScreenMirroring = this.oneScreenMirroring;
		s.prgSwitchingArea = this.prgSwitchingArea;
		s.prgSwitchingSize = this.prgSwitchingSize;
		s.vromSwitchingSize = this.vromSwitchingSize;
		s.romSelectionReg0 = this.romSelectionReg0;
		s.romSelectionReg1 = this.romSelectionReg1;
		s.romBankSelect = this.romBankSelect;
		s.regBuffer = this.regBuffer;
		s.regBufferCounter = this.regBufferCounter;
		return s;
	}

	override function fromJSON(s:Dynamic) {
		super.fromJSON(s);
		this.mirroring = s.mirroring;
		this.oneScreenMirroring = s.oneScreenMirroring;
		this.prgSwitchingArea = s.prgSwitchingArea;
		this.prgSwitchingSize = s.prgSwitchingSize;
		this.vromSwitchingSize = s.vromSwitchingSize;
		this.romSelectionReg0 = s.romSelectionReg0;
		this.romSelectionReg1 = s.romSelectionReg1;
		this.romBankSelect = s.romBankSelect;
		this.regBuffer = s.regBuffer;
		this.regBufferCounter = s.regBufferCounter;
	}
	
}

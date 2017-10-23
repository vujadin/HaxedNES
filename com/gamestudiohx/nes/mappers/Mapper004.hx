package com.gamestudiohx.nes.mappers;

import com.gamestudiohx.nes.MapperDefault;
import com.gamestudiohx.nes.NES;
import com.gamestudiohx.nes.CPU;
import com.gamestudiohx.nes.ROM;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mapper004 extends MapperDefault {
	
	static inline var CMD_SEL_2_1K_VROM_0000:Int = 0;
	static inline var CMD_SEL_2_1K_VROM_0800:Int = 1;
	static inline var CMD_SEL_1K_VROM_1000:Int = 2;
	static inline var CMD_SEL_1K_VROM_1400:Int = 3;
	static inline var CMD_SEL_1K_VROM_1800:Int = 4;
	static inline var CMD_SEL_1K_VROM_1C00:Int = 5;
	static inline var CMD_SEL_ROM_PAGE1:Int = 6;
	static inline var CMD_SEL_ROM_PAGE2:Int = 7;
	
	var command:Int;
	var prgAddressSelect:Int;
	var chrAddressSelect:Int;
	var pageNumber:Int;
	var irqCounter:Int;
	var irqLatchValue:Int;
	var irqEnable:Int;
	var prgAddressChanged:Bool;
	

	public function new(nes:NES) {
		super(nes);		
		reset();
	}
	
	inline override public function write(address:Int, value:Int) {
		// Writes to addresses other than MMC registers are handled by NoMapper.
		if (address < 0x8000) {
			super.write(address, value);
			return;
		}

		switch (address) {
			case 0x8000:
				// Command/Address Select register
				command = value & 7;
				var tmp = (value >> 6) & 1;
				if (tmp != prgAddressSelect) {
					prgAddressChanged = true;
				}
				prgAddressSelect = tmp;
				chrAddressSelect = (value >> 7) & 1;
				
			case 0x8001:
				// Page number for command
				executeCommand(command, value);
				
			case 0xA000:        
				// Mirroring select
				if ((value & 1) != 0) {
					nes.ppu.setMirroring(ROM.HORIZONTAL_MIRRORING);
				}
				else {
					nes.ppu.setMirroring(ROM.VERTICAL_MIRRORING);
				}
				
			case 0xA001:
				// SaveRAM Toggle
				// TODO
				//nes.rom.setSaveState((value&1)!=0);
				
			case 0xC000:
				// IRQ Counter register
				irqCounter = value;
				//nes.ppu.mapperIrqCounter = 0;
				
			case 0xC001:
				// IRQ Latch register
				irqLatchValue = value;
				
			case 0xE000:
				// IRQ Control Reg 0 (disable)
				//irqCounter = irqLatchValue;
				irqEnable = 0;
				
			case 0xE001:        
				// IRQ Control Reg 1 (enable)
				irqEnable = 1;
				
			default:
				// Not a MMC3 register.
				// The game has probably crashed,
				// since it tries to write to ROM..
				// IGNORE.
		}
	}
	
	inline function executeCommand(cmd:Int, arg:Int) {
		switch (cmd) {
			case Mapper004.CMD_SEL_2_1K_VROM_0000:
				// Select 2 1KB VROM pages at 0x0000:
				if (chrAddressSelect == 0) {
					load1kVromBank(arg, 0x0000);
					load1kVromBank(arg + 1, 0x0400);
				}
				else {
					load1kVromBank(arg, 0x1000);
					load1kVromBank(arg + 1, 0x1400);
				}
				
			case Mapper004.CMD_SEL_2_1K_VROM_0800:           
				// Select 2 1KB VROM pages at 0x0800:
				if (chrAddressSelect == 0) {
					load1kVromBank(arg, 0x0800);
					load1kVromBank(arg + 1, 0x0C00);
				}
				else {
					load1kVromBank(arg, 0x1800);
					load1kVromBank(arg + 1, 0x1C00);
				}
				
			case Mapper004.CMD_SEL_1K_VROM_1000:         
				// Select 1K VROM Page at 0x1000:
				if (chrAddressSelect == 0) {
					load1kVromBank(arg, 0x1000);
				}
				else {
					load1kVromBank(arg, 0x0000);
				}
				
			case Mapper004.CMD_SEL_1K_VROM_1400:         
				// Select 1K VROM Page at 0x1400:
				if (chrAddressSelect == 0) {
					load1kVromBank(arg, 0x1400);
				}
				else {
					load1kVromBank(arg, 0x0400);
				}
				
			case Mapper004.CMD_SEL_1K_VROM_1800:
				// Select 1K VROM Page at 0x1800:
				if (chrAddressSelect == 0) {
					load1kVromBank(arg, 0x1800);
				}
				else {
					load1kVromBank(arg, 0x0800);
				}
				
			case Mapper004.CMD_SEL_1K_VROM_1C00:
				// Select 1K VROM Page at 0x1C00:
				if (chrAddressSelect == 0) {
					load1kVromBank(arg, 0x1C00);
				}
				else {
					load1kVromBank(arg, 0x0C00);
				}
				
			case Mapper004.CMD_SEL_ROM_PAGE1:
				if (prgAddressChanged) {
					// Load the two hardwired banks:
					if (prgAddressSelect == 0) { 
						load8kRomBank(((nes.rom.romCount - 1) * 2), 0xC000);
					}
					else {
						load8kRomBank(((nes.rom.romCount - 1) * 2), 0x8000);
					}
					prgAddressChanged = false;
				}
				
				// Select first switchable ROM page:
				if (prgAddressSelect == 0) {
					load8kRomBank(arg, 0x8000);
				}
				else {
					load8kRomBank(arg, 0xC000);
				}
				
			case Mapper004.CMD_SEL_ROM_PAGE2:
				// Select second switchable ROM page:
				load8kRomBank(arg, 0xA000);
				
				// hardwire appropriate bank:
				if (prgAddressChanged) {
					// Load the two hardwired banks:
					if (prgAddressSelect == 0) { 
						load8kRomBank(((nes.rom.romCount - 1) * 2), 0xC000);
					}
					else {              
						load8kRomBank(((nes.rom.romCount - 1) * 2), 0x8000);
					}
					prgAddressChanged = false;
				}
		}
	}
	
	override public function loadROM() {
		if (!nes.rom.valid) {
			trace("Mapper 004: Invalid ROM! Unable to load.");
			return;
		}
		
		// Load hardwired PRG banks (0xC000 and 0xE000):
		load8kRomBank(((nes.rom.romCount - 1) * 2), 0xC000);
		load8kRomBank(((nes.rom.romCount - 1) * 2) + 1, 0xE000);
		
		// Load swappable PRG banks (0x8000 and 0xA000):
		load8kRomBank(0, 0x8000);
		load8kRomBank(1, 0xA000);
		
		// Load CHR-ROM:
		loadCHRROM();
		
		// Load Battery RAM (if present):
		loadBatteryRam();
		
		// Do Reset-Interrupt:
		nes.cpu.requestIrq(CPU.IRQ_RESET);
	}
	
	inline override function clockIrqCounter() {
		if (irqEnable == 1) {
			irqCounter--;
			if (irqCounter < 0) {
				// Trigger IRQ:
				nes.cpu.requestIrq(CPU.IRQ_NORMAL);
				irqCounter = irqLatchValue;
			}
		}
	}
	
	override public function reset() {
		super.reset();
        command = 0;
        prgAddressSelect = 0;
        chrAddressSelect = 0;
        pageNumber = 0;
        irqCounter = 0;
        irqLatchValue = 0;
        irqEnable = 0;
        prgAddressChanged = false;
    }
	
	override public function toJSON():Dynamic {
		var s = super.toJSON();
		s.command = command;
		s.prgAddressSelect = prgAddressSelect;
		s.chrAddressSelect = chrAddressSelect;
		s.pageNumber = pageNumber;
		s.irqCounter = irqCounter;
		s.irqLatchValue = irqLatchValue;
		s.irqEnable = irqEnable;
		s.prgAddressChanged = prgAddressChanged;
		
		return s;
	}
	
	override public function fromJSON(s:Dynamic) {
		super.fromJSON(s);
		command = s.command;
		prgAddressSelect = s.prgAddressSelect;
		chrAddressSelect = s.chrAddressSelect;
		pageNumber = s.pageNumber;
		irqCounter = s.irqCounter;
		irqLatchValue = s.irqLatchValue;
		irqEnable = s.irqEnable;
		prgAddressChanged = s.prgAddressChanged;
	}
	
}

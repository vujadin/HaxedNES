package com.gamestudiohx.nes;

import haxe.ds.Vector;

import com.gamestudiohx.nes.mappers.Mapper001;
import com.gamestudiohx.nes.mappers.Mapper002;
import com.gamestudiohx.nes.mappers.Mapper003;
import com.gamestudiohx.nes.mappers.Mapper004;
import com.gamestudiohx.nes.mappers.Mapper007;
import com.gamestudiohx.nes.mappers.Mapper009;
import com.gamestudiohx.nes.mappers.Mapper010;
import com.gamestudiohx.nes.mappers.Mapper011;
import com.gamestudiohx.nes.mappers.Mapper015;
import com.gamestudiohx.nes.mappers.Mapper018;
import com.gamestudiohx.nes.mappers.Mapper021;
import com.gamestudiohx.nes.mappers.Mapper022;
import com.gamestudiohx.nes.mappers.Mapper023;
import com.gamestudiohx.nes.mappers.Mapper032;
import com.gamestudiohx.nes.mappers.Mapper033;
import com.gamestudiohx.nes.mappers.Mapper034;
import com.gamestudiohx.nes.mappers.Mapper048;
import com.gamestudiohx.nes.mappers.Mapper071;
import com.gamestudiohx.nes.mappers.Mapper072;
import com.gamestudiohx.nes.mappers.Mapper075;
import com.gamestudiohx.nes.mappers.Mapper078;
import com.gamestudiohx.nes.mappers.Mapper079;
import com.gamestudiohx.nes.mappers.Mapper087;
import com.gamestudiohx.nes.mappers.Mapper094;
import com.gamestudiohx.nes.mappers.Mapper105;
import com.gamestudiohx.nes.mappers.Mapper140;
import com.gamestudiohx.nes.mappers.Mapper182;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ROM {
	
	// Mirroring types:
    public static inline var VERTICAL_MIRRORING:Int = 0;
    public static inline var HORIZONTAL_MIRRORING:Int = 1;
    public static inline var FOURSCREEN_MIRRORING:Int = 2;
    public static inline var SINGLESCREEN_MIRRORING:Int = 3;
    public static inline var SINGLESCREEN_MIRRORING2:Int = 4;
    public static inline var SINGLESCREEN_MIRRORING3:Int = 5;
    public static inline var SINGLESCREEN_MIRRORING4:Int = 6;
    public static inline var CHRROM_MIRRORING:Int = 7;
	
	var nes:NES;
	var mapperName:Array<String>;
	var supportedMappers:Array<Int>;
	
	var header:Array<Int>;
    public var rom(default, null):Vector<Vector<Int>>;
    public var vrom(default, null):Vector<Vector<Int>>;
    public var vromTile(default, null):Vector<Vector<Tile>>;
    
    public var romCount(default, null):Int;
    public var vromCount(default, null):Int;
    public var mirroring(default, null):Int;
    public var batteryRam(default, null):Vector<Int>;
    public var trainer(default, null):Bool;
    public var fourScreen(default, null):Bool;
    public var mapperType(default, null):Int;
    public var valid(default, null):Bool;

	public function new(nes:NES) {
		this.nes = nes;
    
		mapperName = [];
		
		supportedMappers = [
			0, 1, 2, 3, 4, 7, 9, 10, 
			11, 15, 18, 21, 22, 23, 32, 
			33, 34, 48, 71, 72, 75, 78, 
			79, 87, 94, 105, 140, 182];
		
		for (i in 0...255) {
			mapperName[i] = "Unknown Mapper";
		}
		mapperName[ 0] = "NROM / Direct Access";
		mapperName[ 1] = "Nintendo MMC1 / SxROM";
		mapperName[ 2] = "UNROM / UxROM";
		mapperName[ 3] = "CNROM";
		mapperName[ 4] = "Nintendo MMC3, MMC6, TxROM";
		mapperName[ 5] = "Nintendo MMC5, ExROM";
		mapperName[ 6] = "FFE F4xxx";
		mapperName[ 7] = "AOROM";
		mapperName[ 8] = "FFE F3xxx";
		mapperName[ 9] = "Nintendo MMC2, PxROM";
		mapperName[10] = "Nintendo MMC4, FxROM";
		mapperName[11] = "Color Dreams Chip";
		mapperName[12] = "FFE F6xxx";
		mapperName[13] = "CPROM";
		mapperName[15] = "100-in-1 Contra Function 16";
		mapperName[16] = "Bandai EPROM (24C02)";
		mapperName[17] = "FFE F8xxx";
		mapperName[18] = "Jaleco SS8806 chip";
		mapperName[19] = "Namco 163 chip";
		mapperName[20] = "Famicom Disk System";
		mapperName[21] = "Konami VRC4a / VRC4c";
		mapperName[22] = "Konami VRC2a";
		mapperName[23] = "Konami VRC2a";
		mapperName[24] = "Konami VRC6a";
		mapperName[25] = "Konami VRC4b / VRC4d";
		mapperName[26] = "Konami VRC6b";
		mapperName[32] = "Irem G-101 chip";
		mapperName[33] = "Taito TC0190/TC0350";
		mapperName[34] = "32kB ROM switch / BNROM, NINA-001";		
		mapperName[64] = "Tengen RAMBO-1 chip";
		mapperName[65] = "Irem H-3001 chip";
		mapperName[66] = "GNROM switch / GxROM, MxROM";
		mapperName[67] = "SunSoft3 chip";
		mapperName[68] = "SunSoft4 chip / After Burner";
		mapperName[69] = "SunSoft5 FME-7 chip / 5B";
		mapperName[71] = "Camerica/Codemasters chip";
		mapperName[73] = "VRC3";
		mapperName[74] = "Pirate MMC3 derivative";
		mapperName[75] = "VRC1";
		mapperName[76] = "Namco 109 variant";
		mapperName[78] = "Irem 74HC161/32-based";
		mapperName[79] = "NINA-03/NINA-06";
		mapperName[85] = "VRC7";
		mapperName[86] = "JALECO-JF-13";
		mapperName[91] = "Pirate HK-SF3 chip";
		mapperName[94] = "Senjou no Ookami";
		mapperName[105]	= "NES-EVENT";
		mapperName[113]	= "NINA-03/NINA-06??";	
		mapperName[118]	= "TxSROM, MMC3";	
		mapperName[119]	= "TQROM, MMC3";	
		mapperName[159]	= "Bandai EPROM (24C01)";	
		mapperName[166]	= "SUBOR";	
		mapperName[167]	= "SUBOR";	
		mapperName[180]	= "Crazy Climber";
		mapperName[185]	= "CNROM with protection diodes";	
		mapperName[192]	= "Pirate MMC3 derivative";	
		mapperName[206]	= "DxROM, Namco 118 / MIMIC-1";	
		mapperName[210]	= "Namco 175 and 340";	
		mapperName[228]	= "Action 52";	
		mapperName[232] = "Camerica/Codemasters Quattro";	
	}
	
	public function load(data:String) {
        if (data.indexOf("NES\x1a") == -1) {
			trace("Not a valid NES ROM.");
            return;
        }
		
        header = [];
        for (i in 0...16) {
            header[i] = data.charCodeAt(i) & 0xFF;
        }
		
        romCount = header[4];
        vromCount = header[5] * 2; // Get the number of 4kB banks, not 8kB
        mirroring = ((header[6] & 1) != 0 ? 1 : 0);
        //batteryRam = (header[6] & 2) != 0;
        trainer = (header[6] & 4) != 0;
        fourScreen = (header[6] & 8) != 0;
        mapperType = (header[6] >> 4) | (header[7] & 0xF0);
		
        /* TODO
        if (this.batteryRam)
            this.loadBatteryRam();*/
        // Check whether byte 8-15 are zero's:
        var foundError = false;
        for (i in 8...16) {
            if (header[i] != 0) {
                foundError = true;
                break;
            }
        }
        if (foundError) {
            mapperType &= 0xF; // Ignore byte 7
        }
		
        // Load PRG-ROM banks:
        rom = new Vector<Vector<Int>>(romCount);
        var offset:Int = 16;
        for (i in 0...this.romCount) {
            rom[i] = new Vector<Int>(16384);
            for (j in 0...16384) {
                if (offset+j >= data.length) {
                    break;
                }
                rom[i][j] = data.charCodeAt(offset + j) & 0xFF;
            }
            offset += 16384;
        }
		
        // Load CHR-ROM banks:
        vrom = new Vector<Vector<Int>>(vromCount);
        for (i in 0...this.vromCount) {
            vrom[i] = new Vector<Int>(4096);
            for (j in 0...4096) {
                if (offset+j >= data.length){
                    break;
                }
                vrom[i][j] = data.charCodeAt(offset + j) & 0xFF;
            }
            offset += 4096;
        }
        
        // Create VROM tiles:
        vromTile = new Vector<Vector<Tile>>(vromCount);
        for (i in 0...this.vromCount) {
            vromTile[i] = new Vector<Tile>(256);
            for (j in 0...256) {
                vromTile[i][j] = new Tile();
            }
        }
        
        // Convert CHR-ROM banks to tiles:
        var tileIndex:Int = 0;
        var leftOver:Int = 0;
        for (v in 0...this.vromCount) {
            for (i in 0...4096) {
                tileIndex = i >> 4;
                leftOver = i % 16;
                if (leftOver < 8) {
                    vromTile[v][tileIndex].setScanline(
                        leftOver,
                        vrom[v][i],
                        vrom[v][i+8]
                    );
                } 
				else {
                    vromTile[v][tileIndex].setScanline(
                        leftOver-8,
                        vrom[v][i-8],
                        vrom[v][i]
                    );
                }
            }
        }		
        
        valid = true;
    }
    
    public function getMirroringType():Int {
        if (fourScreen) {
            return ROM.FOURSCREEN_MIRRORING;
        }
        if (mirroring == 0) {
            return ROM.HORIZONTAL_MIRRORING;
        }
		
        return ROM.VERTICAL_MIRRORING;
    }
    
    function getMapperName():String {
        if (mapperType >= 0 && mapperType < mapperName.length) {
            return mapperName[mapperType];
        }
		
        return "Unknown Mapper, " + mapperType;
    }
    
    function mapperSupported():Bool {
        return supportedMappers.indexOf(mapperType) != -1;
    }
    
    public function createMapper():MapperDefault {
		trace(mapperType);
        if (mapperSupported()) {
			trace("mapper supported");
			switch(mapperType) {
				case 0:
					return new MapperDefault(nes);
				
				case 1:
					return new Mapper001(nes);
					
				case 2: 
					return new Mapper002(nes);
					
				case 3:
					return new Mapper003(nes);
					
				case 4:
					return new Mapper004(nes);
					
				case 7:
					return new Mapper007(nes);
					
				case 9:
					return new Mapper009(nes);
					
				case 10:
					return new Mapper010(nes);
					
				case 11:
					return new Mapper011(nes);
					
				case 15:
					return new Mapper015(nes);
					
				case 18:
					return new Mapper018(nes);
					
				case 21:
					return new Mapper021(nes);
					
				case 22:
					return new Mapper022(nes);
					
				case 23:
					return new Mapper023(nes);
					
				case 32:
					return new Mapper032(nes);
					
				case 33:
					return new Mapper033(nes);
					
				case 34:
					return new Mapper034(nes);
					
				case 48:
					return new Mapper048(nes);
					
				case 71:
					return new Mapper071(nes);
					
				case 72:
					return new Mapper072(nes);
					
				case 75:
					return new Mapper075(nes);
					
				case 78:
					return new Mapper078(nes);
					
				case 79:
					return new Mapper079(nes);
					
				case 87:
					return new Mapper087(nes);
					
				case 94:
					return new Mapper094(nes);
					
				case 105:
					return new Mapper105(nes);
					
				case 140:
					return new Mapper140(nes);
					
				case 182:
					return new Mapper182(nes);
			}    
			
			return null;
        }
        else {
            trace("This ROM uses a mapper not supported by JSNES: " + getMapperName() + " (" + mapperType + ")");
            return null;
        }
    }
	
}

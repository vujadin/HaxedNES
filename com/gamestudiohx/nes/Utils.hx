package com.gamestudiohx.nes;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Utils {
        
    public static function fromJSON(obj:Dynamic, state:Dynamic) {
        for (i in 0...obj.JSON_PROPERTIES.length) {
            obj[obj.JSON_PROPERTIES[i]] = state[obj.JSON_PROPERTIES[i]];
        }
    }
    
    public static function toJSON(obj:Dynamic):Dynamic {
        var state:Dynamic = null;
        for (i in 0...obj.JSON_PROPERTIES.length) {
            state[obj.JSON_PROPERTIES[i]] = obj[obj.JSON_PROPERTIES[i]];
        }
        return state;
    }
	
}


package {
	public class JSON {
		public static function encode(o:Object):String {	
			return new JSONEncode(o).getString();
		}
		
		public static function decode(s:String):* {	
			return new JSONDecode(s).getValue();	
		}
	}
}

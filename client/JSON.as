
package {
	public class JSON {
		public static function encode(o:Object):String {	
			return new JSONEncoder(o).getString();
		}
		
		public static function decode(s:String):* {	
			return new JSONDecoder(s).getValue();	
		}
	}
}
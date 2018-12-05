
package {
	public class JSONError extends Error {
		public var location:int;
		public var text:String;

		public function JSONParseError( message:String = "", location:int = 0, text:String = "") {
			super(message);
			name = "JSONParseError";
			this.location = location;
			this.text = text;
		}
	}
	
}

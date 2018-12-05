
package {
	public class JSONToken {
		public var type:int;
		public var value:Object;
		
		public function JSONToken(type:int = -1, value:Object = null) {
			this.type = type;
			this.value = value;
		}
	}
}
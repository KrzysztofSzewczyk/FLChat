
package {
	public class JSONDecode {
		private var strict:Boolean;
		private var value:*;
		private var tokenizer:JSONTokenizer;
		private var token:JSONToken;
		
		public function JSONDecoder(s:String, strict:Boolean) {	
			this.strict = strict;
			tokenizer = new JSONTokenizer(s, strict);
			
			nextToken();
			value = parseValue();
			
			if (strict && nextToken() != null)
				tokenizer.parseError("Unexpected characters left in input stream");
		}
		
		public function getValue():* {
			return value;
		}
		
		private function nextToken():JSONToken {
			return token = tokenizer.getNextToken();
		}
		
		private function parseArray():Array {
			var a:Array = new Array();
			nextToken();
			if (token.type == JSONTokenType.RIGHT_BRACKET)
				return a;
			else if (!strict && token.type == JSONTokenType.COMMA) {
				nextToken();
				if ( token.type == JSONTokenType.RIGHT_BRACKET )
					return a;
				else
					tokenizer.parseError("Leading commas are not supported.");
			}
			
			while (true) {
				a.push(parseValue());
				nextToken();
				if ( token.type == JSONTokenType.RIGHT_BRACKET )
					return a;
				else if ( token.type == JSONTokenType.COMMA ) {
					nextToken();
					if (!strict) {
						if (token.type == JSONTokenType.RIGHT_BRACKET)
							return a;
					}
				} else
					tokenizer.parseError("Expected ] or ,");
			}
            return null;
		}
		
		private function parseObject():Object {
			var o:Object = new Object();
			var key:String
			
			nextToken();
			
			if (token.type == JSONTokenType.RIGHT_BRACE)
				return o;
			else if (token.type == JSONTokenType.COMMA) {
				nextToken();
				if (token.type == JSONTokenType.RIGHT_BRACE)
					return o;
				else
					tokenizer.parseError("Leading commas are not supported.");
			}
			
			while (true) {
				if (token.type == JSONTokenType.STRING) {
					key = String(token.value);
					nextToken();
					if (token.type == JSONTokenType.COLON) {	
						nextToken();
						o[key] = parseValue();	
						nextToken();
						if (token.type == JSONTokenType.RIGHT_BRACE)
							return o;
						else if (token.type == JSONTokenType.COMMA) {
							nextToken();
							if (token.type == JSONTokenType.RIGHT_BRACE)
								return o;
						} else
							tokenizer.parseError("Expected } or ,");
					} else
						tokenizer.parseError("Expected :");
				} else
					tokenizer.parseError("Expected string");
			}
            return null;
		}
		
		private function parseValue():Object {
			if (token == null)
				tokenizer.parseError("Unexpected end of input");
			switch (token.type) {
				case JSONTokenType.LEFT_BRACE:
					return parseObject();
				case JSONTokenType.LEFT_BRACKET:
					return parseArray();
				case JSONTokenType.STRING:
				case JSONTokenType.NUMBER:
				case JSONTokenType.TRUE:
				case JSONTokenType.FALSE:
				case JSONTokenType.NULL:
					return token.value;
				case JSONTokenType.NAN:
					return token.value;
				default:
					tokenizer.parseError("Unexpected " + token.value);
			}
            return null;
		}
	}
}

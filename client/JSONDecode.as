
package {
	public class JSONDecode {
		private var value:*;
		private var lexer:JSONLexer;
		private var token:JSONToken;
		
		public function JSONDecode(s:String) {	
			lexer = new JSONLexer(s);
			
			nextToken();
			value = parseValue();
		}
		
		public function getValue():* {
			return value;
		}
		
		private function nextToken():JSONToken {
			return token = lexer.getNextToken();
		}
		
		private function parseArray():Array {
			var a:Array = new Array();
			nextToken();
			if (token.type == JSONTokenType.RIGHT_BRACKET)
				return a;
			else if (token.type == JSONTokenType.COMMA) {
				nextToken();
				if ( token.type == JSONTokenType.RIGHT_BRACKET )
					return a;
				else
					lexer.parseError("Leading commas are not supported.");
			}
			
			while (true) {
				a.push(parseValue());
				nextToken();
				if ( token.type == JSONTokenType.RIGHT_BRACKET )
					return a;
				else if ( token.type == JSONTokenType.COMMA ) {
					nextToken();
					if (token.type == JSONTokenType.RIGHT_BRACKET)
						return a;
				} else
					lexer.parseError("Expected ] or ,");
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
					lexer.parseError("Leading commas are not supported.");
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
							lexer.parseError("Expected } or ,");
					} else
						lexer.parseError("Expected :");
				} else
					lexer.parseError("Expected string");
			}
            return null;
		}
		
		private function parseValue():Object {
			if (token == null)
				lexer.parseError("Unexpected end of input");
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
					lexer.parseError("Unexpected " + token.value);
			}
            return null;
		}
	}
}

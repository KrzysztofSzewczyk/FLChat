
package {
	public class JSONTokenizer {
		private var strict:Boolean;
		private var obj:Object;
		private var jsonString:String;
		private var loc:int;
		private var ch:String;
		
		public function JSONTokenizer( s:String, strict:Boolean ) {
			jsonString = s;
			this.strict = strict;
			loc = 0;
			nextChar();
		}
		
		public function getNextToken():JSONToken {
			var token:JSONToken = new JSONToken();
			skipIgnored();
			switch (ch) {	
				case '{':
					token.type = JSONTokenType.LEFT_BRACE;
					token.value = ch;
					nextChar();
					break;
				case '}':
					token.type = JSONTokenType.RIGHT_BRACE;
					token.value = ch;
					nextChar();
					break;
				case '[':
					token.type = JSONTokenType.LEFT_BRACKET;
					token.value = ch;
					nextChar();
					break;
				case ']':
					token.type = JSONTokenType.RIGHT_BRACKET;
					token.value = ch;
					nextChar();
					break;
				case ',':
					token.type = JSONTokenType.COMMA;
					token.value = ch;
					nextChar();
					break;
				case ':':
					token.type = JSONTokenType.COLON;
					token.value = ch;
					nextChar();
					break;
				case 't':
					if (nextChar() + nextChar() + nextChar() == "rue") {
						token.type = JSONTokenType.TRUE;
						token.value = true;
						nextChar();
					} else {
						parseError("Expected true.");
					}
					break;
				case 'f':
					if (nextChar() + nextChar() + nextChar() + nextChar() == "alse") {
						token.type = JSONTokenType.FALSE;
						token.value = false;
						nextChar();
					} else {
						parseError("Expected false.");
					}
					break;
				case 'n':
					if (nextChar() + nextChar() + nextChar() == "ull") {
						token.type = JSONTokenType.NULL;
						token.value = null;
						nextChar();
					} else {
						parseError("Expected null.");
					}
					break;
				case 'N':
					if (nextChar() + nextChar() == "aN") {
						token.type = JSONTokenType.NAN;
						token.value = NaN;
						nextChar();
					} else {
						parseError("Expected NaN.");
					}
					break;
				case '"':
					token = readString();
					break;
				default: 
					if (isDigit(ch) || ch == '-') {
						token = readNumber();
					} else if (ch == '') {
						return null;
					} else {
						parseError("Unexpected " + ch + ".");
					}
			}
			
			return token;
		}
		
		private function readString():JSONToken {
			var quoteIndex:int = loc;
			do {
				quoteIndex = jsonString.indexOf("\"", quoteIndex);
				if (quoteIndex >= 0) {
					var backspaceCount:int = 0;
					var backspaceIndex:int = quoteIndex - 1;
					while (jsonString.charAt(backspaceIndex) == "\\") {
						backspaceCount++;
						backspaceIndex--;
					}
					if (backspaceCount % 2 == 0)
						break;
					quoteIndex++;
				} else
					parseError("Unterminated string.");
			} while (true);
			var token:JSONToken = new JSONToken();
			token.type = JSONTokenType.STRING;
			token.value = unescapeString(jsonString.substr(loc, quoteIndex - loc));
			loc = quoteIndex + 1;
			nextChar();
			return token;
		}
		
		public function unescapeString(input:String):String {
			var result:String = "";
			var backslashIndex:int = 0;
			var nextSubstringStartPosition:int = 0;
			var len:int = input.length;
			do {
				backslashIndex = input.indexOf('\\', nextSubstringStartPosition);
				if (backslashIndex >= 0) {
					result += input.substr(nextSubstringStartPosition, backslashIndex - nextSubstringStartPosition);
					nextSubstringStartPosition = backslashIndex + 2;
					var afterBackslashIndex:int = backslashIndex + 1;
					var escapedChar:String = input.charAt(afterBackslashIndex);
					switch (escapedChar) {
						case '"': result += '"'; break;
						case '\\': result += '\\'; break;
						case 'n': result += '\n'; break;
						case 'r': result += '\r'; break;
						case 't': result += '\t'; break;
						case 'u':
							var hexValue:String = "";
							if (nextSubstringStartPosition + 4 > len)
								parseError("Expected 4 digits after \\u.");
							for (var i:int = nextSubstringStartPosition; i < nextSubstringStartPosition + 4; i++) {
								var possibleHexChar:String = input.charAt(i);
								if (!isHexDigit(possibleHexChar))
									parseError("Excepted a hex digit");
								hexValue += possibleHexChar;
							}
							result += String.fromCharCode(parseInt(hexValue, 16));
							nextSubstringStartPosition += 4;
							break;
						case 'f': result += '\f'; break;
						case '/': result += '/'; break;
						case 'b': result += '\b'; break;
						default: result += '\\' + escapedChar;
					}
				} else {
					result += input.substr(nextSubstringStartPosition);
					break;
				}
			} while (nextSubstringStartPosition < len);
			return result;
		}

		private function readNumber():JSONToken {
			var input:String = "";
			if (ch == '-') {
				input += '-';
				nextChar();
			}
			
			if (!isDigit(ch))
				parseError("Expected digit");
			
			if (ch == '0') {
				input += ch;
				nextChar();
				if (isDigit(ch))
					parseError("Not a number");
				else if (!strict && ch == 'x') {
					input += ch;
					nextChar();
					if (isHexDigit(ch)) {
						input += ch;
						nextChar();
					} else
						parseError("Digit expected.");
					while (isHexDigit(ch)) {
						input += ch;
						nextChar();
					}
				}
			} else {
				while (isDigit(ch)) {
					input += ch;
					nextChar();
				}
			}
			
			if (ch == '.') {
				input += '.';
				nextChar();
				if (!isDigit(ch))
					parseError("Expecting a digit");
				while (isDigit(ch)) {
					input += ch;
					nextChar();
				}
			}
			
			var num:Number = Number(input);
			
			if (isFinite(num) && !isNaN(num)) {
				var token:JSONToken = new JSONToken();
				token.type = JSONTokenType.NUMBER;
				token.value = num;
				return token;
			} else
				parseError("Number is not valid.");
			
            return null;
		}

		private function nextChar():String {
			return ch = jsonString.charAt(loc++);
		}
		
		private function skipIgnored():void {
			skipWhite();
			skipComments();
		}
		
		private function skipComments():void {
			if (ch == '/') {
				switch (nextChar()) {
					case '/':
						do
							nextChar();
						while (ch != '\n' && ch != '')
						nextChar();
						break;
					case '*':
						nextChar();
						while (true) {
							if (ch == '*') {
								nextChar();
								if (ch == '/') {
									nextChar();
									break;
								}
							} else
								nextChar();
							if (ch == '')
								parseError("Multi-line comment not closed");
						}
						break;
					default:
						parseError("Unexpected symbol.");
				}
			}
			
		}
		
		private function skipWhite():void {	
			while (isWhiteSpace(ch))
				nextChar();
		}
		
		private function isWhiteSpace(ch:String):Boolean {
			return (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r' || ch.charCodeAt(0) == 16);
		}
		
		private function isDigit(ch:String):Boolean {
			return (ch >= '0' && ch <= '9');
		}
		
		private function isHexDigit(ch:String):Boolean {
			return (isDigit(ch) || (ch >= 'A' && ch <= 'F') || (ch >= 'a' && ch <= 'f'));
		}
	
		public function parseError(message:String):void {
			throw new JSONError(message, loc, jsonString);
		}
	}
	
}

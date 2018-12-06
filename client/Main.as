
package {
	import flash.display.MovieClip;

	public class Main {
		public var client:NetworkClient;
		public var chat:Chat;
		private var parent:MovieClip;
		
		public function Main(parent:MovieClip) {
			this.parent = parent;
			client = new NetworkClient();
			chat = new Chat(parent);
			client.addEventListener(NetworkEvent.CONNECTED, _onConnected);
			client.addEventListener(NetworkEvent.CONNECT_FAIL, _onConnectFail);
			client.connect();
		}
		
		private function log(s:String, b:Boolean = true):void {
			parent.OutputBox.text += s + (b ? "\n" : "");
		}
		
		private function _onConnectFail(e:NetworkEvent):void {
			log("Could not connect to server.");
		}
		
		private function _onConnected(e:NetworkEvent):void {
			client.addEventListener(NetworkMethod.AUTHENTICATE, _onAuth);
			client.sendData(NetworkMethod.AUTHENTICATE);
		}
		
		private function _onAuth(e:NetworkEvent):void {
			log('');
			log('Your ID is ' + e.object.uid + ', online clients: ' + e.object.users);
			log('');
			
			client.uid = e.object.uid;
			
			chat.init();
		}
	}
}

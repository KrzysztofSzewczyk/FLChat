package {
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.ui.KeyboardType;
	
	public class Chat extends MovieClip {
		private var logged:Boolean = false;
		private var parentClip:MovieClip;
		
		public function Chat(parentc:MovieClip) {
			super();
			
			this.parentClip = parentc;
		}
		
		public function log(msg:String, newLine:Boolean = true):void {
			parentClip.OutputBox.appendText(msg);
			if (newLine) {
				parentClip.OutputBox.appendText('\n');
			}
		}
		
		public function appendHistory(msg:String, from:Number):void {
			parentClip.OutputBox.appendText(from + ': ' + msg + '\n');
		}
		
		public function init():void {
			logged = true;
			
			parentClip.MessageInput.addEventListener(KeyboardEvent.KEY_DOWN, onInputKeyDown);
				
			NetworkClient.instance.addEventListener(NetworkMethod.RECEIVE, onReceive);
		}
		
		private function onReceive(e:NetworkEvent):void {
			if (e.object.uid == NetworkClient.instance.uid) return;
			appendHistory(e.object.msg, e.object.uid);
		}
		
		private function onInputKeyDown(e:KeyboardEvent):void {
			if (!logged) return;
			if (Keyboard.ENTER != e.keyCode) return;
			
			NetworkClient.instance.sendData(NetworkMethod.SEND, { 
				msg: parentClip.MessageInput.text
			});
			
			appendHistory(parentClip.MessageInput.text, NetworkClient.instance.uid);
			parentClip.MessageInput.text = '';
		}
	}
}
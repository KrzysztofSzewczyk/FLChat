package {
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.XMLSocket;
	

	public class NetworkClient extends EventDispatcher {
		public static var instance:NetworkClient;
		
		public static const PORT:Number = 40020;
		public static const HOST:String = 'srv02.mikr.us';
		
		public var uid:Number = -1;
		private var xmlSocket:XMLSocket;
		
		public function NetworkClient() {
			xmlSocket = new XMLSocket();
			instance = this;
		}
		
		public function connect():void {
			dispatchEvent(new NetworkEvent(NetworkEvent.CONNECT_BEGIN));
			
			xmlSocket.connect(HOST, PORT);
			xmlSocket.addEventListener(Event.CONNECT, onConnected);
			xmlSocket.addEventListener(Event.CLOSE, onClosed);
			xmlSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			xmlSocket.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			xmlSocket.addEventListener(DataEvent.DATA, onIncomingData);
		}
		
		public function sendData(method:String, params:Object = null):void {
			if (params == null) params = new Object();
			params.uid = this.uid;
			
 			var request:String = JSON.encode({
				action: method, 
				params: params
			});
			
			xmlSocket.send(request);
		}
		
		public function disconnectHandler(event:MouseEvent):void {
			xmlSocket.close();
		}
		
		private function onConnected(e:Event):void {
			dispatchEvent(new NetworkEvent(NetworkEvent.CONNECTED));
		}
		
		private function onClosed(e:Event):void {
			dispatchEvent(new NetworkEvent(NetworkEvent.CLOSED));
		}
		
		private function onIoError(e:IOErrorEvent):void {
			trace(e.text);
			dispatchEvent(new NetworkEvent(NetworkEvent.CONNECT_FAIL));
			dispatchEvent(new NetworkEvent(NetworkEvent.IO_ERROR));
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			trace(e.text);
			dispatchEvent(new NetworkEvent(NetworkEvent.CONNECT_FAIL));
			dispatchEvent(new NetworkEvent(NetworkEvent.SECURITY_ERROR));
		}
		
		public function onIncomingData(event:DataEvent):void {
			if (event.data.indexOf('<?xml version="1.0"?>') == 0) {
				return;
			}
			
			var o:Object = JSON.decode(event.data);
			dispatchEvent(new NetworkEvent(o.action, o.params));
		}
	}
}
package {
    import flash.events.*;

    public class NetworkEvent extends Event {
		public static const CONNECT_BEGIN:String = 'eBeginConnect';
        public static const CONNECTED:String = 'eConnected';
		public static const CONNECT_FAIL:String = 'eConnectFail';
		public static const SECURITY_ERROR:String = 'eSecurityError';
		public static const IO_ERROR:String = 'eIoError';
		public static const CLOSED:String = 'eClosed';
		
		public var object:Object;

        public function NetworkEvent(type:String, object:Object=null):void {
            super(type);
            this.object = object;
        }

        override public function clone():Event {
            return new NetworkEvent(type, this.object);
        }
    }
}

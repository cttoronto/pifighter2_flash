package com.cttoronto.pifighter.Model
{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import net.eriksjodin.arduino.Arduino;
	
	public class ArduinoConnectModel extends EventDispatcher
	{
		
		public static var PLAYER_ONE_BLINK:String = "PLAYER_ONE_BLINK";
		public static var PLAYER_TWO_BLINK:String = "PLAYER_TWO_BLINK";
		
		private static var _instance:ArduinoConnectModel;
		private var _arduino:Socket;
		
		private var last_raweeg:Number = 0;
		private var _poorSignal1:Number;
		private var _attention1:Number = 0;
		private var _poorSignal2:Number;
		private var _attention2:Number = 0;
		private var meditation:Number;
		private var range:Number;
		private var _allow_blink1:Boolean = true;
		private var _allow_blink2:Boolean = true;
		
		private var reset_blink1:uint;
		private var reset_blink2:uint;
		
		private var _range1:Number = 80;
		private var _range2:Number = 80;
		
		private var timer:Timer = new Timer(75);
		
		public function ArduinoConnectModel(target:IEventDispatcher=null)
		{
			init();
		}
		
		public function get allow_blink2():Boolean
		{
			return _allow_blink2;
		}

		public function set allow_blink2(value:Boolean):void
		{
			_allow_blink2 = value;
		}

		public function get allow_blink1():Boolean
		{
			return _allow_blink1;
		}

		public function set allow_blink1(value:Boolean):void
		{
			_allow_blink1 = value;
		}

		public function get range2():Number
		{
			return _range2;
		}

		public function set range2(value:Number):void
		{
			_range2 = value;
		}

		public function get range1():Number
		{
			return _range1;
		}

		public function set range1(value:Number):void
		{
			_range1 = value;
		}

		public function get poorSignal1():Number
		{
			return _poorSignal1;
		}
		
		public function set poorSignal1(value:Number):void
		{
			_poorSignal1 = value;
		}
		
		public function get attention1():Number
		{
			return _attention1;
		}
		
		public function set attention1(value:Number):void
		{
			_attention1 = (value < 1) ? 1 : value;
		}
		
		public function get poorSignal2():Number
		{
			return _poorSignal2;
		}
		
		public function set poorSignal2(value:Number):void
		{
			_poorSignal2 = value;
		}
		
		public function get attention2():Number
		{
			return _attention2;
		}
		
		public function set attention2(value:Number):void
		{
			_attention2 = (value < 1) ? 1 : value;
		}

		private function init():void {
			
			_arduino = new Socket("127.0.0.1", 5331);
			_arduino.addEventListener(Event.CONNECT, onSocketConnect);
			_arduino.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			_arduino.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
//			_arduino.addEventListener(Event.CONNECT, onSocketConnect);
			
			//_arduino.connect("/dev/cu.usbmodem1411");
//			_arduino.connect(Config.getInstance().comport);
			
		}
		
		private function onIOError(e:IOErrorEvent):void {}
		
		private function onSocketConnect(e:Event):void {
			trace("CONNECTED");
			
//			timer.addEventListener(TimerEvent.TIMER, onTick);
//			timer.start();
		}
		
		private function onTick(e:TimerEvent):void {
//			trace(_arduino.readUTF());
//			_arduino.flush();
		}
		
		public static function getInstance():ArduinoConnectModel {
			if (ArduinoConnectModel._instance == null) ArduinoConnectModel._instance = new ArduinoConnectModel();
			return ArduinoConnectModel._instance;
		}
		public function firepie($id:Number):void{
			trace("fire"+$id);
//			_arduino.writeString("fire"+$id);
		}
		public function dispose():void{
//			_arduino.dispose();
		}
		
		
		private var prevLine:String;
		private var buffer:String;
		private var count:int = 0;
		private var values:Array = [];
		private function onSocketData(e:ProgressEvent):void {
			
			buffer = _arduino.readUTFBytes(_arduino.bytesAvailable);
			
			var eol:Number;
			
			if (buffer != '') {
				eol = buffer.lastIndexOf('e');
				
				if (eol == -1) {
					prevLine += buffer;
				} else {
					
					var buff2 = buffer.substring( 0, eol);
					
					//Can now start to think about saving the data...
					//but we need to check if there is any data left from a previous firing of this event handler (i.e. stored in lineBefore)
					if (prevLine == '') {
						//No outstanding data to save from previous event handler
						//Save this to the global array of data 
						processJSON(buff2);
//						trace(buff2);
						
					} else {			
						//There is some outstanding data from before. Save this data as well as the new stuff
						processJSON(prevLine + buff2);
//						trace(prevLine + buff2);
						//Now set lineBefore to null to ensure it is not used again (results in duplicates of data)
						prevLine = '';
						
						
					}
					
					buffer = '';
					buff2 = '';
				}
				
//				
				
			}
			
//			trace(values);
			return;
			try {
				var packetString:String = _arduino.readMultiByte(_arduino.bytesAvailable, "ISO-8859-1");
			} catch(err:Error) {
				
			}
			
			if (packetString == "")return;
			
//			
			_arduino.flush();
			return;
			
			var packets : Array = packetString.split(/\n/);
			var data:Object;
			var item:Object;
			var sub:Object;
			
			for each (var packet:String in packets){
				
				if(packet != "") {
					
					try {
						data = JSON.parse(packet);
					} catch ( jError: Error) {
						return;
					}
					
					if (data["blink"]){
						if (data["id"] == 1) {
							if (ArduinoConnectModel.getInstance().allow_blink1) {
//								ArduinoConnectModel.getInstance().allow_blink1 = false;
								dispatchEvent(new Event(ArduinoConnectModel.PLAYER_ONE_BLINK));
//								reset_blink1 = setTimeout(function():void { ArduinoConnectModel.getInstance().allow_blink1 = true; } , 1500);
							}
						} else {
							if (ArduinoConnectModel.getInstance().allow_blink2) {
//								ArduinoConnectModel.getInstance().allow_blink2 = false;
								dispatchEvent(new Event(ArduinoConnectModel.PLAYER_TWO_BLINK));
//								reset_blink2 = setTimeout(function():void { ArduinoConnectModel.getInstance().allow_blink2 = true; } , 1500);
							}
						}
						
						return;
						
					}
					
					if (data["range"] != null) {
						if (data["id"] == 1) {
							if (Math.abs(range1 - data["range"])  < 300) range1 = data["range"];
						} else {
							if (Math.abs(range2 - data["range"]) < 300) range2 = data["range"];
						}
						return;
					}
					
					//the main packet
					if(data["poorSignalLevel"] != null) {
						poorSignal1 = data["poorSignalLevel"];
						if(poorSignal1 == 0) {		      
							if (data["id"] == 1) {
								attention1 = data["attention"];
							} else {
								attention2 = data["attention"];
							}
														
							
						} else {
							
							if(poorSignal1 == 200) {
								if (data["id"] == 1) {
									attention1 = 0;
								} else {
									attention2 = 0;
								}
								
								meditation = 0;
							}
						} /* else */					
					}
				}

				data = null;

				dispatchEvent(new Event(Event.CHANGE));
				
			} /*for each*/
		}
		
		private function processJSON(packetString:String):void {
//			trace(packetString);
			_arduino.flush();
			
			var packets : Array = packetString.split("e");
			
			var data:Object;
			var item:Object;
			var sub:Object;
			var len:int = packets.length;
			
			for ( var i: int = 0; i < len; ++i) {
				var packet:String = packets[i];
				
				try {
					data = JSON.parse(packet);
				} catch ( jError: Error) {
					
					return;
				}
			
				if (data["b"] != null){
					trace("BLINK");
					if (data["id"] == 1) {
//						if (ArduinoConnectModel.getInstance().allow_blink1) {
//							ArduinoConnectModel.getInstance().allow_blink1 = false;
							dispatchEvent(new Event(ArduinoConnectModel.PLAYER_ONE_BLINK));
//							reset_blink1 = setTimeout(function():void { ArduinoConnectModel.getInstance().allow_blink1 = true; } , 1500);
//						}
					} else {
//						if (ArduinoConnectModel.getInstance().allow_blink2) {
//							ArduinoConnectModel.getInstance().allow_blink2 = false;
							dispatchEvent(new Event(ArduinoConnectModel.PLAYER_TWO_BLINK));
//							reset_blink2 = setTimeout(function():void { ArduinoConnectModel.getInstance().allow_blink2 = true; } , 1500);
//						}
					}
					
					return;
					
				}
				
				if (data["r"] != null) {
					if (data["id"] == 1) {
						range1 = data["r"];
	//					trace("range1",range1);
					} else {
						range2 = data["r"];
					}
					return;
				}
				
				//the main packet
				if(data["psl"] != null) {
					poorSignal1 = data["psl"];
					
					if(poorSignal1 != 200) {
						
						if (data["id"] == 1) {
							attention1 = data["a"];
						} else {
							attention2 = data["a"];
						}
						
						
					} else {
						
						if(poorSignal1 == 200) {
							if (data["id"] == 1) {
								attention1 = 0;
							} else {
								attention2 = 0;
							}
							
						}
					} /* else */					
				}
			
			
			}
		}
		
	}
}
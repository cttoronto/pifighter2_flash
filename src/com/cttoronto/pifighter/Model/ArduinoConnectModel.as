package com.cttoronto.pifighter.Model
{
	import com.greensock.TweenMax;
	import com.quetwo.Arduino.ArduinoConnector;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.setTimeout;
	
	public class ArduinoConnectModel extends EventDispatcher
	{
		
		public static var PLAYER_ONE_BLINK:String = "PLAYER_ONE_BLINK";
		public static var PLAYER_TWO_BLINK:String = "PLAYER_TWO_BLINK";
		
		private static var _instance:ArduinoConnectModel;
		private var _arduino:ArduinoConnector;
		
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
			if (value < 20){
				value = 20;
			}
			_attention1 = value;
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
			if (value < 20){
				value = 20;
			}
			_attention2 = value;
		}

		private function init():void {
			_arduino = new ArduinoConnector();

			_arduino.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			
			//_arduino.connect("/dev/cu.usbmodem1411");
			_arduino.connect(Config.getInstance().comport, Config.getInstance().data.baudrate);
			
		}
		
		public static function getInstance():ArduinoConnectModel {
			if (ArduinoConnectModel._instance == null) ArduinoConnectModel._instance = new ArduinoConnectModel();
			return ArduinoConnectModel._instance;
		}
		public function firepie($id:Number):void{
			var fire_str:String = "f";
			if ($id == 2){
				fire_str = "d";
			}
			TweenMax.delayedCall(0, serialPrint, ["*"]);
		//	_arduino.writeString("pause\n");
			TweenMax.delayedCall(0.25, serialPrint, [fire_str]);
			
		//	_arduino.writeString(fire_str);
		}
		private function serialPrint($msg:String):void{
			_arduino.writeString($msg+"\n");
		}
		public function dispose():void{
			_arduino.dispose();
		}
		private function onSocketData(e:ProgressEvent):void {
			var packetString:String = _arduino.readBytesAsString()
			_arduino.flush();
			//trace("packetString", packetString);
			var packets : Array = packetString.split(/\n/);
			var data:Object;
			var item:Object;
			var sub:Object;
			
			for each (var packet:String in packets){
				//trace(packet);
				if(packet != "") {
					
					try {
						data = JSON.parse(packet);
					} catch ( jError: Error) {
						return;
					}
					if (typeof(data) == "number"){
						return;
					}
					
					if (data["b"] != null){
						trace(data["id"]);
						if (data["id"] == 1) {
							//trace("BLINK1");
							dispatchEvent(new Event(ArduinoConnectModel.PLAYER_ONE_BLINK));
						} else {
							//trace("BLINK2");
							dispatchEvent(new Event(ArduinoConnectModel.PLAYER_TWO_BLINK));
						}
						
						return;
						
					}
					
					if (data["r1"] != null) {
						if (Math.abs(range1 - data["r1"])  < 300) range1 = data["r1"];
						if (Math.abs(range2 - data["r2"]) < 300) range2 = data["r2"];
						return;
					}
					
					//the main packet
					if(data["psl"] != null) {
						poorSignal1 = data["psl"];
						if(poorSignal1 == 0) {		      
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
								
								meditation = 0;
							}
						} /* else */					
					}
				}

				data = null;

				dispatchEvent(new Event(Event.CHANGE));
				
			} /*for each*/
		}
		
	}
}
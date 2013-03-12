package com.cttoronto.pifighter.Events
{
	import flash.events.Event;
	
	public class ApplicationEvent extends Event
	{
		
		public static const START_GAME:String = "START_GAME";
		public static const START_STARTSCREEN:String = "START_STARTSCREEN";
		public static const START_INTRO:String = "START_INTRO";
		public static const START_CHARACTERSELECT:String = "START_CHARACTERSELECT";
		public static const GAME_WIN:String = "GAME_WIN";
		public static const PIGUN_TRIGGER:String = "PIGUN_TRIGGER";
		public static const PLAYER_HIT:String = "PLAYER_HIT";
		public static const SOUND_TOGGLE_SOUND:String = "SOUND_TOGGLE_SOUND";
		public static const ASSETS_LOADED:String = "ASSETS_LOADED";
		
		private var _id:String;
		private var _data:Object;
		
		public function ApplicationEvent(type:String, $id:String = null, $data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			if ($id){
				_id = $id;
			}
			if ($data){
				_data = $data;
			}
		}

		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}

		public function get id():String
		{
			return _id;
		}

		public function set id(value:String):void
		{
			_id = value;
		}

	}
}
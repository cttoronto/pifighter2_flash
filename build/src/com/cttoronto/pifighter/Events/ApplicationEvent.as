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
		
		private var _id:String;
		
		public function ApplicationEvent(type:String, $id:String = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			if ($id){
				_id = $id;
			}
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
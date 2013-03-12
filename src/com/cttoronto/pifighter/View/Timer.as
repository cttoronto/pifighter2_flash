package com.cttoronto.pifighter.View
{
	import com.cttoronto.pifighter.Events.ApplicationEvent;
	import com.cttoronto.pifighter.Model.Config;
	
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class Timer extends DefaultView
	{
		private var _time:uint;
		private var _time_int:uint;
		public var txt_timer:TextField;
		
		private var _complete_id:String = "TIMER_COMPLETE";
		public function Timer()
		{
			super(Config.getInstance());
		}

		public function get complete_id():String
		{
			return _complete_id;
		}

		public function set complete_id(value:String):void
		{
			_complete_id = value;
		}

		public function get time():uint
		{
			return _time;
		}

		public function set time(value:uint):void
		{
			_time = value;
		}
		public function startTimer():void{
			_time_int = setInterval(tick, 1000);
		}
		public function endTimer():void{
			clearInterval(_time_int);
		}
		private function tick():void{
			txt_timer.text = String(time);
			if (time == 0){
				endTimer();
				model.dispatchEvent(new ApplicationEvent(complete_id));
				return;
			}
			time --;
		}
	}
}
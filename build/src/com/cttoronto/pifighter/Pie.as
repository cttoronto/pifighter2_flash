package com.cttoronto.pifighter
{
	import com.cttoronto.pifighter.Events.ApplicationEvent;
	import com.cttoronto.pifighter.Model.Config;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Pie extends MovieClip
	{
		private var _direction:Number = 5;
		private var _pielauncher:MovieClip;
		private var _pietarget:MovieClip;
		private var model:Config;
		public function Pie()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			model = Config.getInstance();
		}
		
		public function get direction():Number
		{
			return _direction;
		}

		public function set direction(value:Number):void
		{
			_direction = value;
		}

		public function get pietarget():MovieClip
		{
			return _pietarget;
		}

		public function set pietarget(value:MovieClip):void
		{
			_pietarget = value;
		}

		public function get pielauncher():MovieClip
		{
			return _pielauncher;
		}

		public function set pielauncher(value:MovieClip):void
		{
			_pielauncher = value;
		}

		protected function onLoop(e:Event):void
		{
			this.x += direction;
			if (this.x > stage.stageWidth || this.x < 0){
				destroy();
			}else{
				if (this.hitTestObject(pietarget.mc_hit)){
					hit();
					destroy();
				}
			}
		}
		
		private function hit():void
		{
			//trace("HIT HIT HIT", pietarget.name);
			if (pietarget.name == "mc_sprite_01"){
				model.winner = "player_02";
			}else {
				model.winner = "player_01";
			}
			destroy();
			model.dispatchApplicationEvent(new ApplicationEvent(ApplicationEvent.GAME_WIN, pietarget.name));
		}
		
		public function onAdded(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.ENTER_FRAME, onLoop);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		}
		private function onRemove(e:Event):void{
			
			removeEventListener(Event.ENTER_FRAME, onLoop);
		}
		private function destroy():void
		{
			if (this.parent){
				this.parent.removeChild(this);
			}
			removeEventListener(Event.ENTER_FRAME, onLoop);
		}
	}
}
package com.cttoronto.pifighter
{
	import com.cttoronto.pifighter.Events.ApplicationEvent;
	import com.cttoronto.pifighter.Model.Config;
	import com.greensock.TweenMax;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Pie extends MovieClip
	{
		private var _direction:Number = 5;
		private var _pielauncher:MovieClip;
		private var _pietarget:MovieClip;
		private var model:Config;
		
		private var active_pie:Boolean = true;
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
			if (pietarget.name == "mc_sprite_02" && value == 0){
				value = 1;
			}else if (pietarget.name == "mc_sprite_01" && value == 0){
				value = -1;
			}
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
				if (this.hitTestObject(pietarget.mc_hit) && active_pie == true){
					hit();
				}
			}
		}
		
		private function hit():void
		{
			active_pie = false;
			switch(Math.floor(Math.random()*3)){
				case 0:
					model.playSound("AUDIO_PIEHIT_1", {loop:0, overwrite:false});
					break;
				case 1:
					model.playSound("AUDIO_PIEHIT_2", {loop:0, overwrite:false});
					break;
				case 2:
					model.playSound("AUDIO_PIEHIT_3", {loop:0, overwrite:false});
					break;
			}
			
			gotoAndPlay(2);
			model.dispatchApplicationEvent(new ApplicationEvent(ApplicationEvent.PLAYER_HIT, pietarget.name));
			TweenMax.delayedCall(0.5, destroy);
		}
		public function onAdded(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.ENTER_FRAME, onLoop);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			switch(Math.floor(Math.random()*3)){
				case 0:
					model.playSound("AUDIO_PIETHROW_1", {loop:0, overwrite:false});
					break;
				case 1:
					model.playSound("AUDIO_PIETHROW_2", {loop:0, overwrite:false});
					break;
				case 2:
					model.playSound("AUDIO_PIETHROW_3", {loop:0, overwrite:false});
					break;
			}
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
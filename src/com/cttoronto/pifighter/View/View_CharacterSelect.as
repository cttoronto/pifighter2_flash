package com.cttoronto.pifighter.View
{
	import com.cttoronto.pifighter.Events.ApplicationEvent;
	import com.cttoronto.pifighter.Model.ArduinoConnectModel;
	import com.cttoronto.pifighter.Model.Config;
	import com.cttoronto.pifighter.PieMath;
	import com.greensock.TweenMax;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import com.quetwo.Arduino.ArduinoConnector;
	
	public class View_CharacterSelect extends DefaultView
	{
		public var mc_characterselect_copy:MovieClip;
		public var mc_character_p1:MovieClip, mc_character_p2:MovieClip;
		public var title_p1:MovieClip, title_p2:MovieClip;
		
		public function View_CharacterSelect()
		{
			super(Config.getInstance());
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		}
		
		override public function onRemove(event:Event):void
		{
			stage.removeEventListener(Event.ENTER_FRAME, onEnter);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
//			ArduinoConnectModel.getInstance().removeEventListener(Event.CHANGE, onPlayerMove);
		}
		override public function onAdded(e:Event):void{
			mc_characterselect_copy.mc_timer.time = 10;
			mc_characterselect_copy.mc_timer.complete_id = ApplicationEvent.START_GAME;
			mc_characterselect_copy.mc_timer.startTimer();
			
			stage.addEventListener(Event.ENTER_FRAME, onPlayerMove);
//			stage.removeEventListener(Event.ENTER_FRAME, onEnter);
//			ArduinoConnectModel.getInstance().waddEventListener(Event.CHANGE, onPlayerMove);
			
			model.playSound("AUDIO_MUSIC_CHARACTER_SELECT", {loop:0, overwrite:true});
		}
		
		protected function onPlayerMove(event:Event):void
		{
			var acm:ArduinoConnectModel = ArduinoConnectModel.getInstance();
			
			var range1:Number = acm.range1 - 80;
			var range2:Number = acm.range2 - 80;
			
			var offset_y:Number = 0;
			
			if (range1 > 0 && range1 < model.motionRange) {
				offset_y = mc_character_p1.height-model.startDistance;
				range1 /= model.motionRange;
				var active_p1:Number = Math.round((range1*offset_y)/80);
				model.active_player_01 = active_p1;
				TweenMax.killTweensOf(mc_character_p1);
				TweenMax.to(mc_character_p1, 0.5, {y:48 - active_p1*90});
			}
			
			if (range2 > 0 && range2 < model.motionRange) {
				offset_y = mc_character_p2.height-model.startDistance;
				range2 /= model.motionRange;
				var active_p2:Number = Math.round((range2*offset_y)/80);
				model.active_player_02 = active_p2;
				
				TweenMax.killTweensOf(mc_character_p2);
				TweenMax.to(mc_character_p2, 0.5, {y:48 - active_p2*90});
			}
			
			title_p1.title.text = model.data_player_01.name.toUpperCase();
			title_p2.title.text = model.data_player_02.name.toUpperCase();
		}
		
		protected function onEnter(e:Event):void
		{
			var perc_p1:Number = stage.mouseX/stage.stageWidth;
			var perc_p2:Number = stage.mouseY/stage.stageHeight;
			var offset_y:Number = mc_character_p2.height-80;
				
			var active_p1:Number = Math.round((perc_p1*offset_y)/80);
			var active_p2:Number = Math.round((perc_p2*offset_y)/80);
			
			model.active_player_01 = active_p1;
			model.active_player_02 = active_p2;
			
			//mc_character_p2.y = 48 - perc_p2*offset_y;
			//mc_character_p2.y = 48 - active_p2*90;
			
			TweenMax.to(mc_character_p1, 0.5, {y:48 - active_p1*90});
			TweenMax.to(mc_character_p2, 0.5, {y:48 - active_p2*90});
			
			
			title_p1.title.text = model.data_player_01.name.toUpperCase();
			title_p2.title.text = model.data_player_02.name.toUpperCase();
		}
	}
}
package com.cttoronto.pifighter.View
{
	import com.cttoronto.pifighter.Pie;
	import com.cttoronto.pifighter.Events.ApplicationEvent;
	import com.cttoronto.pifighter.Model.ArduinoConnectModel;
	import com.cttoronto.pifighter.Model.Config;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.ui.Keyboard;
	
	public class View_Game extends DefaultView
	{
		public var mc_sprite_01:MovieClip, mc_sprite_02:MovieClip, mc_pie:MovieClip, mc_ui:MovieClip;
		public var mc_timer:Timer;
		
		public var mc_bar1:MovieClip, mc_bar2:MovieClip;
		
		public function View_Game()
		{
			super(Config.getInstance());
		}
		override public function onAdded(e:Event):void{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);

			this.addEventListener(Event.ENTER_FRAME, onGotData);
			
			ArduinoConnectModel.getInstance().addEventListener(ArduinoConnectModel.PLAYER_ONE_BLINK, onBlink1);
			ArduinoConnectModel.getInstance().addEventListener(ArduinoConnectModel.PLAYER_TWO_BLINK, onBlink2);
			
			gotoAndPlay(1);
			mc_sprite_01.gotoAndStop(model.data_player_01.frame);
			mc_sprite_02.gotoAndStop(model.data_player_02.frame);
			mc_ui.name_p1.text = model.data_player_01.shortname.toUpperCase();
			mc_ui.name_p2.text = model.data_player_02.shortname.toUpperCase();
			
			mc_timer = mc_ui.mc_timer;
			mc_timer.time = 99;
			mc_timer.complete_id = ApplicationEvent.GAME_WIN;
			mc_timer.startTimer();
			
			mc_bar1.mc_blink.visible = false;
			mc_bar2.mc_blink.visible = false;
		}
		
		private function onGotData(e:Event = null):void {
			
			var offsetY1:Number = ArduinoConnectModel.getInstance().range1 - 80;
			var offsetY2:Number = ArduinoConnectModel.getInstance().range2 - 80;
			
			if (offsetY1 > 0 && offsetY1 < 135) {
				TweenMax.to(mc_sprite_01, 0.10, {y:offsetY1 + 55});
			}
			
			if (offsetY2 > 0 && offsetY2 < 135) {
				TweenMax.to(mc_sprite_02, 0.10, {y:offsetY2 + 55});
			} else { 
				//TweenMax.to(mc_sprite_02, 0.10, {y:1000});
			}
			
			var attention1:Number = ArduinoConnectModel.getInstance().attention1;
			var attention2:Number = ArduinoConnectModel.getInstance().attention2;
			
			TweenMax.to(mc_bar1.mc_powerbar_red, 0.1, {scaleX: attention1 / 100});
			TweenMax.to(mc_bar2.mc_powerbar_red, 0.1, {scaleX: attention2 / 100});
			
		}
		
		private function onBlink1(e:Event):void {
//			trace("BLINK", ArduinoConnectModel.getInstance().attention1);
			var pie_01:Pie = new PieBullet();
			pie_01.pielauncher = mc_sprite_01;
			pie_01.pietarget = mc_sprite_02;
			pie_01.direction *= (ArduinoConnectModel.getInstance().attention1 / 100);
			addChild(pie_01);
			
			pie_01.x = pie_01.pielauncher.x+25;
			pie_01.y = pie_01.pielauncher.y;
			
			mc_sprite_01.sheet.play();
		}
		
		private function onBlink2(e:Event):void {
			var pie_02:Pie = new PieBullet();
			pie_02.scaleX = -1;
			pie_02.direction *= -1;
			pie_02.direction *= (ArduinoConnectModel.getInstance().attention2 / 100);
			pie_02.pielauncher = mc_sprite_02;
			pie_02.pietarget = mc_sprite_01;
			addChild(pie_02);
			
			pie_02.x = pie_02.pielauncher.x-25;
			pie_02.y = pie_02.pielauncher.y;
			
			mc_sprite_02.sheet.play();
		}
		
		override public function onKey(e:KeyboardEvent):void{
			var sprite_offset_01:Number = 10;
			var sprite_offset_02:Number = 10;
			switch (e.keyCode){
				case Keyboard.W:
					sprite_offset_01 *=-1
					//mc_sprite_01.y += sprite_offset;
					TweenMax.to(mc_sprite_01, 0.15, {y:String(sprite_offset_01)});
					break;
				case Keyboard.S:
					//mc_sprite_01.y += sprite_offset;
					TweenMax.to(mc_sprite_01, 0.15, {y:String(sprite_offset_01)});
					break;
				case Keyboard.UP:
					sprite_offset_02 *=-1
					//mc_sprite_01.y += sprite_offset;
					TweenMax.to(mc_sprite_02, 0.15, {y:String(sprite_offset_02)});
					break;
				case Keyboard.DOWN:
					//mc_sprite_01.y += sprite_offset;
					TweenMax.to(mc_sprite_02, 0.15, {y:String(sprite_offset_02)});
					break;
				
				case Keyboard.SHIFT:
					var pie_01:Pie = new PieBullet();
					pie_01.pielauncher = mc_sprite_01;
					pie_01.pietarget = mc_sprite_02;
					addChild(pie_01);
					pie_01.x = pie_01.pielauncher.x+25;
					pie_01.y = pie_01.pielauncher.y;
					mc_sprite_01.sheet.play();
					break;
				case Keyboard.CONTROL:
					var pie_02:Pie = new PieBullet();
					pie_02.scaleX = -1;
					pie_02.direction *= -1;
					pie_02.pielauncher = mc_sprite_02;
					pie_02.pietarget = mc_sprite_01;
					addChild(pie_02);
					pie_02.x = pie_02.pielauncher.x-25;
					pie_02.y = pie_02.pielauncher.y;
					mc_sprite_02.sheet.play();
					break;
				case Keyboard.F:
					stage.scaleMode = StageScaleMode.EXACT_FIT;
					
					stage.displayState=StageDisplayState.FULL_SCREEN;
					break;
			}
			if (mc_sprite_01.y+sprite_offset_01 < 55 || mc_sprite_01.y+sprite_offset_01 >190){
				TweenMax.killTweensOf(mc_sprite_01);
			}
			if (mc_sprite_02.y+sprite_offset_02 < 55 || mc_sprite_02.y+sprite_offset_02 >190){
				TweenMax.killTweensOf(mc_sprite_02);
			}
		}
	}
}
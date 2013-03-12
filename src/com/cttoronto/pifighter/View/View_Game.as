package com.cttoronto.pifighter.View
{
	import com.cttoronto.pifighter.Pie;
	import com.cttoronto.pifighter.Events.ApplicationEvent;
	import com.cttoronto.pifighter.Model.ArduinoConnectModel;
	import com.cttoronto.pifighter.Model.Config;
	import com.greensock.TweenMax;
	
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import net.hires.debug.Stats;
	
	public class View_Game extends DefaultView
	{
		public var mc_sprite_01:MovieClip, mc_sprite_02:MovieClip, mc_pie:MovieClip, mc_ui:MovieClip;
		public var mc_timer:Timer;
		
		public var mc_bar1:MovieClip, mc_bar2:MovieClip;
		
		
		private var healthMeter1:MovieClip ;
		private var healthMeter2:MovieClip ;
		private var pie_ready_01:Boolean = true;
		private var pie_ready_02:Boolean = true;
		
		private var game_enabled:Boolean = true;
		
		private var pie_container:MovieClip = new MovieClip();
		
		public function View_Game()
		{
			super(Config.getInstance());
		}
		override public function onAdded(e:Event):void{
			game_enabled = true;
			
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
			//addChild(new Stats());
			
			healthMeter1 = new MovieClip();
			healthMeter2 = new MovieClip();
			
			createHealthMeter();
			
			model.addEventListener(ApplicationEvent.PLAYER_HIT, onPlayerHit);
			enablePie_01();
			enablePie_02();
			
			model.playSound("AUDIO_MUSIC_GAME", {loop:1, overwrite:true});
			
			addChild(pie_container);
		}
		
		private function onGotData(e:Event = null):void {
			if (game_enabled == false){
				return;
			}
			var offsetY1:Number = model.motionRange - ArduinoConnectModel.getInstance().range1 - model.startDistance;
			var offsetY2:Number = model.motionRange - ArduinoConnectModel.getInstance().range2 - model.startDistance;
			//trace(offsetY1, model.motionRange);
			if (offsetY1 > 0 && offsetY1 < model.motionRange) {
				TweenMax.to(mc_sprite_01, 0.5, {y:offsetY1 + 55});
			}
			
			if (offsetY2 > 0 && offsetY2 < model.motionRange) {
				TweenMax.to(mc_sprite_02, 0.5, {y:offsetY2 + 55});
			} else { 
				//TweenMax.to(mc_sprite_02, 0.10, {y:1000});
			}
			
			var attention1:Number = ArduinoConnectModel.getInstance().attention1;
			var attention2:Number = ArduinoConnectModel.getInstance().attention2;
			
			TweenMax.to(mc_bar1.mc_powerbar_red, 0.1, {scaleX: attention1 / 100});
			TweenMax.to(mc_bar2.mc_powerbar_red, 0.1, {scaleX: attention2 / 100});
		}
		
		private function onPlayerHit(e:ApplicationEvent):void {
			if (game_enabled == false){
				return;
			}
			if (e.id == "mc_sprite_02") {
				if (healthMeter2.numChildren > 1) {
					//Normal Hit
					healthMeter2.removeChildAt(healthMeter2.numChildren -1);
				} else {
					//GAME WIN
					win("player_01");
				}
			} else {
				if (healthMeter1.numChildren > 1) {
					//Normal Hit
					healthMeter1.removeChildAt(healthMeter1.numChildren -1);
				} else {
					//GAME WIN
					win("player_02");
					//model.winner = "player_02";
					//model.dispatchApplicationEvent(new ApplicationEvent(ApplicationEvent.GAME_WIN, e.id));
				}
			}
		}
		private function win($id:String):void{
			game_enabled = false;
			for each (var pie:Pie in pie_container){
				if (pie.currentFrame == 1){
					pie_container.removeChild(pie);
				}
			}
			model.playSound("AUDIO_CROWDEND", {loop:3, overwrite:false});
			model.winner = $id;
			if ($id == "player_01"){
				TweenMax.delayedCall(4, delayedEndGame, ["mc_sprite_01"]);
				//model.dispatchApplicationEvent(new ApplicationEvent(ApplicationEvent.GAME_WIN, "mc_sprite_01"));
			}else {
				TweenMax.delayedCall(4, delayedEndGame, ["mc_sprite_02"]);
				//model.dispatchApplicationEvent(new ApplicationEvent(ApplicationEvent.GAME_WIN, "mc_sprite_02"));
			}
		}
		private function delayedEndGame($id:String):void{
			model.dispatchApplicationEvent(new ApplicationEvent(ApplicationEvent.GAME_WIN));
		}
		private function createHealthMeter():void{
			var i:int = 0;
			for (i = 0; i < 5; ++i) {
				
				var healthMeterPie1:MovieClip = new meterPie();
				var healthMeterPie2:MovieClip = new meterPie();
				
				healthMeterPie1.scaleX = healthMeterPie1.scaleY = 0.5;
				healthMeterPie2.scaleX = healthMeterPie2.scaleY = 0.5;
				
				healthMeterPie1.x = i * healthMeterPie1.width + 3;
				healthMeterPie2.x = i * healthMeterPie2.width + 3;
				
				
				healthMeter1.addChild(healthMeterPie1);
				healthMeter2.addChild(healthMeterPie2);
				
			}
			
			healthMeter1.x = mc_bar1.x;
			healthMeter2.x = mc_bar2.x + mc_bar2.width - healthMeter2.width;
			
			healthMeter1.y = mc_bar1.y + 20;
			healthMeter2.y = mc_bar2.y + 20;
			
			addChild(healthMeter2);
			addChild(healthMeter1);
		}
		private function onBlink1(e:Event = null):void {
			fireGamePie(1);
		}
		
		private function enablePie_01():void
		{
			pie_ready_01 = true;
		}
		
		private function onBlink2(e:Event = null):void {
			fireGamePie(2);
		}
		private function fireGamePie($pie:Number):void{
			if (game_enabled == false){
				return;
			}
			if ($pie == 1){
				if (!pie_ready_01){
					return;
				}
				var pie_01:Pie = new PieBullet();
				pie_01.pielauncher = mc_sprite_01;
				pie_01.pietarget = mc_sprite_02;
				pie_01.direction *= (ArduinoConnectModel.getInstance().attention1 / 100);
				
				pie_container.addChild(pie_01);
				
				pie_01.x = pie_01.pielauncher.x+25;
				pie_01.y = pie_01.pielauncher.y;
				
				mc_sprite_01.sheet.play();
				
				pie_ready_01 = false;
				setTimeout(enablePie_01, model.pieTimeout);
			}else{
				if (!pie_ready_02){
					return;
				}
				var pie_02:Pie = new PieBullet();
				pie_02.scaleX = -1;
				pie_02.pielauncher = mc_sprite_02;
				pie_02.pietarget = mc_sprite_01;
				pie_02.direction *= -1;
				pie_02.direction *= (ArduinoConnectModel.getInstance().attention2 / 100);
				pie_container.addChild(pie_02);
				
				pie_02.x = pie_02.pielauncher.x-25;
				pie_02.y = pie_02.pielauncher.y;
				
				mc_sprite_02.sheet.play();
				
				pie_ready_02 = false;
				setTimeout(enablePie_02, model.pieTimeout);
			}
		}
		private function enablePie_02():void
		{
			pie_ready_02 = true;
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
					fireGamePie(1);
					break;
				case Keyboard.CONTROL:
					fireGamePie(2);
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
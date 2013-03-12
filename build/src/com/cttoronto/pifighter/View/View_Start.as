package com.cttoronto.pifighter.View
{
	import com.cttoronto.pifighter.Events.ApplicationEvent;
	import com.cttoronto.pifighter.Model.Config;
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class View_Start extends DefaultView
	{
		private const PLAYER_1:String = "PLAYER_1";
		private const PLAYER_2:String = "PLAYER_2";
		
		private var state_player_1:String;
		private var state_player_2:String;
		
		private const STATE_READY:String = "STATE_READY";
		private const STATE_WAITING:String = "STATE_WAITING";
		
		public var dispatcher:EventDispatcher = new EventDispatcher();
		public var mc_playertext_01:MovieClip, mc_playertext_02:MovieClip;
		
		private var timeout_id:uint;
		public function View_Start()
		{
			super(Config.getInstance());
		}
		override public function onAdded(e:Event):void{
			this.visible = true;
			gotoAndPlay(1);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			
			mc_playertext_01.player_title.text = "PLAYER 1";
			mc_playertext_02.player_title.text = "PLAYER 2";
			
			timeout_id = setTimeout(onTimeout, 20000);
		}
		private function onTimeout():void{
			model.dispatchEvent(new Event(ApplicationEvent.START_INTRO));
		}
		override public function onKey(e:KeyboardEvent):void{
			switch (e.keyCode){
				case Keyboard.NUMBER_1:
					player_ready(PLAYER_1);
					break;
				case Keyboard.NUMBER_2:
					player_ready(PLAYER_2);
					break;
				case Keyboard.NUMBER_3:
					player_waiting(PLAYER_1);
					break;
				case Keyboard.NUMBER_4:
					player_waiting(PLAYER_2);
					break;
				case Keyboard.R:
					gotoAndPlay(1);
					break;
			}
			
		}
		private function player_ready($player:String):void{
			switch ($player){
				case PLAYER_1:
					trace("PLAYER_1 READY");
					state_player_1 = STATE_READY;
					mc_playertext_01.mc_start_player_status.mc_start_status_waiting.visible = false;
					mc_playertext_01.mc_start_player_status.mc_start_status_ready.visible = true;
					break;
				case PLAYER_2:
					trace("PLAYER_2 READY");
					state_player_2 = STATE_READY;
					mc_playertext_02.mc_start_player_status.mc_start_status_waiting.visible = false;
					mc_playertext_02.mc_start_player_status.mc_start_status_ready.visible = true;
					break;
			}
			if (state_player_1 == STATE_READY && state_player_2 == STATE_READY){
				gameStart();
			}
		}
		private function player_waiting($player:String):void{
			switch ($player){
				case PLAYER_1:
					trace("PLAYER_1 WAITING");
					state_player_1 = STATE_WAITING;
					mc_playertext_01.mc_start_player_status.mc_start_status_waiting.visible = true;
					mc_playertext_01.mc_start_player_status.mc_start_status_ready.visible = false;
					break;
				case PLAYER_2:
					trace("PLAYER_2 WAITING");
					state_player_2 = STATE_WAITING;
					mc_playertext_02.mc_start_player_status.mc_start_status_waiting.visible = true;
					mc_playertext_02.mc_start_player_status.mc_start_status_ready.visible = false;
					break;
			}
		}
		public function gameStart(){
			clearTimeout(timeout_id);
			model.dispatchEvent(new Event(ApplicationEvent.START_CHARACTERSELECT));
			this.visible = false;
			player_waiting(PLAYER_1);
			player_waiting(PLAYER_2);
		}
	}
}
package com.cttoronto.pifighter.View
{
	import com.cttoronto.pifighter.Events.ApplicationEvent;
	import com.cttoronto.pifighter.Model.ArduinoConnectModel;
	import com.cttoronto.pifighter.Model.Config;
	import com.greensock.TweenMax;
	
	import flash.display.BitmapData;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.StatusEvent;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	public class View_End extends DefaultView
	{
		
		private var _state:String;
		static const  STATE_MIDDLE:String = "STATE_MIDDLE";
		static const  STATE_CAMERA_RIGHT:String = "STATE_CAMERA_RIGHT";
		static const  STATE_CAMERA_LEFT:String = "STATE_CAMERA_LEFT";
		
		private var container_video:Sprite = new Sprite();
		
		private var cam:Camera;
		private var video1:Video;
		private var video2:Video;
		private var video2_mask:Sprite = new Sprite();
		
		public var mc_timer:Timer;
		public var mc_prepare_copy:MovieClip;
		public var mc_credit:MovieClip;
		private var labelsArray:Array;
		
		private var snapshots:Array = new Array();
		
		public function View_End()
		{
			super(Config.getInstance());
		}
		override public function onAdded(e:Event):void{
			super.onAdded(e);
			mc_credit.visible = false;
			
			video1 = new Video(640,480);
			video2 = new Video(640,480);
			
			var cam1:Camera = Camera.getCamera(model.data.camera1);
			var cam2:Camera = Camera.getCamera(model.data.camera2);
			
			cam1.addEventListener(StatusEvent.STATUS, camStatusHandler); 
			
			cam1.setMode(640,480,30);
			cam2.setMode(640,480,30);
			
			video1.attachCamera(cam1);
			video2.attachCamera(cam2);
			
			video2_mask.graphics.beginFill(0x00FF00);
			video2_mask.graphics.drawRect(video1.width, 0, video1.width, video1.height);
			video2_mask.graphics.endFill();
			container_video.addChild(video2_mask);
			video2.mask = video2_mask;
			
			video2.x=video1.width;
			
			container_video.addChild(video1);
			container_video.addChild(video2);
			addChildAt(container_video,0);
			
			container_video.width = 640;
			container_video.height = 240;
			
			mc_timer.time = 10;
			mc_timer.complete_id = ApplicationEvent.PIGUN_TRIGGER;
			mc_timer.startTimer();
			
			state = STATE_MIDDLE;
			mc_prepare_copy.alpha = mc_timer.alpha = 1;
			
			setTimeout(hideUI, 10000);
			mc_credit.visible = false;
			
			labelsArray = mc_credit.currentLabels;
			for(var i:uint=0; i<labelsArray.length; i++){
				var frameLabel:FrameLabel = labelsArray[i];
				frameLabel.addEventListener(Event.FRAME_LABEL, onFrameLabel);
			}
			
			model.playSound("AUDIO_MUSIC_CREDITS", {loop:0, overwrite:true});
		}
		
		protected function onFrameLabel(e:Event):void
		{
			e.target.removeEventListener(Event.FRAME_LABEL, onFrameLabel);
			if (e.target.name == "end_credits"){
				mc_credit.gotoAndStop(1);
				
				model.dispatchApplicationEvent(new ApplicationEvent(ApplicationEvent.START_INTRO));
			}
		}
		protected function camStatusHandler(e:StatusEvent):void
		{
		}
		
		private function hideUI():void
		{
			TweenMax.to(mc_timer, 2,{alpha:0});
			TweenMax.to(mc_prepare_copy, 2,{alpha:0});
			
			if (model.winner == "player_01"){
				state = STATE_CAMERA_LEFT;
			}else if (model.winner == "player_02"){
				state = STATE_CAMERA_RIGHT;
			}
			setTimeout(FIREPIEGUNFUCKER, 3000);
			setTimeout(showCredits, 10000);
		}
		
		private function FIREPIEGUNFUCKER():void
		{
			trace("FIREPIEGUNFUCKER MODEL WINNER", model.winner);
			
			if (model.winner == "player_01"){
				ArduinoConnectModel.getInstance().firepie(1);
				//bmpd.draw(video2);
			}else if (model.winner == "player_02"){
				ArduinoConnectModel.getInstance().firepie(2);
				
				//bmpd.draw(video1);
			}else{
				ArduinoConnectModel.getInstance().firepie(1);
				ArduinoConnectModel.getInstance().firepie(2);
			}
			TweenMax.delayedCall(0,snapshot);
		}
		private function snapshot():void{
			var bmpd:BitmapData = new BitmapData(video1.width*2, video1.height);
			container_video.scaleX = container_video.scaleY = 1;
			
			var pre_video1_x:Number = video1.x;
			var pre_video2_x:Number = video2.x;
			
			video1.x = 0;
			video2.x = video1.width;
			video2.mask = null;
			
			bmpd.draw(container_video);
			video2.mask = video2_mask;
			//bmpd.draw(video1);
			
			video1.x = pre_video1_x;
			video2.x = pre_video2_x;
			container_video.scaleX = container_video.scaleY = 0.5;
			
			snapshots.push(bmpd);
			
			model.saveJPGToUser(snapshots[0], "FirePie_");
			snapshots = new Array();
			/*
			if (snapshots.length >=3){
				for (var i = 0; i < snapshots.length; i++){
					model.saveJPGToUser(snapshots[i], "FirePie_");
				}
				snapshots = new Array();
			}else{
				//TweenMax.delayedCall(1,snapshot);
			}
			*/
		}
		private function showCredits():void{
			mc_credit.visible = true;
			mc_credit.gotoAndPlay(2);
			setTimeout(killEnd, 15000);
			ArduinoConnectModel.getInstance().dispose();
		}
		private function killEnd():void
		{
			model.dispatchApplicationEvent(new ApplicationEvent(ApplicationEvent.START_INTRO));
		}
		
		override public function onKey(e:KeyboardEvent):void{
			switch(e.keyCode){
				case Keyboard.LEFT:
					state = STATE_CAMERA_LEFT;
					break;
				case Keyboard.RIGHT:
					state = STATE_CAMERA_RIGHT;
					break;
				case Keyboard.DOWN:
				case Keyboard.UP:
					state = STATE_MIDDLE;
					break;
				case Keyboard.END:
					model.dispatchApplicationEvent(new ApplicationEvent(ApplicationEvent.START_STARTSCREEN));
					break;
			}
		}
		
		private function set state($state:String):void{
			_state = $state;
			switch (_state){
				case STATE_CAMERA_LEFT:
					TweenMax.to(container_video, 0.5, {x:0});
					TweenMax.to(video1, 0.5, {x:0});
					TweenMax.to(video2, 0.5, {x:video1.width});
					break;
				case STATE_CAMERA_RIGHT:
					TweenMax.to(container_video, 0.5, {x:-320});
					TweenMax.to(video1, 0.5, {x:0});
					TweenMax.to(video2, 0.5, {x:video1.width});
					break;
				case STATE_MIDDLE:
					TweenMax.to(container_video, 0.5, {x:-(160)});
					TweenMax.to(video1, 0.5, {x:video1.width>>2});
					TweenMax.to(video2, 0.5, {x:video1.width-(video1.width>>2)});
					break;
			}
		}
		private function webcamSupportedModes(minW:Number, minH:Number, maxW:Number, maxH:Number, fps:Number, step:uint = 20)
		{
			var cam:Camera = Camera.getCamera("2");
			
			for (var w:uint = minW; w < maxW + 1; w = w + step)
			{
				for (var h:uint = minH; h < maxH + 1; h = h + step)
				{
					cam.setMode(w, h, fps);
					if (w == cam.width && h == cam.height)
					{
						trace(cam.width + " x " + cam.height + " @ " + cam.fps);
					}
				}
			}
		}
	}
}
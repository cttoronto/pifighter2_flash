package com.cttoronto.pifighter.View
{
	import com.cttoronto.pifighter.Events.ApplicationEvent;
	import com.cttoronto.pifighter.Model.Config;
	
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	public class View_Intro extends DefaultView
	{
		private var intro_video:Video = new Video(320,240);
		private var intro_video_ns:NetStream;
		private var intro_video_nc:NetConnection = new NetConnection();
		
		private var video_gaiden:String = "videos/pifight_ninjagaiden_intro_02.f4v";
		private var video_allyourbase:String = "videos/pifight_allyourbase_intro_02.f4v";
		
		
		//public var video_gaiden:MovieClip, video_allyourbase:MovieClip;
		private var active_video:MovieClip;
		private var labelsArray:Array;
		private var labelsArrayVid:Array;
		public function View_Intro()
		{
			super(Config.getInstance());
			intro_video_nc.connect(null);
			intro_video_ns  = new NetStream(intro_video_nc);
			intro_video_ns.client = { onMetaData: function():void {} }
			intro_video.attachNetStream(intro_video_ns);
			
			intro_video_ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorEventHandler);
		}
		
		protected function asyncErrorEventHandler(event:AsyncErrorEvent):void
		{
		}
		private function onFrameLabel(e:Event):void{
			e.target.removeEventListener(Event.FRAME_LABEL, onFrameLabel);
			if (e.target.name == "play_video"){
				stop();
				if (Math.round(Math.random()*1) == 0){
					intro_video_ns.play(video_gaiden);
				}else{
					intro_video_ns.play(video_allyourbase);
				}
				initVid();
				
			}
		}
		private function onVidLabels(e:Event):void{
			e.target.removeEventListener(Event.FRAME_LABEL, onVidLabels);
			if (e.target.name == "end_video"|| e.target.name =="end_test"){
				onTimeout();
			}
		}
		private function initVid():void{
			intro_video.visible = true;
			intro_video_ns.seek(0);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		}
		override public function onAdded(e:Event):void{
			//removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			//setTimeout(onTimeout, 5000);
			gotoAndPlay(1);
			
			addChild(intro_video);
			intro_video.visible = false;
			labelsArray = currentLabels;
			for(var i:uint=0; i<labelsArray.length; i++){
				var frameLabel:FrameLabel = labelsArray[i];
				frameLabel.addEventListener(Event.FRAME_LABEL, onFrameLabel);
			}
			intro_video_ns.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			
		}
		override public function onKey(e:KeyboardEvent):void{
			onTimeout();
		}
		private function statusHandler(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case "NetStream.Play.Start":
					break;
				case "NetStream.Play.Stop":
					onTimeout();
					break;
			}
		}
		private function onTimeout():void{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
			intro_video_ns.removeEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			intro_video_ns.pause();
			model.dispatchEvent(new Event(ApplicationEvent.START_STARTSCREEN));
		}
	}
}
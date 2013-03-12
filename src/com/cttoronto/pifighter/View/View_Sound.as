package com.cttoronto.pifighter.View
{
	import com.cttoronto.pifighter.Events.ApplicationEvent;
	import com.cttoronto.pifighter.Model.Config;
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.Dictionary;
	
	import net.gomangostudios.ToyotaMatchGame.Events.ApplicationEvent;
	
	
	public class View_Sound extends DefaultView
	{
		private var sound_dict:Dictionary = new Dictionary();
		
		private var _sound_on:Boolean = true;
		
		
		public function View_Sound()
		{
			super(Config.getInstance());
		}
		
		public function get sound_on():Boolean
		{
			return _sound_on;
		}
		
		public function set sound_on(value:Boolean):void
		{
			_sound_on = value;
		}
		override public function onAdded(e:Event):void{
			initSounds();
			model.addEventListener(ApplicationEvent.SOUND_TOGGLE_SOUND, onToggleSound);
			model.volume = 1;
			return;
		}
		private function initSounds():void
		{
			var snd:Sound;
			for each (var sound:Object in model.data.audio){
				addSound(sound.id, model.getSound(sound.id));
				model.addEventListener(sound.id, onSoundPlay);
			}
		}
		private function onSoundPlay(e:ApplicationEvent):void{
			playSound(e.type, e.data.loop, e.data.overwrite);
		}
		public function playSound($id:String, $loop:int = 0, $overwrite:Boolean = false):void{
			if ($overwrite){
				stopAllSounds();
			}
			if (sound_dict[$id] && sound_on == true){
				sound_dict[$id].soundChannel = sound_dict[$id].sound.play(0, $loop);
			}
		}
		private function addSound($id:String, $snd:Sound):void{
			sound_dict[$id] = {"sound":$snd, "soundChannel":new SoundChannel()};
		}
		private function stopSound($id:String):void{
			sound_dict[$id].soundChannel.stop();
		}
		
		private function stopAllSounds():void{
			for (var id:String in sound_dict){
				sound_dict[id].soundChannel.stop();
			}
		}
		private function onToggleSound(e:Event):void{
			_sound_on = !_sound_on;
		}
	}
}
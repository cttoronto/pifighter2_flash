package com.cttoronto.pifighter.Model
{
	import com.cttoronto.pifighter.PieMath;
	import com.cttoronto.pifighter.Events.ApplicationEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	
	import br.com.stimuli.loading.BulkLoader;
	
	public class Config extends EventDispatcher
	{
		//Smells like singleton spirit
		private static var _instance:Config;
		//JSON Config "Object"
		private var _data:Object;
		private var _bl:BulkLoader;
		private var _jsonPath:String = "main_en.json";
		
		private var _player_01:String = "character_00";
		private var _player_02:String = "character_00";
		
		private var _winner:String = "player_tie";
		private var _comport:String = "COM11";
		
		public function Config(pvt:PrivateClass)
		{
			_bl = new BulkLoader("BulkLoader_PieFighter2");
		}

		public function get comport():String
		{
			if (data["comport"]){
				return data["comport"];
			}
			return _comport;
		}

		public function set comport(value:String):void
		{
			_comport = value;
		}

		public function get winner():String
		{
			return _winner;
		}

		public function set winner(value:String):void
		{
			_winner = value;
		}

		public function get player_02():String
		{
			return _player_02;
		}
		public function set player_02($name:String):void{
			_player_02 = $name;
		}

		public function set active_player_02(value:Number):void
		{
			_player_02 = "character_"+PieMath.padZero(value, 2);
		}

		public function get player_01():String
		{
			return _player_01;
		}
		
		public function set player_01($name:String):void{
			_player_01 = $name;
		}
		public function set active_player_01(value:Number):void
		{
			_player_01 = "character_"+PieMath.padZero(value, 2);
		}
		public function get data_player_01():Object{
			return data.characters[player_01];
		}
		public function get data_player_02():Object{
			return data.characters[player_02];
		}
		public function get data():Object{
			//Returns "well formed" JSON
			return _data;
		}
		
		public function set data($data:Object):void{
			//Takes the content of a text file
			if (!$data){
				trace("Config.as Error: parameter $data not set");
				return;	
			}
			_data = JSON.parse($data.toString());
		}
		public function get bulkloader():BulkLoader{
			return _bl;
		}
		
		public function set bulkloader($bl:BulkLoader):void{
			if (!$bl){
				trace("Config.as Error: parameter $bl not set");
				return;	
			}
			_bl = $bl;
		}
		public function sortJSONElement($jsonObj:Object):Array{
			var sortedArray:Array = new Array();
			
			for each(var i:Object in $jsonObj){
				sortedArray.push(i);
			}
			sortedArray.sortOn("element_order", Array.NUMERIC);
			return sortedArray;
		}
		public function loadConfigFile($jsonPath:String = null):void{
			if ($jsonPath != null){
				_jsonPath = $jsonPath;
			}
			bulkloader.add(_jsonPath, {id:"jsonConfig"});
			
			// listen to when the lazy loader has loaded the external definition
			bulkloader.addEventListener(BulkLoader.COMPLETE, setBulkloaderManifest);
			bulkloader.start();
		}
		private function setBulkloaderManifest(e:Event = null):void{
			bulkloader.removeEventListener(BulkLoader.COMPLETE,setBulkloaderManifest);
			data = bulkloader.getContent("jsonConfig");
			
			var imageList:Array = new Array();
			recurse (imageList, data);
			for each (var item:Object in imageList){
				if (item.preload == false){
					continue;
				}
				bulkloader.add(item.item_asset,{id:item.id, "pausedAtStart":true});
				
				//trace("id:",item.id, " - item_asset:",item.item_asset);
			}
			bulkloader.start();
			bulkloader.addEventListener(BulkLoader.COMPLETE, assetsLoaded);
			bulkloader.removeEventListener(BulkLoader.COMPLETE, update);
			volume = 1;
			update();
		}
		public function set volume ($volume:Number):void{
			SoundMixer.soundTransform = new SoundTransform($volume);
		}
		public function toggleVolume():void{
			if (SoundMixer.soundTransform.volume == 0){
				volume = 1;
			}else{
				volume = 0;
			}
		}
		public function assetsLoaded(e:Event = null):void{
			bulkloader.removeEventListener(BulkLoader.COMPLETE,assetsLoaded);
		}
		private function recurse(a:Array, targ:Object, id:String = "ui"):void{
			for (var i:String in targ){
				if (i=="preload"){
					if (targ.preload == false){
						continue;
					}
				}
				if (i=="asset_path"){
					if (targ.id){
						id = targ.id;
						
					}
					var preload:Boolean = true;
					if (targ["preload"]!= null){
						preload=targ.preload;
					}
					a.push({preload:preload, id:id,item_asset:targ[i]});
				}
				recurse (a, targ[i], i);
			}
		}
		protected function update(e:Event = null):void{
			dispatchEvent(new Event(Event.CHANGE));
		}
		public static function getInstance():Config{
			if (Config._instance == null){
				Config._instance = new Config(new PrivateClass());
			}
			return Config._instance;
		}
		public function dispatchApplicationEvent(e:ApplicationEvent):void{
			dispatchEvent(e);
		}
	}
}

class PrivateClass
{
	public function PrivateClass()
	{
	}
}
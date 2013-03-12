package com.cttoronto.pifighter.View
{
	import com.cttoronto.pifighter.Model.Config;
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	public class DefaultView extends MovieClip
	{
		public var model:Config;
		public function DefaultView($model:Config)
		{
			super();
			model = $model;
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		}
		
		public function onRemove(event:Event):void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
		}
		public function onAdded(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		}
		public function onKey(e:KeyboardEvent):void{
			
		}
	}
}
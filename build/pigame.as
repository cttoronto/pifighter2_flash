package  {
	
	import com.cttoronto.pifighter.Pie;
	import com.cttoronto.pifighter.Events.ApplicationEvent;
	import com.cttoronto.pifighter.Model.ArduinoConnectModel;
	import com.cttoronto.pifighter.Model.Config;
	import com.cttoronto.pifighter.View.View_CharacterSelect;
	import com.cttoronto.pifighter.View.View_End;
	import com.cttoronto.pifighter.View.View_Game;
	import com.cttoronto.pifighter.View.View_Intro;
	import com.cttoronto.pifighter.View.View_Start;
	import com.greensock.TweenMax;
	
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import fl.transitions.Tween;
	
	import org.puremvc.as3.core.View;
	
	public class pigame extends MovieClip {
		
		private var view_start:View_Start;
		private var view_game:View_Game;
		private var view_intro:View_Intro;
		private var view_characterselect:View_CharacterSelect;
		private var view_end:View_End;
		
		private var model:Config;
		public function pigame() {
			// constructor code
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			model = Config.getInstance();
			model.addEventListener(ApplicationEvent.START_GAME, onStartGame);
			model.addEventListener(ApplicationEvent.START_STARTSCREEN, onStartScreenStart);
			model.addEventListener(ApplicationEvent.START_INTRO, onStartIntro);
			model.addEventListener(ApplicationEvent.START_CHARACTERSELECT, onCharacterSelect);
			model.addEventListener(ApplicationEvent.GAME_WIN, onGameWin);
			
			addEventListener(Event.CLOSE, closeApp);
			
			//Check the "_root" for flashvars
			//specifying the path the the json file
			var jsonPath:String;
			try {
				var paramObj:Object = LoaderInfo(this.root.loaderInfo).parameters;
				for (var keyStr:Object in paramObj) {
					if (keyStr == "jsonPath"){
						jsonPath = paramObj[keyStr];
					}
				}
			} catch (error:Error) {
				trace("Pigame.as: No JSON Path Specified. Using default.");
			}
			//Make a custom context menu
			
			var a:ArduinoConnectModel = ArduinoConnectModel.getInstance();
			
			view_start = new fla_view_start();
			view_game = new fla_view_game();
			view_intro = new fla_view_intro();
			view_characterselect = new fla_view_characterselect();
			view_end = new fla_view_end();
			
			//Load JSON File
			model.addEventListener(Event.CHANGE, initPreload);
			model.loadConfigFile(jsonPath);
		}
		
		protected function initPreload(event:Event):void
		{
			model.dispatchEvent(new Event(ApplicationEvent.START_INTRO));
			//model.dispatchApplicationEvent(new ApplicationEvent(ApplicationEvent.GAME_WIN));
		}
		
		protected function onStartGame(event:Event):void
		{
			removeAllViews();
			addChild(view_game);
		}
		protected function onCharacterSelect(e:Event = null):void{
			removeAllViews();
			addChild(view_characterselect);
		}
		protected function onStartScreenStart(event:Event = null):void
		{
			removeAllViews();
			addChild(view_start);
		}
		protected function onStartIntro(event:Event):void
		{
			removeAllViews();
			addChild(view_intro);//98.75
		}
		private function removeAllViews():void{
			if (contains(view_start)){
				removeChild(view_start);
			}
			if (contains(view_intro)){
				removeChild(view_intro);
			}
			if (contains(view_characterselect)){
				removeChild(view_characterselect);
			}
			if (contains(view_game)){
				removeChild(view_game);
			}
			if (contains(view_end)){
				removeChild(view_end);
			}
		}
		private function onAdded(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		private function onGameWin(e:ApplicationEvent):void{
			removeAllViews();
			addChild(view_end);
			//onStartScreenStart();
		}
		protected function closeApp(event:Event):void
		{
			trace("ONCLOSE");
			ArduinoConnectModel.getInstance().dispose();                              
		}
	}
}

package red.game.witcher3.menus.character_menu
{
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.GTweener;
   import com.gskinner.motion.easing.Exponential;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.geom.ColorTransform;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import red.game.witcher3.controls.TooltipAnchor;
   import red.game.witcher3.slots.SlotBase;
   import red.game.witcher3.slots.SlotsListPreset;
   import scaleform.clik.controls.StatusIndicator;
   import scaleform.gfx.MouseEventEx;
   
   public class MutationItemRenderer extends SlotBase
   {
      
      protected static const COLOR_MAP:Object = [{
         "color":"yellow",
         "id_list":[1,7,11,12,9,5]
      },{
         "color":"red",
         "id_list":[3,8]
      },{
         "color":"green",
         "id_list":[4,10]
      },{
         "color":"blue",
         "id_list":[2,6]
      }];
      
      public static var TRIGGER_EQUIP_FX:Boolean = false;
      
      public static var TRIGGER_UNEQUIP_FX:Boolean = false;
      
      public static var TRIGGER_RESEARCHED_ID_FX:int = -1;
      
      internal const DISABLED_ALPHA_COLOR:* = 0.7;
      
      internal const DISABLED_ALPHA_ICON:* = 0.3;
      
      protected const MAX_PROGRESS:* = 100;
      
      public var tfMutationName:TextField;
      
      public var tfTempText:TextField;
      
      public var mcFakeProgressbar:StatusIndicator;
      
      public var mcProgressbar:StatusIndicator;
      
      public var mcMutagenColor:MovieClip;
      
      public var mcIconBackground:MovieClip;
      
      public var mcEquippedIndicator:MovieClip;
      
      public var mcFlashAnimation:MovieClip;
      
      public var mcMutagenColorAnim:MovieClip;
      
      public var mcEquippedBkg:MovieClip;
      
      public var mcResearchCompleteAnim:MovieClip;
      
      private var _mutationId:int;
      
      private var _slotNavigationId:int;
      
      private var _firstDataUpdate:Boolean;
      
      protected var _blocked:Boolean;
      
      protected var _tooltipAnchorName:String;
      
      protected var _tooltipAnchorComponent:TooltipAnchor;
      
      protected var _renderersContainer:Sprite;
      
      public var mcProgressList:SlotsListPreset;
      
      public var mcMutationResource1:MutationProgressItemRenderer;
      
      public var mcMutationResource2:MutationProgressItemRenderer;
      
      public var mcMutationResource3:MutationProgressItemRenderer;
      
      public var mcMutationResource4:MutationProgressItemRenderer;
      
      protected var _connectorsList:Vector.<MutationConnector>;
      
      public function MutationItemRenderer()
      {
         super();
         this._firstDataUpdate = true;
         if(this.tfMutationName)
         {
            this.tfMutationName.visible = false;
         }
         this._connectorsList = new Vector.<MutationConnector>();
         addEventListener(Event.ENTER_FRAME,this.handleEnterFrame,false,0,true);
         if(this.mcMutagenColorAnim)
         {
            this.mcMutagenColorAnim.visible = false;
         }
      }
      
      public static function getColorById(id:int) : String
      {
         var curDataItem:Object = null;
         var dataList:Array = null;
         for each(curDataItem in COLOR_MAP)
         {
            dataList = curDataItem.id_list as Array;
            if(Boolean(dataList) && dataList.indexOf(id) > -1)
            {
               return curDataItem.color;
            }
         }
         return "";
      }
      
      public function addConnector(value:MutationConnector) : void
      {
         this._connectorsList.push(value);
         this.updateConnectors();
      }
      
      public function get tooltipAnchorName() : String
      {
         return this._tooltipAnchorName;
      }
      
      public function set tooltipAnchorName(value:String) : void
      {
         this._tooltipAnchorName = value;
         if(Boolean(this._tooltipAnchorName) && Boolean(parent))
         {
            this._tooltipAnchorComponent = parent.getChildByName(this._tooltipAnchorName) as TooltipAnchor;
         }
      }
      
      public function getTooltipAnchorComponent() : TooltipAnchor
      {
         return this._tooltipAnchorComponent;
      }
      
      override public function getSlotRect() : Rectangle
      {
         var selSize:Number = NaN;
         var widthSize:Number = NaN;
         var textWidth:Number = NaN;
         if(mcStateSelectedActive)
         {
            if(this.tfMutationName)
            {
               textWidth = this.tfMutationName.textWidth;
            }
            selSize = mcStateSelectedActive.width;
            widthSize = Math.max(textWidth,selSize);
            return new Rectangle(-widthSize / 2,-selSize / 2,widthSize,selSize);
         }
         return super.getSlotRect();
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         if(this.mcEquippedIndicator)
         {
            this.mcEquippedIndicator.visible = false;
         }
         if(this.mcIconBackground)
         {
            this.mcEquippedBkg = this.mcIconBackground.getChildByName("mcEquipped") as MovieClip;
            if(this.mcEquippedBkg)
            {
               this.mcEquippedBkg.visible = false;
            }
         }
      }
      
      override public function set data(value:*) : void
      {
         super.data = value;
      }
      
      // Spectre: with "Several mutations at once", the main mutation (spectreShown) has its ring and icon background
      // in bright gold instead of white, and a soft gold glow around the ring.
      private function spectreTintMain(main:Boolean) : void
      {
         var tint:ColorTransform = main ? new ColorTransform(1,0.84,0.4,1,0,0,0,0) : new ColorTransform();
         if(this.mcEquippedIndicator)
         {
            this.mcEquippedIndicator.transform.colorTransform = tint;
            this.mcEquippedIndicator.filters = main ? [new GlowFilter(16762442,0.9,18,18,2.5,2)] : [];
         }
         if(this.mcEquippedBkg)
         {
            this.mcEquippedBkg.transform.colorTransform = tint;
         }
      }
      
      override protected function updateData() : *
      {
         super.updateData();
         this.updateMutationData();
      }
      
      public function setFakeProgressValue(value:Number) : void
      {
         if(!this.mcFakeProgressbar)
         {
            return;
         }
         if(value >= 0)
         {
            this.mcFakeProgressbar.maximum = this.MAX_PROGRESS;
            this.mcFakeProgressbar.value = (_data.usedResourcesCount + value) / _data.requaredResourcesCount * 100;
            this.mcFakeProgressbar.visible = true;
         }
         else
         {
            this.mcFakeProgressbar.visible = false;
         }
      }
      
      protected function handleEnterFrame(event:Event) : void
      {
         if(Boolean(this.mcMutagenColorAnim && this.mcMutagenColorAnim.visible) && Boolean(_data) && Boolean(_data.researchCompleted))
         {
            this.mcMutagenColorAnim.rotation += 0.5;
         }
      }
      
      protected function updateMutationData() : *
      {
         var colorId:String = null;
         var dataIsEquipped:Boolean = false;
         var HIDE_ICON:* = true;
         if(_data)
         {
            trace("GFX MutationItemRenderer :: updateData",_data.mutationId,_data.overallProgress);
            if(this.mcProgressbar)
            {
               this.mcProgressbar.maximum = this.MAX_PROGRESS;
               this.mcProgressbar.value = _data.overallProgress;
               this.mcProgressbar.visible = false;
            }
            colorId = getColorById(_data.mutationId);
            if(colorId != "")
            {
               if(this.mcMutagenColor)
               {
                  this.mcMutagenColor.gotoAndStop(colorId);
                  this.mcIconBackground.gotoAndStop(colorId);
                  if(_imageLoader)
                  {
                     _imageLoader.alpha = 1;
                  }
                  if(this.mcMutagenColorAnim)
                  {
                     this.mcMutagenColorAnim.gotoAndStop(colorId);
                  }
               }
               if(Boolean(this.mcEquippedIndicator) && Boolean(this.mcEquippedIndicator["mcEquippedIndicator"]))
               {
                  this.mcEquippedIndicator["mcEquippedIndicator"].gotoAndStop(colorId);
               }
            }
            if(this.tfMutationName)
            {
               if(_data.name)
               {
                  this.tfMutationName.text = _data.name;
               }
               else
               {
                  this.tfMutationName.text = "";
               }
            }
            if(Boolean(this.mcMutagenColor) && !_data.enabled)
            {
               this.mcMutagenColor.gotoAndStop("gray");
               this.mcIconBackground.gotoAndStop("gray");
               if(this.mcMutagenColorAnim)
               {
                  this.mcMutagenColorAnim.gotoAndStop("gray");
               }
            }
            dataIsEquipped = Boolean(_data.isEquipped);
            if(Boolean(this.mcEquippedIndicator) && this.mcEquippedIndicator.visible != dataIsEquipped)
            {
               GTweener.removeTweens(this.mcEquippedIndicator);
               if(dataIsEquipped)
               {
                  this.mcEquippedIndicator.visible = true;
                  this.mcEquippedBkg.visible = true;
                  this.mcMutagenColor.scaleX = 1.15;
                  this.mcMutagenColor.scaleY = 1.15;
                  if(TRIGGER_EQUIP_FX)
                  {
                     TRIGGER_EQUIP_FX = false;
                     this.mcEquippedIndicator.alpha = 0;
                     this.mcEquippedIndicator.scaleX = this.mcEquippedIndicator.scaleY = 0.1;
                     GTweener.to(this.mcEquippedIndicator,1,{
                        "alpha":1,
                        "scaleX":1,
                        "scaleY":1
                     },{"ease":Exponential.easeOut});
                     this.mcFlashAnimation.gotoAndPlay("animation");
                  }
                  else
                  {
                     this.mcEquippedIndicator.alpha = 1;
                     this.mcEquippedIndicator.scaleX = this.mcEquippedIndicator.scaleY = 1;
                  }
               }
               else if(TRIGGER_UNEQUIP_FX)
               {
                  TRIGGER_UNEQUIP_FX = false;
                  GTweener.to(this.mcEquippedIndicator);
                  GTweener.to(this.mcEquippedIndicator,0.3,{
                     "alpha":0,
                     "scaleX":0.1,
                     "scaleY":0.1
                  },{
                     "onComplete":this.handleUnequippedAnimation,
                     "ease":Exponential.easeIn
                  });
               }
               else
               {
                  this.handleUnequippedAnimation();
               }
            }
            if(!(Boolean(!HIDE_ICON) && Boolean(_data.iconPath) && _data.iconPath != "None"))
            {
               if(mcHitArea)
               {
                  addChild(mcHitArea);
               }
            }
            this._firstDataUpdate = false;
            this.spectreTintMain(Boolean(_data.isEquipped) && Boolean(_data.spectreShown));
            if(this.mcFakeProgressbar)
            {
               this.mcFakeProgressbar.visible = false;
            }
            if(this.mcMutagenColorAnim)
            {
               this.mcMutagenColorAnim.visible = _data.researchCompleted;
            }
            if(this.mcMutagenColor)
            {
               this.mcMutagenColor.alpha = _data.researchCompleted ? 1 : Number(this.DISABLED_ALPHA_COLOR);
            }
            if(_imageLoader)
            {
               _imageLoader.alpha = Boolean(_data.researchCompleted) && enabled ? 1 : Number(this.DISABLED_ALPHA_ICON);
            }
            if(Boolean(enabled) && Boolean(_data) && Boolean(_data.researchCompleted) && _data.mutationId == TRIGGER_RESEARCHED_ID_FX)
            {
               if(this.mcResearchCompleteAnim)
               {
                  this.mcResearchCompleteAnim.gotoAndPlay("start");
                  TRIGGER_RESEARCHED_ID_FX = -1;
               }
            }
            this.updateConnectors();
         }
      }
      
      protected function updateConnectors() : void
      {
         var baseColor:String = null;
         var curConnector:MutationConnector = null;
         if(Boolean(_data && _data.enabled) && Boolean(!this._blocked) && Boolean(_data.researchCompleted))
         {
            baseColor = getColorById(_data.mutationId);
         }
         else
         {
            baseColor = "gray";
         }
         var len:int = int(this._connectorsList.length);
         for(var i:int = 0; i < len; i++)
         {
            curConnector = this._connectorsList[i];
            curConnector.alpha = this._blocked ? 0.1 : 1;
            curConnector.color = baseColor;
         }
      }
      
      private function handleUnequippedAnimation(tw:GTween = null) : void
      {
         this.mcEquippedIndicator.visible = false;
         this.mcMutagenColor.scaleX = 1;
         this.mcMutagenColor.scaleY = 1;
         this.mcEquippedBkg.visible = false;
      }
      
      override public function set selected(value:Boolean) : void
      {
         super.selected = value;
         if(this.tfMutationName)
         {
            this.tfMutationName.visible = _selected;
         }
      }
      
      override protected function handleIconLoaded(event:Event) : void
      {
         super.handleIconLoaded(event);
         if(_imageLoader)
         {
            _imageLoader.x = this.mcIconBackground.x - _imageLoader.width / 2;
            _imageLoader.y = this.mcIconBackground.y - _imageLoader.height / 2;
            _imageLoader.alpha = Boolean(_data.researchCompleted) && enabled ? 1 : Number(this.DISABLED_ALPHA_ICON);
         }
         addChild(this.mcProgressbar);
         addChild(this.mcIconBackground);
         addChild(_imageLoader);
         addChild(this.mcProgressbar);
         addChild(this.mcFakeProgressbar);
         addChild(mcHitArea);
      }
      
      override protected function updateImageLoaderStates() : void
      {
      }
      
      override protected function loadIcon(iconPath:String) : void
      {
         super.loadIcon(iconPath);
      }
      
      override protected function canExecuteAction() : Boolean
      {
         return false;
      }
      
      override protected function handleMouseDoubleClick(event:MouseEvent) : void
      {
         var superMouseEvent:MouseEventEx = event as MouseEventEx;
         if(Boolean(_data) && Boolean(superMouseEvent) && superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
         {
            fireActionEvent(_data.actionType);
         }
      }
      
      public function get mutationId() : int
      {
         return this._mutationId;
      }
      
      public function set mutationId(value:int) : void
      {
         this._mutationId = value;
      }
      
      public function get slotNavigationId() : int
      {
         return this._slotNavigationId;
      }
      
      public function set slotNavigationId(value:int) : void
      {
         this._slotNavigationId = value;
      }
      
      public function get blocked() : Boolean
      {
         return this._blocked;
      }
      
      public function set blocked(value:Boolean) : void
      {
         this._blocked = value;
         this.updateConnectors();
      }
   }
}


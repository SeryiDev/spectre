package red.game.witcher3.menus.character_menu
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import red.game.witcher3.constants.CommonConstants;
   import red.game.witcher3.controls.InputFeedbackButton;
   
   public class MasterMutationItemRenderer extends MutationItemRenderer
   {
      
      private const MUTATION_STATE_FRAME_OFFSET:int = 5;
      
      private const TEXT_PADDING:* = 15;
      
      private const DESC_FIXER_BACKPUSH:* = 16;
      
      public var tfState:TextField;
      
      public var tfAdditionalState:TextField;
      
      public var tfMutationDescription:TextField;
      
      public var btnMutationMode:InputFeedbackButton;
      
      public var mcStateBackground:MovieClip;
      
      public var mcLevelBackground:MovieClip;
      
      public var mcIconLock:MovieClip;
      
      public var mcMutationBackground:MovieClip;
      
      public var mcMutationAnimation:MovieClip;
      
      private var _mcColorOverlay:MovieClip;
      
      private var _mcColorBackground:MovieClip;
      
      private var _equippedMutationData:Object;
      
      private var _color:String;
      
      private var _standalone:Boolean;
      
      public function MasterMutationItemRenderer()
      {
         super();
         this._mcColorOverlay = this.mcMutationAnimation.mcAnimation.mcColor;
         this._mcColorBackground = this.mcMutationAnimation.mcAnimation.background;
         mouseChildren = false;
      }
      
      public function setColorByMutationId(id:int) : void
      {
         var colorMut:String = getColorById(id);
         this._color = colorMut;
         this._mcColorOverlay.gotoAndStop(colorMut);
         this._mcColorBackground.gotoAndStop(colorMut);
         this.updateConnectors();
      }
      
      public function resetColor() : void
      {
         this._color = "";
         this._mcColorOverlay.gotoAndStop(1);
         this._mcColorBackground.gotoAndStop(1);
         this.updateConnectors();
      }
      
      public function hideDescription(value:Boolean) : void
      {
         this.tfState.visible = !value;
         this.tfMutationDescription.visible = !value;
      }
      
      public function setEquippedMutationData(value:Object) : void
      {
         this._equippedMutationData = value;
         this.updateMutationData();
      }
      
      override protected function updateConnectors() : void
      {
         var baseColor:String = null;
         var curConnector:MutationConnector = null;
         if(Boolean(this._color) && Boolean(this._color != "default") && !_blocked)
         {
            baseColor = this._color;
         }
         else
         {
            baseColor = "gray";
         }
         var len:int = int(_connectorsList.length);
         for(var i:int = 0; i < len; i++)
         {
            curConnector = _connectorsList[i];
            curConnector.alpha = _blocked ? 0.1 : 1;
            curConnector.color = baseColor;
         }
      }
      
      override protected function updateMutationData() : *
      {
         trace("Minimap2 -------------------- updateMutationData ",_data,this._equippedMutationData);
         if(_data)
         {
            if(mcProgressbar)
            {
               mcProgressbar.maximum = MAX_PROGRESS;
               mcProgressbar.value = _data.overallProgress;
            }
            if(Boolean(this.mcMutationAnimation) && Boolean(_data.stage))
            {
               this.mcMutationAnimation.gotoAndPlay("state" + _data.stage);
            }
            if(this.tfState)
            {
               if(this._equippedMutationData)
               {
                  this.tfState.text = this._equippedMutationData.name;
               }
               else
               {
                  this.tfState.text = _data.stageLabel;
               }
            }
            trace("GFX [MasterMutationItemRenderer] [ at menu ? ",this.mcIconLock != null ? "YES" : "NO","! ] ",this.tfAdditionalState,this.mcStateBackground,_data.stageNumbLabel);
            if(this.tfAdditionalState)
            {
               if(_data.stageNumbLabel)
               {
                  this.tfAdditionalState.text = _data.stageNumbLabel;
                  this.tfAdditionalState.visible = true;
                  this.mcIconLock.visible = true;
                  if(this.mcIconLock)
                  {
                     this.mcIconLock.visible = false;
                  }
               }
               else
               {
                  this.tfAdditionalState.visible = false;
                  if(this.mcIconLock)
                  {
                     this.mcIconLock.visible = true;
                  }
               }
            }
            if(Boolean(this.tfMutationDescription) && Boolean(this._equippedMutationData))
            {
               // Spectre: with several mutations active, the main one's description would read as the only one working; the
               // script sends what the main mutation does instead.
               this.tfMutationDescription.htmlText = Boolean(this._equippedMutationData.spectreCenterDescription) ? this._equippedMutationData.spectreCenterDescription : this._equippedMutationData.description;
               this.tfMutationDescription.y = -this.tfMutationDescription.textHeight / 2 - this.DESC_FIXER_BACKPUSH;
               this.tfMutationDescription.height = this.tfMutationDescription.textHeight + CommonConstants.SAFE_TEXT_PADDING;
            }
         }
      }
      
      override protected function loadIcon(iconPath:String) : void
      {
      }
      
      public function get standalone() : Boolean
      {
         return this._standalone;
      }
      
      public function set standalone(value:Boolean) : void
      {
         this._standalone = value;
      }
   }
}


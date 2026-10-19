package red.game.witcher3.menus.character_menu
{
   import com.gskinner.motion.GTweener;
   import com.gskinner.motion.easing.Exponential;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.GestureEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import red.core.constants.KeyCode;
   import red.core.data.InputAxisData;
   import red.core.events.GameEvent;
   import red.core.events.GestureEventEx;
   import red.game.witcher3.constants.TooltipAlignment;
   import red.game.witcher3.controls.TooltipAnchor;
   import red.game.witcher3.events.ControllerChangeEvent;
   import red.game.witcher3.managers.InputManager;
   import red.game.witcher3.slots.SlotsListBase;
   import scaleform.clik.constants.InputValue;
   import scaleform.clik.core.UIComponent;
   import scaleform.clik.events.InputEvent;
   import scaleform.clik.events.ListEvent;
   import scaleform.clik.ui.InputDetails;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.text.TextFieldAutoSize;
   import flash.display.Shape;
   import flash.geom.Point;
   import red.game.witcher3.utils.CommonUtils;
   import red.game.witcher3.managers.InputFeedbackManager;
   import scaleform.clik.constants.NavigationCode;
   
   public class MutationsPanel extends UIComponent
   {
      
      protected const RESEARCH_BUTTON_PADDING:Number = 20;
      
      public var mcMutationList:MutationItemsList;
      
      public var mcMutation1:MutationItemRenderer;
      
      public var mcMutation2:MutationItemRenderer;
      
      public var mcMutation3:MutationItemRenderer;
      
      public var mcMutation4:MutationItemRenderer;
      
      public var mcMutation5:MutationItemRenderer;
      
      public var mcMutation6:MutationItemRenderer;
      
      public var mcMutation7:MutationItemRenderer;
      
      public var mcMutation8:MutationItemRenderer;
      
      public var mcMutation9:MutationItemRenderer;
      
      public var mcMutation10:MutationItemRenderer;
      
      public var mcMutation11:MutationItemRenderer;
      
      public var mcMutation12:MutationItemRenderer;
      
      public var mcMutation13:MutationItemRenderer;
      
      public var mcMutConnector3_8:MutationConnector;
      
      public var mcMutConnector8_7:MutationConnector;
      
      public var mcMutConnector8_9:MutationConnector;
      
      public var mcMutConnector9_12:MutationConnector;
      
      public var mcMutConnector7_11:MutationConnector;
      
      public var mcMutConnector6_7:MutationConnector;
      
      public var mcMutConnector10_9:MutationConnector;
      
      public var mcMutConnector4_10:MutationConnector;
      
      public var mcMutConnector2_6:MutationConnector;
      
      public var mcMutConnector6_1:MutationConnector;
      
      public var mcMutConnector10_5:MutationConnector;
      
      public var mcMasterMutationConnector1:MutationConnector;
      
      public var mcMasterMutationConnector2:MutationConnector;
      
      public var mcMasterMutationConnector3:MutationConnector;
      
      public var mcAnchor1:TooltipAnchor;
      
      public var mcAnchor2:TooltipAnchor;
      
      public var mcAnchor3:TooltipAnchor;
      
      public var mcAnchor4:TooltipAnchor;
      
      public var mcAnchor5:TooltipAnchor;
      
      public var mcAnchor6:TooltipAnchor;
      
      public var mcAnchor7:TooltipAnchor;
      
      public var mcAnchor8:TooltipAnchor;
      
      public var mcAnchor9:TooltipAnchor;
      
      public var mcAnchor10:TooltipAnchor;
      
      public var mcAnchor11:TooltipAnchor;
      
      public var mcAnchor12:TooltipAnchor;
      
      public var mcAnchor13:TooltipAnchor;
      
      public var mcFadeoutSprite:MovieClip;
      
      public var mcMutationBackground:MovieClip;
      
      public var mcMutagenTooltip:MutationTooltip;
      
      public var equippedMutationId:int = -1;
      
      protected var _fadeOutComponents:Vector.<MovieClip>;
      
      protected var _fadeInComponent:Vector.<MovieClip>;
      
      protected var _selectedMutationData:Object;
      
      protected var _selectedMutationRenderer:MutationItemRenderer;
      
      protected var _researchMode:Boolean;
      
      protected var _active:Boolean;
      
      protected var _data:Array;
      
      protected var _linesCanvas:Sprite;
      
      protected var _mutationChanged:Boolean = false;
      
      private var tooltipTimer:Timer;
      
      private var _cachedChangeList:Object;
      
      private var _tapHappened:Boolean = false;
      
      private var _spectreCounter:TextField;
      
      private var _spectreCounterBox:Sprite;
      
      private var _spectreCounterBg:Shape;
      
      private var _spectreCounterRight:Number = 0;
      
      private var _spectreCounterMidY:Number = 0;
      
      private var _spectreMainHint:int = -1;
      
      private var _spectreActionHint:int = -1;
      
      private var _spectreBackgroundMask:Shape;
      
      public function MutationsPanel()
      {
         super();
         visible = false;
         this.mcMutationList.sortData = true;
         this.mcMutationList.focusable = false;
         this.mcMutationList.addEventListener(ListEvent.INDEX_CHANGE,this.handleMutationSelected,false,0,true);
         this.mcMutationList.addEventListener(ListEvent.ITEM_CLICK,this.hanldeMutationClick,false,0,true);
         this.mcMutationList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK,this.hanldeMutationDoubleClick,false,0,true);
         this.mcMutationList.addEventListener(ListEvent.ITEM_ROLL_OVER,this.hanldeMutationOver,false,0,true);
         this.mcMutationList.addEventListener(ListEvent.ITEM_ROLL_OUT,this.hanldeMutationOut,false,0,true);
         this.mcMutationList.addEventListener(SlotsListBase.EVENT_SELECTED_TAPPED,this.handleSelectedMutationTapped,false,0,true);
         InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE,this.handleControllerChanged,false,0,true);
      }
      
      override protected function configUI() : void
      {
         super.configUI();
      }
      
      // Spectre: "Active mutations: 3/3" (and below, "Main: name") with "Several mutations at once", left of the mutation tree, in a box like
      // the map's place names (dark fill, thin sand frame with corner marks, cream capitals). Empty hides it.
      public function setSpectreCounter(value:String) : void
      {
         var format:TextFormat = null;
         var renderers:Array = null;
         var minX:Number = NaN;
         var i:int = 0;
         var w:Number = NaN;
         var h:Number = NaN;
         var g:* = null;
         if(!this._spectreCounterBox)
         {
            this._spectreCounterBox = new Sprite();
            this._spectreCounterBox.mouseEnabled = false;
            this._spectreCounterBox.mouseChildren = false;
            this._spectreCounterBg = new Shape();
            this._spectreCounterBox.addChild(this._spectreCounterBg);
            this._spectreCounter = CommonUtils.spawnTextField(28,15263168);
            format = this._spectreCounter.defaultTextFormat;
            format.align = TextFormatAlign.LEFT;
            this._spectreCounter.defaultTextFormat = format;
            this._spectreCounter.multiline = true;
            this._spectreCounter.wordWrap = false;
            this._spectreCounter.autoSize = TextFieldAutoSize.LEFT;
            this._spectreCounter.selectable = false;
            this._spectreCounter.mouseEnabled = false;
            this._spectreCounterBox.addChild(this._spectreCounter);
            renderers = [this.mcMutation1,this.mcMutation2,this.mcMutation3,this.mcMutation4,this.mcMutation5,this.mcMutation6,this.mcMutation7,this.mcMutation8,this.mcMutation9,this.mcMutation10,this.mcMutation11,this.mcMutation12];
            for(i = 0; i < renderers.length; i++)
            {
               if(Boolean(renderers[i]) && (isNaN(minX) || renderers[i].x < minX))
               {
                  minX = renderers[i].x;
               }
            }
            this._spectreCounterRight = (isNaN(minX) ? 0 : minX) - 40;
            this._spectreCounterMidY = (Boolean(this.mcMutation13) ? this.mcMutation13.y : 0) + 230;
            addChild(this._spectreCounterBox);
         }
         this._spectreCounterBox.visible = Boolean(value) && value != "";
         if(!this._spectreCounterBox.visible)
         {
            return;
         }
         this._spectreCounter.text = value.toUpperCase().split("|").join("\n");
         this._spectreCounter.x = 18;
         this._spectreCounter.y = 8;
         w = this._spectreCounter.width + 36;
         h = this._spectreCounter.height + 16;
         g = this._spectreCounterBg.graphics;
         g.clear();
         g.beginFill(1380621,0.92);
         g.drawRect(0,0,w,h);
         g.endFill();
         g.lineStyle(1,9142372,1);
         g.drawRect(3,3,w - 6,h - 6);
         g.lineStyle(2,9142372,1);
         this.spectreCorner(g,1,1,1,1);
         this.spectreCorner(g,w - 1,1,-1,1);
         this.spectreCorner(g,1,h - 1,1,-1);
         this.spectreCorner(g,w - 1,h - 1,-1,-1);
         this._spectreCounterBox.x = this._spectreCounterRight - w;
         this._spectreCounterBox.y = this._spectreCounterMidY - h / 2;
      }
      
      private function spectreCorner(g:*, x:Number, y:Number, dx:Number, dy:Number) : void
      {
         g.moveTo(x,y + 8 * dy);
         g.lineTo(x,y);
         g.lineTo(x + 8 * dx,y);
      }
      
      // Spectre: R / gamepad X makes the selected active mutation the main one (the script marks the ones that can be
      // spectreCanBeMain, with "Several mutations at once"). It asks the script to equip it, which moves it to the end.
      private function spectreSetMain() : void
      {
         var renderer:MutationItemRenderer = this.mcMutationList.getSelectedRenderer() as MutationItemRenderer;
         if(Boolean(renderer) && Boolean(renderer.data) && Boolean(renderer.data.spectreCanBeMain))
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnEquipMutation",[renderer.data.mutationId]));
         }
      }
      
      // The hints of a researched mutation, in this order: E "Activate/Deactivate mutation" (the panel's own action,
      // which the base game only shows in the tooltip) and, when it can be made the main one, R "Use as main".
      private function spectreUpdateMainHint() : void
      {
         var renderer:MutationItemRenderer = this.mcMutationList.getSelectedRenderer() as MutationItemRenderer;
         var data:Object = Boolean(renderer) ? renderer.data : null;
         var researched:Boolean = this._active && Boolean(data) && Boolean(data.enabled) && Boolean(data.researchCompleted) && !data.isMasterMutation;
         if(this._spectreActionHint != -1)
         {
            InputFeedbackManager.removeButton(this,this._spectreActionHint);
            this._spectreActionHint = -1;
         }
         if(this._spectreMainHint != -1)
         {
            InputFeedbackManager.removeButton(this,this._spectreMainHint);
            this._spectreMainHint = -1;
         }
         if(researched)
         {
            this._spectreActionHint = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_A,KeyCode.E,Boolean(data.isEquipped) ? "mutation_input_deactivate_mutation" : "mutation_input_activate_mutation");
            if(Boolean(data.spectreCanBeMain))
            {
               this._spectreMainHint = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_X,KeyCode.R,"spectre_use_as_main_mutation");
            }
         }
         InputFeedbackManager.updateButtons(this);
      }
      
      // Spectre: the mutation background (cells, dark clouds in the corners) covered the bottom bar of button hints,
      // which the base game's few hints did not reach. It is cut above that bar; the top stays as it was.
      private function spectreClipBackground() : void
      {
         var topLeft:Point = null;
         var bottomRight:Point = null;
         if(!this.mcMutationBackground || !stage || this._spectreBackgroundMask)
         {
            return;
         }
         topLeft = this.mcMutationBackground.parent.globalToLocal(new Point(0,-stage.stageHeight));
         bottomRight = this.mcMutationBackground.parent.globalToLocal(new Point(stage.stageWidth,stage.stageHeight * 0.93));
         this._spectreBackgroundMask = new Shape();
         this._spectreBackgroundMask.graphics.beginFill(0,1);
         this._spectreBackgroundMask.graphics.drawRect(topLeft.x,topLeft.y,bottomRight.x - topLeft.x,bottomRight.y - topLeft.y);
         this._spectreBackgroundMask.graphics.endFill();
         // Under the background, not on top: on top, the mask took every mouse event, so hovering and clicking a
         // mutation did nothing. A mask works at any depth.
         this.mcMutationBackground.parent.addChildAt(this._spectreBackgroundMask,this.mcMutationBackground.parent.getChildIndex(this.mcMutationBackground));
         this.mcMutationBackground.mask = this._spectreBackgroundMask;
      }
      
      private function handleTapBubble(event:GestureEvent) : void
      {
         trace("MutationsPanel::handleTapBubble");
         this._tapHappened = false;
      }
      
      private function handleTapCapture(event:GestureEvent) : void
      {
         trace("MutationsPanel::handleTapCapture");
         this._tapHappened = true;
         if(this.mcMutagenTooltip.mcButtonPanel.btnAction.hitTestPoint(event.stageX,event.stageY))
         {
            trace("MutationsPanel::handleTap - BUTTON HIT");
            event.stopImmediatePropagation();
            event.preventDefault();
            this.mutationAction();
            this._tapHappened = false;
         }
      }
      
      private function handleControllerChanged(e:Event) : void
      {
         if(this._selectedMutationRenderer)
         {
            this.alignControls();
         }
      }
      
      private function handleSelectedMutationTapped(event:Event) : *
      {
         this.mutationAction();
      }
      
      private function hanldeMutationClick(event:ListEvent) : void
      {
      }
      
      private function hanldeMutationDoubleClick(event:ListEvent) : void
      {
         this.mutationAction();
      }
      
      private function cleanupTooltipTimer() : void
      {
         if(this.tooltipTimer)
         {
            this.tooltipTimer.stop();
            this.tooltipTimer.removeEventListener(TimerEvent.TIMER,this.handleTooltipTimer,false);
            this.tooltipTimer = null;
         }
      }
      
      private function initTooltipTimer() : void
      {
         this.tooltipTimer = new Timer(500);
         this.tooltipTimer.addEventListener(TimerEvent.TIMER,this.handleTooltipTimer,false,0,true);
         this.tooltipTimer.start();
      }
      
      private function hanldeMutationOver(event:ListEvent) : void
      {
         var targetRenderer:MutationItemRenderer = null;
         trace("MutationsPanel::hanldeMutationOver");
         targetRenderer = event.itemRenderer as MutationItemRenderer;
         this.mcMutationList.selectedIndex = targetRenderer.index;
         this.mcMutationList.validateNow();
         if(Boolean(targetRenderer) && !targetRenderer.blocked)
         {
            this.cleanupTooltipTimer();
            GTweener.removeTweens(this.mcMutagenTooltip);
            this.mcMutagenTooltip.alpha = 0;
            this.mcMutagenTooltip.visible = true;
            this.mcMutagenTooltip.data = targetRenderer.data;
            this.mcMutagenTooltip.validateNow();
            this.alignTooltip(targetRenderer);
            GTweener.to(this.mcMutagenTooltip,1,{"alpha":1},{"ease":Exponential.easeOut});
         }
      }
      
      private function hanldeMutationOut(event:ListEvent) : void
      {
         trace("MutationsPanel::hanldeMutationOut");
         this.cleanupTooltipTimer();
         this.mcMutagenTooltip.visible = false;
         this.mcMutagenTooltip.alpha = 0;
         GTweener.removeTweens(this.mcMutagenTooltip);
      }
      
      private function handleMutationSelected(e:ListEvent) : void
      {
         var selectedItem:MutationItemRenderer = this.mcMutationList.getSelectedRenderer() as MutationItemRenderer;
         trace("MutationsPanel::handleMutationSelected : ",selectedItem);
         this.selectMutation(selectedItem);
         this.spectreUpdateMainHint();
      }
      
      private function selectMutation(selectedItem:MutationItemRenderer, forced:Boolean = false) : void
      {
         var isMouse:Boolean = InputManager.getInstance().isMouse();
         if(this._tapHappened)
         {
            isMouse = false;
         }
         if(this._selectedMutationRenderer == selectedItem && !forced)
         {
            return;
         }
         if(!isMouse)
         {
            this.cleanupTooltipTimer();
            this.mcMutagenTooltip.alpha = 0;
            GTweener.removeTweens(this.mcMutagenTooltip);
         }
         if(Boolean(selectedItem) && Boolean(selectedItem.data))
         {
            this._selectedMutationRenderer = selectedItem;
            this._selectedMutationData = selectedItem.data;
            if(!isMouse)
            {
               this.mcMutagenTooltip.data = this._selectedMutationData;
               this.mcMutagenTooltip.validateNow();
               this.initTooltipTimer();
            }
            else if(this.mcMutagenTooltip.data != selectedItem.data)
            {
               this.mcMutagenTooltip.visible = false;
            }
         }
         else if(!isMouse)
         {
            this.mcMutagenTooltip.visible = false;
         }
         if(this._selectedMutationData)
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnMutationSelected",[int(this._selectedMutationData.mutationId)]));
         }
         if(!isMouse)
         {
            this.alignControls();
         }
      }
      
      private function alignControls() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.validateAlignControls);
         addEventListener(Event.ENTER_FRAME,this.validateAlignControls,false,0,true);
      }
      
      private function validateAlignControls(e:Event = null) : void
      {
         trace("GFX MutationPanel::validateAlignControls ");
         removeEventListener(Event.ENTER_FRAME,this.validateAlignControls);
         if(this._selectedMutationRenderer)
         {
            this.alignTooltip(this._selectedMutationRenderer);
         }
      }
      
      private function alignTooltip(attachedRenderer:MutationItemRenderer, moveWithTween:Boolean = false) : void
      {
         var targetX:Number = NaN;
         var targetY:Number = NaN;
         var curAlignment:String = null;
         var ttHeight:Number = NaN;
         var ttWidth:Number = NaN;
         var TO_PADDING_X:* = 0;
         var TO_PADDING_Y:* = 0;
         var curAnchor:TooltipAnchor = attachedRenderer.getTooltipAnchorComponent();
         trace("GFX MutationPanel::alignTooltip ");
         trace("GFX curAnchor  ",curAnchor);
         if(curAnchor)
         {
            curAlignment = curAnchor.alignment;
            ttHeight = this.mcMutagenTooltip.currentHeight;
            ttWidth = this.mcMutagenTooltip.mcBackground.width;
            this.mcMutagenTooltip.anchor = curAnchor;
            switch(curAlignment)
            {
               case TooltipAlignment.BOTTOM_LEFT:
                  targetY = curAnchor.y;
                  targetX = curAnchor.x - ttWidth;
                  break;
               case TooltipAlignment.BOTTOM_RIGHT:
                  targetY = curAnchor.y;
                  targetX = curAnchor.x;
                  break;
               case TooltipAlignment.TOP_LEFT:
                  targetY = curAnchor.y - ttHeight;
                  targetX = curAnchor.x - ttWidth;
                  break;
               case TooltipAlignment.TOP_RIGHT:
                  targetY = curAnchor.y - ttHeight;
                  targetX = curAnchor.x;
            }
         }
         if(moveWithTween)
         {
            GTweener.removeTweens(this.mcMutagenTooltip);
            GTweener.to(this.mcMutagenTooltip,0.5,{
               "x":targetX,
               "y":targetY,
               "alpha":1
            },{"ease":Exponential.easeOut});
         }
         else
         {
            this.mcMutagenTooltip.x = targetX;
            this.mcMutagenTooltip.y = targetY;
         }
      }
      
      private function handleTooltipTimer(event:TimerEvent) : void
      {
         this.cleanupTooltipTimer();
         trace("GFX MutationPanel::handleTooltipTimer ");
         GTweener.removeTweens(this.mcMutagenTooltip);
         this.mcMutagenTooltip.alpha = 0;
         if(this._selectedMutationRenderer)
         {
            this.alignControls();
         }
         if(!GTweener.getTweens(this.mcMutagenTooltip).length)
         {
            GTweener.to(this.mcMutagenTooltip,1,{"alpha":1},{"ease":Exponential.easeOut});
         }
      }
      
      public function get active() : Boolean
      {
         return this._active;
      }
      
      public function set active(value:Boolean) : void
      {
         trace("MutationsPanel::active ",this._active,value);
         if(this._active != value)
         {
            this._active = value;
            enabled = this._active;
            stage.removeEventListener(InputEvent.INPUT,this.handleInput,false);
            stage.removeEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP,this.handleGestureTwoFingerTap,false);
            removeEventListener(GestureEventEx.GESTURE_TAP,this.handleTapCapture,true);
            removeEventListener(GestureEventEx.GESTURE_TAP,this.handleTapBubble,false);
            this.mcMutationList.enableTouch(false);
            if(this._active)
            {
               stage.addEventListener(InputEvent.INPUT,this.handleInput,false,1000,true);
               stage.addEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP,this.handleGestureTwoFingerTap,false,1000,true);
               addEventListener(GestureEventEx.GESTURE_TAP,this.handleTapCapture,true,1000,true);
               addEventListener(GestureEventEx.GESTURE_TAP,this.handleTapBubble,false,1000,true);
               this.mcMutationList.enableTouch(true);
               dispatchEvent(new Event(Event.ACTIVATE));
               this.mcMutationList.enabled = true;
               this.initPopulateData(true);
               this._mutationChanged = false;
               this.spectreClipBackground();
            }
            else
            {
               this.mcMutationList.selectedIndex = -1;
               this.mcMutationList.enabled = false;
               this.mcMutationList.focused = 0;
               dispatchEvent(new Event(Event.DEACTIVATE));
               if(this._mutationChanged)
               {
                  dispatchEvent(new GameEvent(GameEvent.CALL,"OnUpdateMutationData",[]));
                  this._mutationChanged = false;
               }
               this.spectreUpdateMainHint();
            }
         }
      }
      
      public function get data() : Array
      {
         return this._data;
      }
      
      public function set data(value:Array) : void
      {
         trace("GFX *data ",value);
         this._data = value;
         if(this._active)
         {
            this.initPopulateData();
         }
      }
      
      public function setSingleMutationData(value:Object) : void
      {
         var count:int = 0;
         var i:int = 0;
         var itemData:Object = null;
         trace("MutationsPanel::setSingleMutationData");
         if(this._data)
         {
            count = int(this._data.length);
            for(i = 0; i < count; i++)
            {
               itemData = this._data[i];
               if(itemData.mutationId == value.mutationId)
               {
                  this._data[i] = value;
                  this.mcMutationList.data[i] = value;
                  this.mcMutationList.updateSingleMutation(value);
                  this.mcMutationList.validateNow();
                  return;
               }
            }
         }
      }
      
      public function setDataList(value:Array) : void
      {
         this.data = value;
      }
      
      private function initPopulateData(resetSelection:Boolean = false) : void
      {
         var cachedSelectedIdx:int = this.mcMutationList.selectedIndex;
         trace("GFX [MutationPanel] initPopulateData ",resetSelection);
         this.mcMutationList.focused = 1;
         this.mcMutationList.selectedIndex = -1;
         this.mcMutationList.data = this.data as Array;
         this.mcMutationList.validateNow();
         if(!resetSelection)
         {
            this.mcMutationList.selectedIndex = cachedSelectedIdx;
            this.selectMutation(this.mcMutationList.getSelectedRenderer() as MutationItemRenderer,true);
         }
         else
         {
            this.mcMutationList.selectedIndex = 12;
         }
         this.spectreUpdateMainHint();
      }
      
      override public function handleInput(event:InputEvent) : void
      {
         var axisData:InputAxisData = null;
         var details:InputDetails = event.details;
         var isKeyUp:Boolean = details.value == InputValue.KEY_UP;
         var isKeyDown:Boolean = details.value == InputValue.KEY_DOWN;
         var inputCaptured:Boolean = false;
         super.handleInput(event);
         if(this._active && isKeyUp)
         {
            switch(details.code)
            {
               case KeyCode.R:
               case KeyCode.PAD_X_SQUARE:
                  this.spectreSetMain();
                  inputCaptured = true;
                  break;
               case KeyCode.E:
               case KeyCode.SPACE:
               case KeyCode.ENTER:
               case KeyCode.PAD_A_CROSS:
                  this.mutationAction();
                  inputCaptured = true;
                  break;
               case KeyCode.C:
               case KeyCode.ESCAPE:
               case KeyCode.PAD_B_CIRCLE:
               case KeyCode.PAD_Y_TRIANGLE:
                  inputCaptured = true;
                  this.active = false;
            }
         }
         if(this._active && !inputCaptured)
         {
            this.mcMutationList.handleInputPreset(event);
            inputCaptured = true;
         }
         if(inputCaptured)
         {
            event.handled = true;
            event.stopImmediatePropagation();
         }
      }
      
      private function handleGestureTwoFingerTap(event:GestureEvent) : void
      {
         event.stopImmediatePropagation();
         event.preventDefault();
         this.active = false;
      }
      
      private function mutationAction() : void
      {
         var params:Array = null;
         this._selectedMutationRenderer = this.mcMutationList.getSelectedRenderer() as MutationItemRenderer;
         if(this._selectedMutationRenderer)
         {
            this._selectedMutationData = this._selectedMutationRenderer.data;
         }
         if(Boolean(this._selectedMutationData) && Boolean(this._selectedMutationData.enabled))
         {
            if(!this._selectedMutationData.researchCompleted)
            {
               if(this._selectedMutationData.canResearch)
               {
                  params = [this._selectedMutationData.mutationId,this._selectedMutationData.skillpointsRequired,this._selectedMutationData.redRequired,this._selectedMutationData.greenRequired,this._selectedMutationData.blueRequired];
                  MutationItemRenderer.TRIGGER_RESEARCHED_ID_FX = this._selectedMutationData.mutationId;
                  dispatchEvent(new GameEvent(GameEvent.CALL,"OnResearchMutation",params));
               }
               else
               {
                  dispatchEvent(new GameEvent(GameEvent.CALL,"OnCantResearchMutation",[]));
                  this.mcMutagenTooltip.mcRequaredResources.playFeedbackAnim();
               }
            }
            else if(this._selectedMutationData.isEquipped)
            {
               MutationItemRenderer.TRIGGER_UNEQUIP_FX = true;
               dispatchEvent(new GameEvent(GameEvent.CALL,"OnUnequipMutation",[]));
            }
            else
            {
               MutationItemRenderer.TRIGGER_EQUIP_FX = true;
               if(this.equippedMutationId != -1 && this.equippedMutationId != this._selectedMutationData.mutationId)
               {
                  MutationItemRenderer.TRIGGER_UNEQUIP_FX = true;
               }
               dispatchEvent(new GameEvent(GameEvent.CALL,"OnEquipMutation",[this._selectedMutationData.mutationId]));
            }
         }
      }
   }
}


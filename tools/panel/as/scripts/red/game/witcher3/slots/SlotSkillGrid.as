package red.game.witcher3.slots
{
   import com.gskinner.motion.GTweener;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import red.core.constants.KeyCode;
   import red.game.witcher3.LinearEase;
   import red.game.witcher3.constants.InventoryActionType;
   import red.game.witcher3.events.GridEvent;
   import red.game.witcher3.events.SlotActionEvent;
   import red.game.witcher3.interfaces.IDragTarget;
   import red.game.witcher3.interfaces.IInventorySlot;
   import red.game.witcher3.managers.InputManager;
   import scaleform.clik.constants.InputValue;
   import scaleform.clik.events.InputEvent;
   import scaleform.gfx.MouseEventEx;
   
   public class SlotSkillGrid extends SlotPaperdoll implements IInventorySlot
   {
      
      private static const HOLD_TIME:Number = 1;
      
      public var colorBorder:MovieClip;
      
      public var unlockAnim:MovieClip;
      
      public var mcCollapsedTooltipIcon:MovieClip;
      
      public var coreFrame:MovieClip;
      
      public var mcSkillPoints:red.game.witcher3.slots.SlotPointIndicator;
      
      public var mcHoldAnimBlock:MovieClip;
      
      private var _isFirstDataUpdate:Boolean;
      
      private var _isUnlockedAnimPlayed:Boolean;
      
      private var _mouseRMBdownStatus:Boolean = false;
      
      public var spectreMaxPurchase:Boolean = false;
      
      public var spectreResetRanks:Boolean = false;

      private static const SPECTRE_REPEAT_FACTOR:Number = 0.6;

      private static const SPECTRE_REPEAT_MIN_TIME:Number = 0.2;

      private var _spectreBuyHeld:Boolean = false;

      private var _spectreBuyTime:Number = 1;

      private var _spectreWaitData:Boolean = false;

      private var _spectreRepeatPending:Boolean = false;

      public function SlotSkillGrid()
      {
         super();
         _isLocked = false;
         if(iconLock)
         {
            iconLock.visible = false;
            iconLock.mouseEnabled = false;
            iconLock.mouseChildren = false;
         }
         if(equipedIcon)
         {
            equipedIcon.mouseEnabled = false;
            equipedIcon.mouseChildren = false;
         }
         if(this.mcSkillPoints)
         {
            this.mcSkillPoints.mouseEnabled = false;
         }
         if(this.colorBorder)
         {
            this.colorBorder.mouseEnabled = false;
            this.colorBorder.mouseChildren = false;
         }
         if(this.mcHoldAnimBlock)
         {
            this.mcHoldAnimBlock.visible = false;
         }
         dropEnabled = false;
         this._isFirstDataUpdate = true;
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         var hitArea:MovieClip = getHitArea() as MovieClip;
         if(hitArea)
         {
            hitArea.addEventListener(MouseEvent.MOUSE_DOWN,this.handleMouseDownGrid,false,0,true);
            hitArea.addEventListener(MouseEvent.MOUSE_UP,this.handleMouseUp,false,0,true);
            hitArea.addEventListener(MouseEvent.MOUSE_OUT,this.handleMouseOutGrid,false,0,true);
         }
      }
      
      override protected function initCollapsedIconBehavior() : void
      {
         AUTO_SHOW_COLLAPSED_ICON = true;
         _mcCollapsedTooltipIcon = this.mcCollapsedTooltipIcon;
         if(_mcCollapsedTooltipIcon)
         {
            _mcCollapsedTooltipIcon.visible = false;
         }
         super.initCollapsedIconBehavior();
      }
      
      override public function get isLocked() : Boolean
      {
         return _isLocked;
      }
      
      override protected function updateData() : *
      {
         super.updateData();
         if(!_data)
         {
            return;
         }
         if(_data.skillPath != "ESP_NotSet")
         {
            if(_data.color && this.colorBorder && _data.level > 0 && !_data.isCoreSkill)
            {
               this.colorBorder.gotoAndStop(_data.color);
            }
            else if(this.colorBorder)
            {
               this.colorBorder.gotoAndStop("SC_Grey");
               if(Boolean(_data.isUsingSkillDependency) && !_data.hasRequiredSkillDependency)
               {
                  this.colorBorder.gotoAndStop("SC_Grey_Transparent");
               }
            }
         }
         else if(this.colorBorder)
         {
            this.colorBorder.gotoAndStop("SC_None");
         }
         if(_data.level && _data.level > 0 && _data.maxLevel && _data.maxLevel > 0 && !_data.isCoreSkill)
         {
            this.mcSkillPoints.setCount(_data.level,_data.maxLevel);
            this.mcSkillPoints.setColor(_data.color);
            this.mcSkillPoints.visible = true;
         }
         else
         {
            this.mcSkillPoints.visible = false;
         }
         this.applyAvailability();
         if(mcColorBackground)
         {
            mcColorBackground.visible = false;
         }
         if(this._spectreWaitData)
         {
            this._spectreWaitData = false;
            this.spectreScheduleRepeat();
         }
      }

      // Spectre: while E / gamepad X stays held, the next rank starts once the new data arrives, each one faster.
      // It stops at the maximum rank, without points or links, or when the key is released.
      // The menu refresh after a purchase takes the selection off this cell and gives it back, which stops the
      // fill animation, so the next rank starts one frame later, and again if the refresh stopped it.
      protected function spectreScheduleRepeat() : void
      {
         this._spectreRepeatPending = true;
         addEventListener(Event.ENTER_FRAME,this.spectreOnRepeatFrame,false,0,true);
      }

      protected function spectreOnRepeatFrame(event:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.spectreOnRepeatFrame);
         if(!selected)
         {
            this._spectreBuyHeld = false;
         }
         if(!this._spectreRepeatPending)
         {
            return;
         }
         this._spectreRepeatPending = false;
         if(!this._spectreBuyHeld || !_data || _data.level >= _data.maxLevel || Boolean(_data.notEnoughPoints))
         {
            this._spectreBuyHeld = false;
            return;
         }
         this.startPurchaseAnimation(this._spectreBuyTime);
      }
      
      public function updateIconAlpha() : void
      {
         if(_imageLoader.content)
         {
            if(_data.level < 1 && !_data.hasRequiredPointsSpent)
            {
               _imageLoader.content.alpha = 0.2;
            }
            else if(_data.hasOwnProperty("isUsingSkillDependency") && Boolean(_data.isUsingSkillDependency) && !_data.hasRequiredSkillDependency)
            {
               _imageLoader.content.alpha = 0.2;
            }
            else
            {
               _imageLoader.content.alpha = 1;
            }
         }
      }
      
      override protected function handleIconLoaded(event:Event) : void
      {
         super.handleIconLoaded(event);
         if(this.colorBorder)
         {
            addChild(this.colorBorder);
         }
         if(iconLock)
         {
            addChild(iconLock);
         }
         if(this.mcSkillPoints)
         {
            addChild(this.mcSkillPoints);
         }
         if(this.mcCollapsedTooltipIcon)
         {
            addChild(this.mcCollapsedTooltipIcon);
         }
         if(hitArea)
         {
            addChild(hitArea);
         }
         if(_imageLoader.content)
         {
            if(_data.level < 1 && !_data.hasRequiredPointsSpent)
            {
               _imageLoader.content.alpha = 0.2;
            }
            else if(_data.hasOwnProperty("isUsingSkillDependency") && Boolean(_data.isUsingSkillDependency) && !_data.hasRequiredSkillDependency)
            {
               _imageLoader.content.alpha = 0.2;
            }
            else
            {
               _imageLoader.content.alpha = 1;
            }
         }
      }
      
      protected function handleMouseDownGrid(event:MouseEvent) : void
      {
         var eventEx:MouseEventEx = event as MouseEventEx;
         if(eventEx)
         {
            switch(eventEx.buttonIdx)
            {
               case MouseEventEx.RIGHT_BUTTON:
                  this._mouseRMBdownStatus = true;
                  this.spectreMaxPurchase = false;
                  this.spectreResetRanks = false;
                  this.startPurchaseAnimation(HOLD_TIME);
                  break;
               case MouseEventEx.MIDDLE_BUTTON:
            }
         }
      }
      
      protected function handleMouseUp(event:MouseEvent) : void
      {
         var eventEx:MouseEventEx = event as MouseEventEx;
         if(eventEx)
         {
            switch(eventEx.buttonIdx)
            {
               case MouseEventEx.RIGHT_BUTTON:
                  this._mouseRMBdownStatus = false;
                  this.stopPurchaseAnimation();
                  break;
               case MouseEventEx.MIDDLE_BUTTON:
            }
         }
      }
      
      protected function handleMouseOutGrid(event:MouseEvent) : void
      {
         if(this._mouseRMBdownStatus)
         {
            this.stopPurchaseAnimation();
         }
      }
      
      protected function applyAvailability() : void
      {
         this.filters = [];
         if(equipedIcon)
         {
            equipedIcon.visible = true;
            if(equipedIcon.getChildByName("mcFullColor"))
            {
               equipedIcon.mcFullColor.gotoAndStop(_data.color);
               equipedIcon.mcFullColor.alpha = Boolean(_data.isEquipped) || _data.level > 0 ? 1 : (Boolean(_data.isUsingSkillDependency) && Boolean(_data.hasRequiredSkillDependency) ? 0.5 : 0);
            }
            if(_data.isEquipped)
            {
               equipedIcon.gotoAndStop("equipped");
            }
            else if(_data.level > 0)
            {
               equipedIcon.gotoAndStop("purchased");
            }
            else if(Boolean(_data.isUsingSkillDependency) && Boolean(_data.hasRequiredSkillDependency))
            {
               equipedIcon.gotoAndStop("available");
            }
            else
            {
               equipedIcon.gotoAndStop("none");
            }
            if(_data.isCoreSkill)
            {
               if(this.coreFrame)
               {
                  this.coreFrame.visible = true;
                  this.coreFrame.gotoAndStop(_data.color);
               }
            }
            else
            {
               this.coreFrame.visible = false;
            }
         }
         this.alpha = 1;
         if(_data.level < 1 && !_data.hasRequiredPointsSpent)
         {
            if(_imageLoader.content)
            {
               _imageLoader.content.alpha = 0.2;
            }
            _isLocked = true;
         }
         else
         {
            _isLocked = false;
            if(_imageLoader.content)
            {
               _imageLoader.content.alpha = 1;
            }
         }
         if(Boolean(this.unlockAnim) && Boolean(_data.playUpgradeAnimation))
         {
            this.unlockAnim.gotoAndPlay(2);
            _data.playUpgradeAnimation = false;
         }
         iconLock.visible = false;
      }
      
      override protected function setBackgroundColor() : void
      {
         if(mcColorBackground)
         {
            mcColorBackground.setBySkillType(_data.color);
         }
      }
      
      override protected function fireTooltipShowEvent(isMouseTooltip:Boolean = false) : void
      {
         var displayEvent:GridEvent = null;
         if(!(activeSelectionEnabled || InputManager.getInstance().isMouse()) && isParentEnabled())
         {
            return;
         }
         if(_data)
         {
            displayEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP,true,false,index,-1,-1,null,_data as Object);
            displayEvent.tooltipContentRef = "SkillTooltipRef";
            displayEvent.tooltipDataSource = "OnGetGridSkillTooltipData";
            displayEvent.isMouseTooltip = isMouseTooltip;
            displayEvent.anchorRect = getGlobalSlotRect();
            _tooltipRequested = true;
            dispatchEvent(displayEvent);
            if(isMouseTooltip)
            {
               hasMouseTooltip = true;
            }
         }
      }
      
      override protected function fireTooltipHideEvent(isMouseTooltip:Boolean = false) : void
      {
         var hideEvent:GridEvent = null;
         if(_tooltipRequested)
         {
            hideEvent = new GridEvent(GridEvent.HIDE_TOOLTIP,true,false,index,-1,-1,null,_data as Object);
            dispatchEvent(hideEvent);
            _tooltipRequested = false;
            if(isMouseTooltip)
            {
               hasMouseTooltip = false;
            }
         }
      }
      
      override protected function handleMouseDoubleClick(event:MouseEvent) : void
      {
         if(canExecuteAction())
         {
            this.executeDefaultAction(KeyCode.PAD_A_CROSS,null);
         }
      }
      
      override protected function executeDefaultAction(keyCode:Number, event:InputEvent) : void
      {
         if(!selectable)
         {
            return;
         }
         var isSwitchPlatform:Boolean = InputManager.getInstance().isSwitchPlatform();
         if(keyCode == KeyCode.PAD_A_CROSS || keyCode == KeyCode.ENTER || keyCode == KeyCode.NUMPAD_ENTER || keyCode == KeyCode.SPACE)
         {
            if(Boolean(event) && Boolean(event.details) && event.details.value != InputValue.KEY_UP)
            {
               return;
            }
            fireActionEvent(InventoryActionType.EQUIP,SlotActionEvent.EVENT_ACTIVATE);
            if(event)
            {
               event.handled = true;
            }
         }
         else if(keyCode == KeyCode.E || isSwitchPlatform && keyCode == KeyCode.PAD_Y_TRIANGLE || !isSwitchPlatform && keyCode == KeyCode.PAD_X_SQUARE)
         {
            this.spectreMaxPurchase = false;
            this.spectreResetRanks = false;
            if(!event)
            {
               fireActionEvent(InventoryActionType.SUB_ACTION,SlotActionEvent.EVENT_SECONDARY_ACTION);
            }
            else if(event.details.value == InputValue.KEY_DOWN)
            {
               this._spectreBuyHeld = true;
               this._spectreWaitData = false;
               this._spectreRepeatPending = false;
               this._spectreBuyTime = HOLD_TIME;
               this.startPurchaseAnimation(HOLD_TIME);
            }
            else if(event.details.value == InputValue.KEY_UP)
            {
               this._spectreBuyHeld = false;
               this._spectreWaitData = false;
               this._spectreRepeatPending = false;
               this.stopPurchaseAnimation();
            }
            if(Boolean(event) && event.details.value == InputValue.KEY_DOWN)
            {
               event.handled = true;
            }
         }
         else if(keyCode == KeyCode.Z || keyCode == KeyCode.PAD_RIGHT_THUMB)
         {
            if(!event)
            {
               this.spectreMaxPurchase = false;
               this.spectreResetRanks = true;
               fireActionEvent(InventoryActionType.SUB_ACTION,SlotActionEvent.EVENT_SECONDARY_ACTION);
            }
            else if(event.details.value == InputValue.KEY_DOWN)
            {
               this.spectreMaxPurchase = false;
               this.spectreResetRanks = true;
               this.spectreStartResetAnimation(HOLD_TIME);
            }
            else if(event.details.value == InputValue.KEY_UP)
            {
               this.stopPurchaseAnimation();
            }
            if(Boolean(event) && event.details.value == InputValue.KEY_DOWN)
            {
               event.handled = true;
            }
         }
         else if(keyCode == KeyCode.R)
         {
            if(!event)
            {
               this.spectreResetRanks = false;
               this.spectreMaxPurchase = true;
               fireActionEvent(InventoryActionType.SUB_ACTION,SlotActionEvent.EVENT_SECONDARY_ACTION);
            }
            else if(event.details.value == InputValue.KEY_DOWN)
            {
               this.spectreResetRanks = false;
               this.spectreMaxPurchase = true;
               this.startPurchaseAnimation(HOLD_TIME);
            }
            else if(event.details.value == InputValue.KEY_UP)
            {
               this.stopPurchaseAnimation();
            }
            if(Boolean(event) && event.details.value == InputValue.KEY_DOWN)
            {
               event.handled = true;
            }
         }
      }
      
      override public function executeAction(keyCode:Number, event:InputEvent) : Boolean
      {
         if(canExecuteAction())
         {
            this.executeDefaultAction(keyCode,event);
            return true;
         }
         return false;
      }
      
      override public function canDrag() : Boolean
      {
         return Boolean(_data) && !this.isLocked && _data.level > 0 && !data.isCoreSkill;
      }
      
      override public function canDrop(dragData:IDragTarget) : Boolean
      {
         return false;
      }
      
      override protected function initDropTarget() : void
      {
      }
      
      public function onDie() : void
      {
         this.fireTooltipHideEvent();
      }
      
      internal function splitEase(timePercent:Number, progressPercent:Number) : Function
      {
         return function(ratio:Number, unused1:Number, unused2:Number, unused3:Number):*
         {
            var p:* = undefined;
            if(ratio <= timePercent)
            {
               p = ratio / timePercent;
               p = p * p * (3 - 2 * p);
               return progressPercent * p;
            }
            p = (ratio - timePercent) / (1 - timePercent);
            p = p * p * (3 - 2 * p);
            return progressPercent + (1 - progressPercent) * p;
         };
      }
      
      public function startPurchaseAnimation(time:Number) : *
      {
         if(Boolean(_data.isUsingSkillDependency) && Boolean(_data.hasRequiredSkillDependency) && _data.level < 10)
         {
            GTweener.removeTweens(equipedIcon.mcFullColor);
            GTweener.to(equipedIcon.mcFullColor,time - 0.05,{"alpha":1},{
               "ease":LinearEase.easeIn,
               "onComplete":this.completePurchase
            });
            if(this.mcHoldAnimBlock)
            {
               this.mcHoldAnimBlock.y = 64;
               this.mcHoldAnimBlock.height = 0;
               this.mcHoldAnimBlock.alpha = 0.5;
               this.mcHoldAnimBlock.visible = true;
               GTweener.removeTweens(this.mcHoldAnimBlock);
               GTweener.to(this.mcHoldAnimBlock,time,{
                  "height":62,
                  "y":2
               });
               GTweener.to(this.mcHoldAnimBlock,time,{"alpha":0},{"ease":this.splitEase(0.75,0.25)});
            }
         }
      }
      
      public function spectreStartResetAnimation(time:Number) : *
      {
         if(Boolean(_data) && _data.level > 0 && !_data.isCoreSkill)
         {
            GTweener.removeTweens(equipedIcon.mcFullColor);
            GTweener.to(equipedIcon.mcFullColor,time - 0.05,{"alpha":0.5},{
               "ease":LinearEase.easeIn,
               "onComplete":this.completePurchase
            });
            if(this.mcHoldAnimBlock)
            {
               this.mcHoldAnimBlock.y = 64;
               this.mcHoldAnimBlock.height = 0;
               this.mcHoldAnimBlock.alpha = 0.5;
               this.mcHoldAnimBlock.visible = true;
               GTweener.removeTweens(this.mcHoldAnimBlock);
               GTweener.to(this.mcHoldAnimBlock,time,{
                  "height":62,
                  "y":2
               });
               GTweener.to(this.mcHoldAnimBlock,time,{"alpha":0},{"ease":this.splitEase(0.75,0.25)});
            }
         }
      }
      
      public function stopPurchaseAnimation() : *
      {
         var afterAlpha:* = undefined;
         var DEFAULT_BACK_TIME:Number = 0.2;
         GTweener.removeTweens(equipedIcon.mcFullColor);
         if(this.mcHoldAnimBlock)
         {
            this.mcHoldAnimBlock.visible = false;
            GTweener.removeTweens(this.mcHoldAnimBlock);
         }
         if(Boolean(_data.isUsingSkillDependency) && Boolean(_data.hasRequiredSkillDependency))
         {
            afterAlpha = _data.level > 0 ? 1 : 0.5;
            GTweener.to(equipedIcon.mcFullColor,DEFAULT_BACK_TIME,{"alpha":afterAlpha});
         }
      }
      
      public function completePurchase() : *
      {
         this._spectreWaitData = this._spectreBuyHeld && !this.spectreMaxPurchase && !this.spectreResetRanks;
         if(this._spectreWaitData)
         {
            this._spectreBuyTime = Math.max(SPECTRE_REPEAT_MIN_TIME,this._spectreBuyTime * SPECTRE_REPEAT_FACTOR);
         }
         fireActionEvent(InventoryActionType.SUB_ACTION,SlotActionEvent.EVENT_SECONDARY_ACTION);
      }
      
      override public function set selected(value:Boolean) : void
      {
         super.selected = value;
         if(!value)
         {
            this.stopPurchaseAnimation();
            // A refresh gives the selection back at once; if it does not by the next frame, the repeat ends there.
            if(this._spectreBuyHeld)
            {
               addEventListener(Event.ENTER_FRAME,this.spectreOnRepeatFrame,false,0,true);
            }
         }
         else if(this._spectreBuyHeld && !this._spectreWaitData)
         {
            this.spectreScheduleRepeat();
         }
      }
   }
}


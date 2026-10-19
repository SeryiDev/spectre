package red.game.witcher3.menus.character_menu
{
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.GTweener;
   import com.gskinner.motion.easing.Sine;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.getDefinitionByName;
   import flash.utils.setTimeout;
   import red.core.CoreMenu;
   import red.core.constants.KeyCode;
   import red.core.events.GameEvent;
   import red.core.events.GestureEventEx;
   import red.game.witcher3.constants.EInputDeviceType;
   import red.game.witcher3.constants.InventoryActionType;
   import red.game.witcher3.controls.InputFeedbackButton;
   import red.game.witcher3.events.ControllerChangeEvent;
   import red.game.witcher3.events.SlotActionEvent;
   import red.game.witcher3.managers.ContextInfoManager;
   import red.game.witcher3.managers.InputFeedbackManager;
   import red.game.witcher3.managers.InputManager;
   import red.game.witcher3.slots.SlotBase;
   import red.game.witcher3.slots.SlotInventoryGrid;
   import red.game.witcher3.slots.SlotSkillGrid;
   import red.game.witcher3.slots.SlotSkillMutagen;
   import red.game.witcher3.slots.SlotSkillSocket;
   import red.game.witcher3.slots.SlotsListBase;
   import red.game.witcher3.slots.SlotsTransferManager;
   import red.game.witcher3.utils.CommonUtils;
   import scaleform.clik.constants.InputValue;
   import scaleform.clik.constants.NavigationCode;
   import scaleform.clik.events.ButtonEvent;
   import scaleform.clik.events.InputEvent;
   import scaleform.clik.events.ListEvent;
   import scaleform.clik.interfaces.IListItemRenderer;
   import scaleform.clik.ui.InputDetails;
   import scaleform.gfx.Extensions;
   
   [SWF(width="1920", height="1080", backgroundColor="#000000", frameRate="40")]
   [SWF(frameRate="40",backgroundColor="#000000",width="1920",height="1080")]
   [SWF(frameRate="40",backgroundColor="#000000",width="1920",height="1080")]
   public class MenuCharacterDupe extends CoreMenu
   {
      
      private const UNEQUIP_MUTAGEN_HOLD_DURATION:Number = 1000;
      
      private const POINTS_AVAILABLE_GAP:Number = 25;
      
      public var mcDupeTabModule:red.game.witcher3.menus.character_menu.CharacterTabbedListModuleDupe;
      
      public var moduleSkillSlot:ModuleSkillsSocketsDupe;
      
      public var applyMode:CharacterModeBackground;
      
      public var tooltipAnchor:DisplayObject;
      
      public var txfAvailablePoints:TextField;
      
      public var txfPointsValue:TextField;
      
      public var btnMutationMode:InputFeedbackButton;
      
      public var mcPointIcon:MovieClip;
      
      public var mcPointsBorder:MovieClip;
      
      public var mcBackgroundImage:MovieClip;
      
      public var mcRunewordIcon:MovieClip;
      
      public var tfRunewordDescription:TextField;
      
      public var mcSlotChangeHighlight:MovieClip;
      
      public var _calledWSChange:Boolean = false;
      
      public var _pointsCount:int = 0;
      
      protected var _cachedSlotData:Object;
      
      protected var _holdY_triggered:Boolean = false;
      
      public var mcMasterMutation:MasterMutationItemRenderer;
      
      private var _isMutationEnabled:Boolean = false;
      
      private var _mcMutationPanel:MutationsPanel;
      
      private var _spectreMutationCounter:String = "";
      
      private var _btn_mutation:int = -1;
      
      private var _btn_switch_sections:int = -1;
      
      private var _btn_left_tab:int = -1;
      
      private var _btn_right_tab:int = -1;
      
      private var _isMutationInited:Boolean = false;
      
      public function MenuCharacterDupe()
      {
         super();
         this.applyMode.deactivate();
         this.btnMutationMode = this.mcMasterMutation.btnMutationMode;
         this.btnMutationMode.visible = true;
         this.btnMutationMode.label = "[[mutation_title_mutations]]";
         this.btnMutationMode.clickable = false;
         this.btnMutationMode.mouseChildren = this.btnMutationMode.mouseEnabled = false;
         this.btnMutationMode.x = this.mcMasterMutation.tfState.x + this.mcMasterMutation.tfState.width - this.btnMutationMode.getOccupiedWidth() - 130;
         if(this.mcMasterMutation)
         {
            this.mcMasterMutation.enabled = false;
            this.mcMasterMutation.selectable = false;
            this.mcMasterMutation.visible = false;
            this.mcMasterMutation.mouseChildren = this.mcMasterMutation.mouseEnabled = false;
            this.mcMasterMutation.addEventListener(MouseEvent.CLICK,this.handleMasterMutationTapOrClick,false,0,true);
            this.mcMasterMutation.addEventListener(GestureEventEx.GESTURE_TAP,this.handleMasterMutationTapOrClick,false,0,true);
         }
         setTimeout(this.configButtonDelayed_HACK,500);
         this.__setProp_mcDupeTabModule_Scene1_moduleSkillTabList_0();
         this.__setProp_mcMasterMutation_Scene1_equippedMutation_0();
      }
      
      private function configButtonDelayed_HACK() : void
      {
         var isSwitchPlatform:Boolean = InputManager.getInstance().isSwitchPlatform();
         this.btnMutationMode.setDataFromStage(isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y,KeyCode.C);
      }
      
      override protected function get menuName() : String
      {
         return "CharacterMenuDupe";
      }
      
      override protected function configUI() : void
      {
         var isSwitch2Mouser:Boolean = false;
         super.configUI();
         if(this.mcRunewordIcon)
         {
            this.mcRunewordIcon.visible = false;
         }
         if(this.tfRunewordDescription)
         {
            this.tfRunewordDescription.visible = false;
         }
         this.txfAvailablePoints.text = "[[panel_character_availablepoints]]";
         this.txfAvailablePoints.text = CommonUtils.toUpperCaseSafe(this.txfAvailablePoints.text);
         this.txfPointsValue.text = "0";
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"character.skills.grid",[this.updateSkillsGrid]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"character.skills.slots",[this.updateSkillsSockets]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"character.skills.slot.update",[this.updateSkillSocket]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"character.skills.mutagens",[this.updateSkillMutagens]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"character.skills.points",[this.setSkillPoints]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"character.groups.bonus",[this.updateGroupsBonus]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"character.skills.grid.stable",[this.stableUpdateSkillsGrid]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"character.paperdoll.changed",[this.onPaperdollChanged]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"character.mutations.list",[this.setMutationDataList]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"character.mutation",[this.setSingleMutationData]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"spectre.mutations.counter",[this.setSpectreMutationCounter]));
         if(!Extensions.isScaleform)
         {
            this.initDebugData();
         }
         this.mcDupeTabModule.mcSkillModule.addEventListener("EVENT_SELECTED_SKILL_TAPPED",this.onSkillTappedTwice,false,0,true);
         this.mcDupeTabModule.mcMutagenSlotList.addEventListener(SlotsListBase.EVENT_SELECTED_TAPPED,this.onMutagenTappedTwice,false,0,true);
         this.moduleSkillSlot.socketsList.addEventListener(SlotsListBase.EVENT_SELECTED_TAPPED,this.onSocketTappedTwice,false,0,true);
         this.moduleSkillSlot.addEventListener(SlotActionEvent.EVENT_ACTIVATE,this.handleSlotAction,false,0,true);
         this.moduleSkillSlot.socketsList.addEventListener(ListEvent.INDEX_CHANGE,this.onSlotSelected,false,0,true);
         this.moduleSkillSlot.addEventListener(SlotActionEvent.EVENT_SELECT,this.handleSlotActivate,false,0,true);
         this.moduleSkillSlot.addEventListener(SlotActionEvent.EVENT_SECONDARY_ACTION,this.handleSkillSecondaryAction,false,0,true);
         this.mcDupeTabModule.addEventListener(SlotActionEvent.EVENT_ACTIVATE,this.handleSkillAction,false,0,true);
         this.mcDupeTabModule.addEventListener(SlotActionEvent.EVENT_SECONDARY_ACTION,this.handleSkillSecondaryAction,false,0,true);
         this.applyMode.addEventListener(CharacterModeBackground.CANCEL,this.handleApplyModeCancel,false,0,true);
         this.applyMode.addEventListener(CharacterModeBackground.ACCEPT,this.handleApplyModeAccept,false,0,true);
         var inputMgr:InputManager = InputManager.getInstance();
         inputMgr.addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE,this.handleControllerChanged,false,0,true);
         _contextMgr.defaultAnchor = this.tooltipAnchor;
         _contextMgr.addGridEventsTooltipHolder(stage);
         _contextMgr.addEventListener(ContextInfoManager.TOOLTIP_SHOW_ERROR,this.handleTooltipFailedToShow,false,0,true);
         _contextMgr.enableInputFeedbackShowing(true);
         _contextMgr.saveScaleValue = true;
         currentModuleIdx = 1;
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnConfigUI"));
         if(this._btn_switch_sections == -1 && InputManager.getInstance().gamepadType != EInputDeviceType.IDT_Switch2_Mouser)
         {
            this._btn_switch_sections = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_R3,-1,"panel_button_common_jump_sections");
         }
         if(this._btn_left_tab == -1 && this._btn_right_tab == -1)
         {
            isSwitch2Mouser = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;
            this._btn_left_tab = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_L2,-1,"photomode_navigation_previous_tab");
            this._btn_right_tab = InputFeedbackManager.appendButton(this,isSwitch2Mouser ? NavigationCode.GAMEPAD_L1 : NavigationCode.GAMEPAD_R2,-1,"photomode_navigation_next_tab");
         }
         InputFeedbackManager.updateButtons(this);
         SlotsTransferManager.getInstance().enableDragWithPan(true);
      }
      
      public function get mcMutationPanel() : MutationsPanel
      {
         var MUT_PANEL_DEF_X:Number = Number(NaN);
         var MUT_PANEL_DEF_Y:Number = Number(NaN);
         var MUT_PANEL_CLASS_NAME:String = null;
         var classRef:Class = null;
         if(!this._mcMutationPanel)
         {
            MUT_PANEL_DEF_X = -23.6;
            MUT_PANEL_DEF_Y = 8.55;
            MUT_PANEL_CLASS_NAME = "MutationPanelRef";
            classRef = getDefinitionByName(MUT_PANEL_CLASS_NAME) as Class;
            this._mcMutationPanel = new classRef() as MutationsPanel;
            this._mcMutationPanel.x = MUT_PANEL_DEF_X;
            this._mcMutationPanel.y = MUT_PANEL_DEF_Y;
            this._mcMutationPanel.addEventListener(Event.ACTIVATE,this.handleMutationPanelToggled,false,0,true);
            this._mcMutationPanel.addEventListener(Event.DEACTIVATE,this.handleMutationPanelToggled,false,0,true);
            addChild(this._mcMutationPanel);
            this._mcMutationPanel.validateNow();
            this._mcMutationPanel.setSpectreCounter(this._spectreMutationCounter);
            this._isMutationInited = true;
         }
         return this._mcMutationPanel;
      }
      
      // Spectre: the active mutations counter, kept until the mutation panel exists.
      public function setSpectreMutationCounter(value:String) : void
      {
         this._spectreMutationCounter = value;
         if(this._mcMutationPanel)
         {
            this._mcMutationPanel.setSpectreCounter(value);
         }
      }
      
      public function confirmMutationResearch() : void
      {
      }
      
      public function setMutationDataList(value:Array) : void
      {
         var len:int = 0;
         var i:int = 0;
         var isSwitchPlatform:Boolean = false;
         var curDataItem:Object = null;
         var isMutationEquipped:Boolean = false;
         var isMasterFound:Boolean = false;
         var spectreHasShown:Boolean = false;
         var masterMutation:MasterMutationItemRenderer = this.mcMutationPanel.mcMutation13 as MasterMutationItemRenderer;
         masterMutation.resetColor();
         this.mcMasterMutation.resetColor();
         if(value)
         {
            len = int(value.length);
            this._isMutationEnabled = len > 0;
            this.moduleSkillSlot.mutationMode = this._isMutationEnabled;
            if(!this._isMutationEnabled)
            {
               this.btnMutationMode.visible = false;
               this.mcMasterMutation.visible = false;
               this.mcMasterMutation.mouseChildren = this.mcMasterMutation.mouseEnabled = false;
            }
            else
            {
               if(this._btn_mutation == -1)
               {
                  isSwitchPlatform = InputManager.getInstance().isSwitchPlatform();
                  this._btn_mutation = InputFeedbackManager.appendButton(this,isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y,KeyCode.C,"mutation_title_mutations");
               }
               this.btnMutationMode.visible = !this.mcMutationPanel.active;
               this.mcMutationPanel.setDataList(value);
               // Spectre: with several mutations equipped, the one shown is the one the script marks (spectreShown).
               for(i = 0; i < len; i++)
               {
                  if(Boolean(value[i].spectreShown))
                  {
                     spectreHasShown = true;
                  }
               }
               i = 0;
               while(i < len)
               {
                  curDataItem = value[i];
                  if(Boolean(curDataItem.isEquipped) && (!spectreHasShown || Boolean(curDataItem.spectreShown)))
                  {
                     this.mcMutationPanel.equippedMutationId = curDataItem.mutationId;
                     masterMutation.setColorByMutationId(curDataItem.mutationId);
                     this.mcMasterMutation.setColorByMutationId(curDataItem.mutationId);
                     this.mcMasterMutation.setEquippedMutationData(curDataItem);
                     isMutationEquipped = true;
                     if(isMasterFound)
                     {
                        break;
                     }
                  }
                  else if(curDataItem.isMasterMutation)
                  {
                     this.mcMasterMutation.data = curDataItem;
                     this.mcMasterMutation.validateNow();
                     this.mcMasterMutation.visible = true;
                     this.mcMasterMutation.enabled = false;
                     this.mcMasterMutation.selectable = false;
                     this.mcMasterMutation.mouseChildren = this.mcMasterMutation.mouseEnabled = true;
                     isMasterFound = true;
                     if(isMutationEquipped)
                     {
                        break;
                     }
                  }
                  i++;
               }
               if(!isMutationEquipped)
               {
                  this.mcMutationPanel.equippedMutationId = -1;
                  this.mcMasterMutation.hideDescription(true);
                  this.moduleSkillSlot.additionalSkillsMode = false;
               }
               else
               {
                  this.mcMasterMutation.hideDescription(false);
                  this.moduleSkillSlot.additionalSkillsMode = true;
               }
            }
         }
      }
      
      public function setSingleMutationData(value:Object) : void
      {
         if(Boolean(value) && Boolean(value.isEquipped))
         {
            this.mcMasterMutation.data = value;
            this.mcMasterMutation.setEquippedMutationData(value);
            this.mcMasterMutation.setColorByMutationId(value.mutationId);
            this.mcMasterMutation.hideDescription(false);
            this.mcMasterMutation.validateNow();
         }
         if(this._isMutationInited)
         {
            this.mcMutationPanel.setSingleMutationData(value);
         }
         if(!this._isMutationEnabled)
         {
            this._isMutationEnabled = true;
            this.moduleSkillSlot.mutationMode = this._isMutationEnabled;
         }
      }
      
      public function setMutationBonusMode(value:Boolean) : void
      {
         this._isMutationEnabled = value;
         if(this._isMutationEnabled)
         {
            this.moduleSkillSlot.mutationMode = this._isMutationEnabled;
         }
         else
         {
            this.btnMutationMode.visible = false;
            this.mcMasterMutation.visible = false;
            this.mcMasterMutation.enabled = false;
            this.mcMasterMutation.selectable = false;
            this.mcMasterMutation.mouseChildren = this.mcMasterMutation.mouseEnabled = false;
         }
         this.mcMasterMutation.hideDescription(true);
      }
      
      public function activateRunwordBuf(value:Boolean, textDescription:String) : void
      {
         if(Boolean(this.mcRunewordIcon) && Boolean(this.tfRunewordDescription))
         {
            this.mcRunewordIcon.visible = value;
            this.tfRunewordDescription.visible = value;
            this.tfRunewordDescription.htmlText = textDescription;
            this.mcRunewordIcon.y = this.tfRunewordDescription.y + this.tfRunewordDescription.textHeight / 2;
         }
         SlotSkillSocket.GLOW_EQUIPPED = value;
      }
      
      private function enableMutationButton(value:Boolean) : void
      {
      }
      
      private function onCallUnequipMutation() : void
      {
         this._holdY_triggered = true;
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnUnequipMutation"));
      }
      
      override protected function handleControllerChanged(event:ControllerChangeEvent) : void
      {
         super.handleControllerChanged(event);
         if(this.mcMutationPanel.active)
         {
            return;
         }
         var isSwitch2Mouser:Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;
         if(this._btn_switch_sections == -1 && !isSwitch2Mouser)
         {
            this._btn_switch_sections = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_R3,-1,"panel_button_common_jump_sections");
         }
         else if(this._btn_switch_sections != -1)
         {
            InputFeedbackManager.removeButton(this,this._btn_switch_sections);
            this._btn_switch_sections = -1;
         }
         InputFeedbackManager.removeButton(this,this._btn_left_tab);
         InputFeedbackManager.removeButton(this,this._btn_right_tab);
         this._btn_left_tab = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_L2,-1,"photomode_navigation_previous_tab");
         this._btn_right_tab = InputFeedbackManager.appendButton(this,isSwitch2Mouser ? NavigationCode.GAMEPAD_L1 : NavigationCode.GAMEPAD_R2,-1,"photomode_navigation_next_tab");
         InputFeedbackManager.updateButtons(this);
      }
      
      protected function startApplyMode(targetSlot:SlotBase) : void
      {
         if(_inCombat)
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnSendNotification",["menu_cannot_perform_action_combat"]));
         }
         else
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnStartApplyMode"));
            enableForeignInputEvent(false);
            this.applyMode.activate(targetSlot);
            if(targetSlot is SlotSkillGrid)
            {
               this.moduleSkillSlot.disableMutagens(true);
               this.moduleSkillSlot.SetUnselectableLockedAndMutagens(targetSlot.data.color);
            }
            else
            {
               this.moduleSkillSlot.disableNonMutagensAndLocked();
            }
            this.moduleSkillSlot.setSelectionMode(true);
            this.moduleSkillSlot.socketsList.ReselectIndexIfInvalid(this.moduleSkillSlot.socketsList.selectedIndex);
            this.mcDupeTabModule.enabled = false;
            currentModuleIdx = 0;
            this._cachedSlotData = targetSlot.data;
            SlotsTransferManager.getInstance().disabled = true;
            this.enableMutationButton(false);
            _contextMgr.enableInputFeedbackShowing(false);
         }
      }
      
      protected function endApplyMode() : void
      {
         this.applyMode.deactivate();
         this.moduleSkillSlot.disableMutagens(false);
         this.moduleSkillSlot.SetAllSelectable();
         this.moduleSkillSlot.setSelectionMode(false);
         this.mcDupeTabModule.enabled = true;
         currentModuleIdx = 0;
         this._cachedSlotData = null;
         SlotsTransferManager.getInstance().disabled = false;
         _contextMgr.enableInputFeedbackShowing(true);
         enableForeignInputEvent(true);
      }
      
      override protected function handleInputNavigate(event:InputEvent) : void
      {
         var details:InputDetails = event.details;
         var inputEnabled:Boolean = details.value == InputValue.KEY_UP && !event.handled;
         var isSwitchPlatform:Boolean = InputManager.getInstance().isSwitchPlatform();
         var isSwitch2Mouser:Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;
         if(details.value == InputValue.KEY_UP && this._holdY_triggered && (isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X || !isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y))
         {
            this._holdY_triggered = false;
            event.handled = true;
            return;
         }
         if(inputEnabled)
         {
            switch(details.navEquivalent)
            {
               case NavigationCode.GAMEPAD_Y:
               case NavigationCode.GAMEPAD_X:
                  if(isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X || !isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y)
                  {
                     if(this._isMutationEnabled && this.btnMutationMode.getCurrentHoldProgress() < 0.1 && !this.applyMode.isActive())
                     {
                        this.mcMutationPanel.active = !this.mcMutationPanel.active;
                        event.handled = true;
                        event.stopImmediatePropagation();
                     }
                  }
                  break;
               case NavigationCode.GAMEPAD_A:
                  if(this.applyMode.isActive())
                  {
                     this.handleApplyModeAccept();
                     event.handled = true;
                     event.stopImmediatePropagation();
                  }
                  break;
               case NavigationCode.GAMEPAD_B:
                  if(this.applyMode.isActive())
                  {
                     this.endApplyMode();
                     dispatchEvent(new GameEvent(GameEvent.CALL,"OnCancelApplyMode"));
                     event.handled = true;
                     event.stopImmediatePropagation();
                     return;
                  }
                  break;
               case NavigationCode.GAMEPAD_L2:
                  if(this.mcDupeTabModule.mcTabList.selectedIndex > 0)
                  {
                     --this.mcDupeTabModule.mcTabList.selectedIndex;
                     this.selectCurrentTabIcon();
                     event.handled = true;
                  }
                  break;
               case NavigationCode.GAMEPAD_R2:
               case NavigationCode.GAMEPAD_L1:
                  if(this.mcDupeTabModule.mcTabList.selectedIndex < 4 && (isSwitch2Mouser && details.navEquivalent == NavigationCode.GAMEPAD_L1 || !isSwitch2Mouser && details.navEquivalent == NavigationCode.GAMEPAD_R2))
                  {
                     ++this.mcDupeTabModule.mcTabList.selectedIndex;
                     this.selectCurrentTabIcon();
                     event.handled = true;
                  }
            }
            if(details.code == KeyCode.C)
            {
               if(this._isMutationEnabled && !this.applyMode.isActive())
               {
                  this.mcMutationPanel.active = !this.mcMutationPanel.active;
                  event.handled = true;
                  event.stopImmediatePropagation();
               }
            }
            else if(details.code == KeyCode.SPACE || details.code == KeyCode.E)
            {
               if(this.applyMode.isActive())
               {
                  this.handleApplyModeAccept();
                  event.handled = true;
                  event.stopImmediatePropagation();
               }
            }
         }
         super.handleInputNavigate(event);
      }
      
      private function handleMasterMutationTapOrClick(event:Event) : void
      {
         if(this._isMutationEnabled && !this.mcMutationPanel.active && !this.applyMode.isActive())
         {
            this.mcMutationPanel.active = true;
         }
      }
      
      protected function handleMutationPanelToggled(event:Event) : void
      {
         var isSwitchPlatform:Boolean = false;
         trace("GFX handleMutationPanelToggled ",this.mcMutationPanel.active);
         this.updateMutationPanelVisibility();
         if(this.mcMutationPanel.active)
         {
            SlotsTransferManager.getInstance().disabled = true;
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnOpenMutationPanel"));
            this.moduleSkillSlot.hideInputFeedback = true;
            this.moduleSkillSlot.enabled = false;
            _contextMgr.blockModeSwitching = true;
            _contextMgr.enableInputFeedbackShowing(false);
            if(this._btn_mutation != -1)
            {
               InputFeedbackManager.removeButton(this,this._btn_mutation);
               this._btn_mutation = -1;
            }
            if(this._btn_switch_sections != -1)
            {
               InputFeedbackManager.removeButton(this,this._btn_switch_sections);
               this._btn_switch_sections = -1;
            }
            InputFeedbackManager.updateButtons(this);
         }
         else
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnCloseMutationPanel"));
            SlotsTransferManager.getInstance().disabled = false;
            this.moduleSkillSlot.hideInputFeedback = false;
            this.moduleSkillSlot.enabled = true;
            _contextMgr.blockModeSwitching = false;
            _contextMgr.enableInputFeedbackShowing(true);
            if(this._btn_mutation == -1)
            {
               isSwitchPlatform = InputManager.getInstance().isSwitchPlatform();
               this._btn_mutation = InputFeedbackManager.appendButton(this,isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y,KeyCode.C,"mutation_title_mutations");
            }
            if(this._btn_switch_sections == -1 && InputManager.getInstance().gamepadType != EInputDeviceType.IDT_Switch2_Mouser)
            {
               this._btn_switch_sections = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_R3,-1,"panel_button_common_jump_sections");
            }
            InputFeedbackManager.updateButtons(this);
         }
      }
      
      protected function updateMutationPanelVisibility() : void
      {
         GTweener.removeTweens(this.moduleSkillSlot);
         GTweener.removeTweens(this.mcMutationPanel);
         GTweener.removeTweens(this.mcMasterMutation);
         GTweener.removeTweens(this.mcBackgroundImage);
         if(this.mcMutationPanel.active)
         {
            this.txfPointsValue.visible = false;
            this.mcPointIcon.visible = false;
            this.mcPointsBorder.visible = false;
            this.mcRunewordIcon.visible = false;
            this.btnMutationMode.visible = false;
            this.mcMutationPanel.visible = true;
            this.mcMutationPanel.alpha = 0;
            this.mcRunewordIcon.alpha = 0;
            this.txfAvailablePoints.alpha = 0;
            GTweener.to(this.moduleSkillSlot,0.5,{"alpha":0},{"ease":Sine.easeOut});
            GTweener.to(this.mcMasterMutation,0.5,{"alpha":0},{"ease":Sine.easeOut});
            GTweener.to(this.mcBackgroundImage,0.5,{"alpha":0},{"ease":Sine.easeOut});
            GTweener.to(this.mcMutationPanel,0.5,{"alpha":1},{"ease":Sine.easeOut});
         }
         else
         {
            GTweener.to(this.moduleSkillSlot,0.5,{"alpha":1},{"ease":Sine.easeOut});
            GTweener.to(this.mcMasterMutation,0.5,{"alpha":1},{"ease":Sine.easeOut});
            GTweener.to(this.mcBackgroundImage,0.5,{"alpha":1},{"ease":Sine.easeOut});
            GTweener.to(this.mcMutationPanel,0.5,{"alpha":0},{
               "ease":Sine.easeOut,
               "onComplete":this.handleMutationHidden
            });
         }
      }
      
      protected function handleMutationHidden(tw:GTween = null) : void
      {
         this.mcMutationPanel.visible = false;
         this.txfAvailablePoints.visible = true;
         this.mcPointsBorder.visible = true;
         this.btnMutationMode.visible = true;
         this.txfPointsValue.visible = true;
         this.mcPointIcon.visible = true;
         this.mcRunewordIcon.alpha = 1;
         this.txfAvailablePoints.alpha = 1;
      }
      
      protected function showFullStats() : void
      {
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnShowFullStats"));
      }
      
      protected function onSlotSelected(event:ListEvent) : void
      {
      }
      
      protected function handleSkillAction(event:SlotActionEvent) : void
      {
         var targetSlot:SlotSkillGrid = event.targetSlot as SlotSkillGrid;
         var inventorySlot:SlotInventoryGrid = event.targetSlot as SlotInventoryGrid;
         if(event.actionType == InventoryActionType.DROP)
         {
            return;
         }
         if(targetSlot)
         {
            if(targetSlot.data == null || targetSlot.isLocked || Boolean(targetSlot.data.isCoreSkill) || targetSlot.data.level == 0)
            {
               return;
            }
            if(this.moduleSkillSlot.hasSkillSlotUnlocked())
            {
               this.startApplyMode(targetSlot);
            }
         }
         else if(Boolean(inventorySlot) && inventorySlot.data != null && this.moduleSkillSlot.hasMutagenSlotUnlocked())
         {
            this.startApplyMode(inventorySlot);
         }
      }
      
      protected function handleSlotAction(event:SlotActionEvent) : void
      {
         var skillSocket:SlotSkillSocket = null;
         if(this.applyMode.isActive())
         {
            this.handleApplyModeAccept();
            return;
         }
         var mutSocket:SlotSkillMutagen = event.targetSlot as SlotSkillMutagen;
         if(Boolean(mutSocket) && !mutSocket.isLocked())
         {
            this.mutagenSlotAction(event.targetSlot as SlotSkillMutagen);
         }
         else
         {
            skillSocket = event.targetSlot as SlotSkillSocket;
            if(event.targetSlot.data.skillPath != SlotSkillSocket.NULL_SKILL || this.applyMode.isActive())
            {
               this.skillSlotAction(event.targetSlot as SlotSkillGrid);
            }
            else if(Boolean(skillSocket) && Boolean(skillSocket.data) && !skillSocket.isLocked)
            {
               currentModuleIdx = 0;
            }
         }
      }
      
      protected function handleSkillSecondaryAction(event:SlotActionEvent) : void
      {
         var targetSlot:SlotSkillGrid = event.targetSlot as SlotSkillGrid;
         if(this.applyMode.isActive())
         {
            this.handleApplyModeAccept();
            return;
         }
         if(targetSlot)
         {
            this.skillSlotSecondaryAction(targetSlot);
         }
      }
      
      protected function skillSlotAction(skillSlot:SlotSkillGrid) : void
      {
         var skillId:int = 0;
         var slotData:Object = this._cachedSlotData;
         var slotId:int = int(skillSlot.data.slotId);
         if(Boolean(slotData) && slotData.level == 0)
         {
            return;
         }
         if(this.applyMode.isActive())
         {
            skillId = int(slotData.skillTypeId);
            this.endApplyMode();
            this.callEquipSkill(skillId,slotId);
         }
         else
         {
            this.changeHighlightSize(0.5);
            this.moveHighlightOverTreeSkill(skillSlot);
            this.callUnequipSkill(slotId);
         }
      }
      
      protected function skillSlotSecondaryAction(targetSlot:SlotSkillGrid) : void
      {
         var targetData:Object = null;
         var upgradeAvailable:Boolean = false;
         var checkSkill:Boolean = false;
         if(this.applyMode.isActive())
         {
            return;
         }
         if(targetSlot)
         {
            targetData = targetSlot.data;
            if(targetSlot.spectreResetRanks)
            {
               targetSlot.spectreResetRanks = false;
               if(targetData.level > 0 && !targetData.isCoreSkill)
               {
                  this.callUpgradeSkill(int(targetData.skillTypeId) + 2000);
               }
               return;
            }
            upgradeAvailable = targetData.level < targetData.maxLevel;
            checkSkill = upgradeAvailable && !targetData.notEnoughPoints && !targetSlot.isLocked;
            if(targetData.hasOwnProperty("isUsingSkillDependency") && Boolean(targetData.isUsingSkillDependency))
            {
               checkSkill &&= Boolean(targetData.hasRequiredSkillDependency);
            }
            if(targetData.notEnoughPoints)
            {
               this.callNotifyNotEnoughtPoints();
               return;
            }
            if(checkSkill)
            {
               if(targetSlot.spectreMaxPurchase)
               {
                  targetSlot.spectreMaxPurchase = false;
                  this.callUpgradeSkill(int(targetData.skillTypeId) + 1000);
               }
               else
               {
                  this.callUpgradeSkill(targetData.skillTypeId);
               }
               if(this._pointsCount > 0)
               {
                  this.changeHighlightSize(0.5);
                  this.moveHighlightOverTreeSkill(targetSlot);
               }
            }
         }
      }
      
      protected function mutagenSlotAction(mutagenSlot:SlotSkillMutagen) : void
      {
         if(this.applyMode.isActive())
         {
            this.moveHighlightOverMutagenSlot(mutagenSlot);
            this.changeHighlightSize(0.5);
            this.callEquipMutagen(this._cachedSlotData.id,mutagenSlot.slotType);
         }
         else if(!mutagenSlot.isMutEquiped())
         {
            currentModuleIdx = 0;
         }
         else
         {
            this.changeHighlightSize(0.5);
            this.moveHighlightOverMutagenSlot(mutagenSlot);
            this.callUnequipMutagen(mutagenSlot.slotType);
         }
      }
      
      protected function handleSlotActivate(event:SlotActionEvent) : void
      {
         var mutSlot:SlotSkillMutagen = event.target as SlotSkillMutagen;
         var skillSlot:SlotSkillSocket = event.target as SlotSkillSocket;
      }
      
      private function onSkillTappedTwice(event:Event) : void
      {
         var selectedSkill:SlotSkillGrid = null;
         var selected:SlotBase = event.target.getSelectedRenderer() as SlotBase;
         trace("MenuCharacterDupe::onSkillTappedTwice : ",this.mcDupeTabModule.isOpen,this.mcDupeTabModule.hasFocus,selected,event);
         if(this.mcDupeTabModule.isOpen && this.mcDupeTabModule.hasFocus && Boolean(selected))
         {
            selectedSkill = selected as SlotSkillGrid;
            if(selectedSkill)
            {
               this.skillSlotSecondaryAction(selectedSkill);
            }
         }
      }
      
      private function onMutagenTappedTwice(event:Event) : void
      {
         var selectedMutagen:SlotInventoryGrid = null;
         var selected:SlotBase = event.target.getSelectedRenderer() as SlotBase;
         trace("MenuCharacterDupe::onMutagenTappedTwice : ",this.mcDupeTabModule.hasFocus,selected,event);
         if(this.mcDupeTabModule.hasFocus && Boolean(selected))
         {
            selectedMutagen = selected as SlotInventoryGrid;
            if(selectedMutagen)
            {
               trace("MenuCharacter::onMutagenTappedTwice B");
               this.startApplyMode(selectedMutagen);
            }
         }
      }
      
      private function onSocketTappedTwice(event:Event) : void
      {
         var mutSocket:SlotSkillMutagen = null;
         var skillSocket:SlotSkillSocket = null;
         var selected:SlotBase = event.target.getSelectedRenderer() as SlotBase;
         trace("MenuCharacterDupe::onSocketTappedTwice : ",this.moduleSkillSlot.hasFocus,selected,event);
         if(this.moduleSkillSlot.hasFocus && Boolean(selected))
         {
            mutSocket = selected as SlotSkillMutagen;
            skillSocket = selected as SlotSkillSocket;
            if(Boolean(mutSocket) || Boolean(skillSocket))
            {
               selected.executeAction(KeyCode.PAD_A_CROSS,new InputEvent("dummy",null));
            }
         }
      }
      
      public function handleApplyModeAccept(event:Event = null) : void
      {
         var selectedSlot:IListItemRenderer = this.moduleSkillSlot.socketsList.getSelectedRenderer();
         var mutSlot:SlotSkillMutagen = selectedSlot as SlotSkillMutagen;
         var skillSlot:SlotSkillSocket = selectedSlot as SlotSkillSocket;
         var targetData:Object = this.applyMode.originalSlot.data;
         if(mutSlot)
         {
            this.moveHighlightOverMutagenSlot(mutSlot);
            this.changeHighlightSize(0.5);
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnEquipMutagen",[uint(targetData.id),mutSlot.slotType]));
         }
         else if(skillSlot)
         {
            this.moveHighlightOverSocket(skillSlot);
            this.changeHighlightSize(0.5);
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnEquipSkill",[uint(targetData.id),skillSlot.slotId]));
         }
         this.endApplyMode();
      }
      
      public function handleApplyModeCancel(event:Event) : *
      {
         this.endApplyMode();
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnCancelApplyMode"));
      }
      
      public function handleTooltipFailedToShow(event:Event) : *
      {
      }
      
      public function onBuyButtonClicked(event:ButtonEvent) : *
      {
         if(event.buttonIdx == 0)
         {
            if(this.moduleSkillSlot.focused)
            {
               this.skillSlotSecondaryAction(this.moduleSkillSlot.socketsList.getSelectedRenderer() as SlotSkillGrid);
            }
            else
            {
               trace("GFX - These are not the modules you are looking for!");
            }
         }
      }
      
      protected function updateGroupsBonus(value:Array) : void
      {
         this.moduleSkillSlot.setBonusData(value);
      }
      
      public function onPaperdollChanged() : void
      {
         this.mcSlotChangeHighlight.gotoAndPlay("animation");
      }
      
      public function notifySkillUpgraded(skillType:int) : void
      {
      }
      
      protected function stableUpdateSkillsGrid(value:Array) : void
      {
      }
      
      protected function updateSkillsGrid(value:Array) : void
      {
      }
      
      protected function updateSkillsSockets(value:Array) : void
      {
         this.moduleSkillSlot.setData(value);
      }
      
      protected function updateSkillSocket(value:Object) : void
      {
         this.moduleSkillSlot.updateSocket(value);
      }
      
      public function clearSkillSlot(slotId:int) : void
      {
         this.moduleSkillSlot.clearSkillSlot(slotId);
      }
      
      protected function updateSkillMutagens(value:Array) : void
      {
         this.moduleSkillSlot.setMutagensData(value);
      }
      
      protected function setSkillPoints(curPoint:int) : void
      {
         this._pointsCount = curPoint;
         this.mcDupeTabModule.pointsCount = curPoint;
         this.moduleSkillSlot.pointsCount = curPoint;
         this.txfAvailablePoints.text = "[[panel_character_availablepoints]]";
         this.txfPointsValue.text = curPoint.toString();
         this.txfAvailablePoints.text = CommonUtils.toUpperCaseSafe(this.txfAvailablePoints.text);
         this.txfAvailablePoints.x = this.txfPointsValue.x + this.txfPointsValue.width - this.txfPointsValue.textWidth - this.POINTS_AVAILABLE_GAP - this.txfAvailablePoints.width;
      }
      
      protected function callNotifyNotEnoughtPoints() : void
      {
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnNotEnoughtPoints"));
      }
      
      protected function callBuySkill(skillId:int, slotId:int) : void
      {
         if(this._pointsCount > 0)
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnBuySkill",[skillId,slotId]));
         }
      }
      
      protected function callEquipSkill(skillId:int, slotId:int) : void
      {
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnEquipSkill",[skillId,slotId]));
         if(this.applyMode.visible)
         {
            this.endApplyMode();
         }
      }
      
      protected function callUnequipSkill(slotId:int) : void
      {
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnUnequipSkill",[slotId]));
      }
      
      protected function callUpgradeSkill(skillId:int) : void
      {
         // Spectre: the reset (skill id + 2000) needs no free points.
         if(this._pointsCount > 0 || skillId >= 2000)
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnUpgradeSkill",[skillId]));
            InputFeedbackManager.updateButtons(this);
         }
      }
      
      protected function callOpenMutagenList(slotType:int) : void
      {
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnRequestMutagenList",[slotType]));
      }
      
      protected function callEquipMutagen(itemID:uint, slotId:int) : void
      {
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnEquipMutagen",[itemID,slotId]));
         if(this.applyMode.visible)
         {
            this.endApplyMode();
         }
      }
      
      protected function callUnequipMutagen(slotType:int) : void
      {
         trace("GFX call callUnequipMutagen ",slotType);
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnUnequipMutagen",[slotType]));
      }
      
      protected function initDebugData() : void
      {
         var testGridData:Array = [];
         var obj1:* = {
            "dropDownLabel":"cat1",
            "skillType":"11",
            "skillSubPath":"ESP_Sword"
         };
         var obj2:* = {
            "dropDownLabel":"cat1",
            "skillType":"11",
            "skillSubPath":"ESP_Sword"
         };
         var obj3:* = {
            "dropDownLabel":"cat1",
            "skillType":"11",
            "skillSubPath":"ESP_Sword"
         };
         testGridData.push(obj1);
         testGridData.push(obj2);
         testGridData.push(obj3);
         this.updateSkillsGrid(testGridData);
      }
      
      protected function debugTraceData(valuesList:Array) : void
      {
         var i:int = 0;
         if(valuesList)
         {
            i = 0;
            while(i < valuesList.length)
            {
               if(valuesList[i].skillType != "S_Undefined")
               {
                  CommonUtils.traceObject(valuesList[i],"GFX [MUTAGENS] ");
               }
               i++;
            }
         }
      }
      
      public function selectTabByColor(color:String) : void
      {
         this.mcDupeTabModule.handleSelectTabByColor(color);
      }
      
      public function selectCurrentTabIcon() : void
      {
         switch(this.mcDupeTabModule.mcTabList.selectedIndex)
         {
            case 0:
               this.selectTabByColor("SC_Red");
               break;
            case 1:
               this.selectTabByColor("SC_Blue");
               break;
            case 2:
               this.selectTabByColor("SC_Green");
               break;
            case 3:
               this.selectTabByColor("SC_Yellow");
         }
      }
      
      public function changeHighlightSize(ratio:Number) : *
      {
         this.mcSlotChangeHighlight.scaleX = this.mcSlotChangeHighlight.scaleY = ratio;
      }
      
      public function moveHighlightOverSocket(item:SlotSkillSocket) : *
      {
         var globalPos:Point = item.localToGlobal(new Point(32,32));
         var highlightPos:Point = globalToLocal(globalPos);
         this.mcSlotChangeHighlight.x = highlightPos.x;
         this.mcSlotChangeHighlight.y = highlightPos.y;
      }
      
      public function moveHighlightOverMutagenSlot(item:SlotSkillMutagen) : *
      {
         var globalPos:Point = item.localToGlobal(new Point(35,35));
         var highlightPos:Point = globalToLocal(globalPos);
         this.mcSlotChangeHighlight.x = highlightPos.x;
         this.mcSlotChangeHighlight.y = highlightPos.y;
      }
      
      public function moveHighlightOverTreeSkill(item:SlotSkillGrid) : *
      {
         var globalPos:Point = item.localToGlobal(new Point(32,32));
         var highlightPos:Point = globalToLocal(globalPos);
         this.mcSlotChangeHighlight.x = highlightPos.x;
         this.mcSlotChangeHighlight.y = highlightPos.y;
      }
      
      internal function __setProp_mcDupeTabModule_Scene1_moduleSkillTabList_0() : *
      {
         try
         {
            this.mcDupeTabModule["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.mcDupeTabModule.enabled = true;
         this.mcDupeTabModule.enableInitCallback = false;
         this.mcDupeTabModule.subDataProvider = "character.menu.tabs.data";
         this.mcDupeTabModule.tabDataEventName = "OnTabDataRequested";
         this.mcDupeTabModule.visible = true;
         try
         {
            this.mcDupeTabModule["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_mcMasterMutation_Scene1_equippedMutation_0() : *
      {
         try
         {
            this.mcMasterMutation["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.mcMasterMutation.draggingEnabled = true;
         this.mcMasterMutation.enabled = true;
         this.mcMasterMutation.enableInitCallback = false;
         this.mcMasterMutation.gridSize = 1;
         this.mcMasterMutation.mutationId = 0;
         this.mcMasterMutation.navigationDown = -1;
         this.mcMasterMutation.navigationLeft = -1;
         this.mcMasterMutation.navigationRight = -1;
         this.mcMasterMutation.navigationUp = -1;
         this.mcMasterMutation.selectable = false;
         this.mcMasterMutation.slotNavigationId = -1;
         this.mcMasterMutation.visible = true;
         try
         {
            this.mcMasterMutation["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
   }
}


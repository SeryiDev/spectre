package red.game.witcher3.menus.character_menu
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import red.core.constants.KeyCode;
   import red.core.events.GameEvent;
   import red.core.events.GestureEventEx;
   import red.game.witcher3.controls.AdvancedTabListItem;
   import red.game.witcher3.events.ControllerChangeEvent;
   import red.game.witcher3.interfaces.IDragTarget;
   import red.game.witcher3.interfaces.IDropTarget;
   import red.game.witcher3.managers.InputFeedbackManager;
   import red.game.witcher3.managers.InputManager;
   import red.game.witcher3.modules.CollapsableTabbedListModule;
   import red.game.witcher3.slots.SlotBase;
   import red.game.witcher3.slots.SlotDragAvatar;
   import red.game.witcher3.slots.SlotInventoryGrid;
   import red.game.witcher3.slots.SlotSkillGrid;
   import red.game.witcher3.slots.SlotSkillMutagen;
   import red.game.witcher3.slots.SlotSkillSocket;
   import red.game.witcher3.slots.SlotsListGrid;
   import red.game.witcher3.slots.SlotsTransferManager;
   import red.game.witcher3.utils.CommonUtils;
   import scaleform.clik.constants.NavigationCode;
   import scaleform.clik.controls.Button;
   import scaleform.clik.core.UIComponent;
   import scaleform.clik.data.DataProvider;
   import scaleform.clik.events.ListEvent;
   import scaleform.clik.interfaces.IListItemRenderer;
   
   public class CharacterTabbedListModuleDupe extends CollapsableTabbedListModule implements IDropTarget
   {
      
      public static const TabIndex_Sword:int = 0;
      
      public static const TabIndex_Signs:int = 1;
      
      public static const TabIndex_Alchemy:int = 2;
      
      public static const TabIndex_Perks:int = 3;
      
      public static const TabIndex_Mutagens:int = 4;
      
      public var mcGridMask:MovieClip;
      
      public var mcMutagenSlotList:SlotsListGrid;
      
      public var txtSpentPoints:TextField;
      
      protected var mcNumSkillPoints:Array;
      
      protected var mcNumSkillsLearnt:Array;
      
      private var _disableMutagenEquipping:Boolean;
      
      private var _inputSymbolIDX:int = -1;
      
      private var _spectreInputSymbolIDR:int = -1;
      
      private var _spectreInputSymbolIDZ:int = -1;
      
      private var _pointsCount:int = 0;
      
      public var iconLock1:MovieClip;
      
      public var iconLock2:MovieClip;
      
      public var iconLock3:MovieClip;
      
      private var _buySkillBtnRef:Button = null;
      
      private var _dropEnabled:Boolean = true;
      
      private var _dropSelection:Boolean;
      
      public function CharacterTabbedListModuleDupe()
      {
         super();
         this.mcNumSkillPoints = new Array();
         this.mcNumSkillPoints.push(0);
         this.mcNumSkillPoints.push(0);
         this.mcNumSkillPoints.push(0);
         this.mcNumSkillPoints.push(0);
         this.mcNumSkillsLearnt = new Array();
         this.mcNumSkillsLearnt.push(0);
         this.mcNumSkillsLearnt.push(0);
         this.mcNumSkillsLearnt.push(0);
         this.mcNumSkillsLearnt.push(0);
         this.mcMutagenSlotList.dropEnabled = false;
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         setTabData(new DataProvider([{
            "icon":"Sword",
            "locKey":"[[panel_character_skill_sword]]"
         },{
            "icon":"Signs",
            "locKey":"[[panel_character_skill_signs]]"
         },{
            "icon":"Alchemy",
            "locKey":"[[panel_character_skill_alchemy]]"
         },{
            "icon":"Perks",
            "locKey":"[[skill_tree_name_survival]]"
         },{
            "icon":"Mutagens",
            "locKey":"[[panel_inventory_paperdoll_slotname_mutagen]]"
         }]));
         enableSelectTabWithTap(true);
         SlotsTransferManager.getInstance().addDropTarget(this);
         addToListContainer(this.mcMutagenSlotList);
         if(mcSkillModule)
         {
            mcSkillModule.focusable = false;
            mcSkillModule.addEventListener(ListEvent.INDEX_CHANGE,this.onSkillSelectionChanged,false,0,true);
         }
         if(this.mcMutagenSlotList)
         {
            this.mcMutagenSlotList.enableTouch(true);
            this.mcMutagenSlotList.enableScrollWithPan(true);
            this.mcMutagenSlotList.focusable = false;
            _inputHandlers.push(this.mcMutagenSlotList);
            this.mcMutagenSlotList.visible = false;
            this.mcMutagenSlotList.handleScrollBar = true;
            this.mcMutagenSlotList.ignoreGridPosition = true;
            this.mcMutagenSlotList.addEventListener(ListEvent.INDEX_CHANGE,this.onMutagenSelectionChanged,false,0,true);
         }
         if(mcSkillModule)
         {
            mcSkillModule.addEventListener(GestureEventEx.GESTURE_TAP,handleContainerTap,true,0,true);
         }
      }
      
      public function get pointsCount() : int
      {
         return this._pointsCount;
      }
      
      public function set pointsCount(value:int) : void
      {
         this._pointsCount = value;
      }
      
      public function set BuySkillBtnRef(value:Button) : void
      {
         this._buySkillBtnRef = value;
      }
      
      protected function setTextfieldsToDefault() : void
      {
         var renderer:AdvancedTabListItem = null;
         var format:TextFormat = null;
         var allRenderers:Vector.<IListItemRenderer> = mcTabList.getAllRenderers();
         var i:int = 0;
         while(i < allRenderers.length)
         {
            renderer = allRenderers[i] as AdvancedTabListItem;
            format = new TextFormat();
            format.color = 11179384;
            renderer.mcText.setTextFormat(format);
            i++;
         }
      }
      
      override protected function onTabListItemSelected(event:ListEvent) : void
      {
         super.onTabListItemSelected(event);
         this.setTextfieldsToDefault();
         this.updatePointsSpentTextField();
      }
      
      override protected function state_colapsed_begin() : void
      {
         super.state_colapsed_begin();
         this.updatePointsSpentTextField();
      }
      
      override protected function state_Open_begin() : void
      {
         super.state_Open_begin();
         this.updatePointsSpentTextField();
         if(mcTabList.selectedIndex != TabIndex_Mutagens)
         {
            mcSkillModule.onGetActive();
         }
      }
      
      protected function updatePointsSpentTextField() : void
      {
         var currentIndex:int = mcTabList.selectedIndex;
         if(currentIndex != TabIndex_Mutagens)
         {
            if(this.txtSpentPoints)
            {
               this.txtSpentPoints.visible = true;
               this.txtSpentPoints.text = "[[panel_character_points_spent]]";
               this.txtSpentPoints.appendText(": " + this.mcNumSkillPoints[currentIndex]);
               this.txtSpentPoints.text = CommonUtils.toUpperCaseSafe(this.txtSpentPoints.text);
            }
         }
         else if(this.txtSpentPoints)
         {
            this.txtSpentPoints.visible = false;
         }
         var renderer:AdvancedTabListItem = mcTabList.getRendererAt(currentIndex) as AdvancedTabListItem;
         var format:TextFormat = new TextFormat();
         format.color = 16777215;
         renderer.mcText.setTextFormat(format);
      }
      
      protected function onSkillSelectionChanged(event:ListEvent) : void
      {
         trace("CharacterTabbedListModuleDupe::onSkillSelectionChanged : ",event);
         this.mcGridMask.visible = false;
         mcListContainer.mask = null;
         updateInputFeedback();
      }
      
      protected function onMutagenSelectionChanged(event:ListEvent) : void
      {
         trace("CharacterTabbedListModuleDupe::onMutagenSelectionChanged : ",event);
         this.mcGridMask.visible = true;
         mcListContainer.mask = this.mcGridMask;
         updateInputFeedback();
      }
      
      override protected function updateInputFeedbackButtons() : void
      {
         var currentMutagen:SlotInventoryGrid = null;
         var currentSkill:SlotSkillGrid = null;
         var text:String = null;
         var isSwitchPlatform:Boolean = false;
         super.updateInputFeedbackButtons();
         trace("CharacterTabbedListModuleDupe::updateInputFeedbackButtons : ",isOpen,_hideInputFeedback,_inputSymbolIDA,this._inputSymbolIDX);
         if(this._buySkillBtnRef)
         {
            this._buySkillBtnRef.visible = false;
         }
         if(this._inputSymbolIDX != -1)
         {
            InputFeedbackManager.removeButton(this,this._inputSymbolIDX);
            this._inputSymbolIDX = -1;
         }
         if(this._spectreInputSymbolIDR != -1)
         {
            InputFeedbackManager.removeButton(this,this._spectreInputSymbolIDR);
            this._spectreInputSymbolIDR = -1;
         }
         if(this._spectreInputSymbolIDZ != -1)
         {
            InputFeedbackManager.removeButton(this,this._spectreInputSymbolIDZ);
            this._spectreInputSymbolIDZ = -1;
         }
         if(isOpen)
         {
            if(_inputSymbolIDA != -1)
            {
               InputFeedbackManager.removeButton(this,_inputSymbolIDA);
               _inputSymbolIDA = -1;
            }
            if(_hideInputFeedback)
            {
               return;
            }
            if(mcTabList.selectedIndex == TabIndex_Mutagens)
            {
               currentMutagen = this.mcMutagenSlotList.getSelectedRenderer() as SlotInventoryGrid;
               if(currentMutagen && currentMutagen.data && Boolean(focused) && !this.disableMutagenEquipping)
               {
                  _inputSymbolIDA = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_A,KeyCode.SPACE,"panel_character_skill_equip");
               }
            }
            else
            {
               currentSkill = mcSkillModule.getSelectedRenderer() as SlotSkillGrid;
               if(Boolean(currentSkill) && Boolean(currentSkill.data) && Boolean(focused))
               {
                  if((parent as MenuCharacterDupe).moduleSkillSlot.hasSkillSlotUnlocked() && currentSkill.data.level > 0 && !currentSkill.data.isCoreSkill)
                  {
                     _inputSymbolIDA = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_A,KeyCode.SPACE,"panel_character_skill_equip");
                  }
                  if(currentSkill.data.level < currentSkill.data.maxLevel && Boolean(currentSkill.data.updateAvailable) && this._pointsCount > 0)
                  {
                     text = currentSkill.data.level == 0 ? "panel_character_popup_title_buy_skill" : "panel_character_popup_title_upgrade_skill";
                     isSwitchPlatform = InputManager.getInstance().isSwitchPlatform();
                     this._inputSymbolIDX = InputFeedbackManager.appendButton(this,isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X,KeyCode.E,text,true,1);
                     if(!InputManager.getInstance().isGamepad())
                     {
                        this._spectreInputSymbolIDR = InputFeedbackManager.appendButton(this,"",KeyCode.R,"spectre_buy_max_rank",true,1);
                     }
                     if(this._buySkillBtnRef)
                     {
                        this._buySkillBtnRef.label = text;
                        this._buySkillBtnRef.enabled = true;
                        if(InputManager.getInstance().isMouse())
                        {
                           this._buySkillBtnRef.visible = true;
                        }
                     }
                  }
                  if(currentSkill.data.level > 0 && !currentSkill.data.isCoreSkill)
                  {
                     this._spectreInputSymbolIDZ = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_R3,KeyCode.Z,"spectre_reset_skill",true,1);
                  }
               }
            }
         }
      }
      
      override protected function handleControllerChange(event:ControllerChangeEvent) : void
      {
         super.handleControllerChange(event);
         if(this._buySkillBtnRef)
         {
            if(!event.isMouse)
            {
               this._buySkillBtnRef.visible = false;
            }
         }
      }
      
      override protected function updateSubData(index:int) : void
      {
         var i:int = 0;
         var currentSlot:SlotInventoryGrid = null;
         super.updateSubData(index);
         if(index == TabIndex_Mutagens)
         {
            i = 0;
            while(i < this.mcMutagenSlotList.getRenderersCount())
            {
               currentSlot = this.mcMutagenSlotList.getRendererAt(i) as SlotInventoryGrid;
               if(currentSlot)
               {
                  currentSlot.useContextMgr = false;
               }
               i++;
            }
         }
         this.updatePointsSpentTextField();
      }
      
      override protected function setSubData(index:int, data:Array) : void
      {
         var currentData:Object = null;
         var i:int = 0;
         super.setSubData(index,data);
         var tabItem:AdvancedTabListItem = mcTabList.getRendererAt(index) as AdvancedTabListItem;
         var numSkillPoints:int = 0;
         var numSkills:int = 0;
         if(index != TabIndex_Mutagens)
         {
            i = 0;
            while(i < data.length)
            {
               currentData = data[i];
               if(!currentData.isCoreSkill && currentData.level > 0)
               {
                  numSkills++;
                  numSkillPoints += currentData.level;
               }
               i++;
            }
            this.mcNumSkillPoints[index] = numSkillPoints;
            this.mcNumSkillsLearnt[index] = numSkills;
            if(lastUpdatedSubDataIndex == -1 || index == lastUpdatedSubDataIndex)
            {
               mcSkillModule.setCurrentTabIndex(index);
               mcSkillModule.setDataArray(data);
               mcSkillModule.enabled = true;
               lastUpdatedSubDataIndex = index;
               if(mcNewTabBackground)
               {
                  mcNewTabBackground.gotoAndStop(index + 1);
               }
            }
         }
         else if(lastUpdatedSubDataIndex == TabIndex_Mutagens)
         {
            mcSkillModule.clearObjects();
         }
         if(tabItem)
         {
            switch(index)
            {
               case TabIndex_Sword:
                  tabItem.setText(this.mcNumSkillsLearnt[TabIndex_Sword].toString());
                  break;
               case TabIndex_Signs:
                  tabItem.setText(this.mcNumSkillsLearnt[TabIndex_Signs].toString());
                  break;
               case TabIndex_Alchemy:
                  tabItem.setText(this.mcNumSkillsLearnt[TabIndex_Alchemy].toString());
                  break;
               case TabIndex_Perks:
                  tabItem.setText(this.mcNumSkillsLearnt[TabIndex_Perks].toString());
                  break;
               case TabIndex_Mutagens:
                  tabItem.setText(this.countMutagens(data).toString());
            }
         }
      }
      
      private function countMutagens(data:Array) : int
      {
         var i:* = undefined;
         var len:* = undefined;
         var sum:* = undefined;
         sum = 0;
         len = data.length;
         i = 0;
         while(i < len)
         {
            sum += data[i].quantity;
            i++;
         }
         return sum;
      }
      
      override protected function setAllowSelectionHighlight(allowed:Boolean) : void
      {
         var currentSlotItem:SlotBase = null;
         var i:int = 0;
         super.setAllowSelectionHighlight(allowed);
         if(mcSkillModule)
         {
            mcSkillModule.validateNow();
            mcSkillModule.setActiveSelectionEnabled(allowed);
         }
         if(this.mcMutagenSlotList)
         {
            this.mcMutagenSlotList.validateNow();
            i = 0;
            while(i < this.mcMutagenSlotList.getRenderersLength())
            {
               currentSlotItem = this.mcMutagenSlotList.getRendererAt(i) as SlotBase;
               if(currentSlotItem)
               {
                  currentSlotItem.activeSelectionEnabled = allowed;
               }
               i++;
            }
         }
      }
      
      override public function getDataShowerForTab(index:int) : UIComponent
      {
         if(index != TabIndex_Mutagens)
         {
            return mcSkillModule;
         }
         return this.mcMutagenSlotList;
      }
      
      public function get dropEnabled() : Boolean
      {
         return this._dropEnabled;
      }
      
      public function set dropEnabled(value:Boolean) : void
      {
         this._dropEnabled = value;
      }
      
      public function get dropSelection() : Boolean
      {
         return this._dropSelection;
      }
      
      public function set dropSelection(value:Boolean) : void
      {
         this._dropSelection = value;
      }
      
      public function get disableMutagenEquipping() : Boolean
      {
         return this._disableMutagenEquipping;
      }
      
      public function set disableMutagenEquipping(value:Boolean) : void
      {
         this._disableMutagenEquipping = value;
         this.updateInputFeedbackButtons();
      }
      
      public function canDrop(sourceObject:IDragTarget) : Boolean
      {
         var curObject:DisplayObject = sourceObject as DisplayObject;
         while(Boolean(curObject) && Boolean(curObject.parent))
         {
            if(this == curObject)
            {
               return false;
            }
            curObject = curObject.parent;
         }
         return true;
      }
      
      public function applyDrop(sourceObject:IDragTarget) : void
      {
         var mutagenSlot:SlotSkillMutagen = sourceObject as SlotSkillMutagen;
         var skillSlot:SlotSkillSocket = sourceObject as SlotSkillSocket;
         if(mutagenSlot)
         {
            if(parent is MenuCharacterDupe)
            {
               (parent as MenuCharacterDupe).changeHighlightSize(0.5);
               (parent as MenuCharacterDupe).moveHighlightOverMutagenSlot(mutagenSlot);
            }
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnUnequipMutagen",[mutagenSlot.slotType]));
         }
         else if(skillSlot)
         {
            if(parent is MenuCharacterDupe)
            {
               (parent as MenuCharacterDupe).changeHighlightSize(0.5);
               (parent as MenuCharacterDupe).moveHighlightOverSocket(skillSlot);
            }
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnUnequipSkill",[uint(skillSlot.getDragData().slotId)]));
         }
      }
      
      public function processOver(avatar:SlotDragAvatar) : int
      {
         var mutagenSlot:SlotSkillMutagen = null;
         var skillSlot:SlotSkillSocket = null;
         if(avatar)
         {
            mutagenSlot = avatar.getSourceContainer() as SlotSkillMutagen;
            skillSlot = avatar.getSourceContainer() as SlotSkillSocket;
            if(mutagenSlot)
            {
               if(currentlySelectedTabIndex != CharacterTabbedListModule.TabIndex_Mutagens)
               {
                  onSetTabCalled(CharacterTabbedListModule.TabIndex_Mutagens);
               }
            }
            else if(skillSlot)
            {
               if(skillSlot.data)
               {
                  onSetTabCalled(skillSlot.data.tabId);
               }
               else if(currentlySelectedTabIndex == CharacterTabbedListModule.TabIndex_Mutagens)
               {
                  onSetTabCalled(CharacterTabbedListModule.TabIndex_Sword);
               }
            }
         }
         return SlotDragAvatar.ACTION_GRID_DROP;
      }
      
      override protected function handleMouseMove(event:MouseEvent) : void
      {
         var target:MovieClip = event.target as MovieClip;
         var parented:Boolean = false;
         var obj:MovieClip = target;
         while(obj != null)
         {
            if(obj == this)
            {
               parented = true;
               break;
            }
            obj = obj.parent as MovieClip;
         }
         if((target is SlotBase || target && target.parent is SlotBase) && parented)
         {
            super.handleMouseMove(event);
         }
      }
   }
}


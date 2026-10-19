package red.game.witcher3.menus.character_menu
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import red.core.constants.KeyCode;
   import red.core.data.InputAxisData;
   import red.core.events.GameEvent;
   import red.core.events.GestureEventEx;
   import red.core.utils.InputUtils;
   import red.game.witcher3.interfaces.IBaseSlot;
   import red.game.witcher3.managers.InputFeedbackManager;
   import red.game.witcher3.slots.SlotBase;
   import red.game.witcher3.slots.SlotSkillGrid;
   import red.game.witcher3.utils.CommonUtils;
   import scaleform.clik.constants.InputValue;
   import scaleform.clik.constants.NavigationCode;
   import scaleform.clik.core.UIComponent;
   import scaleform.clik.data.DataProvider;
   import scaleform.clik.events.InputEvent;
   import scaleform.clik.events.ListEvent;
   import scaleform.clik.managers.FocusHandler;
   import scaleform.clik.ui.InputDetails;
   import scaleform.gfx.Extensions;
   import scaleform.gfx.FocusManager;
   
   public class CharacterSkillsGridModule extends UIComponent
   {
      
      public static const EVENT_SELECTED_SKILL_TAPPED:String = "EVENT_SELECTED_SKILL_TAPPED";
      
      private static const REF_SOCKET_WIDTH:Number = 64;
      
      private static const REF_SOCKET_HEIGHT:Number = 64;
      
      private static const REF_SOCKET_WIDTH_SELECTIONLESS:Number = 64;
      
      private static const REF_SOCKET_HEIGHT_SELECTIONLESS:Number = 64;
      
      public static const TabIndex_Sword:int = 0;
      
      public static const TabIndex_Signs:int = 1;
      
      public static const TabIndex_Alchemy:int = 2;
      
      public static const TabIndex_Perks:int = 3;
      
      public static const TabIndex_Mutagens:int = 4;
      
      protected static const MAGNITUDE_DEAD_ZONE:Number = 0.75;
      
      protected static const MAGNITUDE_DEC_DEAD_ZONE:Number = 0.1;
      
      protected static const MAGNITUDE_TIME_DELTA:Number = 0.5;
      
      protected static const MAGNITUDE_CHARGE:* = 15;
      
      private static const SKILL_OBJECT:String = "SlotSkillGridRef";
      
      private static const GRID_X_DIVIDE:Number = 3;
      
      private static const GRID_Y_DIVIDE:Number = 3;
      
      internal static const JOYSTICK_WAIT_TIME_MS:Number = 300;
      
      public var m_00topleftAnchor:MovieClip;
      
      public var m_spawnedSkills:Vector.<SlotSkillGrid>;
      
      public var m_dependencyLines:Vector.<DisplayObject>;
      
      public var m_gapX:int = 46;
      
      public var m_gapY:int = 8;
      
      public var m_scaleX:Number = 1;
      
      public var m_scaleY:Number = 1;
      
      private var selectedRendererIdx:int = -1;
      
      private var data:DataProvider;
      
      private var m_lineContainer:MovieClip;
      
      private var m_lastSelectedSkill:SlotSkillGrid;
      
      private var m_lastSelectedSkillName:String = "";
      
      private var prevMagnitude:Number = 0;
      
      private var posOverrideArray:Array;
      
      private var lineOverrideArray:Array;
      
      private var curTabIndex:int;
      
      public var allowSimpleNavDPad:Boolean = true;
      
      internal var lastJoystickTime:Number = 0;
      
      public function CharacterSkillsGridModule()
      {
         super();
         this.m_spawnedSkills = new Vector.<SlotSkillGrid>();
         this.m_dependencyLines = new Vector.<DisplayObject>();
         focusable = true;
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         this.m_lineContainer = new MovieClip();
         addChildAt(this.m_lineContainer,0);
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"on.skill.selected",[this.Hax_OnSkillSelectedUpdate]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"skill.tree.line.override",[this.onGotLineOverrideArray]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"skill.tree.pos.override",[this.onGotPosOverrideArray]));
         this.createDefaultLineOverrideArray();
         this.createDefaultPositionOverrideArray();
      }
      
      protected function createDefaultLineOverrideArray() : *
      {
         this.lineOverrideArray = [];
         this.lineOverrideArray.push({
            "main":"perk_30",
            "dep":"perk_38",
            "logic":"corMidHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_38",
            "dep":"perk_30",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_30",
            "dep":"perk_34",
            "logic":"corMidHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_34",
            "dep":"perk_30",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_43",
            "dep":"perk_34",
            "logic":"corMidHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_34",
            "dep":"perk_43",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_43",
            "dep":"perk_33",
            "logic":"corMidHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_33",
            "dep":"perk_43",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_35",
            "dep":"perk_31",
            "logic":"corMidHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_31",
            "dep":"perk_35",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_35",
            "dep":"perk_41",
            "logic":"corMidHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_41",
            "dep":"perk_35",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_37",
            "dep":"perk_41",
            "logic":"corMidHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_41",
            "dep":"perk_37",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_37",
            "dep":"perk_44",
            "logic":"corMidHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_44",
            "dep":"perk_37",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_31",
            "dep":"perk_26",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_31",
            "dep":"perk_25",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_41",
            "dep":"perk_25",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_41",
            "dep":"perk_24",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_44",
            "dep":"perk_24",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_44",
            "dep":"perk_27",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_38",
            "dep":"perk_26",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_38",
            "dep":"perk_25",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_34",
            "dep":"perk_25",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_34",
            "dep":"perk_24",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_33",
            "dep":"perk_24",
            "logic":"midCorHor"
         });
         this.lineOverrideArray.push({
            "main":"perk_33",
            "dep":"perk_27",
            "logic":"midCorHor"
         });
      }
      
      protected function createDefaultPositionOverrideArray() : *
      {
         this.posOverrideArray = [];
         this.posOverrideArray.push({
            "skill":"perk_31",
            "row":7.5
         });
         this.posOverrideArray.push({
            "skill":"perk_38",
            "row":7.5
         });
         this.posOverrideArray.push({
            "skill":"perk_41",
            "row":12.5
         });
         this.posOverrideArray.push({
            "skill":"perk_34",
            "row":12.5
         });
         this.posOverrideArray.push({
            "skill":"perk_44",
            "row":17.5
         });
         this.posOverrideArray.push({
            "skill":"perk_33",
            "row":17.5
         });
      }
      
      protected function onGotLineOverrideArray(dataArray:Array) : *
      {
         this.lineOverrideArray = dataArray;
      }
      
      protected function onGotPosOverrideArray(dataArray:Array) : *
      {
         this.posOverrideArray = dataArray;
      }
      
      protected function getLineOverride(mainName:String, depName:String) : String
      {
         var obj:Object = null;
         for(var i:int = 0; i < this.lineOverrideArray.length; i++)
         {
            obj = this.lineOverrideArray[i];
            if(obj.main == mainName && obj.dep == depName)
            {
               return obj.logic;
            }
         }
         return "0";
      }
      
      protected function Hax_OnSkillSelectedUpdate() : *
      {
         InputFeedbackManager.updateButtons(this);
      }
      
      public function clearObjects() : void
      {
         for(var i:* = int(this.m_dependencyLines.length - 1); i >= 0; i--)
         {
            this.m_lineContainer.removeChild(this.m_dependencyLines[i]);
         }
         for(i = int(this.m_spawnedSkills.length - 1); i >= 0; i--)
         {
            this.m_spawnedSkills[i].onDie();
            removeChild(this.m_spawnedSkills[i]);
         }
         this.m_dependencyLines.length = 0;
         this.m_spawnedSkills.length = 0;
      }
      
      public function getDependentSkillObject(name:String) : SlotSkillGrid
      {
         var l_Data:Object = null;
         for(var i:int = 0; i < this.m_spawnedSkills.length; i++)
         {
            l_Data = this.m_spawnedSkills[i].data;
            if(l_Data.abilityName == name)
            {
               return this.m_spawnedSkills[i];
            }
         }
         return null;
      }
      
      public function spawnLineBetweenPoints(aX:Number, aY:Number, bX:Number, bY:Number, color:uint) : void
      {
         var thickness:Number = 1;
         var line:Shape = new Shape();
         this.m_lineContainer.addChild(line);
         line.graphics.lineStyle(thickness,color);
         line.graphics.moveTo(aX,aY);
         line.graphics.lineTo(bX,bY);
         this.m_dependencyLines.push(line);
      }
      
      public function spawnLineBetweenObjects(main:SlotSkillGrid, dep:SlotSkillGrid, logic:String = "0") : void
      {
         var aX:Number = NaN;
         var aY:Number = NaN;
         var bX:Number = NaN;
         var bY:Number = NaN;
         var diffX:Number = main.x - dep.x;
         var diffY:Number = main.y - dep.y;
         var pX:Number = 0;
         var pY:Number = 0;
         var depMidX:* = dep.x + REF_SOCKET_WIDTH_SELECTIONLESS / 2;
         var depMidY:* = dep.y + REF_SOCKET_HEIGHT_SELECTIONLESS / 2;
         var mainMidX:* = main.x + REF_SOCKET_WIDTH_SELECTIONLESS / 2;
         var mainMidY:* = main.y + REF_SOCKET_HEIGHT_SELECTIONLESS / 2;
         aX = mainMidX;
         aY = mainMidY;
         bX = depMidX;
         bY = depMidY;
         if(logic == "0")
         {
            if(diffX != 0)
            {
               bX = depMidX + REF_SOCKET_WIDTH_SELECTIONLESS / 2 * diffX / Math.abs(diffX);
               aX = mainMidX - REF_SOCKET_WIDTH_SELECTIONLESS / 2 * diffX / Math.abs(diffX);
            }
            if(diffY != 0)
            {
               bY = depMidY + REF_SOCKET_HEIGHT_SELECTIONLESS / 2 * diffY / Math.abs(diffY);
               aY = mainMidY - REF_SOCKET_HEIGHT_SELECTIONLESS / 2 * diffY / Math.abs(diffY);
            }
         }
         else if(logic == "corMidHor")
         {
            if(diffX != 0)
            {
               bX = depMidX + REF_SOCKET_WIDTH_SELECTIONLESS / 2 * diffX / Math.abs(diffX);
               aX = mainMidX - REF_SOCKET_WIDTH_SELECTIONLESS / 2 * diffX / Math.abs(diffX);
            }
            if(diffY != 0)
            {
               aY = mainMidY - REF_SOCKET_HEIGHT_SELECTIONLESS / 2 * diffY / Math.abs(diffY);
            }
         }
         if(logic == "midCorHor")
         {
            if(diffX != 0)
            {
               bX = depMidX + REF_SOCKET_WIDTH_SELECTIONLESS / 2 * diffX / Math.abs(diffX);
               aX = mainMidX - REF_SOCKET_WIDTH_SELECTIONLESS / 2 * diffX / Math.abs(diffX);
            }
            if(diffY != 0)
            {
               bY = depMidY + REF_SOCKET_HEIGHT_SELECTIONLESS / 2 * diffY / Math.abs(diffY);
            }
         }
         var depAvailable:Boolean = true;
         if(Boolean(dep.data.hasOwnProperty("isUsingSkillDependency")) && Boolean(dep.data.isUsingSkillDependency))
         {
            depAvailable = dep.data.level > 0;
         }
         var color:uint = depAvailable ? uint(4294967295) : uint(4281545523);
         if(main.data.level > 0 && dep.data.level > 0)
         {
            switch(main.data.color)
            {
               case "SC_Red":
                  color = 4291166208;
                  break;
               case "SC_Green":
                  color = 4283076608;
                  break;
               case "SC_Blue":
                  color = 4278208966;
                  break;
               case "SC_Yellow":
                  color = 4289884416;
            }
         }
         var dX:Number = bX - aX;
         var dY:Number = bY - aY;
         var len:Number = Math.sqrt(dX * dX + dY * dY);
         pX = -dY / len;
         pY = dX / len;
         var d:Number = 3;
         var oX:Number = pX * d / 2;
         var oY:Number = pY * d / 2;
         this.spawnLineBetweenPoints(aX - oX,aY - oY,bX - oX,bY - oY,color);
         this.spawnLineBetweenPoints(aX + oX,aY + oY,bX + oX,bY + oY,color);
      }
      
      public function spawnDependenciesLines(data:Object) : void
      {
         var sdr:Object = null;
         var dep:SlotSkillGrid = null;
         var logic:String = null;
         if(!data.hasOwnProperty("abilityName"))
         {
            return;
         }
         var main:SlotSkillGrid = this.getDependentSkillObject(data.abilityName);
         if(!main)
         {
            return;
         }
         for(var j:int = 0; j < data.skillDependencyRequirements.length; j++)
         {
            sdr = data.skillDependencyRequirements[j];
            if(sdr.hasOwnProperty("name"))
            {
               dep = this.getDependentSkillObject(sdr.name);
               logic = this.getLineOverride(data.abilityName,dep.data.abilityName);
               if(dep)
               {
                  this.spawnLineBetweenObjects(main,dep,logic);
               }
            }
         }
      }
      
      public function spawnDependenciesLinesForEach(dataArray:Array) : void
      {
         for(var i:int = 0; i < dataArray.length; i++)
         {
            this.spawnDependenciesLines(dataArray[i]);
         }
      }
      
      public function isDataForTheSameItems(dataArray:Array) : Boolean
      {
         var socket:SlotSkillGrid = null;
         if(dataArray.length != this.m_spawnedSkills.length)
         {
            return false;
         }
         for(var i:int = 0; i < dataArray.length; i++)
         {
            socket = this.m_spawnedSkills[i];
            if(socket.data.iconPath != dataArray[i].iconPath)
            {
               return false;
            }
         }
         return true;
      }
      
      public function updateDataArray(dataArray:Array) : void
      {
         var socket:SlotSkillGrid = null;
         var data:Object = null;
         for(var i:* = 0; i < dataArray.length; i++)
         {
            socket = this.m_spawnedSkills[i];
            data = dataArray[i];
            socket.data = data;
            socket.validateNow();
            socket.updateIconAlpha();
         }
         for(i = int(this.m_dependencyLines.length - 1); i >= 0; i--)
         {
            this.m_lineContainer.removeChild(this.m_dependencyLines[i]);
         }
         this.m_dependencyLines.length = 0;
         this.spawnDependenciesLinesForEach(dataArray);
         data = dataArray;
      }
      
      public function replacePositionsInDataArray(dataArray:Array) : Array
      {
         var j:int = 0;
         var obj:Object = null;
         for(var i:int = 0; i < dataArray.length; i++)
         {
            for(j = 0; j < this.posOverrideArray.length; j++)
            {
               obj = this.posOverrideArray[j];
               if(dataArray[i].abilityName == obj.skill)
               {
                  if(obj.hasOwnProperty("row"))
                  {
                     dataArray[i].gridRow = obj.row;
                  }
                  if(obj.hasOwnProperty("column"))
                  {
                     dataArray[i].gridColumn = obj.column;
                  }
               }
            }
         }
         return dataArray;
      }
      
      public function setCurrentTabIndex(index:int) : void
      {
         this.curTabIndex = index;
      }
      
      public function setDataArray(dataArray:Array) : void
      {
         var data:Object = null;
         var socket:SlotSkillGrid = null;
         var gridX:Number = NaN;
         var gridY:Number = NaN;
         if(this.isDataForTheSameItems(dataArray))
         {
            this.updateDataArray(dataArray);
            return;
         }
         this.clearObjects();
         dataArray = this.replacePositionsInDataArray(dataArray);
         var socketClass:Class = getDefinitionByName(SKILL_OBJECT) as Class;
         var oldSkillFound:Boolean = false;
         for(var i:int = 0; i < dataArray.length; i++)
         {
            data = dataArray[i];
            socket = new socketClass() as SlotSkillGrid;
            gridX = 0;
            gridY = i;
            if(data.hasOwnProperty("gridRow"))
            {
               gridX = Number(data.gridColumn);
            }
            if(data.hasOwnProperty("gridColumn"))
            {
               gridY = Number(data.gridRow);
            }
            addChild(socket);
            socket.owner = this;
            socket.x = (REF_SOCKET_WIDTH + this.m_gapX) * gridX / GRID_X_DIVIDE;
            socket.y = (REF_SOCKET_HEIGHT + this.m_gapY) * gridY / GRID_Y_DIVIDE;
            socket.data = data;
            socket.addEventListener(MouseEvent.MOUSE_DOWN,this.onRendererClicked,true,100000,true);
            socket.addEventListener(GestureEventEx.GESTURE_TAP,this.onRendererTapped,false,0,true);
            this.m_spawnedSkills.push(socket);
            if(socket.data.abilityName == this.m_lastSelectedSkillName)
            {
               this.setSelectedRenderer(socket);
               oldSkillFound = true;
            }
         }
         if(!oldSkillFound)
         {
            this.m_lastSelectedSkillName = "";
            this.m_lastSelectedSkill = null;
         }
         this.spawnDependenciesLinesForEach(dataArray);
         data = dataArray;
      }
      
      override public function set focused(value:Number) : void
      {
         if(value == _focused || !_focusable)
         {
            return;
         }
         _focused = value;
         if(value)
         {
            this.setSelectedRenderer(this.getSelectedRenderer() as SlotSkillGrid);
         }
         if(Extensions.isScaleform)
         {
            if(_focused > 0)
            {
               FocusManager.setFocus(this,0);
               FocusHandler.getInstance().setFocus(this);
               if(Boolean(this.getSelectedRenderer()) && enabled)
               {
                  (this.getSelectedRenderer() as SlotBase).showTooltip();
               }
            }
         }
         else if(stage != null && _focused > 0)
         {
            stage.focus = this;
         }
      }
      
      private function setSelectedRenderer(socket:SlotSkillGrid) : void
      {
         var curRenderer:SlotSkillGrid = null;
         trace("CharacterSkillsGridModule::setSelectedRenderer : ",socket,socket.data,socket.data.hasOwnProperty("id"));
         if(Boolean(socket) && Boolean(socket.data))
         {
            if(socket.data.hasOwnProperty("id"))
            {
               curRenderer = this.getSelectedRenderer();
               if(curRenderer)
               {
                  curRenderer.selected = false;
               }
               this.selectedRendererIdx = socket.data.id;
               socket.selected = true;
               this.m_lastSelectedSkill = socket;
               this.m_lastSelectedSkillName = socket.data.abilityName;
               trace("CharacterSkillsGridModule::setSelectedRenderer - DISPATCH ");
               dispatchEvent(new GameEvent(GameEvent.CALL,"OnSetSelectedRenderer",[socket.data.id]));
               dispatchEvent(new ListEvent(ListEvent.INDEX_CHANGE,true,false,socket.data.id,-1,-1,socket,this.data));
            }
         }
      }
      
      public function getSelectedRenderer() : SlotSkillGrid
      {
         var socket:SlotSkillGrid = null;
         for(var i:int = 0; i < this.m_spawnedSkills.length; i++)
         {
            socket = this.m_spawnedSkills[i];
            if(Boolean(socket) && Boolean(socket.data) && Boolean(socket.data.hasOwnProperty("id")) && socket.data.id == this.selectedRendererIdx)
            {
               return socket;
            }
         }
         return null;
      }
      
      private function onRendererTapped(event:Event) : void
      {
         var currentTapped:SlotSkillGrid = event.currentTarget as SlotSkillGrid;
         var currentSelected:IBaseSlot = this.getSelectedRenderer() as IBaseSlot;
         var tapTwiceEvent:Event = null;
         trace("CharacterSkillsGridModule::onRendererTapped : ",currentTapped,currentSelected);
         if(currentSelected != null)
         {
            tapTwiceEvent = new Event(EVENT_SELECTED_SKILL_TAPPED);
            dispatchEvent(tapTwiceEvent);
            trace("CharacterSkillsGridModule::onRendererTapped ---------- TWICE: ");
         }
         if(currentTapped)
         {
            this.setSelectedRenderer(currentTapped);
            this.dispatchItemClickEvent(currentTapped);
            this.focused = 1;
            stage.focus = this;
         }
      }
      
      private function onRendererClicked(event:Event) : void
      {
         var socket:SlotSkillGrid = event.currentTarget as SlotSkillGrid;
         if(socket)
         {
            this.setSelectedRenderer(socket);
            this.dispatchItemClickEvent(socket);
            this.focused = 1;
            stage.focus = this;
         }
      }
      
      public function dispatchItemClickEvent(targetRenderer:IBaseSlot) : void
      {
         if(focused < 1)
         {
            this.focused = 1;
         }
         var clickEvent:ListEvent = new ListEvent(ListEvent.ITEM_CLICK,true);
         clickEvent.itemData = targetRenderer.data as Object;
         clickEvent.index = targetRenderer.index;
         clickEvent.itemRenderer = targetRenderer;
         dispatchEvent(clickEvent);
      }
      
      override public function set enabled(value:Boolean) : void
      {
         var len:int = int(this.m_spawnedSkills.length);
         for(var i:int = 0; i < len; i++)
         {
            this.m_spawnedSkills[i].enabled = value;
         }
         super.enabled = value;
      }
      
      private function canGoUp(current:SlotSkillGrid) : *
      {
         if(!current)
         {
            return true;
         }
         for(var i:int = 0; i < this.m_spawnedSkills.length; i++)
         {
            if(this.m_spawnedSkills[i].data.gridRow < current.data.gridRow)
            {
               return true;
            }
         }
         return false;
      }
      
      private function canGoDown(current:SlotSkillGrid) : *
      {
         if(!current)
         {
            return true;
         }
         for(var i:int = 0; i < this.m_spawnedSkills.length; i++)
         {
            if(this.m_spawnedSkills[i].data.gridRow > current.data.gridRow)
            {
               return true;
            }
         }
         return false;
      }
      
      private function canGoLeft(current:SlotSkillGrid) : *
      {
         if(!current)
         {
            return true;
         }
         for(var i:int = 0; i < this.m_spawnedSkills.length; i++)
         {
            if(this.m_spawnedSkills[i].data.gridColumn < current.data.gridColumn)
            {
               return true;
            }
         }
         return false;
      }
      
      private function canGoRight(current:SlotSkillGrid) : *
      {
         if(!current)
         {
            return true;
         }
         for(var i:int = 0; i < this.m_spawnedSkills.length; i++)
         {
            if(this.m_spawnedSkills[i].data.gridColumn > current.data.gridColumn)
            {
               return true;
            }
         }
         return false;
      }
      
      private function angleDelta(a:Number, b:Number) : Number
      {
         var d:Number = Math.abs(a - b);
         if(d > Math.PI)
         {
            d = 2 * Math.PI - d;
         }
         return d;
      }
      
      private function getGeneralAngle(_from:SlotSkillGrid, _to:SlotSkillGrid) : Number
      {
         var ea:Object = _from.data;
         var eb:Object = _to.data;
         var ax:Number = Number(ea.gridColumn);
         var ay:Number = Number(ea.gridRow);
         var bx:Number = Number(eb.gridColumn);
         var by:Number = Number(eb.gridRow);
         var dx:Number = bx - ax;
         var dy:Number = by - ay;
         if(dx > 0 && Math.abs(dy) < 0.001)
         {
            return 0;
         }
         if(dx > 0 && dy > 0)
         {
            return Math.PI / 4;
         }
         if(Math.abs(dx) < 0.001 && dy > 0)
         {
            return Math.PI / 2;
         }
         if(dx < 0 && dy > 0)
         {
            return 3 * Math.PI / 4;
         }
         if(dx < 0 && Math.abs(dy) < 0.001)
         {
            return Math.PI;
         }
         if(dx < 0 && dy < 0)
         {
            return -3 * Math.PI / 4;
         }
         if(Math.abs(dx) < 0.001 && dy < 0)
         {
            return -Math.PI / 2;
         }
         if(dx > 0 && dy < 0)
         {
            return -Math.PI / 4;
         }
         return 0;
      }
      
      protected function getRendererByAbilityName(abilityName:String) : SlotSkillGrid
      {
         for(var i:int = 0; i < this.m_spawnedSkills.length; i++)
         {
            if(this.m_spawnedSkills[i].data.abilityName == abilityName)
            {
               return this.m_spawnedSkills[i];
            }
         }
         return null;
      }
      
      protected function doSurvivalTabOverrideNavigation(event:InputEvent) : Boolean
      {
         var target:SlotSkillGrid = null;
         var current:SlotSkillGrid = this.getSelectedRenderer();
         if(current.data.abilityName == "perk_23")
         {
            if(event.details.navEquivalent == NavigationCode.LEFT)
            {
               target = this.getRendererByAbilityName("perk_40");
               if(target)
               {
                  this.setSelectedRenderer(target);
                  event.handled = true;
                  return true;
               }
            }
            else if(event.details.navEquivalent == NavigationCode.RIGHT)
            {
               target = this.getRendererByAbilityName("perk_42");
               if(target)
               {
                  this.setSelectedRenderer(target);
                  event.handled = true;
                  return true;
               }
            }
         }
         if(current.data.abilityName == "perk_28")
         {
            if(event.details.navEquivalent == NavigationCode.LEFT)
            {
               target = this.getRendererByAbilityName("perk_39");
               if(target)
               {
                  this.setSelectedRenderer(target);
                  event.handled = true;
                  return true;
               }
            }
            else if(event.details.navEquivalent == NavigationCode.RIGHT)
            {
               target = this.getRendererByAbilityName("perk_32");
               if(target)
               {
                  this.setSelectedRenderer(target);
                  event.handled = true;
                  return true;
               }
            }
         }
         return false;
      }
      
      public function navigateBasedOnDirection(direction:Number, event:InputEvent) : *
      {
         var indexes:Vector.<int>;
         var i:int;
         var currentRow:Number = NaN;
         var currentColumn:Number = NaN;
         var current:SlotSkillGrid = null;
         var obj:Object = null;
         var x:Number = NaN;
         var y:Number = NaN;
         var distSquared:Number = NaN;
         var angle:Number = NaN;
         var delta:Number = NaN;
         var bestIndex:int = 0;
         var maxDistance:Number = 3;
         currentRow = -1;
         currentColumn = -1;
         current = this.getSelectedRenderer();
         if(current)
         {
            currentRow = current.data.gridRow / GRID_Y_DIVIDE;
            currentColumn = current.data.gridColumn / GRID_X_DIVIDE;
         }
         else if(this.m_spawnedSkills.length > 0)
         {
            current = this.m_spawnedSkills[0];
         }
         indexes = new Vector.<int>();
         for(i = 0; i < this.m_spawnedSkills.length; i++)
         {
            if(current != this.m_spawnedSkills[i])
            {
               obj = this.m_spawnedSkills[i].data;
               x = obj.gridColumn / GRID_X_DIVIDE - currentColumn;
               y = obj.gridRow / GRID_Y_DIVIDE - currentRow;
               if(!(this.curTabIndex == TabIndex_Perks && x * x > 1))
               {
                  distSquared = x * x + y * y;
                  if(distSquared <= maxDistance * maxDistance)
                  {
                     angle = Math.atan2(y,x);
                     delta = this.angleDelta(angle,direction);
                     if(delta < Math.PI / 3)
                     {
                        indexes.push(i);
                     }
                  }
               }
            }
         }
         if(indexes.length > 0)
         {
            if(indexes.length > 1)
            {
               indexes.sort(function(a:int, b:int):Number
               {
                  var ea:SlotSkillGrid = m_spawnedSkills[a];
                  var eb:SlotSkillGrid = m_spawnedSkills[b];
                  var ax:Number = ea.data.gridColumn / GRID_X_DIVIDE - currentColumn;
                  var ay:Number = ea.data.gridRow / GRID_Y_DIVIDE - currentRow;
                  var bx:Number = eb.data.gridColumn / GRID_X_DIVIDE - currentColumn;
                  var by:Number = eb.data.gridRow / GRID_Y_DIVIDE - currentRow;
                  var distA:Number = ax * ax + ay * ay;
                  var distB:Number = bx * bx + by * by;
                  var angleA:Number = getGeneralAngle(current,ea);
                  var angleB:Number = getGeneralAngle(current,eb);
                  var deltaA:Number = angleDelta(angleA,direction);
                  var deltaB:Number = angleDelta(angleB,direction);
                  if(deltaA == deltaB)
                  {
                     return distA - distB;
                  }
                  return deltaA - deltaB;
               });
            }
            bestIndex = indexes[0];
            this.setSelectedRenderer(this.m_spawnedSkills[bestIndex]);
            event.handled = true;
         }
      }
      
      private function canDoJoystickAction() : Boolean
      {
         var now:Number = new Date().time;
         return now - this.lastJoystickTime > JOYSTICK_WAIT_TIME_MS;
      }
      
      private function updateJoystickTimer() : void
      {
         var now:Number = new Date().time;
         this.lastJoystickTime = now;
      }
      
      public function handleInputNavSimple(event:InputEvent) : void
      {
         var axisData:InputAxisData = null;
         var magnitude:Number = NaN;
         var curRenderer:SlotBase = null;
         if(event.handled)
         {
            return;
         }
         var details:InputDetails = event.details;
         CommonUtils.fixupKeyCode(details);
         var keyPress:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD;
         CommonUtils.convertWASDCodeToNavEquivalent(details);
         var navCommand:String = details.fromJoystick || this.allowSimpleNavDPad ? details.navEquivalent : NavigationCode.INVALID;
         if(!this.allowSimpleNavDPad)
         {
            switch(details.code)
            {
               case KeyCode.W:
               case KeyCode.UP:
                  navCommand = NavigationCode.UP;
                  break;
               case KeyCode.S:
               case KeyCode.DOWN:
                  navCommand = NavigationCode.DOWN;
                  break;
               case KeyCode.A:
               case KeyCode.LEFT:
                  navCommand = NavigationCode.LEFT;
                  break;
               case KeyCode.D:
               case KeyCode.RIGHT:
                  navCommand = NavigationCode.RIGHT;
            }
         }
         var current:SlotSkillGrid = this.getSelectedRenderer();
         var direction:Number = 0;
         if(details.code == KeyCode.PAD_LEFT_STICK_AXIS)
         {
            axisData = InputAxisData(details.value);
            magnitude = InputUtils.getMagnitude(axisData.xvalue,axisData.yvalue);
            this.prevMagnitude = magnitude;
            if(magnitude < MAGNITUDE_DEAD_ZONE)
            {
               return;
            }
            if(this.prevMagnitude > magnitude && Math.abs(this.prevMagnitude - magnitude) > 0.0005)
            {
               return;
            }
            if(this.canDoJoystickAction())
            {
               direction = Math.atan2(-axisData.yvalue,axisData.xvalue);
               this.navigateBasedOnDirection(direction,event);
               if(event.handled)
               {
                  this.updateJoystickTimer();
               }
            }
         }
         else if(keyPress && details.fromJoystick == false && (Boolean(navCommand == NavigationCode.UP) && Boolean(this.canGoUp(current)) || Boolean(navCommand == NavigationCode.DOWN) && Boolean(this.canGoDown(current)) || Boolean(navCommand == NavigationCode.LEFT) && Boolean(this.canGoLeft(current)) || Boolean(navCommand == NavigationCode.RIGHT) && Boolean(this.canGoRight(current))))
         {
            switch(navCommand)
            {
               case NavigationCode.RIGHT:
                  direction = 0;
                  break;
               case NavigationCode.DOWN:
                  direction = Math.PI / 2;
                  break;
               case NavigationCode.LEFT:
                  direction = Math.PI;
                  break;
               case NavigationCode.UP:
                  direction = -Math.PI / 2;
            }
            if(this.curTabIndex == TabIndex_Perks)
            {
               this.doSurvivalTabOverrideNavigation(event);
            }
            if(!event.handled)
            {
               this.navigateBasedOnDirection(direction,event);
            }
         }
         else if(keyPress && details.fromJoystick == false && (navCommand == NavigationCode.LEFT && !this.canGoLeft(current)))
         {
            event.handled = true;
         }
         if((keyPress || details.code == KeyCode.PAD_LEFT_STICK_AXIS) && !event.handled && (navCommand == NavigationCode.UP || navCommand == NavigationCode.RIGHT || details.code == KeyCode.PAD_LEFT_STICK_AXIS))
         {
            if(Boolean(current) && (details.code == KeyCode.PAD_LEFT_STICK_AXIS && details.fromJoystick && this.canDoJoystickAction() || !details.fromJoystick))
            {
               this.m_lastSelectedSkill = current as SlotSkillGrid;
               this.m_lastSelectedSkillName = (current as SlotSkillGrid).data.abilityName;
               current.selected = false;
               this.selectedRendererIdx = -1;
               this.updateJoystickTimer();
            }
            else if(current)
            {
               event.handled = true;
            }
         }
         if(!event.handled)
         {
            if(!this.getSelectedRenderer())
            {
               return;
            }
            curRenderer = this.getSelectedRenderer() as SlotBase;
            if(Boolean(curRenderer) && !curRenderer.isEmpty())
            {
               curRenderer.executeAction(details.code,event);
            }
         }
      }
      
      public function setActiveSelectionEnabled(allowed:Boolean) : void
      {
         var currentSlotItem:SlotBase = null;
         for(var i:int = 0; i < this.m_spawnedSkills.length; i++)
         {
            currentSlotItem = this.m_spawnedSkills[i] as SlotBase;
            if(currentSlotItem)
            {
               currentSlotItem.activeSelectionEnabled = allowed;
            }
         }
         if(allowed)
         {
            this.selectDefault();
            this.updateJoystickTimer();
         }
      }
      
      public function onGetActive() : void
      {
         this.selectDefault();
      }
      
      private function selectDefault() : void
      {
         var closestIndex:int = 0;
         var closestDiff:int = 0;
         var i:int = 0;
         var x:* = undefined;
         var y:* = undefined;
         var diff:* = undefined;
         if(this.m_lastSelectedSkill)
         {
            this.setSelectedRenderer(this.m_lastSelectedSkill);
         }
         else
         {
            closestIndex = -1;
            closestDiff = 0;
            for(i = 0; i < this.m_spawnedSkills.length; i++)
            {
               x = this.m_spawnedSkills[i].data.gridColumn;
               y = this.m_spawnedSkills[i].data.gridRow * 2;
               diff = x * x + y * y;
               if(closestIndex == -1 || diff < closestDiff)
               {
                  closestIndex = i;
                  closestDiff = diff;
               }
            }
            if(closestIndex != -1)
            {
               this.setSelectedRenderer(this.m_spawnedSkills[closestIndex]);
            }
         }
      }
   }
}


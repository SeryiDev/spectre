package red.game.witcher3.tooltips
{
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import red.core.CoreComponent;
   import red.game.witcher3.constants.CommonConstants;
   import red.game.witcher3.constants.PlatformType;
   import red.game.witcher3.interfaces.IAnchorable;
   import red.game.witcher3.managers.InputManager;
   import red.game.witcher3.utils.CommonUtils;
   
   public class TooltipSkill extends TooltipBase implements IAnchorable
   {
      
      private static const TEXT_PADDING:Number = 5;
      
      private static const TEXT_BIG_PADDING:Number = 15;
      
      private static const BLOCK_PADDING:Number = 8;
      
      public var mcBackground:MovieClip;
      
      public var mcHeaderBackground:MovieClip;
      
      public var mcShadow:MovieClip;
      
      public var tfSkillName:TextField;
      
      public var tfSkillLevel:TextField;
      
      public var tfCurrentLevelDescription:TextField;
      
      public var tfNextLevelDescription:TextField;
      
      public var txfRequiredPoints:TextField;
      
      public var tfType:TextField;
      
      private var _textValue:String;
      
      public function TooltipSkill()
      {
         super();
         visible = false;
         this.tfSkillName.text = "";
         this.tfSkillLevel.text = "";
         this.tfCurrentLevelDescription.text = "";
         this.tfNextLevelDescription.text = "";
      }
      
      override protected function populateData() : void
      {
         var _loc1_:String = null;
         super.populateData();
         if(!data)
         {
            return;
         }
         this._textValue = _data.skillName;
         this.tfSkillName.htmlText = CommonUtils.toUpperCaseSafe(this._textValue);
         if(CoreComponent.isArabicAligmentMode)
         {
            this.tfSkillName.htmlText = "<p align=\"right\">" + this._textValue + "</p>";
         }
         if(Boolean(_data.skillSubCategory) && _data.skillSubCategory != "")
         {
            this._textValue = _data.skillSubCategory;
            this.tfType.htmlText = CommonUtils.toUpperCaseSafe(this._textValue);
            if(CoreComponent.isArabicAligmentMode)
            {
               this.tfType.htmlText = "<p align=\"left\">" + this._textValue + "</p>";
            }
            this.tfType.visible = true;
         }
         else
         {
            this.tfType.visible = false;
         }
         if(_data.isCoreSkill)
         {
            this._textValue = _data.skillLevelString;
            this.tfSkillLevel.htmlText = this._textValue;
            this.tfSkillLevel.visible = true;
         }
         else if(_data.skillLevelString != "")
         {
            this.tfSkillLevel.htmlText = "[[panel_character_tooltip_skills_level]]";
            this.tfSkillLevel.htmlText = CommonUtils.toUpperCaseSafe(this.tfSkillLevel.htmlText);
            this.tfSkillLevel.htmlText += "<font color = \'#FFFFFF\'>" + _data.skillLevelString + "</font>";
            this.tfSkillLevel.width = this.tfSkillLevel.textWidth + CommonConstants.SAFE_TEXT_PADDING;
            this.tfSkillLevel.visible = true;
         }
         else
         {
            this.tfSkillLevel.text = "";
            this.tfSkillLevel.visible = false;
         }
         _loc1_ = "#FFFFFF";
         if(_data.level < _data.maxLevel)
         {
            if(!_data.hasEnoughPoints)
            {
               _loc1_ = "#EE0404";
            }
            else if(_data.curSkillPoints > 0)
            {
               _loc1_ = "#93FF93";
            }
         }
         if(_data.requiredPointsSpent >= 0)
         {
            this.txfRequiredPoints.htmlText = "[[panel_character_tooltip_skills_req_points]]";
            this._textValue = this.txfRequiredPoints.htmlText;
            this._textValue = this._textValue + " " + _data.requiredPointsSpent;
            this.txfRequiredPoints.htmlText = this._textValue;
            this._textValue = this.txfRequiredPoints.htmlText;
            this.txfRequiredPoints.visible = true;
         }
         else
         {
            this.txfRequiredPoints.text = "";
            this.txfRequiredPoints.visible = false;
         }
         var _loc2_:Number = 85;
         var _loc3_:Number = _loc2_;
         if(_data.currentLevelDescription)
         {
            this.tfCurrentLevelDescription.y = _loc3_;
            this._textValue = _data.currentLevelDescription;
            // Spectre: the description is aligned left (right in Arabic) instead of centered.
            this.tfCurrentLevelDescription.htmlText = "<p align=\"left\">" + this._textValue + "</p>";
            if(CoreComponent.isArabicAligmentMode)
            {
               this.tfCurrentLevelDescription.htmlText = "<p align=\"right\">" + this._textValue + "</p>";
            }
            this.tfCurrentLevelDescription.height = this.tfCurrentLevelDescription.textHeight + CommonConstants.SAFE_TEXT_PADDING;
            _loc3_ += this.tfCurrentLevelDescription.height + TEXT_PADDING;
         }
         if(_data.nextLevelDescription)
         {
            this.tfNextLevelDescription.y = _loc3_;
            this._textValue = _data.nextLevelDescription;
            // Spectre: the description is aligned left (right in Arabic) instead of centered.
            this.tfNextLevelDescription.htmlText = "<p align=\"left\">" + this._textValue + "</p>";
            if(CoreComponent.isArabicAligmentMode)
            {
               this.tfNextLevelDescription.htmlText = "<p align=\"right\">" + this._textValue + "</p>";
            }
            this.tfNextLevelDescription.height = this.tfNextLevelDescription.textHeight + CommonConstants.SAFE_TEXT_PADDING;
            _loc3_ += this.tfNextLevelDescription.height + TEXT_PADDING;
         }
         this.mcBackground.gotoAndStop("solid");
         this.mcShadow.height = this.mcBackground.height = _loc3_;
         visible = true;
      }
      
      override protected function updatePosition() : void
      {
         var _loc1_:Point = new Point();
         if(_anchorRect)
         {
            this.x = _anchorRect.x + _anchorRect.width;
            this.y = _anchorRect.y + _anchorRect.height;
            _loc1_.x = this.x;
            _loc1_.y = this.y;
         }
         var _loc2_:Rectangle = this.mcBackground.getRect(parent);
         var _loc3_:Number = 1080;
         var _loc4_:Number = 1920;
         var _loc5_:Number = _loc2_.y + _loc2_.height;
         var _loc6_:Number = _loc2_.x + _loc2_.width;
         if(InputManager.getInstance().getPlatform() != PlatformType.PLATFORM_PC && InputManager.getInstance().getPlatform() != PlatformType.PLATFORM_PC_GDK)
         {
            _loc3_ *= 0.95;
            _loc4_ *= 0.95;
         }
         if(_loc5_ > _loc3_)
         {
            if(_anchorRect)
            {
               if(_anchorRect.y - _loc2_.height < _loc3_ && _anchorRect.y - _loc2_.height > 0)
               {
                  _loc1_.y = _anchorRect.y - _loc2_.height;
               }
               else
               {
                  _loc1_.y -= _loc5_ - _loc3_;
               }
            }
            else
            {
               _loc1_.y -= _loc5_ - _loc3_;
            }
         }
         if(_loc6_ > _loc4_)
         {
            if(_anchorRect)
            {
               if(_anchorRect.x - _loc2_.width < _loc4_ && _anchorRect.x - _loc2_.width > 0)
               {
                  _loc1_.x = _anchorRect.x - _loc2_.width;
               }
               else
               {
                  _loc1_.x -= _loc6_ - _loc4_;
               }
            }
            else
            {
               _loc1_.x -= _loc6_ - _loc4_;
            }
         }
         x = _loc1_.x;
         y = _loc1_.y;
      }
      
      override public function set backgroundVisibility(param1:Boolean) : void
      {
         super.backgroundVisibility = param1;
         if(this.mcBackground)
         {
            this.mcBackground.gotoAndStop(_backgroundVisibility ? "solid" : "transparent");
         }
      }
   }
}


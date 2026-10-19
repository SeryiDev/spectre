package red.game.witcher3.slots
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import red.game.witcher3.utils.CommonUtils;
   import scaleform.clik.core.UIComponent;
   
   public class SlotPointIndicator extends UIComponent
   {
      
      public var spawnedClips:Vector.<MovieClip> = new Vector.<MovieClip>();
      
      public var spectreRankBox:Sprite;
      
      public function SlotPointIndicator()
      {
         super();
      }
      
      public function clean() : void
      {
         var i:int = 0;
         while(i < this.spawnedClips.length)
         {
            removeChild(this.spawnedClips[i]);
            i++;
         }
         this.spawnedClips = new Vector.<MovieClip>();
         if(this.spectreRankBox)
         {
            removeChild(this.spectreRankBox);
            this.spectreRankBox = null;
         }
      }
      
      public function setCount(filled:int, max:int) : *
      {
         var rankText:TextField = null;
         var slot:SlotBase = null;
         var hit:DisplayObject = null;
         var area:Rectangle = null;
         var boxWidth:Number = Number(NaN);
         var boxHeight:Number = Number(NaN);
         this.clean();
         rankText = CommonUtils.spawnTextField(18,16777215);
         rankText.selectable = false;
         rankText.mouseEnabled = false;
         rankText.autoSize = TextFieldAutoSize.CENTER;
         rankText.text = String(filled);
         boxHeight = rankText.height;
         boxWidth = Math.max(rankText.width + 4,boxHeight);
         this.spectreRankBox = new Sprite();
         this.spectreRankBox.mouseEnabled = false;
         this.spectreRankBox.mouseChildren = false;
         this.spectreRankBox.graphics.beginFill(1710618,0.9);
         this.spectreRankBox.graphics.drawRect(0,0,boxWidth,boxHeight);
         this.spectreRankBox.graphics.endFill();
         rankText.x = (boxWidth - rankText.width) / 2;
         this.spectreRankBox.addChild(rankText);
         addChild(this.spectreRankBox);
         slot = parent as SlotBase;
         if(slot)
         {
            hit = slot.getHitArea();
         }
         if(hit && hit != this && hit != slot)
         {
            area = hit.getBounds(this);
         }
         if(area)
         {
            this.spectreRankBox.x = area.right - boxWidth;
            this.spectreRankBox.y = area.bottom - boxHeight;
         }
         else
         {
            this.spectreRankBox.x = -boxWidth / 2;
            this.spectreRankBox.y = -boxHeight / 2;
         }
      }
      
      public function setColor(color:String) : *
      {
      }
   }
}


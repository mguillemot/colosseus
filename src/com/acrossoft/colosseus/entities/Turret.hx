/**
 * ...
 * @author 
 */

package com.acrossoft.colosseus.entities;
import flash.display.Sprite;

class Turret extends Sprite
{

	public function new() 
	{
		super();
		graphics.clear();
		graphics.lineStyle(1, 0x000000);
		graphics.beginFill(0xFFC60C);
		graphics.drawCircle(0, 0, 10);
		graphics.endFill();
	}
	
	public function startFire() : Void
	{
		trace("bang!");
	}
	
}
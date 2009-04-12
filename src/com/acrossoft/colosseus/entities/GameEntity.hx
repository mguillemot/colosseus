/**
 * ...
 * @author 
 */

package com.acrossoft.colosseus.entities;
import com.acrossoft.colosseus.hitboxes.CircleHitbox;
import flash.display.Sprite;
import flash.display.Stage;

class GameEntity extends Sprite
{

	public function new() 
	{
		super();
	}
	
	public function getHitbox() : CircleHitbox
	{
		return m_hitbox;
	}
	
	public function hits(o : GameEntity) : Bool
	{
		var ax : Float = m_hitbox.getCenter().x + x;
		var ay : Float = m_hitbox.getCenter().y + y;
		var bx : Float = o.m_hitbox.getCenter().x + o.x;
		var by : Float = o.m_hitbox.getCenter().y + o.y;
		var dx : Float = bx - ax;
		var dy : Float = by - ay;
		var distSquare : Float = dx * dx + dy * dy;
		var sumRadius : Float = m_hitbox.getRadius() + o.m_hitbox.getRadius();
		return distSquare < sumRadius * sumRadius;
	}
	
	public function outOfStage(stage : Stage) : Bool
	{
		return x < -m_hitbox.getRadius() || x > (stage.stageWidth + m_hitbox.getRadius())
			|| y < -m_hitbox.getRadius() || y > (stage.stageHeight + m_hitbox.getRadius());
	}
	
	private var m_hitbox : CircleHitbox;

}
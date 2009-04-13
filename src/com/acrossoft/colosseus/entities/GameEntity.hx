/**
 * ...
 * @author 
 */

package com.acrossoft.colosseus.entities;
import com.acrossoft.colosseus.GameContext;
import com.acrossoft.colosseus.hitboxes.CircleHitbox;
import flash.display.AVM1Movie;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.geom.Point;

class GameEntity extends Sprite
{

	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
	}
	
	private function onAddedToStage(e : Event) : Void
	{
	}
	
	private function onRemovedFromStage(e : Event) : Void
	{
	}
	
	public function update(context : GameContext) : Void
	{
		// Out of screen ?
		var radius : Float = if (m_hitbox != null) m_hitbox.getRadius() else 0;
		var stagePos : Point = localToGlobal(new Point(0, 0));
		m_outOfStage = stagePos.x < -radius || stagePos.x > (context.stage.stageWidth + radius) || stagePos.y < -radius || stagePos.y > (context.stage.stageHeight + radius);
		
		// Hitbox visibility
		if (m_hitbox != null && m_hitboxVisible != context.hitboxVisible)
		{
			if (context.hitboxVisible)
			{
				addChild(m_hitbox.getRepresentation());
				m_hitboxVisible = true;
			}
			else
			{
				removeChild(m_hitbox.getRepresentation());
				m_hitboxVisible = false;
			}
		}
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
		return m_outOfStage;
	}
	
	private var m_hitbox : CircleHitbox;
	private var m_hitboxVisible : Bool;
	private var m_outOfStage : Bool;

}
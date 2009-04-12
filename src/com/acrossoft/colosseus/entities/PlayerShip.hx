package com.acrossoft.colosseus.entities;

import com.acrossoft.colosseus.hitboxes.CircleHitbox;
import flash.geom.Point;
import flash.Lib;
/**
 * ...
 * @author Matthieu Guillemot
 */
 
class PlayerShip extends GameEntity
{
	
	public function new()
	{
		super();
		var g = Lib.attach("asset.PlayerShip");
		g.width = 40;
		g.height = 40;
		addChild(g);
		m_hitbox = new CircleHitbox(new Point(0, 0), 10);
		addChild(m_hitbox.getRepresentation());
	}
	
}
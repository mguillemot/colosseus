/**
 * ...
 * @author 
 */

package com.acrossoft.colosseus.utils;
import com.acrossoft.colosseus.utils.LinkedListCell;
import com.acrossoft.colosseus.utils.LinkedListIterator;

class LinkedList<T>
{

	public function new() 
	{
	}
	
	public var size(getSize, null) : Int;

	public function pushBack(element : T) : Void
	{
		var cell : LinkedListCell<T> = new LinkedListCell<T>();
		cell.value = element;
		cell.previous = m_tail;
		m_tail.next = cell;
	}
	
	public function head() : T
	{
		return m_head.value;
	}

	public function tail() : T
	{
		return m_tail.value;
	}

	public function iterator() : LinkedListIterator<T>
	{
		return new LinkedListIterator<T>(this);
	}
	
	private function getSize() : Int
	{
		return m_size;
	}

	private var m_head : LinkedListCell<T>;
	private var m_tail : LinkedListCell<T>;
	private var m_size : Int;
	
}


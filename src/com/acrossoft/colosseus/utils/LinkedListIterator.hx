/**
 * ...
 * @author 
 */

package com.acrossoft.colosseus.utils;

class LinkedListIterator<T> 
{
	
	public function new(list : LinkedList<T>)
	{
		m_list = list;
		m_nextCell = null; // TODO
	}
	
	public function hasNext() : Bool
	{
		return m_nextCell != null;
	}
	
	public function next() : T
	{
		var currentCell : LinkedListCell<T> = m_nextCell;
		m_nextCell = m_nextCell.next;
		return currentCell.value;
	}
	
	public function remove() : Void
	{
	}
	
	private var m_list : LinkedList<T>;
	private var m_nextCell : LinkedListCell<T>;
	
}

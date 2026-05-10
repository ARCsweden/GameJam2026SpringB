extends Node
# Put "global" signals here that are not tied directly to an object
signal click_output(object_clicked : Node)

signal click_cancel()

signal slot_entered(slot: NodeSlot)
signal slot_exited(slot: NodeSlot)

signal node_entered(slot: SchematicsNode)
signal node_exited(slot: SchematicsNode)

signal show_goal_story(goal: GoalData)

signal connection_removed(conn: Connection)
signal spawn_goal_done_effect(pos: Vector2)
signal update_slot_flow(start_slot: NodeSlot, end_slot: NodeSlot)
signal disconnect_slot_flow(start_slot: NodeSlot, end_slot: NodeSlot)
signal flow_updated(start_slot: NodeSlot, end_slot: NodeSlot)
signal spawn_from_store(module: ModuleData)
signal spawn_goal_from_store(module: GoalData)
signal goal_unlocked(goal: GoalData)

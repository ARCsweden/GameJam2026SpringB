extends Node
# Put "global" signals here that are not tied directly to an object
signal click_output(object_clicked : Node)

signal click_cancel()

signal slot_entered(slot: NodeSlot)
signal slot_exited(slot: NodeSlot)

signal node_entered(slot: SchematicsNode)
signal node_exited(slot: SchematicsNode)

signal update_slot_flow(start_slot: NodeSlot, end_slot: NodeSlot)
signal spawn_from_store(module: ModuleData)

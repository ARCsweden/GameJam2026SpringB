extends Node
# Put "global" signals here that are not tied directly to an object
signal click_output(object_clicked : Node)

signal click_cancel()

signal slot_entered(slot: NodeSlot)
signal slot_exited(slot: NodeSlot)

signal connection_made()

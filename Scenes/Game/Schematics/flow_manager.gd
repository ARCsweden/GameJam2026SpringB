extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO: Note, these functions use signals to call themselves.
	SignalBus.update_slot_flow.connect(_update_slot_flow)
	SignalBus.disconnect_slot_flow.connect(_disconnect_slot_flow)


func _disconnect_slot_flow(start_slot: NodeSlot, stop_slot: NodeSlot):
	var input_slot: NodeSlot
	# TODO: Note, output_slot here is never used, so only one side of the flow is updated. Is this correct?
	#var output_slot: NodeSlot
	if start_slot.dir == ResourceTypes.DIR.IN:
		input_slot = start_slot
		#output_slot = stop_slot
	else:
		input_slot = stop_slot
		#output_slot = start_slot

	var total_arr : Array[int] = []
	for a in ResourceTypes.RT.size():
		total_arr.append(0)
	var zero_arr = total_arr.duplicate(true)

	input_slot.amount_arr = zero_arr.duplicate(true)

	var input_resource_slots = []
	var output_resource_slots =  []
	var input_power_slots = []
	var output_power_slots = []
	for c in input_slot.parent_node.slots.get_children():
		var ns : NodeSlot = c as NodeSlot
		if ns.dir == ResourceTypes.DIR.IN and ns.type != ResourceTypes.RT.POWER:
			input_resource_slots.append(ns)
		elif ns.dir == ResourceTypes.DIR.OUT and ns.type != ResourceTypes.RT.POWER:
			output_resource_slots.append(ns)
			ns.amount_arr = zero_arr.duplicate(true)
		elif ns.dir == ResourceTypes.DIR.IN and ns.type == ResourceTypes.RT.POWER:
			input_power_slots.append(ns)
		elif ns.dir == ResourceTypes.DIR.OUT and ns.type == ResourceTypes.RT.POWER:
			output_power_slots.append(ns)
			ns.amount_arr = zero_arr.duplicate(true)

	for s_o in output_resource_slots:
		if s_o.connection != null:
			SignalBus.disconnect_slot_flow.emit(s_o.connection.start, s_o.connection.end)
			SignalBus.flow_updated.emit(s_o.connection.start, s_o.connection.end)
	SignalBus.flow_updated.emit(start_slot, stop_slot)

		#if input_slot.type != ResourceTypes.RT.POWER:
			#SignalBus.update_slot_flow.emit(s_o.connection.start, s_o.connection.end)


func _update_slot_flow(start_slot: NodeSlot, stop_slot: NodeSlot):
	# If direction is output, do nothing. So we want to find input
	var input_slot: NodeSlot
	var output_slot: NodeSlot
	if start_slot.dir == ResourceTypes.DIR.IN:
		input_slot = start_slot
		output_slot = stop_slot
	else:
		input_slot = stop_slot
		output_slot = start_slot

	input_slot.amount_arr = output_slot.amount_arr.duplicate(true)
	# Investigate all NodeSlots of the SchematicsNode that is our Input.
	var input_resource_slots : Array[NodeSlot] = []
	var output_resource_slots : Array[NodeSlot] =  []
	var input_power_slots : Array[NodeSlot] = []
	var output_power_slots : Array[NodeSlot] = []
	for c in input_slot.parent_node.slots.get_children():
		var ns : NodeSlot = c as NodeSlot
		# Sort the NodeSlots into their various types
		if ns.type == ResourceTypes.RT.POWER:
			if ns.dir == ResourceTypes.DIR.IN:
				input_power_slots.append(ns)
			elif ns.dir == ResourceTypes.DIR.OUT:
				output_power_slots.append(ns)
		else:
			if ns.dir == ResourceTypes.DIR.IN:
				input_resource_slots.append(ns)
			elif ns.dir == ResourceTypes.DIR.OUT:
				output_resource_slots.append(ns)

	# Check all power slots are powered
	for p in input_power_slots:
		# TODO: Could use if they are connected or not here instead?
		if p.amount_arr[ResourceTypes.RT.POWER] == 0:
			# Add in all unpowered amounts
			for s_o in output_resource_slots:
				for i in ResourceTypes.RT.size():
					s_o.amount_arr[i] = s_o.unpowered_amount_arr[i]
				if s_o.connection != null:
					# Emit signal to propagate the change
					SignalBus.update_slot_flow.emit(s_o.connection.start, s_o.connection.end)
					SignalBus.flow_updated.emit(s_o.connection.start, s_o.connection.end)
			SignalBus.flow_updated.emit(start_slot, stop_slot)
			return

	# Instantiates the array
	var total_arr = []
	for a in ResourceTypes.RT.size():
		total_arr.append(0)

	# Special case, vision blocks have no resource inputs
	# TODO: Is the if here needed? Kinda ugly.
	if input_slot.type == ResourceTypes.RT.POWER:
		if input_resource_slots == []:
			for s_o in output_resource_slots:
				s_o.amount_arr[ResourceTypes.RT.VISION] = 1
				if s_o.connection != null:
					# Emit signal to propagate the change
					SignalBus.update_slot_flow.emit(s_o.connection.start, s_o.connection.end)
			return

	# Counts up all inputs
	for s_i in input_resource_slots:
		# TODO: Note, better if these bus blocks were a type instead, holding the resources.
		for i in ResourceTypes.RT.size():
			total_arr[i] += s_i.amount_arr[i]

	# Is ANY resource flowing through the node?
	var inputs_flowing = true
	for s_i in input_resource_slots:
		var s_i_total = 0
		for i in ResourceTypes.RT.size():
			s_i_total += s_i.amount_arr[i]
		if s_i_total == 0:
			inputs_flowing = false

	# Combines input resources to the output. Meaning we are creating flow
	for s_o in output_resource_slots:
		for i in ResourceTypes.RT.size():
			s_o.amount_arr[i] = total_arr[i]
	for s_o in output_resource_slots:
		# If flow exists on all inputs, then the output can produce its unique resource
		if inputs_flowing:
			for i in ResourceTypes.RT.size():
				s_o.amount_arr[i] += s_o.powered_amount_arr[i]
		if s_o.connection != null:
			# Emit signal to propagate the change
			SignalBus.update_slot_flow.emit(s_o.connection.start, s_o.connection.end)
			if s_o.connection:
				SignalBus.flow_updated.emit(s_o.connection.start, s_o.connection.end)
	SignalBus.flow_updated.emit(start_slot, stop_slot)

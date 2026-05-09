extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.update_slot_flow.connect(_update_slot_flow)
	SignalBus.disconnect_slot_flow.connect(_disconnect_slot_flow)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _disconnect_slot_flow(start_slot: NodeSlot, stop_slot: NodeSlot):	
	var input_slot: NodeSlot
	var output_slot: NodeSlot
	if start_slot.dir == ResourceTypes.DIR.IN:
		input_slot = start_slot
		output_slot = stop_slot
	else:
		input_slot = stop_slot
		output_slot = start_slot
	
	var total_arr = []
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
	
	# New version
	
	if input_slot.type != ResourceTypes.RT.POWER:
		"""
		input_slot.amount_arr = output_slot.amount_arr.duplicate(true)
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
				#ns.amount_arr = input_slot.amount_arr.duplicate(true)
			elif ns.dir == ResourceTypes.DIR.IN and ns.type == ResourceTypes.RT.POWER:
				input_power_slots.append(ns)
			elif ns.dir == ResourceTypes.DIR.OUT and ns.type == ResourceTypes.RT.POWER:
				output_power_slots.append(ns)
		
		for s_o in output_resource_slots:
			s_o.amount_arr = [1, 1, 1, 1]
		
		for s_o in output_resource_slots:
			if s_o.connection != null:
				SignalBus.update_slot_flow.emit(s_o.connection.start, s_o.connection.end)
				"""
	
		input_slot.amount_arr = output_slot.amount_arr.duplicate(true)
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
			elif ns.dir == ResourceTypes.DIR.IN and ns.type == ResourceTypes.RT.POWER:
				print(ns.amount_arr)
				input_power_slots.append(ns)
			elif ns.dir == ResourceTypes.DIR.OUT and ns.type == ResourceTypes.RT.POWER:
				output_power_slots.append(ns)

		var total_arr = []
		for a in ResourceTypes.RT.size():
			total_arr.append(0)
		var zero_arr = total_arr.duplicate(true)
		
		for s_i in input_resource_slots:
			for i in ResourceTypes.RT.size():
				total_arr[i] += s_i.amount_arr[i]
				
		# Check all power slots are powered
		for p in input_power_slots:
			if p.amount_arr[ResourceTypes.RT.POWER] == 0:
				print("zero power")
				total_arr = zero_arr.duplicate(true)
				
		for s_o in output_resource_slots:
			for i in ResourceTypes.RT.size():
				s_o.amount_arr[i] = total_arr[i]
			if s_o.connection != null:
				# Emit signal to propagate the change
				SignalBus.update_slot_flow.emit(s_o.connection.start, s_o.connection.end)

	if input_slot.type == ResourceTypes.RT.POWER:
		
		input_slot.amount_arr[ResourceTypes.RT.POWER] = output_slot.amount_arr[ResourceTypes.RT.POWER]
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
			elif ns.dir == ResourceTypes.DIR.IN and ns.type == ResourceTypes.RT.POWER:
				input_power_slots.append(ns)
			elif ns.dir == ResourceTypes.DIR.OUT and ns.type == ResourceTypes.RT.POWER:
				output_power_slots.append(ns)
				
		# Check all power slots are powered
		for p in input_power_slots:
			if p.amount_arr[ResourceTypes.RT.POWER] == 0:
				return
				
		# Check if it's a Vision block with no inputs
		if input_resource_slots == []:
			for s_o in output_resource_slots:
				s_o.amount_arr[ResourceTypes.RT.VISION] = 1
				if s_o.connection != null:
					# Emit signal to propagate the change
					SignalBus.update_slot_flow.emit(s_o.connection.start, s_o.connection.end)
		# All other blocks work the same
		else:
			var total_arr = []
			for a in ResourceTypes.RT.size():
				total_arr.append(0)
			var zero_arr = total_arr.duplicate(true)
			for s_i in input_resource_slots:
				for i in ResourceTypes.RT.size():
					total_arr[i] += s_i.amount_arr[i]
			for s_o in output_resource_slots:
				for i in ResourceTypes.RT.size():
					s_o.amount_arr[i] = total_arr[i]
				if s_o.connection != null:
					# Emit signal to propagate the change
					SignalBus.update_slot_flow.emit(s_o.connection.start, s_o.connection.end)
						
	# If power, update the amount value of output slots. Then update all inputs that are connected to the outpouts
	# TODO check all power inputs, otherwise power shouldn't turn on.
	"""
	if input_slot.type == ResourceTypes.RT.POWER:
		# Update that power is on
		input_slot.amount = output_slot.amount
		# Calculate what the output should be
		var total = 0
		for c in input_slot.parent_node.slots.get_children():
			var ns : NodeSlot = c as NodeSlot
			if ns.dir == ResourceTypes.DIR.IN and ns.type != ResourceTypes.RT.POWER:
				total += ns.amount
		# Find all output slots, and update the input slot they are connected to
		for c in input_slot.parent_node.slots.get_children():
			var ns : NodeSlot = c as NodeSlot
			ns.amount = total
			if ns.dir == ResourceTypes.DIR.OUT and ns.type != ResourceTypes.RT.POWER:
				# Check that an output is connected to an input
				if ns.connection != null:
					# Identify which slot in the connection is the input
					#var signal_receiver
					#if ns.connection.start == input_slot:
					#	signal_receiver = ns.connection.end
					#else:
					#	signal_receiver = ns.connection.start
					# Emit signal to propagate the change
					SignalBus.update_slot_flow.emit(ns.connection.start, ns.connection.end)
				
	# Otherwise, update the input so its equal to what the output is
	else:
		input_slot.amount = output_slot.amount
	
	
	print(input_slot.dir)
	"""
	

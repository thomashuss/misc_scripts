#!/usr/bin/awk -f
function deque_push(id) {
	if (id != deque_head) {
		if (deque[id, deque_left]) {
			if (deque[id, deque_left] != -1)
				deque[deque[id, deque_left], deque_right] = deque[id, deque_right]
			if (deque[id, deque_right] != -1)
				deque[deque[id, deque_right], deque_left] = deque[id, deque_left]
		}
		if (deque_head == -1) deque_tail = id
		else if (deque_tail == id) deque_tail = deque[id, deque_left]
		deque[id, deque_left] = -1
		deque[id, deque_right] = deque_head
		deque[deque_head, deque_left] = id
		deque_head = id
	}
}
function deque_push_tail(id) {
	if (id != deque_tail) {
		if (deque[id, deque_left]) {
			if (deque[id, deque_left] != -1)
				deque[deque[id, deque_left], deque_right] = deque[id, deque_right]
			if (deque[id, deque_right] != -1)
				deque[deque[id, deque_right], deque_left] = deque[id, deque_left]
		}
		if (deque_tail == -1) deque_head = id
		else if (deque_head == id) deque_head = deque[id, deque_right]
		deque[id, deque_left] = deque_tail
		deque[id, deque_right] = -1
		deque[deque_tail, deque_right] = id
		deque_tail = id
	}
}
BEGIN {
	deque_head = deque_tail = -1; deque_left = 0; deque_right = 1
	xp = "xprop -notype -root _NET_ACTIVE_WINDOW _NET_CLIENT_LIST_STACKING _NET_CURRENT_DESKTOP"
	xp | getline xp_a
	xp | getline xp_s
	xp | getline xp_w
	close(xp)
	active = substr(xp_a, 33)
	if (active_first)
		print print_prefix active print_postfix
	workspace = substr(xp_w, 24)
	stack_length = split(substr(xp_s, 39), stack_list, ", ")
}
$2 != "-1" {
	if (curr_workspace && workspace != $2)
		next
	gsub(/0x0+/, "0x", $1)
	deque_push($1)
}
END {
	idx = 1
	while (idx <= stack_length) {
		gsub(/0x0+/, "0x", stack_list[idx])
		if (deque[stack_list[idx], deque_left])
			if (reverse)
				deque_push_tail(stack_list[idx])
			else
				deque_push(stack_list[idx])
		idx++
	}
	printed_windows = 0
	if (reverse) active_printed = 1
	while (deque_head != -1) {
		if (printed_windows && printed_windows == num_windows)
			break
		if (after_active) {
			if (reverse) {
				if (deque_head == active) {
					active_printed = 0
					deque_head = deque[deque_head, deque_right]
					continue
				}
			}
			if (!active_printed) {
				if (deque_head == active)
					active_printed = 1
				else {
					deque_head = deque[deque_head, deque_right]
					continue
				}
			}
		}
		if (skip_first && !skipped) {
			skipped = 1
			deque_head = deque[deque_head, deque_right]
			continue
		}
		print print_prefix deque_head print_postfix
		printed_windows++
		deque_head = deque[deque_head, deque_right]
	}
}
